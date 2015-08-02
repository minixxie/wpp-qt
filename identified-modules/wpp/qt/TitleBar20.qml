import QtQuick 2.4

Rectangle {
	id: titleBar
	property alias label: label
	property bool centerTitle: true
	property alias bottomBorder: bottomBorder

	height: 44*wpp.dp2px
	anchors.top: parent.top
	anchors.left: parent.left
	anchors.right: parent.right
	color: "#f7f7f7"

	Text {
		id: label
		color: "#000000"
		font.pixelSize: 14*wpp.dp2px
		font.bold: true
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		height: parent.height
		anchors.centerIn: width > parent.width || !titleBar.centerTitle ? undefined : parent
		anchors.left: width > parent.width ? parent.left : undefined
	}
	Rectangle {
		id: bottomBorder
		height: visible? 1*wpp.dp2px : 0
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		color: "#b2b2b2"
	}
}
