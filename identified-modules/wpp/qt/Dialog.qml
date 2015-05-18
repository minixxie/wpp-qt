import QtQuick 2.1
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3

Rectangle {
	id: "dialog"
	property alias text: textMessage.text
	property Component contentComponent: null
	property string type: "MSG" //MSG, CONFIRM, MSG_TIMER
	property color bgColor: "#ffffff"
    property color borderColor: "#c0c0c0"
	property color textColor: "#333333"
	property color buttonTextColor: "#0080ff"
	property alias contentWidth: contentLoader.width
    property int cfRadius: 5*reso.dp2px
    property int textFontSize: 18*reso.dp2px
	property alias okButtonText: okButton.text
	property alias cancelButtonText: cancelButton.text
	property alias hMarign: contentFrame.x
	property alias rotation: contentFrame.rotation

	property int contentTopMagein: 15*reso.dp2px
	property int contentLeftMagein: 15*reso.dp2px
	property int contentRightMagein: 15*reso.dp2px
	property int contentBottomMagein: 15*reso.dp2px
	property int xAxis: 15*reso.dp2px
	property int seconds: 0
	property bool timerRunning: false


	signal accepted
	signal rejected
	signal disappeared

	parent: fullScreen
	anchors.fill: parent
	color: "transparent"

	onVisibleChanged: {
		if ( visible )
		{
			Qt.inputMethod.hide();
		}
	}

	Rectangle {
		z: parent.z + 1
		anchors.fill: parent
        color: Qt.rgba(0,0,0,0.36)
	}
	MouseArea {//to implement modal
		id: "modalMouseArea"
		anchors.fill: parent
		z: parent.z + 1
	}

	Rectangle {
		id: "contentFrame"
		z: modalMouseArea.z + 1
		x: dialog.xAxis
		y: (parent.height - height)/2
		width: parent.width - 2*x
		//height: buttonPanel.y + buttonPanel.height + 1*reso.dp2px
		height: ( contentComponent == null?
					 textMessage.anchors.topMargin + textMessage.height + textMessage.anchors.bottomMargin:
					 contentLoader.anchors.topMargin + contentLoader.height + contentLoader.anchors.bottomMargin )+
				hLine.height + buttonPanel.height
		color: dialog.bgColor
//        border.width: 1*reso.dp2px > 1 ? 1 : 1*reso.dp2px
//		border.color: dialog.borderColor
        radius: dialog.cfRadius
		//opacity: 0.96

		Text {
			id: "textMessage"
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.topMargin: 15*reso.dp2px
			anchors.leftMargin: 15*reso.dp2px
			anchors.rightMargin: 15*reso.dp2px
			anchors.bottomMargin: 15*reso.dp2px
			//height: 40*reso.dp2px
			wrapMode: Text.WrapAtWordBoundaryOrAnywhere
			clip: true
            font.pixelSize: dialog.textFontSize
			color: dialog.textColor
			//anchors.horizontalCenter: parent.horizontalCenter
			visible: contentComponent == null
		}
		Loader {
			id: "contentLoader"
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.topMargin: dialog.contentTopMagein
			anchors.leftMargin: dialog.contentLeftMagein
			anchors.rightMargin: dialog.contentRightMagein
			anchors.bottomMargin: dialog.contentBottomMagein
			sourceComponent: contentComponent
			visible: contentComponent != null
		}

		Line {
			id: "hLine"
			anchors.bottom: buttonPanel.top
			width: parent.width
			//x1: 0; y1: contentComponent != null? contentLoader.y + contentLoader.height + 20*reso.dp2px: textMessage.y + textMessage.height + 20*reso.dp2px
			//x2: parent.width; y2: y1
            height: 1*reso.dp2px > 1 ? 1 : 1*reso.dp2px
			color: dialog.borderColor
			visible: dialog.seconds > 0 ? false : true
		}

		Rectangle {
			id: "buttonPanel"
			//anchors.top: hLine.bottom
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			//x: 1
			//y: hLine.y + hLine.height
			//width: parent.width - 2*x
			height: dialog.seconds > 0 ? 0 : 40*reso.dp2px
            color: "transparent"
			Button {
				id: "cancelButton"
				width: (parent.width - 2*x)/2 - 1
				height: parent.height
				//text: qsTr("Cancel")
				//textColor: dialog.buttonTextColor
				//textFont.pixelSize: 18*reso.dp2px
				//color: "transparent"
				style: ButtonStyle {
					background: Rectangle {
						color: "transparent"
					}
					label: Text {
						text: qsTr("Cancel")
						color: dialog.buttonTextColor
						font.pixelSize: 18*reso.dp2px
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}
				}

				//effect: "DARKER"
				visible: dialog.type=="CONFIRM"
				onClicked: {
					dialog.rejected();
				}
			}
			Line {
				id: "vLine"
				width: 1
				height: parent.height
				x1:cancelButton.x + cancelButton.width ; y1:0
				x2:x1; y2:parent.height
				visible: dialog.type=="CONFIRM"
				color: dialog.borderColor
			}
			Button {
				id: "okButton"
				x: dialog.type=="MSG"? 0 : vLine.x + vLine.width
				width: dialog.type=="MSG"? parent.width - 2*x: cancelButton.width
				height: parent.height
				//text: qsTr("OK")
				//textColor: dialog.buttonTextColor
				//textFont.pixelSize: 18*reso.dp2px
				//color: "transparent"
				//effect: "DARKER"
				visible: dialog.seconds > 0 ? false : true
				onClicked: {
					dialog.accepted();
				}
				style: ButtonStyle {
					background: Rectangle {
						color: "transparent"
					}
					label: Text {
						text: qsTr("OK")
						color: dialog.buttonTextColor
						font.pixelSize: 18*reso.dp2px
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}
				}
			}

		}
	}

	Timer {
		id: megTimer
		interval: dialog.seconds*1000
		repeat: true
		running: {

			if (dialog.seconds > 0 && dialog.timerRunning === true)
			{
				return true;
			}

			return false;
		}

		onTriggered: {
			dialog.disappeared();
		}
	}


}
