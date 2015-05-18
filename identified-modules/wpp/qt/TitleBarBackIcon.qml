import QtQuick 2.1

Rectangle {
	id: "backIconFrame"

	property string iconType: "DARK"
	property alias mouseAreaZ: backIconMouseArea.z
	signal clicked


	color: "transparent"

	height: 44*reso.dp2px
	width: height
	onZChanged: {
		//console.debug("backIconFrame.z=" + z);
	}

	Image {
		id: "backIcon"
		source: backIconFrame.iconType == "DARK" ?
            "qrc:/img/android-icons/All_Icons/holo_dark/mdpi/1-navigation-previous-item.png" :
			"qrc:/img/android-icons/All_Icons/holo_light/mdpi/1-navigation-previous-item.png"
		x: ( parent.height - height )/2
		y: x
		z: parent.z+1
		width: 32*reso.dp2px
		height: width
		smooth: true
		fillMode: Image.PreserveAspectFit
	}
	MouseArea {
		id: "backIconMouseArea"
		x:0; y:0
		z: parent.z+1
		onZChanged: {
			//console.debug("backIconMouseArea.z=" + z);
		}

		anchors.fill: parent
		onClicked: {
			//console.debug("backIconMouseArea clicked");
			backIconFrame.clicked();
			//parent.onBack();
			//pageStack.pop();
		}
		Overlay {
			target: parent
			isTargetMouseArea: true
		}
	}

}
