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
		text: "Adjust Resize"
	}

	TextField {
		id: textfield
		width: 240*wpp.dp2px
		height: 44*wpp.dp2px
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 10*wpp.dp2px
		anchors.horizontalCenter: parent.horizontalCenter
		placeholderText: "Input sticking bottom"
	}

}
