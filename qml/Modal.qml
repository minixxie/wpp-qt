import QtQuick 2.1

Rectangle {
	color: Qt.rgba(0,0,0,0.3)

	parent: fullScreen
	anchors.fill: parent
	focus: true
	MouseArea {
		anchors.fill: parent
	}
	onVisibleChanged: {
		if ( visible )
		{
			Qt.inputMethod.hide();
		}
	}
}
