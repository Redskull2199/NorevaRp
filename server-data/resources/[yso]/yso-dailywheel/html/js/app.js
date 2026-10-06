var spinSound = null;
$(document).ready(function () {
	if (spinSound != null) {
		spinSound.pause();
	}
	spinSound = new Howl({ src: ["sound/spinSound.mp3"] });
	spinSound.volume(0.7);
});

var tebexLink = "";
var translate = [];

window.addEventListener("message", (event) => {
	if (event.data.type === "openMenu") {
		translate = event.data.translate;
		tebexLink = event.data.tebexLink;

		$(".getSpinAmountx").html(`(${event.data.spinCost}CR)`);

		$(".Title").html(`
			${translate.title1}
			<p>${translate.title2}</p>
		`);

		$(".subTitle").html(translate.lwTxt);
		$(".ttlDsc").html(translate.ttlDesc);
		$(".spinButton").html(translate.spin);
		$(".dlySpinTxt").html(translate.dlySpin);
		$("#gtSpntXT").html(translate.gtSpin);

		$(".reedemTitle").html(`
			${translate.redeemCode}
			<p>${translate.enterCode}</p>
		`);

		$(".enterCodeButton").html(translate.ecButton);

		$(".buyReedemBox").html(`
			${translate.noRedeemCd}
			<div class="buyButton">${translate.byCodeButton}</div>
		`);

		$("#infoTttle").html(translate.infoTitle);
		$(".infoTxtXX").html(translate.infoWrongCodeDesc);

		firstOpen = false;
		var xhr = new XMLHttpRequest();
		xhr.responseType = "text";
		xhr.open("GET", event.data.profilePhoto, true);
		xhr.send();
		xhr.onreadystatechange = processRequest;
		function processRequest(e) {
			if (xhr.readyState == 4 && xhr.status == 200) {
				var string = xhr.responseText.toString();
				var array = string.split("avatarfull");
				var array2 = array[1].toString().split('"');
				profilePhoto = array2[2].toString();
				$(".profileImg").css("background-image", `url(${profilePhoto})`);
			}
		}

		$("#coinAmount").html(`${event.data.myCoinAmount} CR`);
		if (event.data.freeRoll) {
			$(".spinButton").css("display", "flex");
			$(".spinTimeButton").css("display", "none");
			$(".getSpinButton").css("display", "none");
		} else {
			$(".spinButton").css("display", "none");
			$(".spinTimeButton").css("display", "flex");
			$(".getSpinButton").css("display", "flex");
			$("#remainingTime").html(event.data.remaining);
		}

		$(".nameSection").html(event.data.myFirstName + " " + event.data.myLastName);
		$(".profileName").html(event.data.myFirstName + " " + event.data.myLastName);

		$(".General").css("display", "flex");
		if (event.data.items) {
			$(".wheel").empty();
			var newIndex = 1;
			event.data.items.forEach((element, index) => {
				var text = "#25303c";
				var itemIdText = newIndex == 1 ? "id='winSpan'" : "";
				var imgIdText = newIndex == 1 ? "id='winImage'" : "";
				newIndex = index + 1;
				text = index % 2 == 0 ? "#25303c" : "#1b222b";
				$(".wheel").append(`
					<div  class="number" style="--i: ${newIndex}; --clr: ${text}">
						<img src="${element.image}" alt="" class="itemImg"  ${imgIdText}/>
						<span  ${itemIdText}
							>${element.label}
							<p>${element.giveItemType.toUpperCase()}</p></span
						>
					</div>
				`);
			});

			if (event.data.items.length < 8) {
				var lentghx = 8 - event.data.items.length;
				for (let index = 0; index < lentghx; index++) {
					var newElementInt = Math.floor(Math.random() * event.data.items.length);
					var newElement = event.data.items[newElementInt];
					var itemIdText = newIndex == 1 ? "id='winSpan'" : "";
					var imgIdText = newIndex == 1 ? "id='winImage'" : "";
					var text = "#25303c";
					newIndex = newIndex + 1;
					text = newIndex % 2 == 0 ? "#1b222b" : "#25303c";

					$(".wheel").append(`
						<div  class="number" style="--i: ${newIndex}; --clr: ${text}">
							<img src="${newElement.image}" alt="" class="itemImg"  ${imgIdText} />
							<span  ${itemIdText}
								>${newElement.label}
								<p>${newElement.giveItemType.toUpperCase()}</p></span
							>
						</div>
					`);
				}
			}
		}
	}
});

