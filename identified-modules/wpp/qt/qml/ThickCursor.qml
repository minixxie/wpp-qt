import QtQuick 2.1

Rectangle {
	id: "thickCursor"
	property Item textBox

	width:2*reso.dp2px
	height: textBox.font.pixelSize + 4*reso.dp2px
	color: "#555555"
	visible: textBox.cursorVisible
	SequentialAnimation {
		loops: Animation.Infinite
		running: true
		PropertyAnimation {
			target: thickCursor
			property: "opacity"
			easing.type: Easing.OutSine
			from: 0
			to: 1.0
			duration: 50
		}
		PauseAnimation { duration: 450 }
		PropertyAnimation {
			target: thickCursor
			property: "opacity"
			easing.type: Easing.OutSine
			from: 1.0
			to: 0
			duration: 50
		}
		PauseAnimation { duration: 450 }

	}
}
