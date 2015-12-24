import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import wpp.qt 2.0
import QtGraphicalEffects 1.0

Rectangle {
	id: rect
	property string name: ""
    property alias isOn: switchButton.isOn

	color: "#fff"
	Text {
		id: text
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.leftMargin: 10*wpp.dp2px
		anchors.bottom: parent.bottom
		width: contentWidth
		verticalAlignment: Text.AlignVCenter
		text: rect.name
                color: "#333333"
                font.pixelSize: 12*wpp.dp2px
	}
    SwitchButton {
        id: switchButton
        anchors.verticalCenter: parent.verticalCenter
		anchors.right: parent.right
		anchors.rightMargin: 10*wpp.dp2px
        height: 24*wpp.dp2px
        width: 40*wpp.dp2px
	}
}
