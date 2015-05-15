import QtQuick 2.1

Rectangle {
	property Item target
	property string style: "DARKER"  //DARKER, LIGHTER
	property bool isTargetMouseArea: false

	anchors.fill: target
	color: style == "DARKER" ? Qt.rgba(0,0,0,0.1) : Qt.rgba(1,1,1,0.1);
	z: target.z + 1

	visible: {
		if ( isTargetMouseArea )
		{
			return target.pressed? true: false;
		}
		else
		{
			return true;
		}
	}

}

