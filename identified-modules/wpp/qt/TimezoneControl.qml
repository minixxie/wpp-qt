import QtQuick 2.2
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3
import wpp.qt.IOSTimeZonePicker 1.0

Item {
	id: timezoneControl

	property alias topBorder: upperBorderLine.visible
	property alias bottomBorder: lowerBorderLine.visible
	property alias timezoneTitle: title.text
	property string timezoneId
	signal selected(string timezoneId)

	height: 36*wpp.dp2px + upperBorderLine.height + lowerBorderLine.height

	Rectangle {//top line
		id: upperBorderLine
		anchors.top: parent.top
		anchors.left: parent.left; anchors.right: parent.right
		height: visible?1*wpp.dp2px:0
		color: "#dddddd"
		visible: false
	}

	Text {
		id: title
		anchors.top: parent.top; anchors.bottom: parent.bottom;
		anchors.left: parent.left; anchors.leftMargin:10*wpp.dp2px;
		text: qsTr("Time Zone")
		font.pixelSize: 12*wpp.dp2px
		color: "#333333"
		verticalAlignment: Text.AlignVCenter
	}
	TimezoneModel {
		id: timezoneModel
	}
	ComboBox {
		id: timezoneCombo
		visible: Qt.platform.os != "ios" //for iOS, uses IOSTimeZonePicker
		anchors.top: parent.top; anchors.bottom: parent.bottom;
		anchors.left: parent.left; anchors.leftMargin:10*wpp.dp2px;
		anchors.right: parent.right; anchors.rightMargin:10*wpp.dp2px;
		editable: false
		model: timezoneModel
		onActivated: {
			if ( Qt.platform.os != "ios" )
			{
				timezoneControl.selected( timezoneModel.get(index).text );
			}
		}
		width:timezoneControl.width/2
		style: Component {
			ComboBoxStyle {
				background: Rectangle {
					color: "transparent"
					border.width: 0
				}
				label: Text {
					text: control.currentText
					horizontalAlignment: Text.AlignRight
					verticalAlignment: Text.AlignVCenter
					font.pixelSize: 12*wpp.dp2px
					font.bold: false
					color: "#333333"
					elide: Text.ElideRight
				}
			}
		}
		Component.onCompleted: {
			console.debug("TimezoneCombo: timezoneId=" + timezoneControl.timezoneId);
			initCurrentIndex();
			//currentIndex = timezoneModel.find(timezoneControl.timezoneId);
			console.debug("TimezoneCombo: currentIndex=" + currentIndex);
		}
		function initCurrentIndex()
		{
			for ( var i = 0 ; i < timezoneModel.count ; i++ )
			{
				var obj = timezoneModel.get(i);
				if ( obj["text"] == timezoneControl.timezoneId )
				{
					currentIndex = i;
				}
			}
		}
	}
	Rectangle {//bottom line
		id: lowerBorderLine
		anchors.bottom: parent.bottom
		anchors.left: parent.left; anchors.right: parent.right
		height: visible?1*wpp.dp2px:0
		color: "#dddddd"
		visible: false
	}

	IOSTimeZonePicker {
		id: iosTimeZonePicker
		timezoneId: timezoneControl.timezoneId
		onPicked: {
			timezoneControl.selected( timezoneId );
		}
	}
	Text {
		id: timezoneText
		visible: Qt.platform.os == "ios"
		text: timezoneControl.timezoneId
		font.pixelSize: 12*wpp.dp2px
		color: "#333333"
		anchors.top: parent.top
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		verticalAlignment: Text.AlignVCenter
		anchors.rightMargin: 10*wpp.dp2px
	}
	MouseArea {
		enabled: Qt.platform.os == "ios"
		anchors.fill: parent
		Overlay { target: parent; isTargetMouseArea: true; }
		onClicked: {
			iosTimeZonePicker.open();
		}
	}
}


