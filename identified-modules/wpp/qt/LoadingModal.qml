import QtQuick 2.1

Modal {
	id: "loadingModal"
	parent: fullScreen

	AnimatedImage {
		z: loadingModal.z + 1
		width:50*wpp.dp2px
		height:50*wpp.dp2px
		source: "qrc:/img/loading.200x200.gif"
		anchors.verticalCenter: parent.verticalCenter
		anchors.horizontalCenter: parent.horizontalCenter
	}
}
