import QtQuick 2.1

TextEdit {
	id: textEdit

	property alias placeholderText: placeholder.text
	property alias placeholderFont: placeholder.font
	property alias placeholderColor: placeholder.color

	property alias text: textEdit.text
	property alias textFont: textEdit.font
	property real initialHeight: textEdit.font.pixelSize
	property alias hPadding: textEdit.x
	property alias cursorRectangle: textEdit.cursorRectangle
	property alias cursorDelegate: textEdit.cursorDelegate
	property alias cursorPosition: textEdit.cursorPosition
	property alias verticalAlignment: textEdit.verticalAlignment
	//property bool focus: textEdit.focus
	//signal cursorRectangleChanged

	//height: textEdit.height// + 2*textEdit.anchors.topMargin
	//onFocusChanged: if (focus) textEdit.focus = true;
	Keys.forwardTo: textEdit


	//selectByMouse: true
	selectionColor: "lightsteelblue"



	clip: text != ""
	width:parent.width - 2*x
	//height: font.pixelSize
	height: {
			return lineCount*(font.pixelSize) + 2*(initialHeight-font.pixelSize)/2 +
			(lineCount-1)*(font.pixelSize*0.3);
	}
	//y: (initialHeight - font.pixelSize)/2
	//height:
	text: ""
	//verticalAlignment: Text.AlignVCenter
	//anchors.topMargin: (initialHeight - font.pixelSize)/2
	wrapMode: TextEdit.Wrap

	font.family: "Helvetica";

	/*onCursorRectangleChanged: {//cursorRectangle
		height = cursorRectangle.y + cursorRectangle.height + (initialHeight-font.pixelSize)/2;
	}*/

	Text {
		id: placeholder

		anchors.fill: parent
		verticalAlignment: Text.AlignVCenter

		//width: textEdit.width
		//height: initialHeight//font.pixelSize
		//x: textEdit.x
		//y: textEdit.anchors.topMargin//(parent.height - font.pixelSize)/2

		color:"#aaaaaa"
		visible: (textEdit.text == "" || (!textEdit.activeFocus && textEdit.text=="" )) && !textEdit.inputMethodComposing
		font.family: "Helvetica";
	}

	MouseArea {
		anchors.fill: parent
		onPressAndHold: {
			//console.debug("onPressAndHold...")
			menu.visible = true

			if (textEdit.text != "") {
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

			menu.item.attachX = curX - menu.x - menu.item.attachWidth/2

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

			// 确保输入框获取焦点
			textEdit.forceActiveFocus()
			var index = textEdit.positionAt(mouseX, mouseY)
			textEdit.cursorPosition = index

			menu.visible = false
		}
		onReleased: {
			if (textEdit.selectedText != "") {
				if (!menu.visible) {
					menu.visible = true
				}
			}
		}
		onPositionChanged: {
			var currentIndex = textEdit.cursorPosition
			var index = textEdit.positionAt(mouseX, mouseY)
			textEdit.select(index, currentIndex)
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
			textEdit.copy()
			menu.visible = false
		})
		menu.item.pasteItemClicked.connect(function (){
			textEdit.paste()
			menu.visible = false
		})
		menu.item.cutItemClicked.connect(function (){
			textEdit.cut()
			menu.visible = false
		})
		menu.item.selectAllItemClicked.connect(function (){
			textEdit.selectAll()
		})

		pageStackContainer.menuVisibleChanged.disconnect(hideMenu)
		pageStackContainer.menuVisibleChanged.connect(hideMenu)
	}

	onFocusChanged: {
		if ( !focus ) {
			hideMenu(true)
		}
	}

	function hideMenu(b) {
		if (b && menu != null) {
			menu.visible = false
		}
	}
}

