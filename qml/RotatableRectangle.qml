import QtQuick 2.2
//import QtSensors 5.0
import QtQuick.Window 2.2
import QtSensors 5.0

Rectangle {
	id: rotatableRectangle

	property bool isOn: true
	property bool activateUpsideDown: false

	/*OrientationSensor {
		dataRate: 1
		//active:rotatableRectangle.isOn
		active: true
		onReadingChanged: {
			//console.debug( "reading.orientation=" + reading.orientation );

		}
	}*/
	/*RotationSensor {
		dataRate: 1
		active: true
		onReadingChanged: {
			//console.debug("rotation sensor:" + reading.x + "," + reading.y + "," + reading.z );
		}
	}*/

	/*Screen.orientationUpdateMask:
		Qt.PrimaryOrientation |
		Qt.LandscapeOrientation |
		Qt.PortraitOrientation |
		Qt.InvertedLandscapeOrientation |
		Qt.InvertedPortraitOrientation

	Screen.onOrientationChanged: {
			//console.debug("*** RotatableRectangel: Screen Orientation: " + Screen.orientation);
		if ( Screen.primaryOrientation == Qt.LandscapeOrientation )
		{
			if ( Screen.orientation == Qt.LandscapeOrientation )
			{
				rotatableRectangle.rotation = 0;
				//console.debug("Qt.LandscapeOrientation...");
			}
			else if ( Screen.orientation == Qt.PortraitOrientation )
			{
				rotatableRectangle.rotation = rotatableRectangle.isOn ? 270 : 0;
				//console.debug("Qt.PortraitOrientation...");
			}
			else if ( Screen.orientation == Qt.InvertedLandscapeOrientation )
			{
				rotatableRectangle.rotation = rotatableRectangle.isOn && rotatableRectangle.activateUpsideDown? 180 : 0;
				//console.debug("Qt.InvertedLandscapeOrientation...");
			}
			else if ( Screen.orientation == Qt.InvertedPortraitOrientation )
			{
				rotatableRectangle.rotation = rotatableRectangle.isOn ? 90 : 0;
				//console.debug("Qt.InvertedPortraitOrientation...");
			}
			else
			{
				rotatableRectangle.rotation = 0;
				//console.debug("unknown orientation??");
			}
		}
		else
		{
			if ( Screen.orientation == Qt.LandscapeOrientation )
			{
				rotatableRectangle.rotation = rotatableRectangle.isOn ? 90 : 0;
				//console.debug("Qt.LandscapeOrientation...");
			}
			else if ( Screen.orientation == Qt.PortraitOrientation )
			{
				rotatableRectangle.rotation = 0;
				//console.debug("Qt.PortraitOrientation...");
			}
			else if ( Screen.orientation == Qt.InvertedLandscapeOrientation )
			{
				rotatableRectangle.rotation = rotatableRectangle.isOn ? 270 : 0;
				//console.debug("Qt.InvertedLandscapeOrientation...");
			}
			else if ( Screen.orientation == Qt.InvertedPortraitOrientation )
			{
				rotatableRectangle.rotation = rotatableRectangle.isOn && rotatableRectangle.activateUpsideDown? 180 : 0;
				//console.debug("Qt.InvertedPortraitOrientation...");
			}
			else
			{
				rotatableRectangle.rotation = 0;
				//console.debug("unknown orientation??");
			}
		}
	}*/

	transformOrigin: Item.Center
	Accelerometer {
		id: accel
		//dataRate: 1
		active:rotatableRectangle.isOn // && Qt.platform.os == "android"
		onReadingChanged: {
			//console.debug("x,y,z=(" + accel.reading.x + "," + accel.reading.y + "," + accel.reading.z );
			if ( Math.abs(accel.reading.y) > Math.abs(accel.reading.x) )
			{
				if ( accel.reading.y > 0 )
				{
					//console.debug("down");
					rotatableRectangle.rotation = 0;
				}
				else
				{
					//console.debug("up");
					rotatableRectangle.rotation = rotatableRectangle.isOn && rotatableRectangle.activateUpsideDown? 180 : 0;
				}
			}
			else if ( Math.abs(accel.reading.x) > Math.abs(accel.reading.y) )
			{
				if ( accel.reading.x > 0 )
				{
					//console.debug("left");
					rotatableRectangle.rotation = rotatableRectangle.isOn ? 90 : 0;
				}
				else
				{
					//console.debug("right");
					rotatableRectangle.rotation = rotatableRectangle.isOn ? 270 : 0;
				}
			}

		}
	}

	//width: parent.width
	//height: parent.height
	x: rotatableRectangle.rotation === 90 || rotatableRectangle.rotation === 270 ?
				-(parent.height - parent.width)/2 : 0
	y: rotatableRectangle.rotation === 90 || rotatableRectangle.rotation === 270 ?
		   (parent.height - parent.width)/2 : 0

	width: rotatableRectangle.rotation === 0 || rotatableRectangle.rotation === 180 ?
			   parent.width : parent.height
	height: rotatableRectangle.rotation === 0 || rotatableRectangle.rotation === 180 ?
			   parent.height : parent.width


}
