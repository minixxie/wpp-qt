import QtQuick 2.4
import QtQuick.Window 2.2

import wpp.qt 1.0

Window {
    visible: true
	width: 320*reso.dp2px
	height: 480*reso.dp2px

	DateTimeControl {
		id: startDateTimeControl
		anchors.top: parent.top
		anchors.left: parent.left; anchors.right: parent.right;
		height: 36*reso.dp2px
		topBorder: true; bottomBorder: true
		title: qsTr("Date/Time")
		dateTime: new Date()
		timeZoneId: "Asia/Hong_Kong"
		onPicked: {
			dateTime = dateTimePicked;
			console.debug("picked=" + dateTimePicked);
		}
	}
}
