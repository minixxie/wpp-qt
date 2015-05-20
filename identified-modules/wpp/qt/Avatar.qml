import QtQuick 2.1


Rectangle {
	id: avatar
	property alias url: img.source
	property alias fillMode: img.fillMode
	property bool circleMask: true
	property alias bgColor: imgBg.bgColor
	property alias maskColor: circleImageMask.bgColor
    property alias bgText: bgTextElement.text
    property alias bgTextColor: bgTextElement.color
	signal clicked

	ImageBackground {
		id: imgBg
		imgTarget: img
        Text {
            id: "bgTextElement"
            anchors.fill: parent
            text: avatar.bgText
            font.pixelSize: 12*reso.dp2px
            color: "#7f7f7f"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
	}
	Image {
		id: img
		width: avatar.width
		height: avatar.height
		smooth: true
		fillMode: Image.PreserveAspectFit
		MouseArea {
			anchors.fill: parent
			onClicked: avatar.clicked()
			Overlay {
				target: parent
				isTargetMouseArea: true
			}
		}
	}
	CircleImageMask {
		id: circleImageMask
		maskedTarget: img
		bgColor: "#ffffff"
		visible: circleMask
	}

}
