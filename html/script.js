let displayOnlyOnChange = false;
let displayCounter = 0;
let displayWait = 3000;
let type = ''

window.onload = (e) => {
	window.addEventListener('message', onMessageRecieved);
};

function onMessageRecieved(event){
	const data = event.data;
	switch (data.action) {
		case "changeLimit":
			const hasClass = $("#numerals").hasClass(".numerals-cramp-"+type)
			if (data.numeral >= 100) {
				if (!hasClass) {
					$("#numerals").addClass("numerals-cramp-"+type)
				}
			} else if (hasClass == true) {
				$("#numerals").removeClass("numerals-cramp-"+type)
			}

			if (data.fade == true) {
				$("#numerals").fadeOut(200, function() {
					$(this).text(data.numeral).fadeIn(200);
				});
			} else {
				$("#numerals").text(data.numeral);
			};

			if (displayOnlyOnChange == true) {
				displayCounter++;
				setTimeout(function() {
					const visible = $("#sign").is(":visible");
					if (visible == false) {
						$("#sign").fadeIn(500);
					};
					setTimeout(function() {
						if (displayCounter == 1) {
							$("#sign").fadeOut(500);
						};
						displayCounter--;
					}, displayWait);
				}, 250);
			};
			break;
		case "changeAdvisory":
			if (data.fade == true) {
				$("#advisory-numerals").fadeOut(200, function() {
					$(this).text(data.numeral).fadeIn(200);
				});
			} else {
				$("#advisory-numerals").text(data.numeral)
			}
			$("#advisory-label").text(data.label);
			break;
		case "showAdvisory":
			$("#advisory-sign").slideToggle(500);
			break;
		case "hideAdvisory":
			$("#advisory-sign").slideToggle(500);
			break;
		case "show":
			$("#sign").show(0);
			$("#container").fadeIn(500);
			break;
		case "hide":
			$("#container").fadeOut(400, function() {
				$("#sign").hide(0);
				$("#advisory-sign").hide(0);
			});
			break;
		case "setConfig":
			type = data.type;
			const backgroundClass = "background-" + type;
			const background = $("#background")
			background.removeClass();
			background.addClass(backgroundClass);

			const numeralClass = "numerals-" + type;
			const numerals = $("#numerals")
			numerals.removeClass();
			numerals.addClass(numeralClass);

			if (data.advisory != false) {
				const aBackgroundClass = "advisory-background-" + data.advisory;
				const aBackground = $("#advisory-background")
				aBackground.removeClass();
				aBackground.addClass(aBackgroundClass);

				const aNumeralsClass = "advisory-numerals-" + data.advisory;
				const aNumerals = $("#advisory-numerals")
				aNumerals.removeClass();
				aNumerals.addClass(aNumeralsClass);

				const aLabelClass = "advisory-label-" + data.advisory;
				const aLabel = $("#advisory-label")
				aLabel.removeClass();
				aLabel.addClass(aLabelClass);
			}

			displayOnlyOnChange = data.displayOnlyOnChange;
			displayWait = data.displayWait;
			break;
		default:
			console.log("ERROR: An invalid action was recieved!");
	}
}

