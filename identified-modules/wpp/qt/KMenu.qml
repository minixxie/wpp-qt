import QtQuick 2.0
import QtQuick.Controls 1.3

Rectangle {
	id: kmenu

	property real itemWidth: 60*wpp.dp2px
	property real itemHeight: 36*wpp.dp2px
	property color defaultItemColor: "transparent"
	property color pressedColor: "#cc666666"
	property color lineColor: "#88888888"
	property real lineWidth: 1*wpp.dp2px
	property color fontColor: "#ffffff"
	property real fontSize: 12*wpp.dp2px

	color: "#cc000000"
	border.width: 2*wpp.dp2px
	radius: 6*wpp.dp2px
	width: {
		return (copy.visible ? itemWidth : 0)
				+ (paste.visible ? itemWidth : 0)
				+ (cut.visible ? itemWidth : 0)
				+ (selectAll.visible ? itemWidth : 0)
	}
	height: itemHeight

	property alias copyVisible: copy.visible
	property alias pasteVisible: paste.visible
	property alias cutVisible: cut.visible
	property alias selectAllVisible: selectAll.visible

	property alias attachX: kmenAttach.x
	property alias attachY: kmenAttach.y
	property alias attachWidth: kmenAttach.width
	property alias attachHeight: kmenAttach.height
	property alias attachInvert: kmenAttach.invert

	signal copyItemClicked()
	signal pasteItemClicked()
	signal cutItemClicked()
	signal selectAllItemClicked()

	function attachAndRepaint() {
		kmenAttach.invert = false
		kmenAttach.requestPaint()
	}
	function invertAttachAndRepaint() {
		kmenAttach.invert = true
		kmenAttach.requestPaint()
	}

	Rectangle {
		id: copy
		visible: false
		color: defaultItemColor
		anchors.left: parent.left
		anchors.verticalCenter: parent.verticalCenter
		width: visible ? itemWidth : 0
		height: parent.height

		Text {
			anchors.fill: parent
			color: fontColor
			font.pixelSize: fontSize
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			text: qsTr("copy")
		}

		MouseArea {
			anchors.fill: parent
			onPressed: copy.color = pressedColor
			onReleased: {
				copy.color = defaultItemColor
				copyItemClicked()
			}
		}
	}

	Rectangle {
		anchors.left: copy.right
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: lineWidth
		height: parent.height
		color: lineColor
		visible: paste.visible
	}

	Rectangle {
		id: paste
		visible: false
		color: defaultItemColor
		anchors.left: copy.right
		anchors.verticalCenter: parent.verticalCenter
		width: visible ? itemWidth : 0
		height: parent.height

		Text {
			anchors.fill: parent
			color: fontColor
			font.pixelSize: fontSize
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			text: qsTr("paste")
		}

		MouseArea {
			anchors.fill: parent
			onPressed: paste.color = pressedColor
			onReleased: {
				paste.color = defaultItemColor
				pasteItemClicked()
			}
		}
	}

	Rectangle {
		anchors.left: paste.right
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: lineWidth
		height: parent.height
		color: lineColor
		visible: cut.visible
	}

	Rectangle {
		id: cut
		visible: false
		color: defaultItemColor
		anchors.left: paste.right
		anchors.verticalCenter: parent.verticalCenter
		width: visible ? itemWidth : 0
		height: parent.height

		Text {
			anchors.fill: parent
			color: fontColor
			font.pixelSize: fontSize
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			text: qsTr("cut")
		}

		MouseArea {
			anchors.fill: parent
			onPressed: cut.color = pressedColor
			onReleased: {
				cut.color = defaultItemColor
				cutItemClicked()
			}
		}
	}

	Rectangle {
		anchors.left: cut.right
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		width: lineWidth
		height: parent.height
		color: lineColor
		visible: selectAll.visible
	}

	Rectangle {
		id: selectAll
		visible: false
		color: defaultItemColor
		anchors.left: cut.right
		anchors.verticalCenter: parent.verticalCenter
		width: visible ? itemWidth : 0
		height: parent.height

		Text {
			anchors.fill: parent
			color: fontColor
			font.pixelSize: fontSize
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
			text: qsTr("select all")
		}

		MouseArea {
			anchors.fill: parent
			onPressed: selectAll.color = pressedColor
			onReleased: {
				selectAll.color = defaultItemColor
				selectAllItemClicked()
			}
		}
	}

	KMenuAttach {
		id: kmenAttach
		parent: kmenu
		visible: kmenu.visible
		anchors.verticalCenter: kmenu.verticalCenter
		anchors.verticalCenterOffset: {
			if (invert) {
				return -(kmenu.height/2 + kmenAttach.height/2 - 1*wpp.dp2px)
			} else {
				return kmenu.height/2 + kmenAttach.height/2 - 1*wpp.dp2px
			}
		}
	}
}

