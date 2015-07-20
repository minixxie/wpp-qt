import QtQuick 2.2

WppTextField {
	id: searchText

	property string magnifyingGlass: "RIGHT" //LEFT, RIGHT, NONE

	signal search(string keyword)
	signal keywordChanged(string keyword)

	//width: parent.width - chooseSearchByButton.width -  - anchors.leftMargin - anchors.rightMargin
	radius: 16*wpp.dp2px
	border.color: "#cccccc"

	height:32*wpp.dp2px
	hPadding: magnifyingGlass == "LEFT" ? searchIcon.width + 5*wpp.dp2px : 15*wpp.dp2px

	placeholderText: qsTr("Keywords")
	placeholderFont.pixelSize: 12*wpp.dp2px
	placeholderColor: "#777777"

	text: ""
	onTextChanged: {
		searchText.keywordChanged(text);
	}

	textFont.pixelSize: 14*wpp.dp2px

	focus: true
	Keys.onEnterPressed: {
		searchText.search( text );
	}


	Image {
		id: "searchIcon"
		source: "qrc:/img/android-icons/All_Icons/holo_light/mdpi/2-action-search.png"
		width: 24*wpp.dp2px
		height: 24*wpp.dp2px
		smooth: true
		fillMode: Image.PreserveAspectFit
		//anchors.top: parent.top
		anchors.verticalCenter: parent.verticalCenter
		x: searchText.magnifyingGlass == "LEFT" ? 5*wpp.dp2px : parent.width - width - 5*wpp.dp2px
		//anchors.right: parent.right
		//anchors.rightMargin:5*wpp.dp2px
		visible: searchText.magnifyingGlass != "NONE"
		MouseArea {
			anchors.fill: parent
			Overlay {
				target: parent
				isTargetMouseArea: true
			}
			onClicked: {
				searchText.search( text );
			}
		}
	}
}//TextField

