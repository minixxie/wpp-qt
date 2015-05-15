import QtQuick 2.1

import "./"

Rectangle {
	id: "avatar"
	property alias url: profilePhotoImage.source
	property bool circleMask: true
	property alias maskColor: circleImageMask.bgColor
	property real radius: (width > height)? height/2 : width/2

	signal clicked

	ImageBackground {
		imgTarget: profilePhotoImage
	}
	Image {
		id: "profilePhotoImage"
		width: avatar.width
		height: avatar.height
		smooth: true
		fillMode: Image.PreserveAspectFit
		MouseArea {
			anchors.fill: parent
			onClicked: avatar.clicked()
		}
	}
	CircleImageMask {
		id: "circleImageMask"
		maskedTarget: profilePhotoImage
		bgColor: "#ffffff"
		visible: circleMask
		radius: avatar.radius
	}

}
