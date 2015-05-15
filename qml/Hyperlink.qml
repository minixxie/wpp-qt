import QtQuick 2.1

import "./"

Text {
	id: "link"
	signal clicked

	MouseArea {
		id: "mouseArea"
		anchors.fill: parent
		onClicked: link.clicked()
		Overlay {
			target: parent
			isTargetMouseArea: true
		}
	}

/*	states: State {
		name: "pressed"; when: mouseArea.pressed
		PropertyChanges { target: link; scale: 1.1 }
		PropertyChanges { target: link; font.underline: true }
	}

	transitions: Transition {
		NumberAnimation { properties: "scale"; duration: 200; easing.type: Easing.InOutQuad }
	}*/
}


