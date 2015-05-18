import QtQuick 2.1

Rectangle {
	id: "fullScreen"
	property alias source: pageLoader.source
	property bool toCheckForUpdate: true

	anchors.fill: parent

	Dialog {
		id: confirmDialog
		visible: false
		text: qsTr("Are you sure to quit?")
		type: "CONFIRM"
		onAccepted: {
			Qt.quit();
		}
		onRejected: {
			visible = false;
		}
	}
	focus: true
	Keys.onReleased: {
		if (event.key == Qt.Key_Back)
		{
			//console.debug("Android BACK button!");
			confirmDialog.visible = true;
			event.accepted = true;//prevent from quit
		}
	}

	MouseArea {
		anchors.fill: parent
		preventStealing: true
		propagateComposedEvents: true
		onClicked: {
			Qt.inputMethod.hide();
			//console.debug("hide soft keyboard");
		}
	}

	Loader {
		id: pageLoader
		anchors.fill: parent
		//source: { //console.debug("qml:" + mainController.qmlFile); return mainController.qmlFile; }
		//source: "qtAppBase/HSlides.qml" //mainController.qmlFile
	}

	/*Flickable {
		id: "logFlickable"
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		height: 100*reso.dp2px
		contentWidth: logFlickable.width
		contentHeight: logRec.height
		visible: false
		Rectangle {
			id: "logRec"
			width: logFlickable.width
			color: Qt.rgba(1,1,1,0.3)
			height: logText.height > 100*reso.dp2px ? logText.height : 100*reso.dp2px
			Text {
				id: "logText"
				width: parent.width
				text: mainController != undefined ? mainController.log : ""
				font.pixelSize: 10*reso.dp2px
				color: "#7f7f7f"
			}
		}
	}
	MouseArea {
		anchors.fill: logFlickable
		propagateComposedEvents: true
	}*/

	/*MouseArea {
		anchors.fill: parent
		propagateComposedEvents: true
		onClicked: {
			Qt.inputMethod.hide();
			//console.debug("hide soft keyboard");
		}
	}*/

	function onHasNetworkChanged()
	{
		if ( sys != undefined && sys.hasNetwork && fullScreen.toCheckForUpdate )
		{
			mainController.checkForUpdates();
		}
		else
		{
			//console.debug("NO update check: toCheckForUpdate=" + toCheckForUpdate);
			mainController.updateCheckFinished(false);//emit
		}
	}

	Component.onCompleted: {
		mainController.checkForUpdates();
		sys.hasNetworkChanged.connect( onHasNetworkChanged );
	}

	function goToDownloadPage()
	{
		mainController.qmlFile = "../../wpp/DownloadUpdateUI.qml";
		mainController.downloadAndroidAPK();
	}

	Dialog {
		text: qsTr("New version found, download and update?") +
			  "\n" +
			  "\n"+qsTr("Latest: ") + mainController.newVerCode +
			  "\n"+qsTr("Current: ") + mainController.verCode +
			  "\n" +
			  "\n" + qsTr("Please do this under WIFI network")
		type: "CONFIRM"
		onAccepted: {
			//console.debug("OK");
			visible = false;
			mainController.verCode = "";
			mainController.newVerCode = "";
			if ( sys.isIOS() )
			{
				mainController.linkToAppleStore();
			}
			else if ( sys.isAndroid() )
			{
				fullScreen.goToDownloadPage();
			}
			else
			{
				fullScreen.goToDownloadPage();
			}
		}
		onRejected: {
			//console.debug("Cancel...");
			mainController.verCode = "";
			mainController.newVerCode = "";
			mainController.showUpdateDialog = false;
			mainController.updateCheckFinished(false);
		}
		visible: mainController != undefined ? mainController.showUpdateDialog : false
			/*if ( mainController != undefined )
				return (sys.isAndroid() || sys.isIOS()) && mainController.verCode != mainController.newVerCode;
			else
				return false;
		}*/
	}
}
