import QtQuick 2.1
import QtGraphicalEffects 1.0

Rectangle {
    id: "localAlbumBrowse"

    property alias isFolderPage: galleryListGridView.visible
    property string action: "NONE" // NONE, PICK_ONE, PICK_MANY
    signal selected

    Rectangle {
        id: "navigationBar"
        height: 24*wpp.dp2px
        Text {
            id: "localGalleriesText"
            text: qsTr("Local Galleries")
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 5*wpp.dp2px
            font.pixelSize: 12*wpp.dp2px
            color: "#0080ff"
            MouseArea {
                anchors.fill: parent
                Overlay {
                    target: parent
                    isTargetMouseArea: true
                }
                onClicked: {
                    localAlbumBrowse.backToFolderList();
                }
            }
        }
        Text {
            id: "photoListAlbumNameText"
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            text: ""
            anchors.top: parent.top
            anchors.left: localGalleriesText.right
            font.pixelSize: 12*wpp.dp2px
        }
    }

    GridView {
        id: "galleryListGridView"
        clip: true
        anchors.top: navigationBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        cellWidth: parent.width/2
        cellHeight: cellWidth
        model: gallery.folders
        delegate: Rectangle {
            width: galleryListGridView.cellWidth
            height: galleryListGridView.cellHeight
            Rectangle {
                id: "folderThumbnailImage"
                anchors.fill: parent
                anchors.margins: 2*wpp.dp2px
                border.width: 1
                border.color: "#aaaaaa"
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 1
                    ImageBackground {
                        imgTarget: folderCoverImage
                    }
                    Image {
                        id: "folderCoverImage"
                        anchors.fill: parent
                        source: "file://" + modelData.photos[0].absolutePath
                        asynchronous: true
                        fillMode: Image.PreserveAspectCrop
                    }
                }
            }
            Rectangle {
                anchors.bottom: folderThumbnailImage.bottom
                anchors.left: folderThumbnailImage.left
                anchors.right: folderThumbnailImage.right
                height:20*wpp.dp2px
                color: Qt.rgba(0,0,0,0.6)
                Image {
                    id: "folderIcon"
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: 5*wpp.dp2px
                    anchors.topMargin: 2*wpp.dp2px
                    anchors.bottomMargin: 2*wpp.dp2px
                    height: 16*wpp.dp2px
                    width: height
                    source: "qrc:/img/android-icons/All_Icons/holo_dark/mdpi/4-collections-collection.png"
                    fillMode: Image.PreserveAspectFit
                }
                Text {
                    id: "folderNameText"
                    anchors.top: parent.top
                    anchors.left: folderIcon.right
                    anchors.bottom: parent.bottom
                    anchors.right: folderPhotoCountText.left
                    anchors.leftMargin: 5*wpp.dp2px
                    anchors.rightMargin: 5*wpp.dp2px
                    verticalAlignment: Text.AlignVCenter
                    text: modelData.name
                    font.pixelSize: 12*wpp.dp2px
                    clip: true
                    color: "#ffffff"
                }
                Text {
                    id: "folderPhotoCountText"
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: 5*wpp.dp2px
                    anchors.bottom: parent.bottom
                    verticalAlignment: Text.AlignVCenter
                    text: modelData.photos.length
                    font.pixelSize: 12*wpp.dp2px
                    clip: true
                    color: "#ffffff"
                }
            }
            MouseArea {
                anchors.fill: parent
                Overlay {
                    target: parent
                    isTargetMouseArea: true
                }
                onClicked: {
                    localAlbumBrowse.currentFolder = modelData;
                    photoListGridView.model = modelData.photos;
                    photoListAlbumNameText.text = " > " + folderNameText.text + " (" + folderPhotoCountText.text + ")"
                    photoListGridView.visible = true;
                    galleryListGridView.visible = false;
                }
            }
        }
    }

    property var currentFolder
    GridView {
        id: "photoListGridView"
        visible: false
        clip: true
        anchors.top: navigationBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        cellWidth: parseInt(parent.width/3)
        cellHeight: cellWidth
        delegate: Rectangle {
            width: photoListGridView.cellWidth
            height: photoListGridView.cellHeight
            border.width: 1
            border.color: "#ffffff"
            clip: true
            ImageBackground {
                imgTarget: photoImage
            }
            Image {
                id: "photoImage"
                anchors.fill: parent
                anchors.margins: 1
                source: "file://" + modelData.absolutePath
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                transform: Rotation { origin.x: 50*wpp.dp2px; origin.y: 50*wpp.dp2px; axis { x: 0; y: 0; z: 1 } angle: modelData.orientation }
                clip: true
            }

                Image {
                    id: "photoTickIcon"
                    anchors.fill: parent
                    visible: modelData.isSelected
                    source: "qrc:/img/android-icons/All_Icons/holo_dark/xhdpi/1-navigation-accept.png"
                }
                ColorOverlay {
                    anchors.fill: photoTickIcon
                    source: photoTickIcon
                    color: "#cc0080ff"
                    visible: photoTickIcon.visible
                }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if ( localAlbumBrowse.action == "PICK_ONE" || localAlbumBrowse.action == "PICK_MANY" )
                    {
                        if ( localAlbumBrowse.action == "PICK_ONE" )
                        {
                            currentFolder.clearAllPhotoSelected();
                        }
                        modelData.isSelected = !modelData.isSelected;
                        localAlbumBrowse.selected();
                    }
                }
            }

            /*Text {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                height: 20*wpp.dp2px
                text: modelData.orientation
                font.pixelSize: 12*wpp.dp2px
            }
            Component.onCompleted: {
				//console.debug("photo:" + modelData.absolutePath + ":" + modelData.orientation);
            }*/
        }
    }

    Component.onCompleted: {
		//gallery.fetchAll();
		gallery.asyncFetchAll();
    }

    function backToFolderList()
    {
        photoListAlbumNameText.text = "";
        photoListGridView.visible = false;
        galleryListGridView.visible = true;
    }
}
