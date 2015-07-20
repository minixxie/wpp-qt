import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

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
		text: "Badge Unread Count"
	}

	TextField {
		id: textfield
		width: 240*wpp.dp2px
		height: 44*wpp.dp2px
		anchors.top: titleBar.bottom
		anchors.topMargin: 20*wpp.dp2px
		anchors.horizontalCenter: parent.horizontalCenter
	}

	Rectangle {
		id: setButton
		width: 240*wpp.dp2px
		height: 44*wpp.dp2px
		anchors.top: textfield.bottom
		anchors.topMargin: 20*wpp.dp2px
		anchors.horizontalCenter: parent.horizontalCenter
		color: "#0080ff"
		Text {
			text: "Set Badget Unread Count"
			anchors.centerIn: parent
			font.pixelSize: 12*wpp.dp2px
			color: "#ffffff"
		}
		MouseArea {
			anchors.fill: parent
			Overlay { target: parent; isTargetMouseArea: true }
			onClicked: wpp.setAppIconUnreadCount(parseInt(textfield.text))
		}
	}

	Rectangle {
		width: 240*wpp.dp2px
		height: 44*wpp.dp2px
		anchors.top: setButton.bottom
		anchors.topMargin: 20*wpp.dp2px
		anchors.horizontalCenter: parent.horizontalCenter
		color: "#007700"
		Text {
			text: "Clear Badget Unread Count"
			anchors.centerIn: parent
			font.pixelSize: 12*wpp.dp2px
			color: "#ffffff"
		}
		MouseArea {
			anchors.fill: parent
			Overlay { target: parent; isTargetMouseArea: true }
			onClicked: wpp.setAppIconUnreadCount(0)
		}
	}

}
