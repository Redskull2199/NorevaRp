var mediaListFull = [];   // celý list (originál)
var mediaListView = [];   // aktuálně zobrazený
var isPaused = false;

var volumeslider = document.getElementById("volumesliderdata");
var timeslider = document.getElementById("timesliderdata");
var currentTimeLabel = document.getElementById("currenttimedata");
var maxTimeLabel = document.getElementById("maxtimedata");

var televisionresourcename = "rtx_tv";
var mediaListVisible = true;
var seekingTime = false;

function formatTime(seconds) {
	seconds = Math.floor(Number(seconds) || 0);

	const mins = Math.floor(seconds / 60);
	const secs = seconds % 60;

	return String(mins).padStart(2, "0") + ":" + String(secs).padStart(2, "0");
}

function updateTimeUi(currentTime, duration) {
	currentTime = Number(currentTime) || 0;
	duration = Number(duration) || 0;

	if (currentTimeLabel) currentTimeLabel.innerText = formatTime(currentTime);
	if (maxTimeLabel) maxTimeLabel.innerText = formatTime(duration);

	if (timeslider && !seekingTime) {
		timeslider.max = duration > 0 ? duration : 100;
		timeslider.value = currentTime;
	}
}
function openMediaLibrary() {
	$("#media-modal").css("display", "flex");
}

function closeMediaLibrary() {
	$("#media-modal").css("display", "none");
}

function setPauseResumeState(paused) {
	isPaused = paused === true;

	if (isPaused) {
		$("#pause-resume-icon").removeClass("fa-pause").addClass("fa-play-circle");
		$("#pause-resume-text").text("Resume");
	} else {
		$("#pause-resume-icon").removeClass("fa-play-circle").addClass("fa-pause");
		$("#pause-resume-text").text("Pause");
	}
}

function getMediaIcon(filename) {
	filename = (filename || "").toLowerCase();

	if (filename.endsWith(".mp3") || filename.endsWith(".ogg")) return "fa-music";
	if (filename.endsWith(".mp4")) return "fa-film";

	return "fa-file";
}

function drawMediaList(list) {
	const container = document.getElementById("media-library-list");
	if (!container) return;

	container.innerHTML = "";

	if (!list || list.length === 0) {
		container.innerHTML = '<div class="media-item"><div class="media-item-name">No media found</div></div>';
		return;
	}

	list.forEach(function(media) {
		const icon = getMediaIcon(media.filename);

		const row = document.createElement("div");
		row.className = "media-item";
		row.innerHTML = `
			<div class="media-item-left">
				<i class="fas ${icon} media-item-icon"></i>
				<div class="media-item-name">${media.videoname}</div>
			</div>
			<button class="media-item-play" data-name="${media.videoname}">Play</button>
		`;

		container.appendChild(row);
	});

	// play button handler
	container.querySelectorAll(".media-item-play").forEach(function(btn) {
		btn.addEventListener("click", function() {
			$.post("https://" + televisionresourcename + "/playvideo", JSON.stringify({
				videourldata: this.dataset.name
			}));
		});
	});
}

function filterMediaList(searchValue) {
	const q = (searchValue || "").toLowerCase().trim();

	if (!q) {
		mediaListView = [...mediaListFull];
		drawMediaList(mediaListView);
		return;
	}

	mediaListView = mediaListFull.filter(function(item) {
		return (item.videoname || "").toLowerCase().includes(q) ||
			   (item.filename || "").toLowerCase().includes(q);
	});

	drawMediaList(mediaListView);
}

function renderMediaList(mediaList) {
	mediaListFull = mediaList || [];
	mediaListView = [...mediaListFull];

	drawMediaList(mediaListView);
}
var volumeslider = document.getElementById("volumesliderdata");

var televisionresourcename = "rtx_tv";

function closeMain() {
	$("body").css("display", "none");
}

function openMain() {
	$("body").css("display", "block");
}

$("#close-btn").click(function(){
	$.post('https://'+televisionresourcename+'/quit', JSON.stringify({}));
});

$(".closetvcreatorfinish").click(function(){
	$.post('https://'+televisionresourcename+'/quit', JSON.stringify({}));
});
function hexToRgb(hex) {
   const s = hex.replace("#", "");
   return {
      r: parseInt(s.substr(0, 2), 16),
      g: parseInt(s.substr(2, 2), 16),
      b: parseInt(s.substr(4, 2), 16),
   };
}

function rgba(hex, a) {
   const c = hexToRgb(hex);
   return `rgba(${c.r}, ${c.g}, ${c.b}, ${a})`;
}

function lighten(hex, amt = 0.18) {
   const s = hex.replace("#", "");
   if (s.length !== 6) return hex;
   const to = i =>
      Math.min(255, Math.round(parseInt(s.substr(i, 2), 16) * (1 + amt)));
   const h = n => n.toString(16).padStart(2, "0");
   return `#${h(to(0))}${h(to(2))}${h(to(4))}`;
}

