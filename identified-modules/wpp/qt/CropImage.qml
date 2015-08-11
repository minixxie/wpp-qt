import QtQuick 2.4
import QtQuick.Controls 1.3
import QtQuick.Controls.Styles 1.3

Item {
    id: cropImage
    property int cropSize : 128*wpp.dp2px
    property alias source : preview.source
    property alias rotation: imageRotation.angle

	property int minCropWidth: 50
	property int minCropHeight: 50

	property int afterCopyScaleWidth: 0  //0 represents not to scale
	property int afterCopyScaleHeight: 0  //0 represents not to scale

    signal closed
	signal cropFinished(int id)

	Rectangle {
		id: cropUI
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		//anchors.bottom: buttonUI.top
		height: parent.height - buttonUI.height
		Image {
			id: preview
			cache: false
			anchors.fill : parent
			fillMode: Image.PreserveAspectFit
			smooth: true
			//z: 1
            transform: Rotation {
                id: imageRotation
                origin.x: preview.width/2;
                origin.y: preview.height/2;
                axis { x: 0; y: 0; z: 1 }
                angle: 0
                onAngleChanged: {
					//console.debug("angle=" + angle);
                }
            }
        }


		Rectangle {
			id: previewTop
			anchors.left: parent.left
			//height: (parent.height - cropSize)/2
			anchors.top: parent.top
			anchors.bottom: cropArea.top
			width: parent.width
			color: "#000000"
			opacity: 0.8
			z: preview.z + 1
			MouseArea {
				anchors.fill: parent
				onClicked: {
					//cropImage.closed();
				}
			}
		}

		Rectangle {
			id: previewBottom
			anchors.top: cropArea.bottom
			anchors.left: parent.left
			anchors.bottom: parent.bottom
			width: parent.width
			//height: (parent.height - cropSize)/2
			color: "#000000"
			opacity: 0.8
			z: preview.z + 1
			MouseArea {
				anchors.fill: parent
				onClicked: {
					//cropImage.closed();
				}
			}
		}

		Rectangle {
			id: previewLeft
			anchors.left: parent.left
			anchors.top: previewTop.bottom
			anchors.bottom: previewBottom.top
			anchors.right: cropArea.left
			color: "#000000"
			opacity: 0.8
			z: preview.z + 1
			MouseArea {
				anchors.fill: parent
				onClicked: {
					//cropImage.closed();
				}
			}
		}

		Rectangle {
			id: previewRight
			anchors.left: cropArea.right
			anchors.top: previewTop.bottom
			anchors.bottom: previewBottom.top
			anchors.right: parent.right
			color: "#000000"
			opacity: 0.8
			z: preview.z + 1
			MouseArea {
				anchors.fill: parent
				onClicked: {
					//cropImage.closed();
				}
			}
		}


			Rectangle {
				id: cropArea
				z: preview.z + 1
				width: {

					//console.debug("preview size:" + preview.sourceSize.width + "x" + preview.sourceSize.height);
					//console.debug("preview container size:" + preview.width + "x" + preview.height);
					//console.debug("preview implicit size:" + preview.paintedWidth + "x" + preview.paintedHeight);
					if ( preview.sourceSize.width > preview.sourceSize.height )
					{
						//console.debug("landscape preview");
						return preview.paintedHeight*0.8
					}
					else
					{
						//console.debug("portrait preview");
						return preview.paintedWidth*0.8;
					}
					//return preview.sourceSize.width > preview.sourceSize.height ? preview.sourceSize.height*0.8 : preview.sourceSize.width*0.8;
				}
				height: width
				x: ( parent.width - width )/2
				y: ( parent.height - height)/2
				color: "transparent"
				MouseArea {
					id: cropAreaMouseArea
					z: cropArea.z + 1
					anchors.fill: parent
					drag.target: parent
					drag.minimumX: (preview.width - preview.paintedWidth)/2
					drag.maximumX: preview.width - (preview.width - preview.paintedWidth)/2 - cropArea.width
					drag.minimumY: (preview.height - preview.paintedHeight)/2
					drag.maximumY: preview.height - (preview.height - preview.paintedHeight)/2 - cropArea.height
				}


				Rectangle {
					id: topLeftResizer
					width:20*wpp.dp2px
					height:width
					color: "transparent"
					x: getDefaultX()
					y: getDefaultY()
					z: cropArea.z + 1
					Rectangle {
						width: 10*wpp.dp2px
						height: width
						anchors.centerIn: parent
						color: Qt.rgba(1,1,1,0.4)
					}
					MouseArea {
						id: topLeftResizerMouseArea
						anchors.fill: parent
						drag.target: parent
						drag.threshold: 0
						onPositionChanged: parent.resize()
					}
					function getDefaultX() { var x = -width/2 ; return x; }
					function getDefaultY() { var y = -height/2; return y; }
					function resize()
					{
						if ( !topLeftResizerMouseArea.drag.active )
						{
							//console.debug("mouse-area not dragging");
							//reset
							x = getDefaultX();
							y = getDefaultY();
							return;
						}

						var deltaX = x - getDefaultX();
						var deltaY = y - getDefaultY();
						if ( !( (deltaX < 0 && deltaY < 0) || (deltaX > 0 && deltaY > 0) ) )
						{
							//console.debug("not correct direction");
							//reset
							x = getDefaultX();
							y = getDefaultY();
							return;
						}

						if ( Math.abs(deltaX) > Math.abs(deltaY) )//use smaller delta
							deltaX = deltaY;
						else if ( Math.abs(deltaY) > Math.abs(deltaX) )//use smaller delta
							deltaY = deltaX;

						if ( deltaX < 0 && deltaY < 0 )//possible direction 1: north-west enlarge
						{
							//exceed top-left of image
							if ( !(
								cropArea.x >= (preview.width - preview.paintedWidth)/2 - deltaX
								&& cropArea.y >= (preview.height - preview.paintedHeight)/2 - deltaY
							) )
							{
								//console.debug("exceed top-left of image");
								//reset
								x = getDefaultX();
								y = getDefaultY();
								return;
							}
							cropArea.x += deltaX;
							cropArea.y += deltaY;
							cropArea.width -= deltaX;
								topRightResizer.x = topRightResizer.getDefaultX();
								bottomRightResizer.x = bottomRightResizer.getDefaultX();
							cropArea.height -= deltaY;
								bottomLeftResizer.y = bottomLeftResizer.getDefaultY();
								bottomRightResizer.y = bottomRightResizer.getDefaultY();
						}
						else if ( deltaX > 0 && deltaY > 0 )//possible direction 2: south-east diminish
						{
							//not enough to diminish
                            if ( !( cropArea.width >= cropImage.minCropWidth + deltaX && cropArea.height >= cropImage.minCropHeight + deltaY ) )
							{
								//console.debug("not enough to diminish");
								//reset
								x = getDefaultX();
								y = getDefaultY();
								return;
							}
							cropArea.x += deltaX;
							cropArea.y += deltaY;
							cropArea.width -= deltaX;
								topRightResizer.x = topRightResizer.getDefaultX();
								bottomRightResizer.x = bottomRightResizer.getDefaultX();
							cropArea.height -= deltaY;
								bottomLeftResizer.y = bottomLeftResizer.getDefaultY();
								bottomRightResizer.y = bottomRightResizer.getDefaultY();
						}
						//reset
						x = getDefaultX();
						y = getDefaultY();
					}
				}
				Rectangle {
					id: topRightResizer
					width:20*wpp.dp2px
					height:width
					color: "transparent"
					x: getDefaultX()
					y: getDefaultY()
					z: cropArea.z + 1
					Rectangle {
						width: 10*wpp.dp2px
						height: width
						anchors.centerIn: parent
						color: Qt.rgba(1,1,1,0.4)
					}
					MouseArea {
						id: topRightResizerMouseArea
						anchors.fill: parent
						drag.target: parent
						drag.threshold: 0
						onPositionChanged: parent.resize()
					}
					function getDefaultX() { return cropArea.width - width/2; }
					function getDefaultY() { return -height/2; }
					function resize()
					{
						if ( !topRightResizerMouseArea.drag.active )
						{
							//console.debug("mouse-area not dragging");
							//reset
							x = getDefaultX();
							y = getDefaultY();
							return;
						}

						var deltaX = x - getDefaultX();
						var deltaY = y - getDefaultY();
						if ( !( (deltaX < 0 && deltaY > 0) || (deltaX > 0 && deltaY < 0) ) )
						{
							//console.debug("not correct direction");
							//console.debug("deltaX:"+deltaX);
							//console.debug("deltaY:"+deltaY);
							//reset
							x = getDefaultX();
							y = getDefaultY();
							return;
						}

						if ( Math.abs(deltaX) > Math.abs(deltaY) )//use smaller delta
							deltaX = -deltaY;
						else if ( Math.abs(deltaY) > Math.abs(deltaX) )//use smaller delta
							deltaY = -deltaX;

						if ( deltaX > 0 && deltaY < 0 )//possible direction 1: north-east enlarge
						{
							//console.debug("cropArea.x:" + cropArea.x);
							//console.debug("cropArea.width:" + cropArea.width);
							//console.debug("deltaX:" + deltaX);
							//console.debug("preview.width:" + preview.width);
							//console.debug("preview.paintedWidth:" + preview.paintedWidth);
							//console.debug("cropArea.y:" + cropArea.y);
							//console.debug("preview.height:" + preview.height);
							//console.debug("preview.paintedHeight:" + preview.paintedHeight);
							//console.debug("deltaY:" + deltaY);
							//exceed top-right of image
							if ( !(
								cropArea.x + cropArea.width + deltaX <= preview.width - (preview.width - preview.paintedWidth)/2
								&& cropArea.y >= (preview.height - preview.paintedHeight)/2 - deltaY
							) )
							{
								//console.debug("exceed top-right of image");
								//reset
								x = getDefaultX();
								y = getDefaultY();
								return;
							}
							//cropArea.x += deltaX;
							cropArea.y += deltaY;
							cropArea.width += deltaX;
								bottomRightResizer.x = bottomRightResizer.getDefaultX();
							cropArea.height -= deltaY;
								topLeftResizer.y = topLeftResizer.getDefaultY();
								bottomLeftResizer.y = bottomLeftResizer.getDefaultY();
								bottomRightResizer.y = bottomRightResizer.getDefaultY();
						}
						else if ( deltaX < 0 && deltaY > 0 )//possible direction 2: south-west diminish
						{
							//not enough to diminish
                            if ( !( cropArea.width >= cropImage.minCropWidth + deltaX && cropArea.height >= cropImage.minCropHeight + deltaY ) )
							{
								//console.debug("not enough to diminish");
								//reset
								x = getDefaultX();
								y = getDefaultY();
								return;
							}
							//cropArea.x += deltaX;
							cropArea.y += deltaY;
							cropArea.width += deltaX;
								bottomRightResizer.x = bottomRightResizer.getDefaultX();
							cropArea.height -= deltaY;
								topLeftResizer.y = topLeftResizer.getDefaultY();
								bottomLeftResizer.y = bottomLeftResizer.getDefaultY();
								bottomRightResizer.y = bottomRightResizer.getDefaultY();
						}
						//reset
						x = getDefaultX();
						y = getDefaultY();
					}
				}
				Rectangle {
					id: bottomLeftResizer
					width:20*wpp.dp2px
					height:width
					color: "transparent"
					x: getDefaultX()
					y: getDefaultY()
					z: cropArea.z + 1
					Rectangle {
						width: 10*wpp.dp2px
						height: width
						anchors.centerIn: parent
						color: Qt.rgba(1,1,1,0.4)
					}
					MouseArea {
						id: bottomLeftResizerMouseArea
						anchors.fill: parent
						drag.target: parent
						drag.threshold: 0
						onPositionChanged: parent.resize()
					}
					function getDefaultX() { return -width/2; }
					function getDefaultY() { return cropArea.height - height/2; }
					function resize()
					{
						if ( !bottomLeftResizerMouseArea.drag.active )
						{
							//console.debug("mouse-area not dragging");
							//reset
							x = getDefaultX();
							y = getDefaultY();
							return;
						}

						//console.debug("x:" + x + ",oldX:" + (-width/2) );
						var deltaX = x - getDefaultX();
						var deltaY = y - getDefaultY();
						if ( !( (deltaX < 0 && deltaY > 0) || (deltaX > 0 && deltaY < 0) ) )
						{
							//console.debug("not correct direction");
							//console.debug("deltaX:"+deltaX);
							//console.debug("deltaY:"+deltaY);
							//reset
							x = getDefaultX();
							y = getDefaultY();
							return;
						}

						//console.debug("b4;deltaX:" + deltaX);
						//console.debug("b4;deltaY:" + deltaY);

						if ( Math.abs(deltaX) > Math.abs(deltaY) )//use smaller delta
							deltaX = -deltaY;
						else if ( Math.abs(deltaY) > Math.abs(deltaX) )//use smaller delta
							deltaY = -deltaX;

						if ( deltaX < 0 && deltaY > 0 )//possible direction 1: south-west enlarge
						{
							//console.debug("cropArea.x:" + cropArea.x);
							//console.debug("cropArea.height:" + cropArea.height);
							//console.debug("deltaX:" + deltaX);
							//console.debug("preview.width:" + preview.width);
							//console.debug("preview.paintedWidth:" + preview.paintedWidth);
							//console.debug("cropArea.y:" + cropArea.y);
							//console.debug("preview.height:" + preview.height);
							//console.debug("preview.paintedHeight:" + preview.paintedHeight);
							//console.debug("deltaY:" + deltaY);
							//exceed bottom-left of image
							if ( !(
								cropArea.x + deltaX >= (preview.width - preview.paintedWidth)/2
								&& cropArea.y + cropArea.height + deltaY <= preview.height - (preview.height - preview.paintedHeight)/2
							) )
							{
								//console.debug("exceed bottom-left of image");
								//reset
								x = getDefaultX();
								y = getDefaultY();
								return;
							}
							cropArea.x += deltaX;
							//cropArea.y += deltaY;
							cropArea.width -= deltaX;
								topLeftResizer.x = topLeftResizer.getDefaultX();
								topRightResizer.x = topRightResizer.getDefaultX();
								bottomRightResizer.x = bottomRightResizer.getDefaultX();
							cropArea.height += deltaY;
								bottomRightResizer.y = bottomRightResizer.getDefaultY();
						}
						else if ( deltaX > 0 && deltaY < 0 )//possible direction 2: north-east diminish
						{
							//not enough to diminish
                            if ( !( cropArea.width >= cropImage.minCropWidth + deltaX && cropArea.height >= cropImage.minCropHeight + deltaY ) )
							{
								//console.debug("not enough to diminish");
								//reset
								x = getDefaultX();
								y = getDefaultY();
								return;
							}
							cropArea.x += deltaX;
							//cropArea.y += deltaY;
							cropArea.width -= deltaX;
								topLeftResizer.x = topLeftResizer.getDefaultX();
								topRightResizer.x = topRightResizer.getDefaultX();
								bottomRightResizer.x = bottomRightResizer.getDefaultX();
							cropArea.height += deltaY;
								bottomRightResizer.y = bottomRightResizer.getDefaultY();
						}
						//reset
						x = getDefaultX();
						y = getDefaultY();
					}
				}
				Rectangle {
					id: bottomRightResizer
					width:20*wpp.dp2px
					height:width
					color: "transparent"
					x: getDefaultX()
					y: getDefaultY()
					z: cropArea.z + 1
					Rectangle {
						width: 10*wpp.dp2px
						height: width
						anchors.centerIn: parent
						color: Qt.rgba(1,1,1,0.4)
					}
					MouseArea {
						id: bottomRightResizerMouseArea
						anchors.fill: parent
						drag.target: parent
						drag.threshold: 0
						onPositionChanged: parent.resize()
					}
					function getDefaultX() { return cropArea.width - width/2; }
					function getDefaultY() { return cropArea.height - height/2; }
					function resize()
					{
						if ( !bottomRightResizerMouseArea.drag.active )
						{
							//console.debug("mouse-area not dragging");
							//reset
							x = getDefaultX();
							y = getDefaultY();
							return;
						}

						var deltaX = x - getDefaultX();
						var deltaY = y - getDefaultY();
						if ( !( (deltaX < 0 && deltaY < 0) || (deltaX > 0 && deltaY > 0) ) )
						{
							//console.debug("not correct direction");
							//reset
							x = getDefaultX();
							y = getDefaultY();
							return;
						}

						if ( Math.abs(deltaX) > Math.abs(deltaY) )//use smaller delta
							deltaX = deltaY;
						else if ( Math.abs(deltaY) > Math.abs(deltaX) )//use smaller delta
							deltaY = deltaX;

						if ( deltaX > 0 && deltaY > 0 )//possible direction 1: south-east enlarge
						{
							//exceed bottom-right of image
							if ( !(
								cropArea.x + cropArea.width + deltaX <= preview.width - (preview.width - preview.paintedWidth)/2
								&& cropArea.y + cropArea.height + deltaY <= preview.height - (preview.height - preview.paintedHeight)/2
							) )
							{
								//console.debug("exceed bottom-right of image");
								//reset
								x = getDefaultX();
								y = getDefaultY();
								return;
							}
							//cropArea.x += deltaX;
							//cropArea.y += deltaY;
							cropArea.width += deltaX;
								topRightResizer.x = topRightResizer.getDefaultX();
								//bottomRightResizer.x = cropArea.width - bottomRightResizer.width/2;
							cropArea.height += deltaY;
								bottomLeftResizer.y = bottomLeftResizer.getDefaultY();
								//bottomRightResizer.y = cropArea.height - bottomRightResizer.height/2;
						}
						else if ( deltaX < 0 && deltaY < 0 )//possible direction 2: north-west diminish
						{
							//not enough to diminish
                            if ( !( cropArea.width >= cropImage.minCropWidth + deltaX && cropArea.height >= cropImage.minCropHeight + deltaY ) )
							{
								//console.debug("not enough to diminish");
								//reset
								x = getDefaultX();
								y = getDefaultY();
								return;
							}
							//cropArea.x += deltaX;
							//cropArea.y += deltaY;
							cropArea.width += deltaX;
								topRightResizer.x = topRightResizer.getDefaultX();
								//bottomRightResizer.x = cropArea.width - bottomRightResizer.width/2;
							cropArea.height += deltaY;
								bottomLeftResizer.y = bottomLeftResizer.getDefaultY();
								//bottomRightResizer.y = cropArea.height - bottomRightResizer.height/2;
						}
						//reset
						x = getDefaultX();
						y = getDefaultY();
					}
				}

				//onXChanged: //console.debug("cropArea-x:" + x);
				//onYChanged: //console.debug("cropArea-y:" + y);

			}//Rectangle(cropArea)



		/*BorderImage {
			id: cropArea
			width: cropSize
			anchors.top: previewTop.bottom
			anchors.bottom: previewBottom.top
			anchors.horizontalCenter: parent.horizontalCenter
			border { left: 10*wpp.dp2px; top: 10*wpp.dp2px; right: 10*wpp.dp2px; bottom: 10*wpp.dp2px }
			horizontalTileMode: BorderImage.Repeat
			verticalTileMode: BorderImage.Repeat
			z: 2

			Button {
				width: 60*wpp.dp2px
				height: 30*wpp.dp2px
				radius: 2*wpp.dp2px
				text: qsTr("test")
				textColor: "#636363"
				color: "#f0f0f0"
				onClicked: {

					//console.debug("previewWidth===>"+preview.width);
					//console.debug("previewHeight===>"+preview.height);
					//console.debug("previewX===>"+previewLeft.width);
					//console.debug("previewY===>"+previewTop.height);
					//console.debug("cropWidth===>"+cropArea.width);
					//console.debug("cropHeight===>"+cropArea.height);

					var id = photoCaptureController.crop(
						preview.width,
						preview.height,
						previewLeft.width,
						previewTop.height,
						cropArea.width,
						cropArea.height
					);
                    cropImage.cropFinished(id);

					cropArea.parent.closed()
				}

			}
		}*/

	}
	Rectangle {
		id: buttonUI
		height: 50*wpp.dp2px
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		color: "#dddddd"

		Button {
			id: cropButton
			width: 140*wpp.dp2px
			height: 44*wpp.dp2px
			anchors.verticalCenter: parent.verticalCenter
			anchors.left: parent.left
			anchors.leftMargin: 15*wpp.dp2px
			style: ButtonStyle {
				background: Rectangle {
					color: "#5dcb36"
					radius: 2*wpp.dp2px
				}
				label: Text {
					text: qsTr("Crop")
					color: "#ffffff"
					font.pixelSize: 16*wpp.dp2px
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}
			onClicked: {
				var scaledImageWidth = preview.paintedWidth;
				//console.debug("scaledImageWidth===>"+scaledImageWidth);
				var scaledImageHeight = preview.paintedHeight;
				//console.debug("scaledImageHeight===>"+scaledImageHeight);

				//console.debug("image left margin:" + ((preview.width - preview.paintedWidth)/2));
				var cropX = previewLeft.width - (preview.width - preview.paintedWidth)/2;
				//console.debug("cropX===>"+cropX);

				//console.debug("image top margin:" + ((preview.height - preview.paintedHeight)/2));
				var cropY = previewTop.height - (preview.height - preview.paintedHeight)/2;
				//console.debug("cropY===>"+cropY);

				//console.debug("cropWidth===>"+cropArea.width);
				//console.debug("cropHeight===>"+cropArea.height);

				photoCaptureController.saveCaptureFromFile(source);
				var id = photoCaptureController.crop(
					scaledImageWidth,
					scaledImageHeight,
					cropX,
					cropY,
					cropArea.width,
					cropArea.height,
					cropImage.afterCopyScaleWidth,
					cropImage.afterCopyScaleHeight
				);
				cropImage.cropFinished(id);
				cropImage.closed()
			}
		}
		Button {
			id: reshootButton
			width: 140*wpp.dp2px
			height: 44*wpp.dp2px
			anchors.verticalCenter: parent.verticalCenter
			anchors.right: parent.right
			anchors.rightMargin: 15*wpp.dp2px
			style: ButtonStyle {
				background: Rectangle {
					color: "#aaaaaa"
					radius: 2*wpp.dp2px
				}
				label: Text {
					text: qsTr("Back")
					color: "#ffffff"
					font.pixelSize: 16*wpp.dp2px
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}
			onClicked: {
                cropImage.closed();
			}
		}
	}



//    MouseArea {
//        anchors.fill: parent
//        onClicked: {
//            parent.closed();
//        }
//    }
}

