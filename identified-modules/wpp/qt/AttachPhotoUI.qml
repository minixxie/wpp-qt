import QtQuick 2.1

Rectangle {
	id: "attachPhotoUI"
	anchors.fill: parent

	property alias model: imageAttachmentList.model
	signal photoTaken(string imagePath)
	signal photoChosen(variant imagePaths)

	GridView {
		id: "imageAttachmentList"
		anchors.margins: 10*reso.dp2px
		anchors.fill: parent
		cellWidth: 80*reso.dp2px
		cellHeight: 80*reso.dp2px
		//orientation: ListView.Horizontal
		header: Rectangle {
			width: 80*reso.dp2px
			height: width
			color: "transparent"
			Rectangle {
				anchors.fill: parent
				anchors.margins: 4*reso.dp2px
				border.width: 2*reso.dp2px
				border.color: "#dddddd"
				color: "transparent"
				Text {
					anchors.fill: parent
					text: qsTr("+\nimage")
					font.pixelSize: 16*reso.dp2px
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					color: "#cccccc"
				}
				MouseArea {
					anchors.fill: parent
					Overlay { target: parent; isTargetMouseArea: true }
					onClicked: {
						selectPhotoSourceModal.visible = true;
					}
				}
			}
		}
		delegate: Rectangle {
			width: 80*reso.dp2px
			height: width
			color: "transparent"
			AnimatedImage {
				anchors.fill: parent
				anchors.margins: 20*reso.dp2px
				width: 45*reso.dp2px
				height: 45*reso.dp2px
				source: "qrc:/img/loading.200x200.gif"
				anchors.centerIn: parent
				visible: {
					return image.source == ""
				}
			}
			Image {
				anchors.fill: parent
				anchors.margins: 4*reso.dp2px
				fillMode: Image.PreserveAspectCrop
				cache: false
				source: {
					if (modelData != "") {
						var s = "file://" + modelData;
						//console.debug("microblog-attach:"+s);
						return s;
					} else {
						return ""
					}
				}
			}
		}
	}
	SelectPhotoSourceModal {
		id: "selectPhotoSourceModal"
		anchors.fill: parent
		onPhotoTaken: { //string imagePath
			attachPhotoUI.photoTaken(imagePath);
		}
		onPhotoChosen: { //variant imagePaths
			//console.debug("(AttachPhotoUI)onPhotoChosen...");
			attachPhotoUI.photoChosen(imagePaths);
		}
		onCropFinished: {
			//pageStack.pop();
		}
		onCropCancelled: {
			//pageStack.pop();
		}
	}

}
