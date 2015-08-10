import QtQuick 2.2
import wpp.qt.NativeDateTimePicker 1.0

Rectangle {
	id: dateTimeControl

	property alias title: titleText.text
	property alias font: titleText.font
	property alias msecSinceEpoch: dateTimePicker.msecSinceEpoch
	//property variant msecSinceEpoch: {
	//	var d = new Date();
	//	return d.getTime();
	//}

	/*property date dateTime: {
		return wpp.currentDateTime(dateTimeControl.timeZoneId);

		//var d = new Date();
		//console.debug("DateTimeControl:initialize:dateTime=" + d.getTime()/1000
		//			  + "..." + d );
		//return d;
	}*/
	property string format: "yyyy-MM-dd hh:mm AP"
	property string timeZoneId: Qt.TimeZone
	/*onTimeZoneIdChanged: {
		//var dateTime = new Date();
		console.debug("DateTimeControl.onTimeZoneIdChanged:timezoneId=" + dateTimeControl.timeZoneId);
		console.debug("DateTimeControl.onTimeZoneIdChanged:dateTime(OLD)=" + dateTime.toString("yyyy-MM-dd hh:mm AP"));
		dateTime = wpp.makeDateTime(dateTimeControl.timeZoneId, dateTime.getTime());
		console.debug("DateTimeControl.onTimeZoneIdChanged:dateTime(NEW)=" + dateTime.toString("yyyy-MM-dd hh:mm AP"));
	}*/

	signal picked(variant msecSinceEpoch)

	property alias topBorder: upperBorderLine.visible
	property alias bottomBorder: lowerBorderLine.visible

	height: 36*wpp.dp2px

	Rectangle {//top line
		id: upperBorderLine
		anchors.top: parent.top
		anchors.left: parent.left; anchors.right: parent.right
		height: visible?1*wpp.dp2px:0
		color: "#dddddd"
		visible: false
	}

	Text {
		id: titleText
		anchors.top: parent.top; anchors.bottom: parent.bottom;
		anchors.left: parent.left; anchors.leftMargin:10*wpp.dp2px;
		text: ""
		font.pixelSize: 12*wpp.dp2px
		color: "#333333"
		verticalAlignment: Text.AlignVCenter
	}
	Text {
		anchors.top: parent.top; anchors.bottom: parent.bottom;
		anchors.right: parent.right; anchors.rightMargin:10*wpp.dp2px;
		text: wpp.formatDateTime(dateTimeControl.msecSinceEpoch, dateTimeControl.format, dateTimeControl.timeZoneId)
		font.pixelSize: titleText.font.pixelSize
		color: "#333333"
		verticalAlignment: Text.AlignVCenter
	}
	NativeDateTimePicker {
		id: dateTimePicker
		timeZoneId: dateTimeControl.timeZoneId
		//msecSinceEpoch: dateTimeControl.msecSinceEpoch
		/*{
			console.debug("NativeDateTimePicker:init:dateTime=(" + dateTimeControl.dateTime.getTime()/1000
						  + ")=" + dateTimeControl.dateTime);
			return new Date(dateTimeControl.msecSinceEpoch);
		}*/
		onPicked: {//msecSinceEpoch
			console.debug("NativeDateTimePicker.onPicked: msecSinceEpoch=" + msecSinceEpoch);
			dateTimeControl.picked(msecSinceEpoch);
		}
	}

	Rectangle {//bottom line
		id: lowerBorderLine
		anchors.bottom: parent.bottom
		anchors.left: parent.left; anchors.right: parent.right
		height: visible?1*wpp.dp2px:0
		color: "#dddddd"
		visible: false
	}

	MouseArea {
		anchors.fill: parent
		Overlay { target: parent; isTargetMouseArea: true }
		onClicked: {
			parent.forceActiveFocus();
			Qt.inputMethod.hide();
			dateTimePicker.open();
		}
	}
}


