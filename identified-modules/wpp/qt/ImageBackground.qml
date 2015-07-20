import QtQuick 2.1

Rectangle {
	id: imageBackground
	property var bgColor: ["#f7f7f7"]
	//property color bgColor: "#f7f7f7"
	property Item imgTarget //target to have background

	x: imgTarget.x
	y: imgTarget.y
	width: imgTarget.width
	height: imgTarget.height
	color: {
		if ( bgColor.length == 1 )
		{
			return bgColor[0];
		}
		else if ( bgColor.length > 1 )
		{
			var randIndex = Math.floor((Math.random()*bgColor.length));
			return bgColor[randIndex];
		}
		else
			return "#f7f7f7";
	}
	visible: imgTarget.visible
}