$(document).on("keydown", function () {
	// EKLENECEK
	switch (event.keyCode) {
		case 27: // ESC
			closeMenu();
			$.post("https://wex-dailywheel/closeMenu", JSON.stringify());
			break;
	}
});

$(document).on("click", ".exitBox", function () {
	closeMenu();
	$.post("https://wex-dailywheel/closeMenu", JSON.stringify());
});

$(document).on("click", ".enterCodeButton", function () {
	var codeInputValue = $(".redeemCodeInput").val();
	if (codeInputValue != "redeem code..." && codeInputValue.length > 0) {
		$.post(
			"https://wex-dailywheel/sendInput",
			JSON.stringify({
				input: codeInputValue,
			}),
			function (data) {
				if (data) {
					var htmlCoinText = $("#coinAmount").html();
					var cuttedText = htmlCoinText.replace(/\D/g, "");
					var myCoin = parseInt(cuttedText);
					$("#winBoxImage").attr("src", "./img/coinItem.png");
					$("#winBoxSpan").html(`
						${parseInt(data)} CR
						<p>COIN</p>
					`);
					$(".winSide").css("display", "flex");
					$("#coinAmount").html(myCoin + parseInt(data) + " CR");
				} else {
					$(".infoTxtXX").html(translate.infoWrongCodeDesc);
					$(".notifyBox").css("display", "flex");
					setTimeout(() => {
						$(".notifyBox").css("display", "none");
					}, 3000);
				}
			}
		);
	}
});

function closeMenu() {
	$(".General").css("display", "none");
}

let value = Math.ceil(1 * 3600);
$(document).on("click", ".spinButton", function () {
	let wheel = document.querySelector(".wheel");
	$.post("https://wex-dailywheel/spinWheel", JSON.stringify({ spinType: "free" }), function (data) {
		if (data) {
			spinSound.play();
			let itemData = data.selectedItem;
			let serverData = data.serverSide;

			$(".spinButton").css("display", "none");
			$(".spinTimeButton").css("display", "flex");
			$(".getSpinButton").css("display", "flex");
			$("#remainingTime").html(serverData);
			wheel.style.transform = "rotate(" + value + "deg)";
			value += Math.ceil(1 * 3600);
			setTimeout(() => {
				$("#winImage").attr("src", itemData.image);
				$("#winBoxImage").attr("src", itemData.image);
				$("#winSpan").html(`
				${itemData.label}
					<p>${itemData.giveItemType.toUpperCase()}</p>
				`);
				$("#winBoxSpan").html(`
					${itemData.label}
					<p>${itemData.giveItemType.toUpperCase()}</p>
				`);
			}, 600);
			setTimeout(() => {
				$(".winSide").css("display", "flex");
			}, 5800);
		} else {
			$(".infoTxtXX").html(translate.infoYouDontHaveCoin);
			$(".notifyBox").css("display", "flex");
			setTimeout(() => {
				$(".notifyBox").css("display", "none");
			}, 3000);
		}
	});
});

$(document).on("click", ".getSpinButton", function () {
	let wheel = document.querySelector(".wheel");
	$.post("https://wex-dailywheel/spinWheel", JSON.stringify({ spinType: "notfree" }), function (data) {
		if (data) {
			spinSound.play();
			let itemData = data.selectedItem;

			$(".spinButton").css("display", "none");
			$(".spinTimeButton").css("display", "flex");
			$(".getSpinButton").css("display", "flex");
			$("#coinAmount").html(`${data.coinAmount} CR`);
			wheel.style.transform = "rotate(" + value + "deg)";
			value += Math.ceil(1 * 3600);
			setTimeout(() => {
				$("#winImage").attr("src", itemData.image);
				$("#winBoxImage").attr("src", itemData.image);
				$("#winSpan").html(`
				${itemData.label}
					<p>${itemData.giveItemType.toUpperCase()}</p>
				`);
				$("#winBoxSpan").html(`
					${itemData.label}
					<p>${itemData.giveItemType.toUpperCase()}</p>
				`);
			}, 600);
			setTimeout(() => {
				$(".winSide").css("display", "flex");
			}, 5800);
		} else {
			$(".infoTxtXX").html(translate.infoYouDontHaveCoin);
			$(".notifyBox").css("display", "flex");
			setTimeout(() => {
				$(".notifyBox").css("display", "none");
			}, 3000);
		}
	});
});

$(document).on("click", ".collectButton", function () {
	$(".winSide").css("display", "none");
});

$(document).on("click", ".buyButton", function () {
	window.invokeNative("openUrl", tebexLink);
});
