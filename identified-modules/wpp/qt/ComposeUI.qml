import QtQuick 2.1
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3

Rectangle {
	id: composeUI

	//property var smileyListModel: []
	property alias text: commentInputBox.text
	property alias avatarSource: meAsCommenterProfilePhoto.url
	property alias placeholderText: commentInputBox.placeholderText
	property alias tabs: specialPanels.tabs
	property alias specialDot: specialDotRect.visible
	property bool dontCheckEmptyMsg: false
	property bool useSendButtonImage: true
	property string sendButtonText: qsTr("Send")
	property color sendButtonTextColor: "#ffffff"
	property color sendButtonColor: "#5dcb36"
	property bool keyboardOnShow: true

	signal sendClicked(string msg)

	width: parent.width
	height: topBorder.height +
			commentInputBoxRectangle.anchors.topMargin + commentInputBoxRectangle.height +
			( !specialPanels.visible?  commentInputBoxRectangle.anchors.bottomMargin :
				specialPanels.anchors.topMargin + specialPanels.height + specialPanels.anchors.bottomMargin
			)
	//height: topBorder.height +
			//commentInputBox.anchors.topMargin + commentInputBox.height + commentInputBox.anchors.bottomMargin +
				//specialPanels.anchors.topMargin + specialPanels.height + specialPanels.anchors.bottomMargin
	clip: true
	color: "#ffffff"

	property var constKBHeight: 240*wpp.dp2px
	//property var kbHeight: constKBHeight
	y: parent.height - height
	anchors.left: parent.left
	anchors.right: parent.right
	//anchors.bottom: parent.bottom

	function show()
	{
		//wpp.setSoftInputModeAdjustPan();
		//wpp.setSoftInputModeAdjustResize();
		visible = true;
		//specialPanels.visible = false;
		commentInputBox.forceActiveFocus();
		Qt.inputMethod.show();
	}
	function hide()
	{
		//wpp.setSoftInputModeAdjustPan();
		//console.debug("ComposeUI.hide()....");
		Qt.inputMethod.hide();
		visible = false;
	}
	function insertText(str)
	{
		commentInputBox.insert(commentInputBox.cursorPosition, str);
	}

	Rectangle {
		id: topBorder
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		height: 1*wpp.dp2px
		color: "#dddddd"
	}

	Avatar {
		id: meAsCommenterProfilePhoto
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.margins: 10*wpp.dp2px
		width: 30*wpp.dp2px
		height: 30*wpp.dp2px
		visible: url != ""
	}

	function send()
	{
		var trimmedCommentMsg = commentInputBox.text.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
		if ( dontCheckEmptyMsg )
			sendClicked(trimmedCommentMsg);
		else
		{
			if ( trimmedCommentMsg != "" )
				sendClicked(trimmedCommentMsg);
		}
		//clear
		commentInputBox.text = "";
	}
//	Rectangle {
//		id: vSeparator
//		height: 12*wpp.dp2px
//		width: 1*wpp.dp2px
//		color: "#cccccc"
//		anchors.verticalCenter: sendCommentButton.verticalCenter
//		anchors.right: composeUI.useSendButtonImage ? sendCommentButton.left : sendCommentRealButton.left
//		anchors.rightMargin: 5*wpp.dp2px
//	}

	Rectangle {
		id: specialDotRect
		width: 6*wpp.dp2px
		height: width
		color: "#FF5555"
		radius: height/2
		anchors.left: addSpecialButton.right
		anchors.leftMargin: -width-2*wpp.dp2px
		anchors.bottom: addSpecialButton.top
		anchors.bottomMargin: -height-2*wpp.dp2px
	}
	Image {
		id: addSpecialButton
		anchors.top: parent.top
		anchors.left: {//parent.left
			if (meAsCommenterProfilePhoto.visible) {
				return meAsCommenterProfilePhoto.right
			} else {
				return parent.left
			}
		}
		anchors.leftMargin: 5*wpp.dp2px
		//anchors.right: vSeparator.left
		//anchors.rightMargin: 5*wpp.dp2px
		anchors.topMargin: 10*wpp.dp2px
		source: "qrc:/img/android-icons/All_Icons/holo_light/mdpi/5-content-new.png"
		smooth: true
		fillMode: Image.PreserveAspectFit
		width: 30*wpp.dp2px
		height: 30*wpp.dp2px
		scale: 0.8
		MouseArea {
			anchors.fill: parent
			onClicked: {
				//console.debug("Qt.inputMethod.keyboardRectangle.height:" + Qt.inputMethod.keyboardRectangle.height);
				//console.debug("Qt.inputMethod.keyboardRectangle.width:" + Qt.inputMethod.keyboardRectangle.width);
				//console.debug("Qt.inputMethod.keyboardRectangle.x:" + Qt.inputMethod.keyboardRectangle.x);
				//console.debug("Qt.inputMethod.keyboardRectangle.y:" + Qt.inputMethod.keyboardRectangle.y);

				//console.debug("keyboard.keyboardRectangle.height:" + keyboard.keyboardRectangle.height);
				//console.debug("keyboard.keyboardRectangle.width:" + keyboard.keyboardRectangle.width);
				//console.debug("keyboard.keyboardRectangle.x:" + keyboard.keyboardRectangle.x);
				//console.debug("keyboard.keyboardRectangle.y:" + keyboard.keyboardRectangle.y);
				/*if ( false )//Qt.platform.os == "ios" || Qt.platform.os == "android" )
				{
					//specialPanels.height = Qt.inputMethod.keyboardRectangle.height;
					specialPanels.height = keyboard.keyboardRectangle.height;
				}
				else
				{
					specialPanels.height = composeUI.constKBHeight;
				}*/
				if ( !specialPanels.visible )
				{
					//composeUI.kbHeight = 0;
					Qt.inputMethod.hide();
					specialPanels.visible = true;
					specialPanels.forceActiveFocus();
				}
				else
				{
					specialPanels.visible = false;
					commentInputBox.forceActiveFocus();
					Qt.inputMethod.show();
				}
				//specialPanels.visible = !specialPanels.visible;

			}
			Overlay { target: parent; isTargetMouseArea: true }
		}
	}

	Rectangle {
		id: commentInputBoxRectangle
		anchors.margins: 10*wpp.dp2px
		anchors.top: parent.top
		anchors.left: addSpecialButton.right
		anchors.leftMargin: 5*wpp.dp2px
		width: parent.width
			   - addSpecialButton.width - addSpecialButton.anchors.leftMargin - addSpecialButton.anchors.rightMargin
			   - sendCommentButton.width - sendCommentButton.anchors.leftMargin - sendCommentButton.anchors.rightMargin
			   - sendCommentRealButton.width - sendCommentRealButton.anchors.leftMargin - sendCommentRealButton.anchors.rightMargin
		height: commentInputBox.height
		border.color: "#dddddd"
		border.width: 1*wpp.dp2px
		color: "#ffffff"

		KTextArea {
			id: commentInputBox
			focus: composeUI.keyboardOnShow ? composeUI.visible : false
			anchors.top: parent.top
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.leftMargin: 5*wpp.dp2px
			anchors.rightMargin: 5*wpp.dp2px
			verticalAlignment: TextEdit.AlignVCenter
			//width: parent.width - 2*x - addSpecialButton.width
			//height: parent.height - 2*y
			//height: lineCount * 12*wpp.dp2px
			initialHeight: 30*wpp.dp2px
			//textMargin: (initialHeight - font.pixelSize)/2
			onTextMarginChanged: {
				//console.debug("textMargin="+textMargin);
			}

			//height: contentHeight < initialHeight ? initialHeight : contentHeight

			placeholderText: qsTr("write some comment...")
			placeholderFont.pixelSize: 12*wpp.dp2px
			placeholderColor: "#777777"

			//focus: commentBox.visible
			text: ""
			font.pixelSize: 12*wpp.dp2px
			textFont.pixelSize: 12*wpp.dp2px
			cursorDelegate: ThickCursor {
				textBox: commentInputBox
			}
			onCursorVisibleChanged: {//keep cursor visible
				if ( !cursorVisible )
					cursorVisible = true;
			}

			onFocusChanged: {
				//console.debug("focus changed:"+focus);
				if ( focus )
					specialPanels.visible = false;
			}
			/*MouseArea {
				visible: !commentInputBox.focus
				anchors.fill: parent
				preventStealing: true
				onClicked: {
					//console.debug("clicking...");
					commentInputBox.forceActiveFocus();
					specialPanels.visible = false;
					mouse.accepted = false;//propagate to KTextArea
					commentInputBox.clicked(mouse);
				}
				propagateComposedEvents: true
			}*/
		}
	}


	Button {
		id: sendCommentRealButton
		anchors.top: parent.top
		anchors.topMargin: 10*wpp.dp2px
		anchors.leftMargin: 5*wpp.dp2px
		anchors.right: parent.right
		anchors.rightMargin: 5*wpp.dp2px
		width: visible ? 40*wpp.dp2px : 0
		height: 30*wpp.dp2px
		visible: !composeUI.useSendButtonImage
		style: ButtonStyle {
			background: Rectangle {
				color: composeUI.sendButtonColor
				radius: 2*wpp.dp2px
			}
			label: Text {
				text: composeUI.sendButtonText
				color: composeUI.sendButtonTextColor
				font.pixelSize: 12*wpp.dp2px
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}
		}
		onClicked: {
			composeUI.send();
		}
	}

	Image {
		id: sendCommentButton
		anchors.top: parent.top
		anchors.topMargin: 10*wpp.dp2px
		anchors.leftMargin: 5*wpp.dp2px
		anchors.right: parent.right
		anchors.rightMargin: 5*wpp.dp2px
		source: "qrc:/img/android-icons/All_Icons/holo_light/mdpi/6-social-send-now.png"
		width: visible ? 30*wpp.dp2px : 0
		height: 30*wpp.dp2px
		smooth: true
		fillMode: Image.PreserveAspectFit
		visible: composeUI.useSendButtonImage
		MouseArea {
			id: sendCommentButtonMouseArea
			anchors.fill: parent
			onClicked: {
				composeUI.send();
			}
			Overlay { target: parent; isTargetMouseArea: true }
		}
	}

	WppTabView {
		id: specialPanels
		anchors.top: commentInputBoxRectangle.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.topMargin: 10*wpp.dp2px
		anchors.bottomMargin: 0
		height: tabs.length > 0 ? composeUI.constKBHeight : 0
		tabHeight: 24*wpp.dp2px
		tabBgColor: "#f4f4f4"
		visible: false

		/*tabs: [
			WppTab {
				id: smileysTab
				title: Image {
					source: "qrc:/img/smileys/kuangxiao.gif"
					smooth: true
					fillMode: Image.PreserveAspectFit
					width: 30*wpp.dp2px
					height: 30*wpp.dp2px
				}
				content: SmileysUI {
					anchors.fill: parent;
					smileyListModel: composeUI.smileyListModel
					onSmileyClicked: { //(string escapedText, string imageSource)
						commentInputBox.text += escapedText;
					}
				}
				//onSelected: titleBar.text = qsTr("Home")
			},
			WppTab {
				id: atUserTab
				title: Text {
					text: "@"
					font.pixelSize: 24*wpp.dp2px
					color: "#7f7f7f"
					width: 30*wpp.dp2px
					height: 30*wpp.dp2px
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
				content: AtUserTab { anchors.fill: parent }
				//onSelected: titleBar.text = qsTr("Home")
			},
			WppTab {
				id: detectLocationTab
				title: Image {
					source: "qrc:/img/android-icons/All_Icons/holo_light/mdpi/7-location-place.png"
					smooth: true
					fillMode: Image.PreserveAspectFit
					width: 30*wpp.dp2px
					height: 30*wpp.dp2px
				}
				content: DetectLocationUI { anchors.fill: parent }
				//onSelected: titleBar.text = qsTr("Home")
			},
			WppTab {
				id: addPhotoTab
				title: Image {
					source: "qrc:/img/android-icons/All_Icons/holo_light/mdpi/10-device-access-camera.png"
					smooth: true
					fillMode: Image.PreserveAspectFit
					width: 30*wpp.dp2px
					height: 30*wpp.dp2px
				}
				content: AddPhotoUI { anchors.fill: parent }
				//onSelected: titleBar.text = qsTr("Home")
			}


		]*/
	}//TabView
}
