import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import wpp.qt 2.0
import QtGraphicalEffects 1.0

Rectangle {
	id: rect
	property string name: ""
	property alias text: textfield.text

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
	}
	TextField {
		id: textfield
		anchors.top: parent.top
		anchors.left: text.right
		anchors.right: parent.right
		anchors.rightMargin: 10*wpp.dp2px
		anchors.bottom: parent.bottom
		placeholderText: rect.name
		horizontalAlignment: Text.AlignRight
		style: WppTextFieldStyle {
		}
	}
}
