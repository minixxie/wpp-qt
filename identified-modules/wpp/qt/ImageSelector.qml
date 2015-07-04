import QtQuick 2.1

import wpp.qt.NativeCamera 1.0
import wpp.qt.ImagePicker 1.0

SelectionListModal {
	id: selectionListModal

	property string selectedPhotoPath: ""
	property int selectedPhotoRotation: 0
	property alias maxPick: nativeImagePicker.maxPick

	signal photoTaken(string imagePath)
	signal photoChosen(variant imagePaths)
	signal cropFinished
	signal cropCancelled

	signal needQMLCamera  //pageStack.push(takePhotoUI);
	signal needQMLAlbumBrowser

	onVisibleChanged: {
		if ( visible )
		{
			Qt.inputMethod.hide();
		}
	}

	LoadingModal {
		id: loadingModal
		anchors.fill: parent
		visible: false
	}

	Component {
		id : cropImageUI
		CropImage {
			id: cropImageUIObject
			//anchors.fill : parent
			source: selectionListModal.selectedPhotoPath
			rotation: selectionListModal.selectedPhotoRotation
			onCropFinished: {
				selectionListModal.cropFinished();
				//pageStack.pop();//cropImageUI
				//pageStack.pop();//localAlbumBrowseUI
			}
			onClosed: {
				selectionListModal.cropCancelled();
				//pageStack.pop();
			}
		}
	}
	NativeCamera {
		id: nativeCamera
		onImagePathChanged: {
			//var absPath = imagePath.replace(/^file:\/\//, '' );
			//absPath = absPath.replace(/^file:/, '');
			var absPath = imagePath;

			selectionListModal.photoTaken(absPath);
			//createClubUIController.imagePathBeforeCrop = absPath;
			//createClubUI.readyToCrop(absPath);
			loadingModal.visible = false;
		}
	}
	ImagePicker {
		id: nativeImagePicker
		/*onImagePathChanged: {
			//var absPath = imagePath.replace(/^file:\/\//, '' );
			//absPath = absPath.replace(/^file:/, '');
			var absPath = imagePath;

			selectionListModal.photoChosen(absPath);
			//createClubUIController.imagePathBeforeCrop = absPath;
			//createClubUI.readyToCrop(absPath);
		}*/
		onStartedImageProcessing: {
			//console.debug("onStartedImageProcessing...");
			loadingModal.visible = true;
		}
		onAccepted: {//paths
			//console.debug("onAccepted...");
			for ( var i = 0 ; i < paths.length ; i++ )
			{
				//console.debug("i=" + i + ":path=" + paths[i] );
			}
			selectionListModal.photoChosen(paths);
			loadingModal.visible = false;
		}
	}
	anchors.fill: parent
	visible: false
	itemHeight: 45*reso.dp2px
	font.pixelSize: 18*reso.dp2px
	//listHeight: itemHeight*uploadProfilePhotoChoiceModel.count
	property var uploadProfilePhotoChoiceModel: [
		{ key: "TAKE_PHOTO", value: qsTr("Take a photo") },
		{ key: "BROWSE", value: qsTr("Pick a photo from album") }
	]
	model: uploadProfilePhotoChoiceModel
	onSelected: {
		//console.debug("selection list selected:" + selectedItem.key + "=>" + selectedItem.value);
		if ( selectedItem.key == "TAKE_PHOTO" )
		{
            visible = false;
			if ( sys.isDesktop() )
			{
				selectionListModal.needQMLCamera();
			}
			//else if ( sys.isIOS() )
			else //android, ios
			{
				nativeCamera.open();
				//loadingModal.visible = true;
			}
		}
		else//BROWSE
		{
            visible = false;
			if ( sys.isDesktop() )
			{
				selectionListModal.needQMLAlbumBrowser();
			}
			//else if ( sys.isIOS() )
			else //android, ios
			{
				nativeImagePicker.open();//android,ios
				//loadingModal.visible = true;
			}
		}
	}
}
