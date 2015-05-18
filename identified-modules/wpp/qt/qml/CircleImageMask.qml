import QtQuick 2.1

Rectangle {
	id: "clipRectangle"
	//property alias dimension: clipRectangle.width
	property color bgColor
	property Item maskedTarget //target to be masked
    property int safeMargin: 1

	x: maskedTarget.x - safeMargin
	y: maskedTarget.y - safeMargin
	width: maskedTarget.width + 2*safeMargin
	height: width
	color: "transparent"
	clip: true
	Rectangle {
		id: "innerCircle"
		x: -border.width + safeMargin
		y: x
		width: maskedTarget.width + 2*border.width
		height: width
		border.color: clipRectangle.bgColor//"#ffffff"
        border.width: maskedTarget.width/2
        radius: width/2
		color: "transparent"
	}
}
