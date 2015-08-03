import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

import wpp.qt 1.0
import wpp.qt.SMS 2.0

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
		text: "Dial Phone"
	}

	TextField {
		id: textfield
		width: 240*wpp.dp2px
		height: 44*wpp.dp2px
		anchors.top: titleBar.bottom
		anchors.topMargin: 20*wpp.dp2px
		anchors.horizontalCenter: parent.horizontalCenter
		placeholderText: "Phone Number"
	}
	TextArea {
		id: msg
		width: 240*wpp.dp2px
		height: 100*wpp.dp2px
		anchors.top: textfield.bottom
		anchors.topMargin: 20*wpp.dp2px
		anchors.horizontalCenter: parent.horizontalCenter
	}

	Rectangle {
		id: setButton
		width: 240*wpp.dp2px
		height: 44*wpp.dp2px
		anchors.top: msg.bottom
		anchors.topMargin: 20*wpp.dp2px
		anchors.horizontalCenter: parent.horizontalCenter
		color: "#0080ff"
		Text {
			text: "Send SMS"
			anchors.centerIn: parent
			font.pixelSize: 12*wpp.dp2px
			color: "#ffffff"
		}
		MouseArea {
			anchors.fill: parent
			Overlay { target: parent; isTargetMouseArea: true }
			onClicked: {
				sms.phones = [textfield.text];
				sms.msg = msg.text;
				sms.open();
			}
		}
	}
	MessageDialog {
		id: dialog
		title: "Send SMS"
		text: "Sent successfully"
		visible: false
	}

	SMS {
		id: sms
		onSent: {
			dialog.visible = true;
		}
	}

}
