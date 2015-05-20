import QtQuick 2.2
import wpp.qt.NativeDateTimePicker 1.0

Rectangle {
	id: dateTimeControl

	property alias title: titleText.text
	property date dateTime: {

		var d = new Date();
		console.debug("DateTimeControl:initialize:dateTime=" + d.getTime()/1000
					  + "..." + d );
		return d;
	}
	property string format: "yyyy-MM-dd hh:mm AP"
	property string timeZoneId: Qt.TimeZone
	signal picked(var dateTimePicked)

	property alias topBorder: upperBorderLine.visible
	property alias bottomBorder: lowerBorderLine.visible

	height: 36*reso.dp2px

	Rectangle {//top line
		id: upperBorderLine
		anchors.top: parent.top
		anchors.left: parent.left; anchors.right: parent.right
		height: visible?1*reso.dp2px:0
		color: "#dddddd"
		visible: false
	}

	Text {
		id: titleText
		anchors.top: parent.top; anchors.bottom: parent.bottom;
		anchors.left: parent.left; anchors.leftMargin:10*reso.dp2px;
		text: ""
		font.pixelSize: 12*reso.dp2px
		color: "#333333"
		verticalAlignment: Text.AlignVCenter
	}
	Text {
		anchors.top: parent.top; anchors.bottom: parent.bottom;
		anchors.right: parent.right; anchors.rightMargin:10*reso.dp2px;
		text: Qt.formatDateTime(dateTimeControl.dateTime, format)
		font.pixelSize: 12*reso.dp2px
		color: "#333333"
		verticalAlignment: Text.AlignVCenter
	}
	NativeDateTimePicker {
		id: dateTimePicker
		dateTime: {
			console.debug("NativeDateTimePicker:init:dateTime=(" + dateTimeControl.dateTime.getTime()/1000
						  + ")=" + dateTimeControl.dateTime);
			return dateTimeControl.dateTime
		}
		onPicked: {
			dateTimeControl.picked(dateTime);
		}
	}

	Rectangle {//bottom line
		id: lowerBorderLine
		anchors.bottom: parent.bottom
		anchors.left: parent.left; anchors.right: parent.right
		height: visible?1*reso.dp2px:0
		color: "#dddddd"
		visible: false
	}

	MouseArea {
		anchors.fill: parent
		Overlay { target: parent; isTargetMouseArea: true }
		onClicked: {
			Qt.inputMethod.hide();
			dateTimePicker.open();
		}
	}
}


