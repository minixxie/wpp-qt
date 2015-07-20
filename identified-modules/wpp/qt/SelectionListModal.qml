import QtQuick 2.1

Modal {
	id: "selectionListModal"

	property alias model: selectionListView.model
	signal selected(int selectedIndex, variant selectedItem)

	property int listHeight: height*0.8
	property alias selectedColor: selectionListView.selectedColor
	property alias separatorColor: selectionListView.separatorColor
	property alias itemHeight: selectionListView.itemHeight
	property alias font: selectionListView.font
	MouseArea {
		anchors.fill: parent
		onClicked: selectionListModal.visible = false
	}
	Rectangle {
		id: "listContainer"
		//width:300*wpp.dp2px
		//height:width
		width: 250*wpp.dp2px
		height: selectionListView.itemHeight*selectionListView.model.length < 300*wpp.dp2px ?
					selectionListView.itemHeight*selectionListView.model.length : 300*wpp.dp2px
		//listHeight < parent.height ? listHeight : parent.height*0.8
		color: Qt.rgba(1,1,1,0.7)
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: parent.verticalCenter

		SelectionListView {
			id: "selectionListView"
			anchors.fill: parent
			onSelected: {
				selectionListModal.selected(selectedIndex, selectedItem)
			}
		}

	}
}