function setTheme(accentHex) {
   const acc2 = lighten(accentHex, 0.12);

   $(":root")
      .css("--accent", accentHex)
      .css("--accent-2", acc2)
      .css("--accent-a20", rgba(accentHex, 0.2))
      .css("--accent-a10", rgba(accentHex, 0.1))
      .css("--accent-glow", rgba(accentHex, 0.18));

   const $grad = $("#hmh-pinkwave");
   if ($grad.length) {
      const $stops = $grad.find("stop");
      $stops
         .eq(0)
         .attr("stop-color", accentHex)
         .attr("stop-opacity", ".55");
      $stops
         .eq(1)
         .attr("stop-color", acc2)
         .attr("stop-opacity", ".32");
   }
}

window.addEventListener('message', function (event) {

	var item = event.data;

	if (item.message == "tvshow") {
		$.post("https://" + televisionresourcename + "/requestmedialist", JSON.stringify({}));
		setPauseResumeState(item.tvpausedata);
		closeMediaLibrary();

		$("#media-search-input").val("");
		$("#videoinputtvdata").val("");

		document.getElementById("currentlytexttype").innerHTML = item.tvurltypedata || "&nbsp;";
		volumeslider.value = item.tvvolumedata;

		if (item.tvurldata == "") {
			document.getElementById("currentlytexttype").innerHTML = "&nbsp;";
			document.getElementById("currentlytextdata2").innerHTML = "";
			$("#currentlytextdatashow").hide();
		} else {
			document.getElementById("currentlytexttype").innerHTML = item.tvurltypedata || "YouTube";
			document.getElementById("currentlytextdata2").innerHTML = item.tvurldata;
			$("#currentlytextdatashow").show();
		}

		$("#vehicletvcreatorshow").hide();
		$("#vehicletvcreatorfinishshow").hide();
		$("#tvshow").show();
		openMain();
	}	

	if (item.message == "vehicletvcreatorshow") {
		$("#tvshow").hide();
		$("#vehicletvcreatorfinishshow").hide();
		$("#vehicletvcreatorshow").show();	
		openMain();
	}	
	
	if (item.message == "vehicletvcreatorfinishshow") {
		var offsetdatatv = 
		'	{\n' +
		'		vehiclebone = "windscreen",\n' +
		'		offsetx = ' + item.offsetxdata + ',\n' +
		'		offsety = ' + item.offsetydata + ',\n' +
		'		offsetz = ' + item.offsetzdata + ',\n' +
		'		rotation = ' + item.offsetrotationdata + ',\n' +
		'	},';
		$(".tvcopytextdata").val(offsetdatatv); 
		$("#tvshow").hide();
		$("#vehicletvcreatorshow").hide();
		$("#vehicletvcreatorfinishshow").show();	
		openMain();
	}		
	
	if (item.message == "changespeed") {
		document.getElementById("currentspeeddata").innerHTML = item.speeddata;
	}		
	
	if (item.message == "changemode") {
		document.getElementById("currentmodedata").innerHTML = item.modedata;
	}		
		
	if (item.message == "hide") {
		closeMain();
	}
	if (item.message == "playerstateupdate") {
		updateTimeUi(item.currentTime, item.duration);
	}

	if (item.message == "setmedialist") {
		renderMediaList(item.medialist || []);
	}	
	if (item.message == "updateinterfacedata") {
		televisionresourcename = item.televisionresouredata;
		let theme = item.interfacecolordata;

		setTheme(theme);	
	}		
	
	
    document.onkeyup = function (data) {
        if (open) {
            if (data.which == 27) {
				$.post('https://'+televisionresourcename+'/quit', JSON.stringify({}));
            }
        }	
	};
});

$("#play-btn").click(function () {
	$.post('https://'+televisionresourcename+'/playvideo', JSON.stringify({
		videourldata: $("#videoinputtvdata").val().trim()
	}));
});


$("#power-btn").click(function () {
	$.post('https://'+televisionresourcename+'/turnoff', JSON.stringify({}));
});

function volumechange(e) {
	$.post('https://'+televisionresourcename+'/volumechange', JSON.stringify({
		volumedata: e.value
	})); 
}

$("#open-library-btn").click(function () {
	$.post("https://" + televisionresourcename + "/requestmedialist", JSON.stringify({}));
	openMediaLibrary();
});

$("#close-library-btn").click(function () {
	closeMediaLibrary();
});

$("#refresh-library-btn").click(function () {
	$.post("https://" + televisionresourcename + "/requestmedialist", JSON.stringify({}));
});

$("#media-search-input").on("input", function() {
	filterMediaList($(this).val());
});

$("#pause-resume-btn").click(function () {
	if (isPaused) {
		$.post("https://" + televisionresourcename + "/resumevideo", JSON.stringify({}));
		setPauseResumeState(false);
	} else {
		$.post("https://" + televisionresourcename + "/pausevideo", JSON.stringify({}));
		setPauseResumeState(true);
	}
});
timeslider.addEventListener("mousedown", function() {
	seekingTime = true;
});

timeslider.addEventListener("touchstart", function() {
	seekingTime = true;
});

timeslider.addEventListener("input", function() {
	if (currentTimeLabel) {
		currentTimeLabel.innerText = formatTime(this.value);
	}
});

timeslider.addEventListener("change", function() {
	$.post("https://" + televisionresourcename + "/settime", JSON.stringify({
		videoseconds: Number(this.value)
	}));

	setTimeout(function() {
		seekingTime = false;
	}, 500);
});