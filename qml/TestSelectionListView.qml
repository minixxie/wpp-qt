import QtQuick 2.1

Rectangle {

	SelectionListView {
		width: parent.width*0.8
		height: parent.height*0.8
		ListModel {
			id: "myModel"
			ListElement {
				key: "GOOGLE"; value: "Google"
			}
			ListElement {
				key: "BAIDU"; value: "Baidu"
			}
			ListElement {
				key: "GAODE"; value: "Gao De"
			}
			ListElement {
				key: "APPLE"; value: "Apple"
			}
		}
		model: myModel
		onSelected: {
			console.log("selection list selected:" + selectedItem.key + "=>" + selectedItem.value);
		}
	}

}
