import QtQuick 2.1

Rectangle {
	id: "loadingIcon"
	width: 90*reso.dp2px
	height: width
	color: Qt.rgba(0,0,0,0.8)
	anchors.centerIn: parent
	border.width: 2*reso.dp2px
	border.color: "#ffffff"
	radius: 5*reso.dp2px
	AnimatedImage {
		width:45*reso.dp2px
		height:45*reso.dp2px
		source: "qrc:/img/loading.200x200.gif"
		anchors.centerIn: parent
	}
}


