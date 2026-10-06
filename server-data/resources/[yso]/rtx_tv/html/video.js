var videohandler = undefined;
var nativehandler = undefined;
var mediaEnabled = false;
var apiLoaded = false;
var apiLoading = false;
var pendingPlayerData = null;
var tvResourceName = null;


var lastManualSeekAt = 0;
var manualSeekLockMs = 1500;
var localForcedTime = null;

var currentBlobUrl = null;
var nativeLoadToken = 0;

var playerPausedState = false;

var playerSessionId = 0;

window.addEventListener("load", (event) => {
	let tvresourcenamedata = location.host;
	let tvresourcenamedata2 = tvresourcenamedata.substring(8);
	tvResourceName = tvresourcenamedata2;
	$.post("https://" + tvResourceName + "/readyplayer", JSON.stringify({}));
});


function revokeCurrentBlobUrl() {
	if (currentBlobUrl) {
		try {
			URL.revokeObjectURL(currentBlobUrl);
		} catch (e) {}

		currentBlobUrl = null;
	}
}
function getMediaType(url) {
	if (!url || typeof url !== "string") {
		return "unknown";
	}

	let cleanUrl = url.split("?")[0].toLowerCase();

	if (cleanUrl.endsWith(".mp3")) {
		return "mp3";
	}

	if (cleanUrl.endsWith(".ogg")) {
		return "ogg";
	}

	if (cleanUrl.endsWith(".mp4")) {
		return "mp4";
	}

	return "external";
}

function loadExternalApi(callback) {
	if (apiLoaded && typeof YT !== "undefined" && typeof YT.Player !== "undefined") {
		if (callback) callback();
		return;
	}

	if (apiLoading) {
		const waitForApi = setInterval(() => {
			if (apiLoaded && typeof YT !== "undefined" && typeof YT.Player !== "undefined") {
				clearInterval(waitForApi);
				if (callback) callback();
			}
		}, 100);
		return;
	}

	apiLoading = true;

	var tag = document.createElement("script");
	tag.src = "https://www.youtube.com/iframe_api";
	tag.async = true;
	document.head.appendChild(tag);

	window.onYouTubeIframeAPIReady = function () {
		apiLoaded = true;
		apiLoading = false;

		if (callback) {
			callback();
		}

		if (pendingPlayerData) {
			createPlayer(pendingPlayerData);
			pendingPlayerData = null;
		}
	};
}

function destroyExternalPlayer() {
	if (videohandler != undefined) {
		try {
			videohandler.stopVideo();
		} catch (e) {}

		try {
			videohandler.destroy();
		} catch (e) {}

		videohandler = undefined;
	}
}

function destroyNativePlayer() {
	nativeLoadToken++;

	if (nativehandler != undefined) {
		try {
			nativehandler.pause();
		} catch (e) {}

		try {
			nativehandler.removeAttribute("src");
			nativehandler.load();
		} catch (e) {}

		nativehandler = undefined;
	}

	if (currentBlobUrl) {
		try {
			URL.revokeObjectURL(currentBlobUrl);
		} catch (e) {}

		currentBlobUrl = null;
	}
}

async function loadLocalMediaAsBlob(url) {
	const response = await fetch(url);
	if (!response.ok) {
		throw new Error("Failed to fetch local media: " + response.status);
	}

	const blob = await response.blob();

	if (currentBlobUrl) {
		try {
			URL.revokeObjectURL(currentBlobUrl);
		} catch (e) {}
	}

	currentBlobUrl = URL.createObjectURL(blob);
	return currentBlobUrl;
}
function clearFrame() {
	const frame = document.getElementById("videoframe");
	if (frame) {
		frame.innerHTML = "";
	}
}

function destroyPlayer() {
	playerSessionId++;

	destroyExternalPlayer();
	destroyNativePlayer();
	clearFrame();

	localForcedTime = null;

	const audioUI = document.getElementById("audio-ui");
	if (audioUI) {
		audioUI.style.display = "none";
	}
}

function makeSafeMediaUrl(url) {
	if (!url || typeof url !== "string") return url;

	const mediaPath = "/html/media/";
	const index = url.indexOf(mediaPath);

	if (index === -1) {
		return encodeURI(url);
	}

	const baseUrl = url.substring(0, index + mediaPath.length);
	const fileName = url.substring(index + mediaPath.length);

	return baseUrl + fileName.split("/").map(function(part) {
		return encodeURIComponent(decodeURIComponent(part));
	}).join("/");
}

