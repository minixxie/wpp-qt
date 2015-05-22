import QtQuick 2.1
import QtQuick.Window 2.2

Rectangle {
	id: titleBar
	property alias text: label.text
	property alias label: label
	property bool loading: false
	property string loadingType: "BAR" //ROLLING, BAR
	property bool hasPhoneTop: Qt.platform.os == "ios" //sys.isIOS()
	property bool centerTitle: true

	//property alias leftIcon: leftIconLoader.sourceComponent
	property Component leftComponent
	property Component rightComponent

	height: phoneTopBar.height + label.height + networkCondition.height
	//{ var h = phoneTopBar.height + label.height + networkCondition.height;
	//	console.debug("phoneTopBar-height=" + phoneTopBar.height);
	//	console.debug("label-height=" + label.height);
	//	console.debug("networkCondition-height=" + networkCondition.height);
	//	console.debug("titlebar-height=" + h);
	//	return h;
	//}
	width: parent.width
	color: "#f7f7f7" //"#2a8827" //#94c849" // "#2a8827"
	clip: true

	Rectangle {
		id: "phoneTopBar"
		height: parent.hasPhoneTop? 20*reso.dp2px : 0
		//{ var h = parent.hasPhoneTop? 20*reso.dp2px : 0 ; console.debug("hasTop=" + h); return h; }
	}

	Rectangle {
		id: "leftComponentRectangle"
		x: 0
		y: phoneTopBar.y + phoneTopBar.height
		z: parent.z+1
		height: label.height
		width: height
		color: "transparent"
		Loader {
			id: "leftComponentLoader"
			x: (parent.width - width)/2
			y: (parent.height - height)/2
			z: parent.z+1
			sourceComponent: titleBar.leftComponent
			onZChanged: {
				//console.debug("leftComponentLoader.z=" + z);
			}
			onLoaded: {
				//console.debug("Loaded,z=" + z);
				item.z = z+1;
				//console.debug("Loaded,item.z=" + item.z);
			}
		}
	}
	Rectangle {
		id: "labelBox"
		width: parent.width - 2*height
		height: 44*reso.dp2px
		clip: true
		color: "transparent"
		x: height
		y: phoneTopBar.y + phoneTopBar.height
		z: parent.z+1

		Text {
			id: "label"
			height: parent.height
			//width: parent.width - 2*height
			anchors.centerIn: width > parent.width || !titleBar.centerTitle ? undefined : parent
			anchors.left: width > parent.width ? parent.left : undefined

			text: ""
			color: "#000000" // "#ffffff"
			font.bold: true
			font.pixelSize: 16*reso.dp2px
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter

		}
		AnimatedImage {
			anchors.left: label.right
			anchors.leftMargin: 10*reso.dp2px
			anchors.verticalCenter: label.verticalCenter
			width: 24*reso.dp2px
			height: 24*reso.dp2px
			source: "qrc:/img/loading.200x200.gif"
			visible: loadingType == "ROLLING" && loading
		}
	}
	Rectangle {
		id: "rightComponentRectangle"
		x: parent.width - width
		y: phoneTopBar.y + phoneTopBar.height
		z: parent.z+1
		height: label.height
		width: height
		color: "transparent"
		Loader {
			id: "rightComponentLoader"
			x: (parent.width - width)/2
			y: (parent.height - height)/2
			z: parent.z+1
			sourceComponent: titleBar.rightComponent
			onLoaded: {
				item.z = z+1;
			}
		}
	}

	Rectangle {
		id: underline
		height: 1*reso.dp2px
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		color: "#b2b2b2"
	}

	Rectangle {
		id: "loadingIndicator"
		color: "#fc8215"
		height: 2*reso.dp2px
		width:100*reso.dp2px
		x: 0
		y: parent.height - height
		visible: loadingType == "BAR" && loading
		SequentialAnimation on x {
			id: "loadingAnimation"
			running: loading
			loops: Animation.Infinite // The animation is set to loop indefinitely
			NumberAnimation { from: -loadingIndicator.width; to: 320*reso.dp2px; duration: 1000; easing.type: Easing.InOutQuad }
			//PauseAnimation { duration: 250 } // This puts a bit of time between the loop
		}
	}
	Rectangle {
		id: "networkCondition"
		width: parent.width
		height: !sys.hasNetwork ? 20*reso.dp2px : 0
		color: "#ffffbf"
		//y: label.y + label.height
		//x: phoneTopBar.y + phoneTopBar.height
		anchors.bottom: parent.bottom
		visible: !sys.hasNetwork
		Text {
			id: "networkConditionText"
			anchors.fill: parent
			font.pixelSize: 12*reso.dp2px
			color: "#ff0000"
			text: !sys.hasNetwork ? qsTr("Network Error, please check your Network Setting.") : ""
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter

		}
	}

	/*function onNetworkConfigurationOnlineStateChanged(isOnline)
	{
		//console.debug("onNetworkConfigurationOnlineStateChanged...");
		if ( isOnline )
		{
			sys.hasNetwork = true;
		}
		else
		{
			hasNetwork = false;
		}
	}*/

	/*Component.onCompleted: {
		//console.debug("TitleBar onCompleted");
		networkConfigurationManager.onlineStateChanged.connect(titleBar.onNetworkConfigurationOnlineStateChanged);
	}*/
}
