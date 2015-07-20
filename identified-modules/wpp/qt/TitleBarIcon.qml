import QtQuick 2.1
import QtGraphicalEffects 1.0

Rectangle {
    id: "iconFrame"
    property alias source: iconImage.source
	property alias hasNew: redDot.visible
	property alias hasNewColor: redDot.color
	signal clicked

	color: "transparent"

	height: 44*wpp.dp2px
	width: height
	Image {
        id: "iconImage"
		x: ( parent.height - height )/2
		y: x
		width: 32*wpp.dp2px
		height: width
		smooth: true
		fillMode: Image.PreserveAspectFit
	}
	Rectangle {
		id: redDot
		width: 10*wpp.dp2px
		height: width
		anchors.top: iconImage.top
		anchors.right: iconImage.right
		radius: width/2
		color: "#ff0000"
		z: iconImage.z + 1
		visible: false
	}

    ColorOverlay {
        anchors.fill: iconImage
        source: iconImage
        color: "#ffffffff"
    }
    MouseArea {
        id: "iconMouseArea"
		x:0; y:0
		anchors.fill: parent
		onClicked: {
			//console.debug("iconMouseArea clicked");
            iconFrame.clicked();
		}
		Overlay {
			target: parent
			isTargetMouseArea: true
		}
	}

}
