import QtQuick 2.1

Rectangle {
	id: "atUserTab"
	anchors.fill: parent

	property alias model: gridView.model
	property bool modelReady: true
	signal selected(string userId, string nickname)

	Text {
		id: "loadingText"
		text: qsTr("Loading...")
		anchors.centerIn: parent
		color: "#7f7f7f"
		font.pixelSize: 16*reso.dp2px
		visible: !atUserTab.modelReady
	}
	GridView {
		id: "gridView"
		anchors.fill: parent
		clip: true
		cellWidth: 80*reso.dp2px
		cellHeight: 105*reso.dp2px
		delegate: Rectangle {
			width: 80*reso.dp2px
			height: 95*reso.dp2px //atUserTab.height
			color: "transparent"
			Avatar {
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.topMargin: 10*reso.dp2px
				anchors.leftMargin: 15*reso.dp2px
				anchors.rightMargin: 15*reso.dp2px
				width: 50*reso.dp2px
				height: 50*reso.dp2px
				url: modelData.profilePhotoUrl
			}
			Text {
				text: modelData.nickname
				height: 24*reso.dp2px
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				anchors.margins: 10*reso.dp2px
				anchors.topMargin: 5*reso.dp2px
				font.pixelSize: 12*reso.dp2px
				clip: true
				color: "#2a8827"
				horizontalAlignment: contentWidth > width ? Text.AlignLeft : Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				wrapMode:Text.NoWrap
			}
			MouseArea {
				anchors.fill: parent
				Overlay { target: parent; isTargetMouseArea: true }
				onClicked: {
					atUserTab.selected(modelData.userId, modelData.nickname);
				}
			}
		}
	}


}
