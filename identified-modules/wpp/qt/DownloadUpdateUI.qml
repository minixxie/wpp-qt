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
		anchors.topMargin:120*wpp.dp2px
		anchors.left: parent.left
		anchors.right: parent.right
		text: qsTr("Download Updates")
		color: "#ffffff"
		font.pixelSize: 18*wpp.dp2px
		height: 40*wpp.dp2px
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}
	Rectangle {
		id: "progressBar"
		anchors.top: label.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.margins: 30*wpp.dp2px
		height: 16*wpp.dp2px
		Rectangle {
			anchors.top: parent.top
			anchors.margins:2*wpp.dp2px
			anchors.left: parent.left
			height: 12*wpp.dp2px
			width: (downloadUpdateUI.percentage)*(parent.width - 2*2*wpp.dp2px)
			color: downloadUpdateUI.baseColor
		}
	}
	Text {
		id: "percentageProgress"
		anchors.top: progressBar.bottom
		anchors.margins:10*wpp.dp2px
		anchors.left: parent.left
		anchors.right: parent.right
		text: parseInt(downloadUpdateUI.percentage*100) + "%"
		color: "#ffffff"
		font.pixelSize: 14*wpp.dp2px
		height: 24*wpp.dp2px
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}

	Rectangle {
		id: "installButton"
		anchors.margins: 30*wpp.dp2px
		anchors.top: percentageProgress.bottom
		anchors.topMargin: 50*wpp.dp2px
		anchors.left: parent.left
		anchors.right: parent.right
		width: parent.width - 35*wpp.dp2px + 4*wpp.dp2px
		height: 45*wpp.dp2px + 4*wpp.dp2px
		color: "#ffffff"
		radius:3*wpp.dp2px
		visible: false
		Rectangle {
			anchors.fill: parent
			anchors.margins: 2*wpp.dp2px
			//color: downloadUpdateUI.baseColor
			color: "#0080ff"
			radius:3*wpp.dp2px
			Text {
				anchors.fill: parent
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				text: qsTr("Install Update")
				color: "#ffffff"
				font.pixelSize: 18*wpp.dp2px
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
		font.pixelSize: 12*wpp.dp2px
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
