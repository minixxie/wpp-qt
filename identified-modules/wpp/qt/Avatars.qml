import QtQuick 2.1


Rectangle {
	id: avatar
	property var urls: []
	property bool circleMask: true
	property alias maskColor: circleImageMask.bgColor
    property alias bgText: bgTextElement.text
    property alias bgTextColor: bgTextElement.color
	signal clicked

	ImageBackground {
		imgTarget: profilePhotoImage
        Text {
            id: bgTextElement
            anchors.fill: parent
            text: avatar.bgText
            font.pixelSize: 12*wpp.dp2px
            color: "#7f7f7f"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
	}
	Column {
		id: column
		Row {
			Image {
				id: image1
				width: avatar.width/2
				height: avatar.height/2
				smooth: true
				fillMode: Image.PreserveAspectFit
				source: {
					if ( avatar.urls.length >= 1 )
						return avatar.urls[0];
					else
						return "";
				}
				visible: source != "";
			}
			Image {
				id: image2
				width: avatar.width/2
				height: avatar.height/2
				smooth: true
				fillMode: Image.PreserveAspectFit
				source: {
					if ( avatar.urls.length >= 2 )
						return avatar.urls[1];
					else
						return "";
				}
				visible: source != "";
			}
		}
		Row {
			Image {
				id: image3
				width: avatar.width/2
				height: avatar.height/2
				smooth: true
				fillMode: Image.PreserveAspectFit
				source: {
					if ( avatar.urls.length >= 3 )
						return avatar.urls[2];
					else
						return "";
				}
				visible: source != "";
			}
			Image {
				id: image4
				width: avatar.width/2
				height: avatar.height/2
				smooth: true
				fillMode: Image.PreserveAspectFit
				source: {
					if ( avatar.urls.length >= 4 )
						return avatar.urls[3];
					else
						return "";
				}
				visible: source != "";
			}
		}
	}//Column

	MouseArea {
		anchors.fill: parent
		onClicked: avatar.clicked()
		Overlay {
			target: parent
			isTargetMouseArea: true
		}
	}
	CircleImageMask {
		id: circleImageMask
		maskedTarget: column
		bgColor: "#ffffff"
		visible: circleMask
	}

}
