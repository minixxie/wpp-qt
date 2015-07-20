import QtQuick 2.1

Rectangle {
	id: smileysUI
	anchors.fill: parent
	//color: "red"
	property alias smileyListModel: repeater.model
	signal smileyClicked(string escapedText, string imageSource)

	Flow {
		id: grid
		property int rowCount: Math.ceil( repeater.model.count / colCount )
		property int colCount: 5
		anchors.margins: 10*wpp.dp2px
		anchors.fill: parent
		Repeater {
			id: repeater
			Rectangle {
				//color: c
				width: grid.width / grid.colCount
				height: grid.height / grid.rowCount
				property var listItem: model.modelData? model.modelData: model

				Image {
					anchors.centerIn: parent
					source: listItem.imageFile
					width:32*wpp.dp2px
					height:32*wpp.dp2px
					smooth: true
					fillMode: Image.PreserveAspectFit
				}
				MouseArea {
					anchors.fill: parent
					Overlay { target: parent; isTargetMouseArea: true }
					onClicked: {
						//console.debug("smiley clicked");
						smileysUI.smileyClicked(listItem.escapedText, listItem.imageFile);
					}
				}
			}
		}
		/*Component.onCompleted: {
			//console.debug("smileysList.count: " + smileysList.count);
			//console.debug("Flow colCount:" + colCount);
			//console.debug("Flow rowCount:" + rowCount);
		}*/
	}

	/*GridView {
		id: grid
		property int colCount: 5

		anchors.fill: parent
		model: smileysList
		cellWidth: width/colCount
		cellHeight: 50*wpp.dp2px
		anchors.margins: 10*wpp.dp2px

		delegate: Rectangle {
			color: c
			width: grid.cellWidth
			height: grid.cellHeight

			Image {
				anchors.centerIn: parent
				source: src
				width:32*wpp.dp2px
				height:32*wpp.dp2px
			}
		}
	}*/
}