async function createNativePlayer(item, type) {
	destroyPlayer();
	const mySession = playerSessionId;
	const myToken = ++nativeLoadToken;
	const frame = document.getElementById("videoframe");
	const audioUI = document.getElementById("audio-ui");
	const audioTitle = document.getElementById("audio-title");

	if (!frame) return;

	const isAudio = (type === "mp3" || type === "ogg");
	const element = document.createElement(isAudio ? "audio" : "video");

	element.id = "nativeplayer";
	element.autoplay = false;
	element.controls = false;
	element.playsInline = true;
	element.preload = "auto";
	element.muted = false;

	playerPausedState = item.ispaused === true;

	if (isAudio) {
		element.style.width = "0";
		element.style.height = "0";
		element.style.opacity = "0";
		element.style.position = "absolute";

		if (audioUI) audioUI.style.display = "flex";

		if (audioTitle) {
			let fileName = item.videoid.split("/").pop() || "Unknown Track";
			audioTitle.innerText = decodeURIComponent(fileName);
		}
	} else {
		element.style.width = "100%";
		element.style.height = "100%";
		element.style.position = "absolute";
		element.style.top = "0";
		element.style.left = "0";
		element.style.objectFit = "fill";
		element.style.backgroundColor = "black";

		if (audioUI) audioUI.style.display = "none";
	}

	frame.appendChild(element);

	try {
		const safeUrl = makeSafeMediaUrl(item.videoid);
		let blobUrl = null;

		try {
			blobUrl = await loadLocalMediaAsBlob(safeUrl);
		} catch (e) {
			console.log("Blob failed, using direct src:", e);
			blobUrl = safeUrl;
		}

		if (myToken !== nativeLoadToken || mySession !== playerSessionId) {
			element.remove();
			return;
		}

		nativehandler = element;
		element.src = blobUrl;
		element.load();

		let metadataLoaded = false;

		const fallbackTimer = setTimeout(function () {
			if (metadataLoaded) return;
			if (myToken !== nativeLoadToken || mySession !== playerSessionId) return;

			console.log("Metadata timeout, retrying direct src:", safeUrl);

			try {
				element.pause();
				element.removeAttribute("src");
				element.load();

				revokeCurrentBlobUrl();

				element.src = safeUrl;
				element.load();
			} catch (e) {}
		}, 3000);		

		const targetTime = Number(item.videoseconds) || 0;

		element.addEventListener("loadedmetadata", function () {
			
			if (myToken !== nativeLoadToken || mySession !== playerSessionId) return;
			metadataLoaded = true;
			clearTimeout(fallbackTimer);			

			try {
				element.volume = Math.max(0, Math.min(1, (Number(item.videovolume) || 0) / 100));
			} catch (e) {}

			try {
				if (!isNaN(element.duration) && isFinite(element.duration) && element.duration > 0) {
					element.currentTime = Math.max(0, Math.min(targetTime, element.duration));
				} else {
					element.currentTime = Math.max(0, targetTime);
				}
			} catch (e) {}

			localForcedTime = targetTime;
			lastManualSeekAt = Date.now();

			if (isAudio) {
				if (playerPausedState) {
					element.pause();
				} else {
					element.play().catch(() => {});
				}
				return;
			}

			if (playerPausedState) {
				element.muted = true;

				element.play().then(() => {
					setTimeout(() => {
						if (mySession !== playerSessionId) return;
						element.pause();
						element.muted = false;
					}, 100);
				}).catch(() => {});
			} else {
				element.play().catch(() => {});
			}
		}, { once: true });

		element.addEventListener("seeked", function () {
			if (myToken !== nativeLoadToken || mySession !== playerSessionId) return;

			try {
				localForcedTime = Number(element.currentTime) || 0;
				lastManualSeekAt = Date.now();
			} catch (e) {}

			if (playerPausedState) {
				try {
					element.pause();
				} catch (e) {}
			}
		});
		element.addEventListener("error", function () {
			console.log("Native media error:", element.error, "URL:", safeUrl);
		});		
	} catch (err) {
		if (mySession !== playerSessionId) return;
		console.log("Blob load error:", err);
	}
}

function createExternalPlayer(item) {
	if (!mediaEnabled) return;

	if (!apiLoaded || typeof YT === "undefined" || typeof YT.Player === "undefined") {
		pendingPlayerData = item;
		loadExternalApi();
		return;
	}

	destroyPlayer();
	const mySession = playerSessionId;

	playerPausedState = item.ispaused === true;

	videohandler = new YT.Player("videoframe", {
		videoId: item.videoid,
		width: "100%",
		height: "100%",
		playerVars: {
			playsinline: 1,
			controls: 0,
			autoplay: 0,
			start: item.videoseconds || 0
		},
		events: {
			'onReady': function(event) {
				if (mySession !== playerSessionId) return;

				event.target.setVolume(item.videovolume || 0);

				if (playerPausedState) {
					event.target.cueVideoById({
						videoId: item.videoid,
						startSeconds: item.videoseconds || 0
					});
				} else {
					event.target.loadVideoById({
						videoId: item.videoid,
						startSeconds: item.videoseconds || 0
					});
				}
			}
		}
	});
}

