import QtQuick 2.4
import QtQuick.Window 2.2

import wpp.qt 1.0

Rectangle {
	id: fullScreen
	color: "#efeef4"

	TitleBar {
		id: titleBar
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		text: "Camera & ImagePicker"
	}

	Rectangle {
		anchors.top: titleBar.bottom
		anchors.topMargin: 10*reso.dp2px
		anchors.left: parent.left
		anchors.right: parent.right
		height: 200*reso.dp2px
		color: "#ffffff"

		ImageSelector {
			id: imageSelector
			anchors.fill: parent
			maxPick: 1
			onPhotoTaken: { //string imagePath
				console.debug("onPhotoTaken:" + imagePath);
				profilePhoto.url = "file:" + imagePath;
			}
			onPhotoChosen: { //variant imagePaths
				if ( imagePaths.length == 1 )
				{
					var imagePath = imagePaths[0];
					console.debug("onPhotoChosen:" + imagePath);
					profilePhoto.url = "file:" + imagePath;
				}
			}
			onCropFinished: {
			}
			onCropCancelled: {
			}
		}

		Avatar {
			id: profilePhoto
			anchors.centerIn: parent
			height: 100*reso.dp2px
			width: height
			fillMode: Image.PreserveAspectCrop
			bgText: qsTr("Upload Image")
			bgTextColor: "#0080ff"
			//url: "http://xxxxxx/abc.jpg"
			onClicked: {
				imageSelector.visible=true;
			}
		}

	}

}
