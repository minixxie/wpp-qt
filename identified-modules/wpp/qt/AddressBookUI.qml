import QtQuick 2.1
import QtGraphicalEffects 1.0

Rectangle {
	id: myAddressBookUI
	color: "#ffffff"
	property alias keyword: searchField.text
	property bool alwaysShowDetails: false
	property bool loading: false

	property bool requiresBothPhoneAndEmail: false
	property bool multipleChoice: true
	property bool atLeastOneChoice: false
	property bool mutexInPhones: false
	property bool mutexInEmails: false
	property string isSelectedFieldName: "isSelected"

	property alias model: addressBookPlacesListView.model

	signal selected(var contact)
	signal deselected(var contact)


	property var _letterIndices: [
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1
	]
	property var _indexChars: [
		'A','B','C','D','E','F','G','H','I','J','K','L','M',
		'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
		'#','?'
	];

	onModelChanged: {
		//console.debug("model changed...");
		if ( model != undefined && model.length > 0 )
		{
			var LETTER_A = 65;
			//console.debug("model changed...222");
			for ( var i = 0 ; i < model.length ; i++ )
			{
				var modelData = model[i];
				if ( modelData.isFirstPersonInGroup )
				{
					var firstLetter = modelData.firstLetter;
					var firstLetterAscii = firstLetter.toUpperCase().charCodeAt(0);

					myAddressBookUI._letterIndices[parseInt(firstLetterAscii)-LETTER_A] = i;
				}
			}
			//console.debug("model changed..._letterIndices:" + myAddressBookUI._letterIndices);
			_letterIndicesChanged();
		}
	}


	LoadingModal {
		visible: myAddressBookUI.loading
	}

	SearchField {
		id: searchField
		anchors.top: parent.top
		anchors.topMargin:5*wpp.dp2px
		anchors.left: parent.left
		anchors.leftMargin:5*wpp.dp2px
		anchors.rightMargin: anchors.leftMargin
		anchors.right: parent.right
		height:32*wpp.dp2px
		magnifyingGlass: "LEFT"
		withClearButton: true
		onKeywordChanged: {
			//console.debug("keyword=" + keyword);
			//myAddressBookUI.keywordChanged(keyword);
			myAddressBookUI.keywordChanged();
			/*for ( var k in myAddressBookUI.model )
			{
				var contact = myAddressBookUI.model[k];
				contact.keywordMatching(keyword);
			}*/
		}
		/*onSearch: {
			//console.debug("keyword=" + keyword);
			myAddressBookUI.keyword = keyword;
		}*/
	}
	Rectangle {
		color: "#cccccc"
		height: 1*wpp.dp2px
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: searchField.bottom
		anchors.topMargin: 4*wpp.dp2px
	}


    ListView {
		id: addressBookPlacesListView
		anchors.top: searchField.bottom;
		anchors.topMargin:5*wpp.dp2px
		anchors.left: parent.left
		anchors.right: letterIndexBarRect.left
		anchors.bottom: parent.bottom
		boundsBehavior: Flickable.StopAtBounds
        clip: true
		Component {
			id: sectionHeader
			Rectangle {
				width: addressBookPlacesListView.width
				height: 24*wpp.dp2px
				color: "lightsteelblue"
				Text {
					anchors.fill: parent
					text: section
					verticalAlignment: Text.verticalAlignment
					font.bold: true
					font.pixelSize: 12*wpp.dp2px
				}
			}
		}
		section.property: "firstLetter"
		section.criteria: ViewSection.FullString
		section.delegate: sectionHeader

		delegate: Rectangle {
			id: addressBookPlacesListViewItem
			width: addressBookPlacesListView.width
			//height: 40*wpp.dp2px
			property int letterIndex: {
				var LETTER_A = 65;
				var firstLetter = modelData.firstLetter;
				var firstLetterAscii = firstLetter.toUpperCase().charCodeAt(0);

				//console.debug("firstLetter=" + firstLetter);
				//console.debug("firstLetterAscii=" + firstLetterAscii);

				var i = myAddressBookUI._letterIndices[
					parseInt(firstLetterAscii)-LETTER_A];
				//console.debug("letterIndex=" + firstLetter);
				return i;
			}
			property bool isFirstOfLetterIndex: {
				return index == letterIndex && letterIndex >= 0;
			}

			height: {
				if ( !visible )
				{
					return 0 + (sectionHeaderRectangle.height);
				}

				var h = (sectionHeaderRectangle.height) +
						phoneContactNameText.anchors.topMargin + phoneContactNameText.height +
						emptyPhonesAndEmailsMsg.height +
					phoneContactPhoneListColumn.height
					+ phoneContactEmailListColumn.height
						+ 10*wpp.dp2px;
				if ( h < sectionHeaderRectangle.height + 60*wpp.dp2px )
					h = sectionHeaderRectangle.height + 60*wpp.dp2px;
				return h;
			}
			color: "#ffffff"
			visible: {
				if ( myAddressBookUI.keyword == '' )
					return true;
				else
				{
					//console.debug("name=" + modelData.latinFullName + ",isKeywordMatched=" + modelData.isKeywordMatched);
					return modelData.isKeywordMatched;
				}
				/*
				//compare name with myAddressBookUI.keyword
				var indexInFirstname = modelData.firstName.indexOf( searchField.text );
				var indexInLastname = modelData.lastName.indexOf( searchField.text );
				if ( indexInFirstname >= 0 || indexInLastname >= 0 )
					return true;
				else
					return false;
				*/
			}

			Rectangle {
				id: sectionHeaderRectangle
				visible: {
					//console.debug("name:" + modelData.latinFullName + ":isFirstPersonInGroup=" + modelData.isFirstPersonInGroup);
					if ( myAddressBookUI.keyword != '' )
						return false;
					else
						return modelData.isFirstPersonInGroup

					/*if ( myAddressBookUI.keyword != '' )
						return false;
					else
						return addressBookPlacesListViewItem.isFirstOfLetterIndex;
						*/
				}
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				height: visible? 24*wpp.dp2px : 0
				color: "#f0f0f0"
				Text {
					anchors.fill: parent
					anchors.leftMargin:10*wpp.dp2px
					text: {
						var firstLetter = "" + modelData.firstLetter;
						return firstLetter.toUpperCase();
					}
					font.pixelSize: 12*wpp.dp2px
					color: "#7f7f7f"
					verticalAlignment: Text.AlignVCenter
				}
			}

			MouseArea {
				anchors.top: sectionHeaderRectangle.bottom
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				//anchors.fill: parent
				Overlay { target: parent; isTargetMouseArea: true }
				onClicked: {
					//console.debug("================================ " + model.index);
					////console.debug("================================ UserID  " + modelData.user.userId);

					//console.debug("phones=" + modelData.phones.length);
					//console.debug("emails=" + modelData.emails.length);
					if ( modelData.phones.length == 0 && modelData.emails.length == 0 )
					{
						emptyPhonesAndEmailsMsg.visible = true;
						return;
					}

					modelData[myAddressBookUI.isSelectedFieldName] = !modelData[myAddressBookUI.isSelectedFieldName];
					//console.debug("1.....");
					if ( modelData[myAddressBookUI.isSelectedFieldName] )
					{
						//console.debug("2.....");
						if ( myAddressBookUI.requiresBothPhoneAndEmail )
						{
							//console.debug("3.....");
							modelData.selectOnePhone();
							//console.debug("4.....");
							modelData.selectOneEmail();
						}
						else if ( myAddressBookUI.atLeastOneChoice )
						{
							//console.debug("4.....");
							if ( modelData.selectedPhonesCount + modelData.selectedEmailsCount < 1 )
							{
								modelData.selectOnePhoneOrEmail();
							}
						}
						//console.debug("5.....");
						myAddressBookUI.selected(modelData);
						//console.debug("6.....");
					}
					else
					{
						//console.debug("7.....");
						myAddressBookUI.deselected(modelData);
						//createEventMainUI.selectedInvitedPhoneContactCount--;
					}

					//console.debug("8.....");
				}
			}

			Avatar {
				id: addressBookContactProfilePhoto
				width: 40*wpp.dp2px
				height: 40*wpp.dp2px
				circleMask: false
				anchors.top: sectionHeaderRectangle.bottom
				anchors.topMargin:10*wpp.dp2px
				anchors.left: parent.left
				anchors.leftMargin:10*wpp.dp2px
				//url: modelData.user.profilePhotoUrl
				//anchors.verticalCenter: parent.verticalCenter
			}
			Rectangle {
				border.color: "#dddddd"
				border.width: 1*wpp.dp2px
				anchors.fill: addressBookContactProfilePhoto
				color: "transparent"
			}

			Text {
				id: phoneContactNameText
				verticalAlignment: Text.AlignVCenter
				anchors.left: addressBookContactProfilePhoto.right
				anchors.leftMargin: 10*wpp.dp2px
				font.pixelSize: 14*wpp.dp2px
				height: 30*wpp.dp2px
				anchors.topMargin:10*wpp.dp2px
				anchors.top: sectionHeaderRectangle.bottom
				//text: modelData.latinFullname
				text: modelData.fullName
//							color: modelData.isSelected? "#0080ff" : "#333333"
				color: modelData[myAddressBookUI.isSelectedFieldName]? "#0080ff" : "#333333"

				font.bold: true
			}
			Text {
				id: emptyPhonesAndEmailsMsg
				anchors.top:phoneContactNameText.bottom
				anchors.leftMargin: 10*wpp.dp2px
				anchors.left:addressBookContactProfilePhoto.right
				anchors.right: parent.right
				anchors.rightMargin:40*wpp.dp2px
				width: parent.width
				height: visible ? 32*wpp.dp2px : 0
				text: qsTr("No phones/emails available")
				font.pixelSize: 12*wpp.dp2px
				color: "#ff0000"
				visible: false
			}
			Column {
				id: phoneContactPhoneListColumn
				anchors.top:emptyPhonesAndEmailsMsg.bottom
				anchors.leftMargin: 10*wpp.dp2px
				anchors.left:addressBookContactProfilePhoto.right
				anchors.right: parent.right
				anchors.rightMargin:40*wpp.dp2px
				height: visible? modelData.phones.length*40*wpp.dp2px : 0
				visible: myAddressBookUI.alwaysShowDetails ? true : addressBookContactAcceptImgOverlay.visible
				property variant addressBookContact: modelData
				Repeater {
					model: modelData.phones
					Rectangle {
						id: contactPhoneItemBox
						anchors.left: parent.left
						anchors.right: parent.right
						height: 40*wpp.dp2px
						color: "transparent"
						property var phoneObj: modelData
						Image {
							id: contactPhoneItemBoxTickIcon
							source: "qrc:/img/android-icons/All_Icons/holo_light/xhdpi/1-navigation-back.png"
							width: 20*wpp.dp2px
							height: 20*wpp.dp2px
							//anchors.verticalCenter: parent.verticalCenter
							anchors.top: parent.top
							anchors.right: parent.right
							anchors.rightMargin:10*wpp.dp2px
							opacity: 0.9
							visible: false // modelData.isInvited
						}
						ColorOverlay {
							id: isPhoneSelectedColorOverlay
							source: contactPhoneItemBoxTickIcon
							anchors.fill: contactPhoneItemBoxTickIcon
							color: "#ff0080ff"
							visible: phoneContactPhoneListColumn.addressBookContact[myAddressBookUI.isSelectedFieldName] ? phoneObj.isSelected : false
										 //phoneContactPhoneListColumn.addressBookContact.isInvited ? modelData.isSelected
							/*无条件显示所有手机选
							visible:{

								if ( myAddressBookUI.onClickType == "RSVP")
								{
									return phoneContactPhoneListColumn.addressBookContact.isInvited;
								}
								else if ( myAddressBookUI.onClickType == "NOTIFIED" )
								{
									return phoneContactPhoneListColumn.addressBookContact.isNotified;
								}

							}*/
						}

						Text {
							id: contactPhoneText
							anchors.left: parent.left
							anchors.right: contactPhoneItemBoxTickIcon.left
							anchors.rightMargin: 5*wpp.dp2px
							clip: true
							height: 20*wpp.dp2px
							text: phoneObj.phone
							color: isPhoneSelectedColorOverlay.visible? "#0080ff" : "#333333"
							/*无条件显示全部手机号被选
							color: {

								if ( myAddressBookUI.onClickType == "RSVP")
								{
									return phoneContactPhoneListColumn.addressBookContact.isInvited? "#0080ff" : "#333333";
								}
								else if ( myAddressBookUI.onClickType == "NOTIFIED" )
								{
									return phoneContactPhoneListColumn.addressBookContact.isNotified? "#0080ff" : "#333333";
								}
							}*/
							font.pixelSize: 14*wpp.dp2px
							font.bold: false
							verticalAlignment: Text.AlignVCenter
						}
						Text {
							id: contactPhoneDescription
							anchors.top: contactPhoneText.bottom
							anchors.left: parent.left
							anchors.right: contactPhoneItemBoxTickIcon.left
							height: 15*wpp.dp2px
							text: phoneObj.label
							color: isPhoneSelectedColorOverlay.visible? "#0080ff" : "#333333"
							/*无条件显示全部手机号被选
							color: {

								if ( myAddressBookUI.onClickType == "RSVP")
								{
									return phoneContactPhoneListColumn.addressBookContact.isInvited? "#0080ff" : "#333333";
								}
								else if ( myAddressBookUI.onClickType == "NOTIFIED" )
								{
									return phoneContactPhoneListColumn.addressBookContact.isNotified? "#0080ff" : "#333333";
								}
							}*/
							font.pixelSize: 10*wpp.dp2px
							font.bold: false
							verticalAlignment: Text.AlignVCenter
						}
						MouseArea {
							anchors.fill: parent
							Overlay { target: parent; isTargetMouseArea: true }
							onClicked: {
								if ( myAddressBookUI.atLeastOneChoice &&
										modelData.isSelected &&
										phoneContactPhoneListColumn.addressBookContact.selectedPhonesCount
										+ phoneContactPhoneListColumn.addressBookContact.selectedEmailsCount == 1 )
										return;

								if ( myAddressBookUI.mutexInPhones &&
										!modelData.isSelected &&
										phoneContactPhoneListColumn.addressBookContact.selectedPhonesCount == 1 )
									phoneContactPhoneListColumn.addressBookContact.clearSelectedPhones();//force only 1 selection

								modelData.isSelected = !modelData.isSelected;

								if ( myAddressBookUI.requiresBothPhoneAndEmail
										&& phoneContactPhoneListColumn.addressBookContact.selectedPhonesCount == 0 )
									modelData.isSelected = true;

								if ( myAddressBookUI.requiresBothPhoneAndEmail )
									phoneContactPhoneListColumn.addressBookContact.selectOneEmail();

								if ( phoneContactPhoneListColumn.addressBookContact.selectedPhonesCount +
										phoneContactPhoneListColumn.addressBookContact.selectedEmailsCount > 0 )
								{
									phoneContactPhoneListColumn.addressBookContact[myAddressBookUI.isSelectedFieldName] = true;
									myAddressBookUI.selected(modelData);
								}
								else if ( phoneContactPhoneListColumn.addressBookContact.selectedPhonesCount +
										phoneContactPhoneListColumn.addressBookContact.selectedEmailsCount == 0
										&& myAddressBookUI.atLeastOneChoice )
								{
									phoneContactPhoneListColumn.addressBookContact[myAddressBookUI.isSelectedFieldName] = false;
									myAddressBookUI.deselected(modelData);
								}

								//mouse.accepted = false;
							}
						}//MouseArea
					}//Rectangle
				}//Repeater
			}//Column
			Column {
				id: phoneContactEmailListColumn
				anchors.top:phoneContactPhoneListColumn.bottom
				anchors.leftMargin: 10*wpp.dp2px
				anchors.left:addressBookContactProfilePhoto.right
				anchors.right: parent.right
				anchors.rightMargin:40*wpp.dp2px
				height: visible? modelData.emails.length*40*wpp.dp2px : 0
				visible: myAddressBookUI.alwaysShowDetails ? true : addressBookContactAcceptImgOverlay.visible
				property variant addressBookContact: modelData
				Repeater {
					model: modelData.emails
					Rectangle {
						id: contactEmailItemBox
						anchors.left: parent.left
						anchors.right: parent.right
						height: 40*wpp.dp2px
						color: "transparent"
						property var emailObj: modelData
						Image {
							id: contactEmailItemBoxTickIcon
							source: "qrc:/img/android-icons/All_Icons/holo_light/xhdpi/1-navigation-back.png"
							width: 20*wpp.dp2px
							height: 20*wpp.dp2px
							//anchors.verticalCenter: parent.verticalCenter
							anchors.top: parent.top
							anchors.right: parent.right
							anchors.rightMargin:10*wpp.dp2px
							opacity: 0.9
							visible: false // modelData.isInvited
						}
						ColorOverlay {
							id: isEmailSelectedColorOverlay
							source: contactEmailItemBoxTickIcon
							anchors.fill: contactEmailItemBoxTickIcon
							color: "#ff0080ff"
							visible: phoneContactPhoneListColumn.addressBookContact[myAddressBookUI.isSelectedFieldName] ? emailObj.isSelected : false
							/*无条件显示所有Email选
							visible:{

								if ( myAddressBookUI.onClickType == "RSVP")
								{
									return phoneContactPhoneListColumn.addressBookContact.isInvited;
								}
								else if ( myAddressBookUI.onClickType == "NOTIFIED" )
								{
									return phoneContactPhoneListColumn.addressBookContact.isNotified;
								}

							}*/
						}

						Text {
							id: contactEmailText
							anchors.left: parent.left
							anchors.right: contactEmailItemBoxTickIcon.left
							anchors.rightMargin: 5*wpp.dp2px
							clip: true
							height: 20*wpp.dp2px
							text: emailObj.email
							color: isEmailSelectedColorOverlay.visible? "#0080ff" : "#333333"
							/*无条件显示全部Email被选
							color: {

								if ( myAddressBookUI.onClickType == "RSVP")
								{
									return phoneContactPhoneListColumn.addressBookContact.isInvited? "#0080ff" : "#333333";
								}
								else if ( myAddressBookUI.onClickType == "NOTIFIED" )
								{
									return phoneContactPhoneListColumn.addressBookContact.isNotified? "#0080ff" : "#333333";
								}
							}*/
							font.pixelSize: 14*wpp.dp2px
							font.bold: false
							verticalAlignment: Text.AlignVCenter
						}
						Text {
							id: contactEmailDescription
							anchors.top: contactEmailText.bottom
							anchors.left: parent.left
							anchors.right: contactEmailItemBoxTickIcon.left
							height: 15*wpp.dp2px
							text: emailObj.label
							color: isEmailSelectedColorOverlay.visible? "#0080ff" : "#333333"
							/*无条件显示全部Email被选
							color: {

								if ( myAddressBookUI.onClickType == "RSVP")
								{
									return phoneContactPhoneListColumn.addressBookContact.isInvited? "#0080ff" : "#333333";
								}
								else if ( myAddressBookUI.onClickType == "NOTIFIED" )
								{
									return phoneContactPhoneListColumn.addressBookContact.isNotified? "#0080ff" : "#333333";
								}
							}*/
							font.pixelSize: 10*wpp.dp2px
							font.bold: false
							verticalAlignment: Text.AlignVCenter
						}
						MouseArea {
							anchors.fill: parent
							Overlay { target: parent; isTargetMouseArea: true }
							onClicked: {
								if ( myAddressBookUI.atLeastOneChoice &&
										modelData.isSelected &&
										phoneContactEmailListColumn.addressBookContact.selectedEmailsCount == 1 )
										return;

								if ( myAddressBookUI.mutexInEmails &&
										!modelData.isSelected &&
										phoneContactEmailListColumn.addressBookContact.selectedEmailsCount == 1 )
									phoneContactEmailListColumn.addressBookContact.clearSelectedEmails();//force only 1 selection

								modelData.isSelected = !modelData.isSelected;

								if ( myAddressBookUI.requiresBothPhoneAndEmail
										&& phoneContactEmailListColumn.addressBookContact.selectedEmailsCount == 0 )
									modelData.isSelected = true;

								if ( myAddressBookUI.requiresBothPhoneAndEmail )
									phoneContactEmailListColumn.addressBookContact.selectOnePhone();

								if ( phoneContactEmailListColumn.addressBookContact.selectedPhonesCount +
										phoneContactEmailListColumn.addressBookContact.selectedEmailsCount > 0 )
								{
									phoneContactEmailListColumn.addressBookContact[myAddressBookUI.isSelectedFieldName] = true;
									myAddressBookUI.selected(modelData);
								}
								else if ( phoneContactEmailListColumn.addressBookContact.selectedPhonesCount +
										phoneContactEmailListColumn.addressBookContact.selectedEmailsCount == 0
										&& myAddressBookUI.atLeastOneChoice )
								{
									phoneContactEmailListColumn.addressBookContact[myAddressBookUI.isSelectedFieldName] = false;
									myAddressBookUI.deselected(modelData);
								}

								//mouse.accepted = false;
							}
						}//MouseArea
					}//Rectangle
				}//Repeater
			}//Column

			Rectangle {
				y: parent.height - 1
				width: parent.width
				height: 1
				Component.onCompleted: {
					var modelCount = addressBookPlacesListView.count - 1;
					if ( model.index === modelCount )
						color = Qt.rgba(0,0,0,0);
					else
						color = Qt.rgba(0,0,0,0.1);
				}
			}
			Image {
				id: addressBookContactAcceptImg
				source: "qrc:/img/android-icons/All_Icons/holo_light/xhdpi/1-navigation-accept.png"
				width: 30*wpp.dp2px
				height: 30*wpp.dp2px
				anchors.top: sectionHeaderRectangle.bottom
				anchors.topMargin:10*wpp.dp2px
				anchors.right: parent.right
				anchors.rightMargin:10*wpp.dp2px
				opacity: 0.9
				visible: false // modelData.isInvited
			}
			ColorOverlay {
				id: addressBookContactAcceptImgOverlay
				source: addressBookContactAcceptImg
				anchors.fill: addressBookContactAcceptImg
				color: "#ff0080ff"
//							visible: modelData.isSelected
				visible:{
					if ( modelData[myAddressBookUI.isSelectedFieldName] == undefined )
						return false;
					else
						return modelData[myAddressBookUI.isSelectedFieldName];
				}
			}
			Rectangle {
				height: 1*wpp.dp2px
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom
				color: "#eeeeee"
			}
		}//delegate
		focus: true
    }

	Rectangle {
		id: letterIndexBarRect
		anchors.top: addressBookPlacesListView.top;
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		width: 24*wpp.dp2px
		color: "#ffffff"
		Column {
			id: letterIndexBar
			anchors.fill: parent
			visible: myAddressBookUI.keyword == ''
			z: addressBookPlacesListView.z + 1
			property int oneLetterIndexHeight: letterIndexBar.height / myAddressBookUI._indexChars.length
			Repeater {
				id: letterIndexBarRepeater
				model: myAddressBookUI._indexChars.length
				Rectangle {
					width: letterIndexBar.width
					height: letterIndexBar.oneLetterIndexHeight
					//color: Qt.rgba(0,0,0,0.3)
					Text {
						anchors.fill: parent
						text: myAddressBookUI._indexChars[index];
						font.pixelSize: 12*wpp.dp2px
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
						color: {
							//console.debug("index:::" + index);
							//console.debug("====>" + myAddressBookUI._letterIndices);
							//console.debug("====>" + myAddressBookUI._letterIndices[index]);
							return myAddressBookUI._letterIndices[index] >= 0 ?
							"#000000" : "#7f7f7f"
						}
					}
					MouseArea {
						anchors.fill: parent
						Overlay { target: parent; isTargetMouseArea: true }
						onClicked: {
							var i = parseInt(index);
							//console.debug("i=" + 1);
							//console.debug("myAddressBookUI._letterIndices[i]=" + myAddressBookUI._letterIndices[ i ]);
							if ( myAddressBookUI._letterIndices[ i ] >= 0 )
							{
								addressBookPlacesListView.positionViewAtIndex(
									myAddressBookUI._letterIndices[ i ],
									ListView.Beginning
								);
							}
						}
					}
				}
			}
		}
	}
	MouseArea {
		id: indexColumnBarMouseArea
		anchors.fill: letterIndexBarRect
		onMouseYChanged: {
			//console.debug("mouse-y:"+mouseY);
			//console.debug("letterIndexBar.oneLetterIndexHeight:"+letterIndexBar.oneLetterIndexHeight)
			var iMod = mouseY % letterIndexBar.oneLetterIndexHeight;
			//console.debug("iMod="+iMod);
			var i = parseInt( mouseY / letterIndexBar.oneLetterIndexHeight );
			//console.debug("i="+i);
			//if ( iMod > 0 )
			//{
			//	i++;
			//}

			enlargeCurrentLetterText.text = myAddressBookUI._indexChars[i];

			//console.debug("letterIndices:" + myAddressBookUI._letterIndices)
			//console.debug("position-view-at:" + myAddressBookUI._letterIndices[ i ]);
			if ( myAddressBookUI._letterIndices[ i ] >= 0 )
			{
				addressBookPlacesListView.positionViewAtIndex(
					myAddressBookUI._letterIndices[ i ],
					ListView.Beginning
				);
			}
		}
	}

	Rectangle {
		//anchors.top: parent.top
		//anchors.topMargin: 50*wpp.dp2px
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.verticalCenter: addressBookPlacesListView.verticalCenter
		width:100*wpp.dp2px
		height:width
		color: Qt.rgba(0,0,0,0.3)
		radius: 4*wpp.dp2px
		visible: indexColumnBarMouseArea.pressed
		Text {
			id: enlargeCurrentLetterText
			anchors.fill: parent
			color: "#ffffff"
			font.pixelSize: 46*wpp.dp2px
			font.bold: true
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			/*text: {
				var iMod = letterIndexBarRect.mouseY % letterIndexBar.oneLetterIndexHeight;
				var i = parseInt( letterIndexBarRect.mouseY / letterIndexBar.oneLetterIndexHeight );
				//console.debug("enlarge:i=" + i);
				//console.debug("enlarge:char at i=" + myAddressBookUI._indexChars[i]);
				return myAddressBookUI._indexChars[i];
			}*/
		}
	}

	/*Component.onCompleted: {
		createEventUIController.loadAddressBook();
		//sys.hasNetworkChanged.connect( myAddressBookUI.mayAccessNetwork );
		//mayAccessNetwork();
	}*/
}