function createPlayer(item) {
	playerPausedState = item.ispaused === true;

	const mediatype = getMediaType(item.videoid);

	if (mediatype === "mp3" || mediatype === "ogg" || mediatype === "mp4") {
		createNativePlayer(item, mediatype);
		return;
	}

	createExternalPlayer(item);
}

function setPlayerVolume(volume) {
	if (videohandler != undefined) {
		try {
			videohandler.setVolume(volume);
		} catch (e) {}
	}

	if (nativehandler != undefined) {
		try {
			nativehandler.volume = Math.max(0, Math.min(1, volume / 100));
		} catch (e) {}
	}
}
function attemptNativeSeek(element, targetTime) {
	targetTime = Number(targetTime) || 0;

	try {
		let maxTime = 0;

		if (!isNaN(element.duration) && isFinite(element.duration) && element.duration > 0) {
			maxTime = element.duration;
		}

		let safeTime = targetTime;

		if (maxTime > 0) {
			safeTime = Math.max(0, Math.min(targetTime, maxTime));
		} else {
			safeTime = Math.max(0, targetTime);
		}

		element.currentTime = safeTime;
		localForcedTime = safeTime;
		lastManualSeekAt = Date.now();
	} catch (e) {
		console.log("Seek error:", e);
	}
}
function setPlayerTime(seconds) {
	seconds = Number(seconds) || 0;

	lastManualSeekAt = Date.now();
	localForcedTime = seconds;

	if (videohandler) {
		videohandler.seekTo(seconds, true);
		if (playerPausedState) videohandler.pauseVideo();
	}

	if (nativehandler) {
		attemptNativeSeek(nativehandler, seconds);
		if (playerPausedState) nativehandler.pause();
	}
}

function pausePlayer() {
	playerPausedState = true;

	if (videohandler != undefined) {
		try {
			videohandler.pauseVideo();
		} catch (e) {}
	}

	if (nativehandler != undefined) {
		try {
			nativehandler.pause();
		} catch (e) {}
	}
}


function resumePlayer() {
	playerPausedState = false;

	if (videohandler != undefined) {
		try {
			videohandler.playVideo();
		} catch (e) {}
	}

	if (nativehandler != undefined) {
		try {
			nativehandler.play().catch(function () {});
		} catch (e) {}
	}
}
function getPlayerStateData() {
	let data = {
		currentTime: 0,
		duration: 0,
		playing: false,
		type: "none"
	};

	if (videohandler != undefined) {
		try {
			data.currentTime = Number(videohandler.getCurrentTime()) || 0;
		} catch (e) {}

		try {
			data.duration = Number(videohandler.getDuration()) || 0;
		} catch (e) {}

		data.playing = !playerPausedState;
		data.type = "external";
		return data;
	}

	if (nativehandler != undefined) {
		try {
			data.currentTime = Number(nativehandler.currentTime) || 0;
		} catch (e) {}

		try {
			data.duration = Number(nativehandler.duration) || 0;
			if (!isFinite(data.duration)) {
				data.duration = 0;
			}
		} catch (e) {}

		data.playing = !playerPausedState;
		data.type = getMediaType(nativehandler.currentSrc || nativehandler.src);

		if (localForcedTime !== null && (Date.now() - lastManualSeekAt) < manualSeekLockMs) {
			data.currentTime = localForcedTime;
		} else {
			localForcedTime = null;
		}

		return data;
	}

	return data;
}

function sendPlayerStateToClient() {
	if (!tvResourceName) {
		return;
	}

	const data = getPlayerStateData();

	$.post("https://" + tvResourceName + "/playerstate", JSON.stringify({
		currentTime: data.currentTime,
		duration: data.duration,
		playing: data.playing,
		type: data.type
	}));
}

window.addEventListener("message", function (event) {
	var item = event.data;

	if (item.message == "setmedia") {
		mediaEnabled = item.enabled === true;

		if (mediaEnabled) {
			loadExternalApi();
		} else {
			pendingPlayerData = null;
			destroyExternalPlayer();
		}
	}

	if (item.message == "playvideo") {

		const mediatype = getMediaType(item.videoid);

		if (mediatype === "external" && !mediaEnabled) {
			return;
		}

		if (mediatype === "external" && !apiLoaded) {
			pendingPlayerData = item;
			return;
		}

		createPlayer(item);
}
	if (item.message == "updatevolume") {
		setPlayerVolume(item.videovolume);
	}

	if (item.message == "settime") {
		setPlayerTime(item.videoseconds);
	}

	if (item.message == "pausevideo") {
		pausePlayer();
	}

	if (item.message == "resumevideo") {
		resumePlayer();
	}

	if (item.message == "requeststate") {
		sendPlayerStateToClient();
	}

	if (item.message == "stopvideo") {
		destroyPlayer();
	}
});