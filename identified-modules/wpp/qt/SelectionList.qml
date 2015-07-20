import QtQuick 2.1

Rectangle {
	id: "selectionList"

	property bool modal: false
	//property variant model
	property alias model: dropdownRepeater.model
	property int currentIndex: 0
	property variant currentItem
	property int arrowDirection: 0  //0-down, 1-up
	property real itemHeight: 30*wpp.dp2px
	property bool hideListOnClick: true
	//property Item fullScreenParent

	signal selected

	height: 30*wpp.dp2px
	width: currentText.width + 2*currentText.anchors.leftMargin + arrowText.width + 2*arrowText.anchors.leftMargin
	border.width: 1
	border.color: "#dddddd"

	gradient: Gradient {
		GradientStop { position: 0.0; color: "#ffffff" }
		GradientStop { position: 1.0; color: "#eeeeee" }
	}

	Text {
		id: "currentText"
		anchors.left: parent.left
        anchors.leftMargin: 10*wpp.dp2px
		anchors.rightMargin: anchors.leftMargin
		height: parent.height
		text: Object.prototype.toString.call( model ) === '[object Array]'? model[currentIndex].value : model.get(currentIndex).value
        font.pixelSize: 12*wpp.dp2px
        color: "#555555"
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}
	Text {
		id: "arrowText"
		text: parent.arrowDirection == 0 ? "▽" : "△"  //" ▽" //" ▴" //" ▾"
		height: parent.height
        color: currentText.color
		anchors.right: parent.right
		anchors.leftMargin: 5*wpp.dp2px
		anchors.rightMargin: anchors.leftMargin

		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}

	Rectangle {
		id: "dropdown"
		x: 0
		y: selectionList.arrowDirection == 0 ? currentText.y + currentText.height : currentText.y - height
		width: selectionList.width
		height: dropdownRepeater.model.count * selectionList.itemHeight
		visible: false

		color: "#eeeeee"
		border.width: 1
		border.color: "#dddddd"

		Column {
			anchors.fill: parent
			Repeater {
				id: "dropdownRepeater"
				//model: selectionList.model
				Rectangle {
					width: dropdown.width
					height: selectionList.itemHeight
					color: ( itemMouseArea.containsMouse || itemMouseArea.pressed ) ?
							   "#BEE597" :
							   ( index == selectionList.currentIndex ? "#cccccc" : "transparent" )
					property var listItem: model.modelData? model.modelData: model
					Text {
						id: "listItemText"
						anchors.left: parent.left
						anchors.leftMargin: 5*wpp.dp2px
						anchors.rightMargin: anchors.leftMargin
						height: selectionList.itemHeight
						text: listItem.value
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}
					MouseArea {
						id: "itemMouseArea"
						anchors.fill: parent
						hoverEnabled: true
						onClicked: {
							selectionList.select(index);
						}
					}
				}
			}
		}
	}

	SelectionListModal {
		id: "popup"
		//parent: selectionList.fullScreenParent
		parent: fullScreen
		visible: false
		itemHeight: 45*wpp.dp2px
		font.pixelSize: 18*wpp.dp2px
		listHeight: itemHeight*selectionList.model.count
		model: selectionList.model
		onSelected: {
			//console.debug("selection list selected:" + selectedItem.key + "=>" + selectedItem.value);

			//console.debug( "selectedIndex:" + selectedIndex );
			selectionList.select( selectedIndex );
			popup.visible = false;
		}
	}
/*

	ListViewDialog {
		id: "popup"
		model: selectionList.model
		//anchors.fill: fullScreenParent
		currentIndex: selectionList.currentIndex
		width: fullScreenParent.width
		height: fullScreenParent.height
		onAccepted: {
			//console.debug("OK");

			//console.debug( "SelectionList.ListViewDialog: currentItem.key:" + currentItem.key );
			//console.debug( "currentIndex:" + currentIndex );
			selectionList.select( currentIndex )
		}
		onRejected: {
			//console.debug("Cancel...");
		}
		parent: fullScreenParent
	}
*/
	MouseArea {
		id: "selectionListMouseArea"
		anchors.fill: parent
		onClicked: {
			Qt.inputMethod.hide();
			if ( selectionList.modal )
			{
				//console.debug("modal.......");
				popup.visible = !popup.visible;
			}
			else
			{
				//console.debug("ERR: Non-modal SelectionList is NOT well supported yet.");
				dropdown.visible = !dropdown.visible;
			}
		}
		Overlay {
			target: parent
			isTargetMouseArea: true
		}
	}

	function select(index)
	{
		selectionList.currentIndex = index;
		if ( Object.prototype.toString.call( model ) === '[object Array]' )
			selectionList.currentItem = selectionList.model[ selectionList.currentIndex ];
		else
			selectionList.currentItem = selectionList.model.get( selectionList.currentIndex );

		//selectionListMouseArea.clicked(1);

		selectionList.selected();
	}
}
