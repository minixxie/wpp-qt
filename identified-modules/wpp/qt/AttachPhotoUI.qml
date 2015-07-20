import QtQuick 2.1

Rectangle {
	id: attachPhotoUI
	anchors.fill: parent

	property alias model: imageAttachmentList.mode
	signal photoTaken(string imagePath)
	signal photoChosen(variant imagePaths)

	GridView {
		id: imageAttachmentList
		anchors.margins: 10*wpp.dp2px
		anchors.fill: parent
		cellWidth: width/4 //(parent.width - 2*imageAttachmentList.anchors.margins)/4
		cellHeight: cellWidth
		//orientation: ListView.Horizontal
		header: Rectangle {
			width: imageAttachmentList.cellWidth
			height: imageAttachmentList.cellHeight
			color: "transparent"
			Rectangle {
				anchors.fill: parent
				anchors.margins: 4*wpp.dp2px
				border.width: 2*wpp.dp2px
				border.color: "#dddddd"
				color: "transparent"
				Text {
					anchors.fill: parent
					text: qsTr("+\nimage")
					font.pixelSize: 16*wpp.dp2px
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
			width: imageAttachmentList.cellWidth
			height: imageAttachmentList.cellHeight
			color: "transparent"
			AnimatedImage {
				//anchors.fill: parent
				//anchors.margins: 20*wpp.dp2px
				width: 45*wpp.dp2px
				height: 45*wpp.dp2px
				source: "qrc:/img/loading.200x200.gif"
				anchors.centerIn: parent
				visible: {
					//return image.source == ""
					return !modelData.isDone;
				}
			}
			Image {
				anchors.fill: parent
				anchors.margins: 4*wpp.dp2px
				fillMode: Image.PreserveAspectCrop
				cache: false
				source: {
					console.debug("AttachPhotoUI:image=" + modelData.path);
					return modelData.isDone? "file://" + modelData.path : "";
					/*if (modelData != "") {
						var s = "file://" + modelData.path;
						//console.debug("microblog-attach:"+s);
						return s;
					} else {
						return ""
					}*/
				}
			}
		}
	}
	ImageSelector {
		id: selectPhotoSourceModal
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
