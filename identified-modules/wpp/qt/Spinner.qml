import QtQuick 2.1

Rectangle {
    id: digitItem

    property int visibleCount: 3
    property int from: 0
    property int to: 24

    property alias index: digitPath.currentIndex
	property string value: digitPath.currentIndex + from
		//if ( digitPath.currentItem == null ) //console.debug("digitPath.currentItem is NULL!");
		//return digitPath.currentItem != null ? digitPath.currentItem.text : "";
	//}
    property int digit: 0
    property int widthsize: 40*wpp.dp2px
    property int heightsize: 40*wpp.dp2px

	//signal onValueChanged
	Component.onCompleted: {
		//console.debug("spinner width:" + width);
	}

    width: widthsize
	height: heightsize + heightsize/2
    clip: true

    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: "black"
        }

        GradientStop {
            position: 0.5
            color: "#222222"
        }

		GradientStop {
            position: 1.0
            color: "black"
		}
    }

    border.color: "black"
    border.width: 1

	onFromChanged: {
		//console.debug("Spinner.onFromChanged:from="+ from);
		digitPath.currentIndex = digit - from;
	}
	onToChanged: {
		//console.debug("Spinner.onFromChanged:from="+ from);
        digitPath.currentIndex = digit - from;
	}
	onDigitChanged: {
		//console.debug("spinner.onDigitChanged:currentIndex(b4):" + digitPath.currentIndex);
		digitPath.currentIndex = digit - from;
		//console.debug("spinner.onDigitChanged:digit:" + digit);
		//console.debug("spinner.onDigitChanged:from:" + from);
		//console.debug("spinner.onDigitChanged:currentIndex(after):" + digitPath.currentIndex);
	}

    PathView {
        id: digitPath
        Component.onCompleted: {
			//console.debug("path view width:" + width);
			//console.debug("spinner dragMargin:" + dragMargin);
        }
        width: digitItem.widthsize
        height: (digitItem.heightsize - digitItem.heightsize/4) * (to -from + 1)
        anchors.centerIn: parent

        model: to -from + 1

        delegate: Text {
			width: digitItem.widthsize
            text: (index + from) < 10 ? "0" + (index + from) : "" + (index + from);
            color: "white";

            horizontalAlignment: Text.AlignHCenter;
            verticalAlignment: Text.AlignVCenter;

			font.pixelSize: digitItem.heightsize/2;
        }

        preferredHighlightBegin: 0.5
        preferredHighlightEnd: 0.5

        path: Path {
            startX: digitPath.width / 2
            startY: 0

            PathLine { x: digitPath.width / 2; y: digitPath.height }
        }

        onMovementEnded: {

            if ( currentItem != null )
            {
//                //console.debug("onMovementEnded:  " + currentItem.text);
            }
        }

        currentIndex: 0
        onCurrentIndexChanged: {

            if ( currentItem != null )
            {
//                //console.debug("onCurrentIndexChanged:  " + currentItem.text);
//                //console.debug("currentIndex:  " + currentIndex);
            }
        }
    }


    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
			GradientStop { position: 0.0; color: "black" }
			GradientStop { position: 0.2; color: "transparent" }
			GradientStop { position: 0.8; color: "transparent" }
			GradientStop { position: 1.0; color: "black" }
		}
    }


	function positionViewAtIndex(index, mode)
	{
		digitPath.positionViewAtIndex(index, mode);
	}
}

