import QtQuick 2.4
import QtQuick.Window 2.2

import wpp.qt 1.0

Window {
	id: rootItem
	width: 320
	height: 480
	visible: true

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
		anchors.topMargin: 10*wpp.dp2px
		anchors.left: parent.left; anchors.right: parent.right;
		height: 36*wpp.dp2px
		topBorder: true; bottomBorder: true
		color: "#ffffff"
		title: qsTr("Date/Time")
		msecSinceEpoch: new Date().getTime()
		timeZoneId: "Asia/Hong_Kong"
		onPicked: {
			var dateTime = new Date(msecSinceEpoch);
			console.debug("picked=" + dateTime);
		}
	}
}
