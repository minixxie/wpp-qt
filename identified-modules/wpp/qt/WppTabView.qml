import QtQuick 2.1

import "./"

Rectangle {
	id: tabView
	property int tabWidth: 50*wpp.dp2px
	property int tabHeight: tabButtonsPosition == "TOP" ? 24*wpp.dp2px : 50*wpp.dp2px
	property color tabBgColor: "#eeeeee"
	property color selectedIndicatorColor: "#aaaaaa"
	property int selectedIndicatorHeight: 5*wpp.dp2px
	property color bottomBorderColor: "#dddddd"
	property list<WppTab> tabs
	property int defaultIndex: 0
	property string tabButtonsPosition: "TOP" //TOP, BOTTOM

	//Column {
		//width: parent.width
		//height: parent.height


		Rectangle {
			id: tabTitlesContainer
			x: 0
			y: tabView.tabButtonsPosition == "TOP" ? 0 : parent.height - height
			width: parent.width
			height: tabView.tabHeight
			color: tabView.tabBgColor
			ListView {
				id: tabTitles
				anchors.fill: parent
				model: tabs
				orientation: ListView.Horizontal
				boundsBehavior: Flickable.StopAtBounds
				delegate: Rectangle {
					width: tabView.tabWidth
					height: tabView.tabHeight
					color: "transparent"

					Rectangle {
						id: tabHeaderContainer
						width: parent.width
						height: parent.height - selectedIndicatorRect.height
						color: "transparent"
						Rectangle {
							id: newIndicator
							width: 8*wpp.dp2px
							height: width
							radius: height/2
							color: "#FF5555"
							x: tabHeaderContainer.width - 2*wpp.dp2px - width
							y: 2*wpp.dp2px
							/*anchors.top: tabHeaderContainer.top
							anchors.topMargin: 2*wpp.dp2px
							anchors.right: tabHeaderContainer.right
							anchors.rightMargin: 2*wpp.dp2px*/
						}

						children: {
							model.title.x = (tabHeaderContainer.width - model.title.width)/2;
							model.title.y = (tabHeaderContainer.height - model.title.height)/2;
							//return model.title;
							var c = [];
							c.push( model.title );
							if ( model.hasNew )
							{
								c.push( newIndicator );
							}
							return c;
						}
					}
					Rectangle {
						id: selectedIndicatorRect
						color: tabView.selectedIndicatorColor
						//anchors.bottom: parent.bottom
						width: parent.width - 2*x
						height: tabView.selectedIndicatorHeight
						x: 2*wpp.dp2px
						y: parent.height - bottomBorder.height - height
						visible: tabView.tabButtonsPosition == "TOP" && tabs[model.index].isSelected
					}

					MouseArea {
						anchors.fill: parent
						onClicked: {
							console.log("header " + model.index + " clicked");
							tabView.selectTab(model.index);
						}
					}
				}
				highlightFollowsCurrentItem: true

			}
			Rectangle {
				id: bottomBorder
				width: parent.width
				height: 1*wpp.dp2px
				color: tabView.bottomBorderColor
				y: tabView.tabButtonsPosition == "BOTTOM" ? 0 : parent.height - height
			}
		}

		Rectangle {
			id: tabContentsContainer
			x: 0
			y: tabView.tabButtonsPosition == "TOP" ? tabTitlesContainer.height : 0
			width: parent.width //*tabs.length
			height: parent.height - tabTitlesContainer.height
			color: "#ffffff"
			ListView {
				id: tabContents
				anchors.fill: parent
				model: tabs
				orientation: ListView.Horizontal
				snapMode: ListView.SnapOneItem
				delegate: Rectangle {
					width: tabContentsContainer.width
					height: tabContentsContainer.height
					color: "transparent"
					children: model.content
				}
				clip: true
				highlightFollowsCurrentItem: true
				highlightMoveDuration: 300

				onMovementEnded: {
					var index = indexAt( contentX, 0 );
					console.log("tabContents content X changed:contentX=" + contentX + ", index:" + index);
					tabView.selectTab(index);
				}
				onContentWidthChanged: {
					if ( contentWidth == tabs.length * tabContentsContainer.width )//contents populated
					{
						positionViewAtIndex(tabView.defaultIndex, ListView.Contain);
					}
				}
			}

		}

	//}//Column

	color: "transparent"


	function selectTab(index) {
		for ( var i = 0 ; i < tabs.length ; i++ )
		{
			if ( i == index )
			{
				tabs[i].isSelected = true;
				tabs[i].selected();

				tabContents.currentIndex = i;
				//tabContents.positionViewAtIndex(i, ListView.Beginning);
			}
			else
			{
				tabs[i].isSelected = false;
			}
		}
	}

	Component.onCompleted: {
		selectTab(defaultIndex);
	}
}
