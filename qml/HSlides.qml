import QtQuick 2.1

Rectangle {
	property alias children: itemModel.children
	property alias snapMode: view.snapMode

	VisualItemModel {
		id: itemModel
		/*Item {
			width: view.width;
			height: view.height
			Image {
				id: imagePage1
				source: "http://usr.kuulabu.com/2010.jpg"
				anchors.verticalCenter: parent.verticalCenter
				anchors.horizontalCenter : parent.horizontalCenter
			}
			Component.onDestruction: print("destroyed 1")
		}
		Item {
			width: view.width;
			height: view.height
			Image {
				id: imagePage2
				source: "http://usr.kuulabu.com/2011.jpg"
				anchors.verticalCenter: parent.verticalCenter
				anchors.horizontalCenter : parent.horizontalCenter
			}
			Component.onDestruction: print("destroyed 2")
		}
		Item {
			width: view.width;
			height: view.height
			Image {
				id: imagePage3
				source: "http://usr.kuulabu.com/2012.jpg"
				anchors.verticalCenter: parent.verticalCenter
				anchors.horizontalCenter : parent.horizontalCenter
			}
			Component.onDestruction: print("destroyed 3")
		}*/
	}
	ListView {
		id: view
		anchors.fill: parent
		model: itemModel
		preferredHighlightBegin: 0; preferredHighlightEnd: 0
		highlightRangeMode: ListView.StrictlyEnforceRange
		orientation: ListView.Horizontal
		snapMode: ListView.SnapOneItem
		flickDeceleration: 2000
		cacheBuffer: 200
	}
}
