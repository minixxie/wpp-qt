import QtQuick 2.2
import QtSensors 5.0

Rectangle {
	id: switchButton
	property bool isOn: false

	property color borderColor: "#cccccc"

	border.width: 1*wpp.dp2px
	border.color: borderColor
	radius: height/2
	height: 30*wpp.dp2px
	width: 50*wpp.dp2px
	color: "#ffffff"


	Rectangle {
		id: circle
		x: 0
		y: 0
		border.width: 1*wpp.dp2px
		border.color: borderColor
		radius: height/2
		height: parent.height
		width: height
	}

	ParallelAnimation {
		id: switchOn
		running: false
		NumberAnimation { target: circle; property: "x"; from: 0; to: switchButton.width - circle.width; duration: 300 }
		PropertyAnimation { target: switchButton; property: "color"; from: "#ffffff" ; to: "#4cd964"; duration: 300 }
		PropertyAnimation { target: switchButton; property: "borderColor"; from: "#cccccc" ; to: "#4cd964"; duration: 300 }
	}
	ParallelAnimation {
		id: switchOff
		running: false
		NumberAnimation { target: circle; property: "x"; from: switchButton.width - circle.width; to: 0; duration: 300 }
		PropertyAnimation { target: switchButton; property: "color"; from: "#4cd964"; to: "#ffffff" ;  duration: 300 }
		PropertyAnimation { target: switchButton; property: "borderColor"; from: "#4cd964"; to: "#cccccc" ;  duration: 300 }
	}

	MouseArea {
		anchors.fill: parent
		onClicked: {
			switchButton.isOn = !switchButton.isOn;
			if ( switchButton.isOn )
				switchOn.running = true;
			else
				switchOff.running = true;
		}
	}

	function initState()
	{
		if ( isOn )
		{
			circle.x = switchButton.width - circle.width;
			color = "#4cd964";
		}
		else
		{
			circle.x = 0;
			color = "#ffffff";
		}
	}

	Component.onCompleted: {
		initState();
	}
}
