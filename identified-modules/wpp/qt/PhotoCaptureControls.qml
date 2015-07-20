import QtQuick 2.0
import QtMultimedia 5.0

FocusScope {
    property Camera camera
    property bool previewAvailable : false

    property int buttonsPanelHeight: buttonPaneShadow.height

    signal previewSelected
    id : captureControls

    Rectangle {
        id: buttonPaneShadow
        width: parent.width
		height: 50*wpp.dp2px
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        color: Qt.rgba(0.08, 0.08, 0.08, 1)

        Button {
			width: 200*wpp.dp2px
			height: 44*wpp.dp2px
            radius: 2*wpp.dp2px
            text: qsTr("Capture")
			textColor: "#ffffff"
			textFont.pixelSize: 16*wpp.dp2px
			color: "#5dcb36"
			anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            onClicked: camera.imageCapture.capture()
        }

    }


//    ZoomControl {
//        x : 0
//        y : 0
//        width : 100
//        height: parent.height

//        currentZoom: camera.digitalZoom
//        maximumZoom: Math.min(4.0, camera.maximumDigitalZoom)
//        onZoomTo: camera.setDigitalZoom(value)
//    }
}
