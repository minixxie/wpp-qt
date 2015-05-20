import QtQuick 2.4
import QtQuick.Window 2.2

import wpp.qt 1.0

Rectangle {
	id: rootItem
	color: "#efeef4"

	TitleBar {
		id: titleBar
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		text: "DateTimeControl"
	}

	DateTimeControl {
		id: startDateTimeControl
		anchors.top: titleBar.bottom
		anchors.topMargin: 10*reso.dp2px
		anchors.left: parent.left; anchors.right: parent.right;
		height: 36*reso.dp2px
		topBorder: true; bottomBorder: true
		color: "#ffffff"
		title: qsTr("Date/Time")
		dateTime: new Date()
		timeZoneId: "Asia/Hong_Kong"
		onPicked: {
			dateTime = dateTimePicked;
			console.debug("picked=" + dateTimePicked);
		}
	}
}
