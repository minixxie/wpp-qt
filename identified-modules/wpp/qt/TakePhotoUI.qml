import QtQuick 2.2
import QtMultimedia 5.2
//VideoOutput requires: Android 3.0 (API 11)

Rectangle {
	id: takePhotoUI

	property bool isPreview : false

	signal captured(string requestId)
	signal cropFinished(int id)

	color: "transparent"
	state: "PhotoCapture"

	states: [
		State {
			name: "PhotoCapture"
			StateChangeScript {
				script: {
					camera.captureMode = Camera.CaptureStillImage
					camera.start()
				}
			}
		},
		State {
			name: "PhotoPreview"
		}
	]

	Camera {
		id: camera
		captureMode: Camera.CaptureStillImage
		imageCapture {
			onImageCaptured: {
				photoPreview.source = "";
				photoPreview.source = preview
				console.log("requestIdAAAAA========>" + requestId);
				console.log("previewAAAAA========>" + preview);
				stillControls.previewAvailable = true
				takePhotoUI.isPreview = true
				takePhotoUI.state = "PhotoPreview"
				console.log("requestIdBBBBB========>" + requestId);
				console.log("previewBBBBB========>" + preview);
				//takePhotoUI.captured(requestId);
				photoCaptureController.saveCapture(requestId, 400, 300);
			}
		}
		Component.onCompleted: {
			imageCapture.capture();
		}
	}

    CropImage {
		id : photoPreview
		x: 0
		y: 0
		anchors.fill : parent
		onClosed: {
			takePhotoUI.isPreview = false
			takePhotoUI.state = "PhotoCapture"
		}
		visible: takePhotoUI.state == "PhotoPreview"
		focus: visible
		onCropFinished: {
			takePhotoUI.cropFinished(id);
		}
		onVisibleChanged: {
			console.log("preview-visible:" + visible);
		}
	}

	VideoOutput {
		id: viewfinder
		visible: takePhotoUI.state == "PhotoCapture"

		x: 0
		y: 0
		z: 1

		width: parent.width
		height: parent.height - 50*wpp.dp2px

		source: camera
		autoOrientation: true
	}

	PhotoCaptureControls {
		id: stillControls
		anchors.fill: parent
		camera: camera
		visible: takePhotoUI.state == "PhotoCapture"
		onPreviewSelected: takePhotoUI.state = "PhotoPreview"
		z: 2
		opacity: 0.8
	}
}
