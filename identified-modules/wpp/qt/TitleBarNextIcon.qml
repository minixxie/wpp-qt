import QtQuick 2.1

Rectangle {
	id: "nextIconFrame"

	property string iconType: "DARK"
	signal clicked


	color: "transparent"

	height: 44*wpp.dp2px
	width: height
	Image {
		id: "nextIcon"
		source: nextIconFrame.iconType == "DARK" ?
			"qrc:/img/android-icons/All_Icons/holo_dark/mdpi/1-navigation-next-item.png" :
			"qrc:/img/android-icons/All_Icons/holo_light/mdpi/1-navigation-next-item.png"
		x: ( parent.height - height )/2
		y: x
		width: 32*wpp.dp2px
		height: width
		smooth: true
		fillMode: Image.PreserveAspectFit
	}
	MouseArea {
		id: "nextIconMouseArea"
		x:0; y:0
		anchors.fill: parent
		onClicked: {
			//console.debug("nextIconMouseArea clicked");
			nextIconFrame.clicked();
			//parent.onBack();
			//pageStack.pop();
		}
		Overlay {
			target: parent
			isTargetMouseArea: true
		}
	}

}
