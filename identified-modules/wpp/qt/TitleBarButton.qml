import QtQuick 2.1

Rectangle {
	id: "titleBarButton"

	property string iconType: "DARK"
	property alias text: buttonLabel.text
    property alias rightIconSource: rightIcon.source
	signal clicked


	color: "transparent"

	height: 44*wpp.dp2px
	width: height

	Rectangle {
		width: 40*wpp.dp2px
		height: 28*wpp.dp2px
		anchors.verticalCenter: parent.verticalCenter
		anchors.left: parent.left
		color: Qt.rgba(0,0,0,0.1)
		border.color: Qt.rgba(0,0,0,0.2)
		border.width: 1
		radius: 2*wpp.dp2px
		Text {
			id: "buttonLabel"
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.right: rightIcon.source != "" ? rightIcon.left : parent.right
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			color: titleBarButton.iconType == "DARK"?"#ffffff":"#333333"
			font.pixelSize: 12*wpp.dp2px
		}
        Image {
            id: "rightIcon"
            source: ""
            height: 18*wpp.dp2px
            width: height
            //source: "qrc:/img/android-icons/All_Icons/holo_dark/mdpi/1-navigation-accept.png"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
		MouseArea {
			id: "mouseArea"
			x:0; y:0
			anchors.fill: parent
			onClicked: {
				titleBarButton.clicked();
			}
			Overlay {
				target: parent
				isTargetMouseArea: true
			}
		}

	}


}
