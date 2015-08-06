import QtQuick 2.4

MouseArea {
	id: scrollInputVisible
	property var inputElement
	property var flickable
	property int scrollToContentYWhenFocused: 0

	Timer {
		id: delayFocusTimer
		running: false
		repeat: false
		interval: 200
		onTriggered: {
			scrollInputVisible.inputElement.forceActiveFocus();
		}
	}
	PropertyAnimation {
		id: scrollUpAnimation
		target: scrollInputVisible.flickable
		property: "contentY"
		to: scrollInputVisible.scrollToContentYWhenFocused
		duration: 100
	}
	onClicked: {
		scrollUpAnimation.start();
		delayFocusTimer.running = true;
	}

}
