import QtQuick 2.1



Rectangle {
    id: "dateTime"

	property string type: "DATE_TIME" //DATE, DATE_TIME
	property date date: new Date()
	property date selectedDate: new Date()

	/*property int h: Qt.formatDateTime(new Date(timestamp*1000), "hh");
    property int m: Qt.formatDateTime(new Date(timestamp*1000), "mm");
    property int yy: Qt.formatDateTime(new Date(timestamp*1000), "yyyy");
    property int mm: Qt.formatDateTime(new Date(timestamp*1000), "MM");
	property int dd: Qt.formatDateTime(new Date(timestamp*1000), "dd");*/
    property alias year: yearSpinner.value
    property alias month: monthSpinner.value
	property int nwidth: 90*reso.dp2px
	property int dwidth: 50*reso.dp2px
	property int dheight: 50*reso.dp2px
	property bool isLight: true
	/*property alias month: monthSpinner.value
	property alias day: daySpinner.value
	property alias hour: hourSpinner.value
	property alias minute: minuteSpinner.value*/

	//property int currentYear: Qt.formatDateTime(new Date(), "yyyy");

	//signal onTimestampChanged
	signal dateTimeSelected

    width: parent.width - 16*reso.dp2px
	height: 90*reso.dp2px

	gradient: Gradient {
		GradientStop {
			position: 0.0
			color: "black"
		}

		GradientStop {
			position: 0.5
			color: "#222222"
		}

		GradientStop {
			position: 1.0
			color: "black"
		}
	}


	function dateObjToJSON(dateObj)
	{
		var dateJSON = {
			"year": Qt.formatDateTime(dateObj, "yyyy"),
			"month": Qt.formatDateTime(dateObj, "MM"),
			"day": Qt.formatDateTime(dateObj, "dd"),
			"hour": Qt.formatDateTime(dateObj, "hh"),
			"minute": Qt.formatDateTime(dateObj, "mm")
		};
		//console.debug("dateObjToJSON:" + dateJSON.year + "-" + dateJSON.month + "-" + dateJSON.day + "_"
		//			+ dateJSON.hour + ":" + dateJSON.minute );
		return dateJSON;
	}
	function spinnersToDate()
	{
		/*var d = Date.fromLocaleString(Qt.locale(),
				yearSpinner.value + "-" + monthSpinner.value + "-" + daySpinner.value + " " + hourSpinner.value + ":" + minuteSpinner.value,
				"yyyy-MM-dd hh:mm");*/
		var d = new Date();
		//console.debug("spinnersToDate: date(b4):" + d);
		//console.debug("year spinner value:" + yearSpinner.value);
		//console.debug("monthSpinner spinner value:" + monthSpinner.value);
		//console.debug("daySpinner spinner value:" + daySpinner.value);
		//console.debug("hourSpinner spinner value:" + hourSpinner.value);
		//console.debug("minutes spinner value:" + minuteSpinner.value);
		//var y = parseInt(yearSpinner.value);
		//var m = parseInt(monthSpinner.value);
		//var d = parseInt(daySpinner.value);
        d.setFullYear(parseInt(yearSpinner.value));
		d.setMonth(parseInt(monthSpinner.value) - 1);
		d.setDate(parseInt(daySpinner.value));
		d.setHours(parseInt(hourSpinner.value));
		d.setMinutes(parseInt(minuteSpinner.value));
		d.setSeconds(0);
		//console.debug("spinnersToDate: date:" + d);
		return d;
    }

    Spinner {
		id: "yearSpinner"
		//from: currentYear > yy ? yy : currentYear;
		//to: currentYear + 5
		from: 1900
        to: parseInt(digit) + 5
		digit: date.getFullYear()

		widthsize: dateTime.nwidth
		heightsize: dateTime.dheight
		anchors.verticalCenter: parent.verticalCenter
//        anchors.horizontalCenter: parent.horizontalCenter
		anchors.left: dateTime.left
		anchors.leftMargin: {

			if ( type == "DATE" )
			{

				var leftMarginSize = (dateTime.width - width - monthSpinner.width - daySpinner.width - 2) / 2
				return leftMarginSize;

			}

			return 0;

		}

		onValueChanged: {
			//console.debug("year value changed:" + value);
			selectedDate = spinnersToDate();
			parent.dateTimeSelected();//emit

			dayIndexBackup = daySpinner.index;
			//console.debug("dayIndexBackup:" + dayIndexBackup);
			daySpinner.recalculate();

        }
	}


//    property int mm: monthSpinner.index + 1;
//    property int dayIndex: daySpinner.index;

	Spinner {
		id: "monthSpinner"
        from: 1
        to: 12
        digit: parseInt(date.getMonth()) + 1
//        anchors.verticalCenter: parent.verticalCenter
//        anchors.horizontalCenter: parent.horizontalCenter
		widthsize: dateTime.dwidth
		heightsize: dateTime.dheight
		anchors.top: yearSpinner.top
		anchors.left: yearSpinner.right
		anchors.leftMargin: -1
//        anchors.leftMargin: 5*reso.dp2px
		onValueChanged: {
			//console.debug("month value changed:" + value);

            selectedDate = spinnersToDate();
            parent.dateTimeSelected();//emit

			dayIndexBackup = daySpinner.index;
			//console.debug("dayIndexBackup:" + dayIndexBackup);
			daySpinner.recalculate();

        }
	}

	function calculateDayMax()
	{
		var to = 31;

		if ( parseInt(month) === 2 )
		{

			to = 28;

			if ( year % 4 == 0 )
			{
				to = 29;
			}

		}
		else if ( parseInt(month) === 4 || parseInt(month) === 6 || parseInt(month) === 9 || parseInt(month) === 11 )
		{

			to = 30;

		}

		return to;
	}


	property int dayIndexBackup: -1

    Spinner {
		id: "daySpinner"
		widthsize: dateTime.dwidth
		heightsize: dateTime.dheight
		anchors.leftMargin: -1
        from: 1
		Component.onCompleted: {
			recalculate();
		}
		function recalculate()
		{
			to = parent.calculateDayMax();
			if ( parent.dayIndexBackup != -1 )
			{
				//console.debug("restore to index:" + parent.dayIndexBackup);
				if ( parent.dayIndexBackup + from > to )//too big
				{
					parent.dayIndexBackup = to - from;//max
					//console.debug("index too large, changed to max:" + parent.dayIndexBackup);
				}
				positionViewAtIndex(parent.dayIndexBackup, PathView.SnapPosition);
				parent.dayIndexBackup = -1;
			}
		}

		digit: date.getDate()

		anchors.top: monthSpinner.top
		anchors.left: monthSpinner.right
//        anchors.leftMargin: 5*reso.dp2px
		onValueChanged: {
			//console.debug("day value changed:" + value);
			selectedDate = spinnersToDate();
			parent.dateTimeSelected();//emit
        }
    }

    Spinner {
        id: "hourSpinner"
		visible: dateTime.type == "DATE_TIME"
        from: 0
        to: 23
		widthsize: dateTime.dwidth
		heightsize: dateTime.dheight
        digit: date.getHours()

        anchors.top: colon.top
        anchors.right: colon.left
		onValueChanged: {
			//console.debug("hour value changed:" + value);
			selectedDate = spinnersToDate();
			parent.dateTimeSelected();//emit
		}
    }

    Rectangle {
        id: "colon"
		visible: dateTime.type == "DATE_TIME"
		width:10*reso.dp2px
		height: hourSpinner.height
		anchors.right: minuteSpinner.left
		anchors.top: minuteSpinner.top
		color: "transparent"
        Text {
            text: ":"
            font.pixelSize: 20*reso.dp2px
            anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
			color: dateTime.isLight ? "#FFFFFF" : "#000000"

			SequentialAnimation on visible {
				loops: Animation.Infinite
				PropertyAnimation { to: false; duration: 500 }
				PropertyAnimation { to: true; duration: 500 }
			}
        }
    }

    Spinner {
		id: "minuteSpinner"
		visible: dateTime.type == "DATE_TIME"
		from: 0
		to: 59
		widthsize: dateTime.dwidth
		heightsize: dateTime.dheight
		digit: date.getMinutes()
        anchors.verticalCenter: parent.verticalCenter
//        anchors.horizontalCenter: parent.horizontalCenter
        anchors.right: dateTime.right
//        anchors.rightMargin: 8*reso.dp2px
		onValueChanged: {
			//console.debug("minutes value changed:" + value);
			selectedDate = spinnersToDate();
			parent.dateTimeSelected();//emit
		}
		Component.onCompleted: {
			//console.debug("minute spinner width:" + width);
		}
	}
}
