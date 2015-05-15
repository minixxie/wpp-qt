import QtQuick 2.1

ListView {
	id: "listView"

	property color selectedColor: Qt.rgba(0,0.796,0,0.3)
	property color separatorColor: Qt.rgba(0,0,0,0.3)
	property color textColor: "#7f7f7f"
	property real itemHeight: 30*reso.dp2px
	property font font: { size:12*reso.dp2px }
	signal selected(int selectedIndex, variant selectedItem)

	property int currentIndex: 0
	property variant currentItem

	clip: true
	delegate: Rectangle {
		id: "listViewItem"
		width: listView.width
		height: listView.itemHeight
		color: model.index == listView.currentIndex ? listView.selectedColor : "transparent"
		property var listItem: model.modelData? model.modelData: model
		/*Component.onCompleted: {
			//console.debug("time(E)=" + (new Date().getTime()));
			//console.debug("listItem.icon:" + listItem.icon);
			//console.debug("listItem.key:" + listItem.key);
			//console.debug("listItem.value:" + listItem.value);
			//console.debug("time(E)=" + (new Date().getTime()));
		}*/

		Rectangle {
			id: "itemIcon"
			visible: itemIconImage.visible
			height: parent.height
			width: itemIconImage.width
			anchors.leftMargin: visible? 2*parent.height*0.2 : 0
			//anchors.leftMargin: 2*parent.height*0.2
			color: "transparent"
			Image {
				id: "itemIconImage"
				height: parent.height*0.8
				width: visible? height : 0
				visible: source != ""
				source: listItem.icon != undefined ? listItem.icon : ""
				anchors.centerIn: parent
			}
		}
		Text {
			id: "itemText"
			anchors.left: itemIcon.right
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			anchors.right: parent.right
			verticalAlignment: Text.AlignVCenter
			anchors.leftMargin: itemIcon.visible? 0 : 10*reso.dp2px
			anchors.rightMargin: anchors.leftMargin
			color: "#000000"// listView.textColor
			font: listView.font
			text: listItem.value
		}
		Rectangle {
			y: parent.height - 1
			width: parent.width
			height: 1
			color: listView.separatorColor
		}
		MouseArea {
			anchors.fill: parent
			onPressed: {
				listView.currentIndex = model.index;
				if ( model.modelData )
					listView.currentItem = listView.model[model.index];
				else
					listView.currentItem = listView.model.get( model.index );
			}
			onClicked: {
				listView.selected(listView.currentIndex, listView.currentItem);
			}
		}
	}
}
