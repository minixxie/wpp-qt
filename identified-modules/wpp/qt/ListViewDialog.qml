import QtQuick 2.1

Item {
	id: "listViewDialog"

	property variant model
	property variant currentItem
	property int currentIndex: 0
	property color bgColor: "transparent"
	property alias type: popup.type
	property string sentence: ""
	property string translateContext: ""
	property bool loading: false

	signal accepted
	signal rejected

	visible: false

	WppDialog {
		id: "popup"
		bgColor: listViewDialog.bgColor
		contentComponent: Component {
			Rectangle {
				width: popup.contentWidth
				height: 300*reso.dp2px
				color: listViewDialog.bgColor
				Text {
					id: "sentenceText"
					anchors.top: parent.top
					anchors.left: parent.left
					anchors.right: parent.right
					text: listViewDialog.sentence
					visible: text != ""
				}
				ListView {
					id: "listView"
					anchors.topMargin: sentenceText.visible? 10*reso.dp2px: 0
					anchors.top: sentenceText.bottom
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.bottom: parent.bottom
					model: listViewDialog.model
					//y: dialogTitleSeparator.y + dialogTitleSeparator.height
					//width: popup.contentWidth
					//height: 280*reso.dp2px
					clip: true
					delegate: Rectangle {
						id: "listViewItem"
						width: popup.contentWidth
						height: 30*reso.dp2px
						color: model.index == listViewDialog.currentIndex ? Qt.rgba(0,0.796,0,0.3) : "transparent"
						// cross operability with ListModel and plain JS object list
						property var listItem: model.modelData? model.modelData: model
						Text {
							anchors.fill: parent
							verticalAlignment: Text.AlignVCenter
							anchors.leftMargin: 10*reso.dp2px
							anchors.rightMargin: anchors.leftMargin
							text: listItem.value
						}
						Rectangle {
							y: parent.height - 1
							width: parent.width
							height: 1
							color: Qt.rgba(1,1,1,0.5)
						}
						MouseArea {
							anchors.fill: parent
							onClicked: {
								listViewDialog.currentIndex = model.index;
								if( !model.modelData )
								{
									listViewDialog.currentItem = listViewDialog.model.get( listViewDialog.currentIndex );
								}
								else
								{
									listViewDialog.currentItem = listViewDialog.model[listViewDialog.currentIndex];
								}
							}
						}
					}
				}
				Text {
					id: "loadingText"
					anchors.centerIn: parent
					text: listViewDialog.loading ? qsTr("Loading...") : ""
					visible: text != ""
				}

			}//Rectangle
		}//contentComponent
		type: "CONFIRM"
		//bgColor: Qt.rgba(1,1,1,0.5)
		onAccepted: {
			listViewDialog.visible = false;
			listViewDialog.accepted();
		}
		onRejected: {
			listViewDialog.visible = false;
			listViewDialog.rejected();
		}
		visible: listViewDialog.visible
	}//Dialog
}//Item
