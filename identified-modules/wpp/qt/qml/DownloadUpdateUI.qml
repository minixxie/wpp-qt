import QtQuick 2.1

import "./"

Rectangle {
	id: "downloadUpdateUI"

	property double percentage: 0
	property color baseColor: "#2a8827"

	width: parent.width
    height: parent.height

	color: downloadUpdateUI.baseColor

	Text {
		id: "label"
		anchors.top: parent.top
		anchors.topMargin:120*reso.dp2px
		anchors.left: parent.left
		anchors.right: parent.right
		text: qsTr("Download Updates")
		color: "#ffffff"
		font.pixelSize: 18*reso.dp2px
		height: 40*reso.dp2px
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}
	Rectangle {
		id: "progressBar"
		anchors.top: label.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.margins: 30*reso.dp2px
		height: 16*reso.dp2px
		Rectangle {
			anchors.top: parent.top
			anchors.margins:2*reso.dp2px
			anchors.left: parent.left
			height: 12*reso.dp2px
			width: (downloadUpdateUI.percentage)*(parent.width - 2*2*reso.dp2px)
			color: downloadUpdateUI.baseColor
		}
	}
	Text {
		id: "percentageProgress"
		anchors.top: progressBar.bottom
		anchors.margins:10*reso.dp2px
		anchors.left: parent.left
		anchors.right: parent.right
		text: parseInt(downloadUpdateUI.percentage*100) + "%"
		color: "#ffffff"
		font.pixelSize: 14*reso.dp2px
		height: 24*reso.dp2px
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}

	Rectangle {
		id: "installButton"
		anchors.margins: 30*reso.dp2px
		anchors.top: percentageProgress.bottom
		anchors.topMargin: 50*reso.dp2px
		anchors.left: parent.left
		anchors.right: parent.right
		width: parent.width - 35*reso.dp2px + 4*reso.dp2px
		height: 45*reso.dp2px + 4*reso.dp2px
		color: "#ffffff"
		radius:3*reso.dp2px
		visible: false
		Rectangle {
			anchors.fill: parent
			anchors.margins: 2*reso.dp2px
			//color: downloadUpdateUI.baseColor
			color: "#0080ff"
			radius:3*reso.dp2px
			Text {
				anchors.fill: parent
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				text: qsTr("Install Update")
				color: "#ffffff"
				font.pixelSize: 18*reso.dp2px
			}
			MouseArea {
				anchors.fill: parent
				Overlay { target: parent; isTargetMouseArea: true; }
				onClicked: {
					//console.debug("install update!");
					mainController.installNewAndroidAPK();
				}
			}
		}

	}
	Text {
		color: "#ffffff"
		anchors.top: installButton.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		text: mainController.md5sum
		font.pixelSize: 12*reso.dp2px
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}

	function updateProgressBar(bytesReceived, bytesTotal)
	{
		downloadUpdateUI.percentage = parseFloat(bytesReceived)/parseFloat(bytesTotal);
		//console.debug("updateProgressBar:" + downloadUpdateUI.percentage);
	}
	function onUpdateDownloadFinished(successful)
	{
		downloadUpdateUI.percentage = 1.0;
		//console.debug("100%");
		installButton.visible = true;
	}

	Component.onCompleted: {
		mainController.apkDownloadProgress.connect(updateProgressBar);
		mainController.updateDownloadFinished.connect(onUpdateDownloadFinished);
	}
}
