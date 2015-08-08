import QtQuick 2.4
import QtQuick.Window 2.2

MouseArea {
	id: scrollInputVisible
	property var inputElement: parent
	property var flickable
	property var scrollToContentYWhenFocused
	//property Item rootWindow

	Timer {
		id: delayFocusTimer
		running: false
		repeat: false
		interval: 150
		onTriggered: {
			if ( scrollInputVisible.inputElement !== undefined )
			{
				scrollInputVisible.inputElement.forceActiveFocus();
			}
		}
	}
	property int lastKeyboardHeight: 280*wpp.dp2px
	PropertyAnimation {
		id: scrollUpAnimation
		target: scrollInputVisible.flickable !== undefined ? scrollInputVisible.flickable : null
		property: "contentY"
		/*to: {
			var inputElementGlobalCoord = rootWindow.mapFromItem(scrollInputVisible.inputElement, 0, 0, 1, 1);
			console.debug("inputElementGlobalCoord=" + inputElementGlobalCoord);
			//scrollInputVisible.scrollToContentYWhenFocused
			return 0;
		}*/
		duration: 100
		onStopped: {
			console.debug("scrolling stopped");
			//flickable.contentItem.height -= rootWindow.height;
		}
	}
	onClicked: {
		console.debug("clicking ScrollInputVisible...");
		Qt.inputMethod.show();

		//restore the typing cursor position
		console.debug("click at:" + mouseX + "," + mouseY);
		var index = scrollInputVisible.inputElement.positionAt(mouseX, mouseY);
		scrollInputVisible.inputElement.cursorPosition = index;

		if ( scrollInputVisible.flickable !== undefined )
		{
			if ( scrollInputVisible.scrollToContentYWhenFocused !== undefined )
			{
				scrollUpAnimation.to = parseInt(scrollInputVisible.scrollToContentYWhenFocused);
				console.debug("start scrolling...");
				//flickable.contentItem.height += rootWindow.height;
				scrollUpAnimation.start();
				return;
			}

			var inputElementGlobalCoord = scrollInputVisible.inputElement.mapToItem(null, 0, 0);
			console.debug("inputElementGlobalCoord=" + inputElementGlobalCoord);

			var inputElementCoordInFlickable = scrollInputVisible.inputElement.mapToItem(scrollInputVisible.flickable, 0, 0);
			console.debug("inputElementCoordInFlickable=" + inputElementCoordInFlickable);

			/*if ( Qt.platform.os == "android" )
			{
				scrollUpAnimation.to = inputElementCoordInFlickable.y;

				console.debug("start scrolling...");
				flickable.contentItem.height += rootWindow.height;
				scrollUpAnimation.start();
			}
			else//ios and others
			*/
			{
				var kbHeight = scrollInputVisible.lastKeyboardHeight;
				//var kbHeight = Qt.inputMethod.keyboardRectangle.height;
				console.debug("kbHeight="+kbHeight);
				console.debug("inputElementGlobalCoord.y + scrollInputVisible.inputElement.height="+(inputElementGlobalCoord.y + scrollInputVisible.inputElement.height));
				console.debug("Screen.height:" + Screen.height);
				console.debug("Screen.height - kbHeight=" + (Screen.height - kbHeight));
				if ( parseInt(inputElementGlobalCoord.y + scrollInputVisible.inputElement.height) > parseInt(Screen.height - kbHeight) )
				{//potentially blocked by keyboard
					console.debug("need scroll: Screen.height="+Screen.height);
					console.debug("need scroll: kbHeight="+kbHeight);
					console.debug("need scroll: scrollInputVisible.inputElement.height="+scrollInputVisible.inputElement.height);
					console.debug("need scroll to:"+(Screen.height - kbHeight - scrollInputVisible.inputElement.height) );
					var newY = Screen.height - kbHeight - scrollInputVisible.inputElement.height - 10;
					scrollUpAnimation.to = scrollInputVisible.flickable.contentY + parseInt(inputElementGlobalCoord.y) - parseInt(newY);
					console.debug("need scroll to contentY:"+(scrollUpAnimation.to) );

					console.debug("start scrolling...");
					//flickable.contentItem.height += Screen.height;
					scrollUpAnimation.start();
				}
				else
				{
					console.debug("input element visible, no need to scroll");
				}
			}



			console.debug("count down to focus...");
			delayFocusTimer.running = true;
		}
		else
		{
			console.debug("ScrollInputVisible: no related flickable...");
			if ( scrollInputVisible.inputElement !== undefined )
			{
				if ( wpp.isSoftInputModeAdjustResize() )
				{
					//wpp.__adjustResizeWindow();
				}
				//Qt.inputMethod.show();
				console.debug("count down to focus...");
				delayFocusTimer.running = true;
				//scrollInputVisible.inputElement.forceActiveFocus();
			}
			else
			{
				parent.forceActiveFocus();
			}
		}
	}

	Component.onCompleted: {
		scrollInputVisible.inputElement.focusChanged.connect(function(){
			if ( focus )
			{
				console.debug("ScrollInputVisible:lose focus");
				if ( Qt.platform.os == "ios" )//currently only ios has support for keyboard size
				{
					scrollInputVisible.lastKeyboardHeight = Qt.inputMethod.keyboardRectangle.height;
				}
				scrollInputVisible.visible = false;

			}
			else
			{
				console.debug("ScrollInputVisible:get focus");
				scrollInputVisible.visible = true;
			}
		});
	}




}
