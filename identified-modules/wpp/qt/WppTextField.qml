import QtQuick 2.1
import QtGraphicalEffects 1.0

FocusScope {
	id: textfield
	property alias placeholderText: placeholder.text
	property alias placeholderFont: placeholder.font
	property alias placeholderColor: placeholder.color

	property alias text: textInput.text
	property alias textFont: textInput.font
	property alias echoMode: textInput.echoMode
	property alias validator: textInput.validator

	property alias hPadding: textInput.x

    property alias textColor: textInput.color
	property alias cursorDelegate: textInput.cursorDelegate
	property alias cursorRectangle: textInput.cursorRectangle

	property alias radius: rect.radius
	property alias border: rect.border

	property bool withClearButton: false

	onFocusChanged: textInput.focus = focus
	Keys.forwardTo: textInput

	Rectangle {
		id: rect
		anchors.fill: parent
	}

	TextInput {
		id: textInput
		clip: text != ""
		width:parent.width - 2*x
		//height: font.pixelSize
		//y: (parent.height - font.pixelSize)/2
		height: parent.height
		selectionColor: "lightsteelblue"
		text: ""
		verticalAlignment: Text.AlignVCenter
//        anchors.verticalCenter: parent.verticalCenter
		font.family: "Helvetica";
		cursorDelegate: ThickCursor {
			textBox: textInput
		}
		/*Component.onCompleted: {
			ensureVisible(0);
		}*/
		onFocusChanged: {
			//console.debug("onFocusChanged...focus=" + focus);
			if ( focus )
			{
				Qt.inputMethod.show();
			}
			else
			{
				if (menu.visible)
				{
					menu.visible = false
				}
			}
		}
	}



	MouseArea {
		anchors.fill: parent
		onPressAndHold: {
			//console.debug("onPressAndHold...")
			menu.visible = true

			if (textInput.text != "") {
				menu.item.copyVisible = true
				menu.item.cutVisible = true
				menu.item.selectAllVisible = true
			} else {
				menu.item.copyVisible = false
				menu.item.cutVisible = false
				menu.item.selectAllVisible = false
			}

			menu.item.pasteVisible = true

			var curX = mapToItem(null, cursorRectangle.x, cursorRectangle.y).x
			var curY = mapToItem(null, cursorRectangle.x, cursorRectangle.y).y
			if ((curX + menu.width/2) > fullScreen.width) {
				menu.x = fullScreen.width - menu.width
			} else if ((curX - menu.width/2) < 0) {
				menu.x = 0
			} else {
				menu.x = curX - menu.width/2
			}

			menu.item.attachX = curX - menu.x - menu.item.attachWidth/2 + hPadding

			if (curY - menu.height > 0) {
				menu.y = curY - menu.height - menu.item.attachHeight
				menu.item.attachAndRepaint()
			} else {
				menu.y = curY + menu.height + menu.item.attachHeight
				menu.item.invertAttachAndRepaint()
			}
		}
		onPressed: {
			//console.debug("onPressed...")
			if (!Qt.inputMethod.visible) {
				Qt.inputMethod.show()
			}

			textInput.forceActiveFocus()
			var index = textInput.positionAt(mouseX, mouseY)
			textInput.cursorPosition = index

			menu.visible = false
		}
		onReleased: {
			if (textInput.selectedText != "") {
				if (!menu.visible) {
					menu.visible = true
				}
			}
		}

		onPositionChanged: {
			var currentIndex = textInput.cursorPosition
			var index = textInput.positionAt(mouseX, mouseY)
			textInput.select(index, currentIndex)
		}
	}

	Loader {
		id: menu
		parent: fullScreen
		visible: false
		source: "KMenu.qml"
	}

	Component.onCompleted: {
		menu.item.copyItemClicked.connect(function (){
			textInput.copy()
			menu.visible = false
		})
		menu.item.pasteItemClicked.connect(function (){
			textInput.paste()
			menu.visible = false
		})
		menu.item.cutItemClicked.connect(function (){
			textInput.cut()
			menu.visible = false
		})
		menu.item.selectAllItemClicked.connect(function (){
			textInput.selectAll()
		})

		pageStackContainer.menuVisibleChanged.disconnect(hideMenu)
		pageStackContainer.menuVisibleChanged.connect(hideMenu)
	}

	function hideMenu(b) {
		if (b) {
			menu.visible = false
		}
	}

	Text {
		id: placeholder

		width: textInput.width
        //height: font.pixelSize
        height: textInput.height
        //lineHeight: font.pixelSize
        verticalAlignment: Text.AlignVCenter

        x: textInput.x
        //y: (parent.height - font.pixelSize - ( textfield.border.width * 2) )/2
        color:"#aaaaaa"
		//visible: sys.isAndroid() ? ( textInput.text == "" && !textInput.activeFocus ) : (textInput.text == "" || (!textInput.activeFocus && textInput.text=="" ))

			//sys.isAndroid()? (textInput.text == "" && !textInput.activeFocus) : (textInput.text == "" && !textInput.activeFocus)
		visible: {
			var v =
			(textInput.text == "" || (!textInput.activeFocus && textInput.text=="" )) && !textInput.inputMethodComposing;
			//console.debug("Text.visible: textInput.text=" + textInput.text);
			//console.debug("Text.visible: textInput.activeFocus=" + textInput.activeFocus);
			//console.debug("Text.visible: textInput.inputMethodComposing=" + textInput.inputMethodComposing);
			v = ( textInput.text=="" ) && !textInput.activeFocus;// && !textInput.inputMethodComposing;
			//return v;
			if ( !textInput.activeFocus )
			{
				return ( textInput.text=="" );
			}
			else
			{
				if ( textInput.text=="" )
				{
					return !textInput.inputMethodComposing;
				}
				else
					return false;
			}
		}
		font.family: "Helvetica";
	}
	Rectangle {
		id: "clearButton"
		height: 16*wpp.dp2px
		width: height
		anchors.verticalCenter: parent.verticalCenter
		anchors.right: parent.right
		anchors.rightMargin: 10*wpp.dp2px
		color: "#b9b9b9"
		radius: height/2
		visible: {
			if ( textfield.withClearButton )
			{
				if ( placeholder.visible )
					return false;
				else
				{
					return ( textInput.activeFocus )
				}
			}
			else
			{
				return false;
			}

			//return textfield.withClearButton && !placeholder.visible

			/*if ( textInput.text!="" &&  )
			{
				if ( )
			}

			if ( !textInput.activeFocus )
				return true;
			else
			{
				if ( textInput.text=="" )
				{
					return !textInput.inputMethodComposing;
				}
				else
					return false;
			}*/

		}
		Image {
			id: "clearButtonIcon"
			anchors.fill: parent
			anchors.margins: 2*wpp.dp2px
			source: "qrc:/img/android-icons/All_Icons/holo_light/mdpi/1-navigation-cancel.png"
			visible: false
		}
		ColorOverlay {
			source: clearButtonIcon
			anchors.fill: clearButtonIcon
			color: "#ffffffff"
		}
		MouseArea {
			anchors.fill: parent
			anchors.margins: -(textfield.height - clearButton.height)/2
			onClicked: textInput.text = ""
		}
	}

	/*MouseArea {
		anchors.fill: parent
		onClicked: {
			//textInput.focus = true
			textfield.focus = true
		}
	}*/
}
