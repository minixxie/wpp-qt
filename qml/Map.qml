import QtQuick 2.2

Flickable {
	id: "map"

	property string mapSource: "GOOGLE" //GOOGLE, GAODE, BAIDU...
	property int zoom: 4
	property real mapScale: 1
	property real urlScale: 1

	ListModel {
		id: "tilesModel"
	}

	contentWidth: gridViewContainer.width
	contentHeight: gridViewContainer.height
	clip: true
	boundsBehavior: Flickable.StopAtBounds

	onContentWidthChanged: {
		console.log("flickable-map.contentWidth="+contentWidth);
	}
	onContentHeightChanged: {
		console.log("flickable-map.contentHeight="+contentHeight);
	}

	Rectangle {
		id: "gridViewContainer"
		width: mapTilesGridView.width*mapTilesGridView.scale
		height: mapTilesGridView.height*mapTilesGridView.scale

		GridView {
			id: "mapTilesGridView"
			boundsBehavior: Flickable.StopAtBounds
			interactive: false
			anchors.centerIn: parent
			width: map.calWorldWidth()
			height: map.calWorldHeight()
			onWidthChanged: console.log("GridView.width=" + width);
			onHeightChanged: console.log("GridView.height=" + height);
			clip: true
			//contentWidth: map.calWorldWidth()
			//contentHeight: map.calWorldHeight()
			//flow: GridView.FlowTopToBottom
			cellWidth: 256 *map.mapScale
			cellHeight: 256 *map.mapScale
			//flickableDirection: Flickable.HorizontalAndVerticalFlick
			model: tilesModel
			delegate: Rectangle {
				width:256 *map.mapScale
				height:256 *map.mapScale
				Rectangle {
					anchors.fill: parent
					color: "transparent"
					border.color: Qt.rgba(0,0,0,0.3)
					border.width: 1
				}
				Image {
					id: "tileImage"
					//source: visible ? calTileUrl(xIndex, yIndex) : ""
					source: url
					anchors.fill: parent
					cache: false
					visible: toLoad
					//onSourceChanged: {
						//console.log("tileImage["+yIndex+"]["+xIndex+"].source=" + source);

					//}
					//onVisibleChanged: {
						//console.log("tileImage["+yIndex+"]["+xIndex+"].visible=" + visible);
					//}
				}

				Text {
					//text: tileImage.loading ? "loading..." : ""
					//color: Qt.rgba(0,0,0,0.3)
					text: "x,y: " + xIndex + "," + yIndex + "=>" + parent.width +"x" + parent.height
					color: "red"
				}
			}//Rectangle-delegate
		}//GridView

	}//Rectangle(gridViewContainer)

	property int pinchedNewContentX: -1
	property int pinchedNewContentY: -1
	PinchArea {
		anchors.fill: parent
		//pinch.target: mapTilesGridView
		pinch.target: mapTilesGridView
		pinch.minimumScale: 0.2
		pinch.maximumScale: 8.0

		onPinchStarted: { //pinch:{scale, center, angle}
			console.log("map:onPinchStarted:pinch:{scale:"+pinch.scale+",center:"+pinch.center+",angle:"+pinch.angle+"}" );
		}
		onPinchFinished: { //pinch:{scale, center, angle}
			console.log("map:onPinchFinished:pinch:{scale:"+pinch.scale+",center:"+pinch.center+",angle:"+pinch.angle+"}" );
			console.log("pinch-finish:old contentx:"+map.contentX);
			var scaleStep = pinch.scale / pinch.previousScale;
			var newContentX = ( pinch.center.x * scaleStep ) - ( pinch.previousCenter.x - map.contentX );
			var newContentY = ( pinch.center.y * scaleStep ) - ( pinch.previousCenter.y - map.contentY );
			console.log("pinch-finish:new contentx:"+newContentX);
			console.log("pinch-finish:new contentx:"+map.contentX);

			map.contentX = newContentX;
			map.contentY = newContentY;
			console.log("pinch-finish:new contenty:"+map.contentY);

			map.pinchedNewContentX = newContentX;
			map.pinchedNewContentY = newContentY;

			map.set(pinch.scale);
			map.showOnDemand();

			map.pinchedNewContentX = -1;
			map.pinchedNewContentY = -1;

			map.contentX = newContentX;
			map.contentY = newContentY;
		}
		onPinchUpdated: { //pinch:{scale, center, angle}
			console.log("map:onPinchUpdated:pinch:{scale:"+pinch.scale+",center:"+pinch.center+",angle:"+pinch.angle+"}" );
			//map.set(pinch.scale);
			//map.mapScale = pinch.scale;

			//map.set(pinch.scale);
			//map.showOnDemand();

			//map.contentX += pinch.previousCenter.x - pinch.center.x
			//map.contentY += pinch.previousCenter.y - pinch.center.y
			//map.contentX

			if ( pinch.scale <= 8.0 )
			{
			var scaleStep = pinch.scale / pinch.previousScale;
				console.log("old contentx:"+map.contentX);
			map.contentX = ( pinch.center.x * scaleStep ) - ( pinch.previousCenter.x - map.contentX );
			map.contentY = ( pinch.center.y * scaleStep ) - ( pinch.previousCenter.y - map.contentY );
				console.log("new contentx:"+map.contentX);
			}
			//map.contentX = map.contentX * pinch.scale / pinch.previousScale;
			//map.contentY = map.contentY * pinch.scale / pinch.previousScale;

			//map.resizeContent(mapTilesGridView.width*pinch.scale, mapTilesGridView.height, pinch.center)


			/*mapTilesGridView.scale = pinch.scale;
			gridViewContainer.width = mapTilesGridView.width*pinch.scale;
			gridViewContainer.height = mapTilesGridView.height*pinch.scale;

			map.contentX += pinch.previousCenter.x - pinch.center.x
			map.contentY += pinch.previousCenter.y - pinch.center.y

			console.log("resizeContent:" + (mapTilesGridView.width*pinch.scale) + "x" + (mapTilesGridView.height*pinch.scale));
			map.resizeContent(mapTilesGridView.width*pinch.scale, mapTilesGridView.height, pinch.center)
*/
			//if ( lastCenterX == -1 ) lastCenterX = pinch.center.x;
			//if ( lastCenterY == -1 ) lastCenterY = pinch.center.y;

	/*		console.log("mapTilesGridView.width:" + mapTilesGridView.width);
			console.log("mapTilesGridView.scale:" + mapTilesGridView.scale);
			console.log("mapTilesGridView.width * scale:" + (mapTilesGridView.width * mapTilesGridView.scale));
			console.log("mapTilesGridView.width * scale - width:" + (( mapTilesGridView.width * mapTilesGridView.scale ) - mapTilesGridView.width));
			console.log("(mapTilesGridView.width * scale - width)/2:" + (( ( mapTilesGridView.width * mapTilesGridView.scale ) - mapTilesGridView.width )/2));

			map.contentX = map.contentX - ( ( mapTilesGridView.width * mapTilesGridView.scale ) - mapTilesGridView.width )/2;
			map.contentY = map.contentY - ( ( mapTilesGridView.height * mapTilesGridView.scale ) - mapTilesGridView.height )/2;
*/
			//pseudo: new_content_x = ( new_center_x * scale ) - ( old_center_x - old_content_x )
			/*var new_content_x = -( ( pinch.center.x * pinch.scale ) - ( lastCenterX - map.contentX ) )
			var new_content_y = -( ( pinch.center.y * pinch.scale ) - ( lastCenterY - map.contentY ) )
			map.contentX = new_content_x;
			map.contentY = new_content_y;

			lastCenterX = pinch.center.x;
			lastCenterY = pinch.center.y;*/


			//console.log("flickable:contentX,contentY:" + flickable.contentX + "," + flickable.contentY );
			//new_content_x = new_center_x * scale - ( pinch.center.x - old_content_x )
			//map.contentX = pinch.center.x * pinch.scale - ( lastCenterX - map.contentX );
			//map.contentY = pinch.center.y * pinch.scale - ( lastCenterY - map.contentY );
			//console.log("flickable:contentX,contentY(after):" + flickable.contentX + "," + flickable.contentY );

			//map.contentX = map.contentX * pinch.scale;
			//map.contentY = map.contentY * pinch.scale;
			//mapTilesGridView.width = calWorldWidth();
			//mapTilesGridView.height = calWorldWidth();

		}
	}

	onFlickEnded: {
		//console.log("flick to:" + contentX + "," + contentY );
		map.showOnDemand();
	}
	onMovementEnded: {
		map.showOnDemand();
	}

	function calWorldWidth()
	{
		var worldWidth = 256 * map.mapScale * Math.pow( 2, zoom );
		//console.log("zoom="+zoom+",worldWidth:" + worldWidth);
		return worldWidth;
	}
	function calWorldHeight()
	{
		var worldWidth = 256 * map.mapScale * Math.pow( 2, zoom );
		var worldHeight = worldWidth*3/4;
		//console.log("zoom="+zoom+",worldHeight:" + worldHeight);
		return worldHeight;
	}
	function calXCount()
	{
		var worldWidth = calWorldWidth();
		var xCount = worldWidth / (256 * map.mapScale);
		return Math.floor(xCount);
	}
	function calYCount()
	{
		var worldHeight = calWorldHeight();
		var yCount = worldHeight / (256 * map.mapScale);
		return Math.floor(yCount);
	}
	function calTileUrl(xIndex, yIndex)
	{
		//return "http://mt1.google.com/vt/lyrs=m@269000000&hl=zh-CN&gl=CN&src=app&x="+xIndex+"&y="+yIndex+"&z="+zoom+"&s=Galileo&scale=1";
		//return "http://emap1.mapabc.com/mapabc/maptile?x="+xIndex+"&y="+yIndex+"&z="+zoom+"&scale="+scale;
		//console.log("tile-url of " + xIndex + "," + yIndex);
		var serverNum = ( yIndex * calXCount() + xIndex ) % 3 + 1;
		var url = "http://mt"+serverNum+".google.com/vt/lyrs=m@269000000&hl=zh-CN&gl=CN&src=app&x="+xIndex+"&y="+yIndex+"&z="+zoom+"&s=Galileo&scale="+map.urlScale;
		//console.log("tile-url:" + url);
		return url;
	}

	function set(scale)
	{
		mapTilesGridView.scale = 1;
		var newScale = map.mapScale * scale;
		console.log("newScale=" + newScale);
		if ( newScale >= 2 )//should increase the zoom, and re-calculate the scale
		{
			var newScaleIsTwoToPowerWhat = Math.log( newScale )/Math.log(2);
			console.log("newScaleIsTwoToPowerWhat=" + newScaleIsTwoToPowerWhat);
			var addToZoom = parseInt( newScaleIsTwoToPowerWhat );
			console.log("addToZoom=" + addToZoom);
			if ( newScale / Math.pow(2,addToZoom) > 1 )//scale left
			{
				console.log("scale to add...");
				var newNewScale = newScale / Math.pow(2,addToZoom);
				console.log("newNewScale=" + newNewScale);
				map.mapScale = newNewScale;
			}
			else
			{
				console.log("scale should go back to 1...");
				map.mapScale = 1;
			}
			var newZoom = map.zoom + addToZoom;
			console.log("zoom should go from " + map.zoom + " => " + newZoom);
			map.zoom = newZoom;

			//var decimalZoom = Math.log( Math.pow(2, map.zoom) * newScale )/Math.log(2);
			//var newNormalizedScale = Math.pow(2, decimalZoom)/Math.pow(2, map.zoom + 1)
		}
		else
		{
			map.mapScale = newScale;
		}
		map.urlScale = map.mapScale;
		console.log("map.mapScale=" + map.mapScale);
		console.log("map.urlScale=" + map.urlScale);

		var worldWidth = calWorldWidth();
		var worldHeight = calWorldHeight();
		console.log("worldWidth---:" + worldWidth);
		mapTilesGridView.width = worldWidth;
		console.log("mapTilesGridView.width---:" + mapTilesGridView.width);
		mapTilesGridView.height = worldHeight;

		var xCount = calXCount();
		var yCount = calYCount();

		console.log("xCount:"+xCount);
		console.log("yCount:"+yCount);

		tilesModel.clear();
		for ( var y = 0 ; y < yCount ; y++ )
		{
			for ( var x = 0 ; x < xCount ; x++ )
			{
				tilesModel.append({
					"xIndex": x,
					"yIndex": y,
					"toLoad": false,
					"url": ""
				});
			}

		}
	}

	function showOnDemand()
	{
		var rows = calYCount();
		var cols = calXCount();

		var myContentX = map.pinchedNewContentX >= 0 ? map.pinchedNewContentX : map.contentX;
		var myContentY = map.pinchedNewContentY >= 0 ? map.pinchedNewContentY : map.contentY;

		console.log("contentX:" + myContentX);
		console.log("cellWidth:" + mapTilesGridView.cellWidth);
		console.log("contentY:" + myContentY);
		console.log("cellHeight:" + mapTilesGridView.cellHeight);
		console.log("width:" + map.width);
		console.log("height:" + map.height);

		var PRE_LOAD_BUFFER_COUNT = 3;
		var topLeftXIndex = Math.floor( myContentX / (mapTilesGridView.cellWidth) );
		console.log("topLeftXIndex:" + topLeftXIndex);
		var topRightXIndex = Math.ceil( ( myContentX + width ) / (mapTilesGridView.cellWidth) ) - 1;
		console.log("topRightXIndex:" + topRightXIndex);
		//add buffer
		var minXIndex = topLeftXIndex - PRE_LOAD_BUFFER_COUNT;
		var maxXIndex = topRightXIndex + PRE_LOAD_BUFFER_COUNT;
		//fix boundary
		if ( minXIndex < 0 ) minXIndex = 0;
		if ( minXIndex > cols - 1 ) minXIndex = cols - 1;
		if ( maxXIndex < 0 ) maxXIndex = 0;
		if ( maxXIndex > cols - 1 ) maxXIndex = cols - 1;

		var topLeftYIndex = Math.floor( myContentY / (mapTilesGridView.cellHeight) );
		console.log("topLeftYIndex:" + topLeftYIndex);
		var bottomLeftYIndex = Math.ceil( ( myContentY + height ) / (mapTilesGridView.cellHeight) ) - 1;
		console.log("bottomLeftYIndex:" + bottomLeftYIndex)
		//add buffer
		var minYIndex = topLeftYIndex - PRE_LOAD_BUFFER_COUNT;
		var maxYIndex = bottomLeftYIndex + PRE_LOAD_BUFFER_COUNT;
		//fix boundary
		if ( minYIndex < 0 ) minYIndex = 0;
		if ( minYIndex > rows - 1 ) minYIndex = rows - 1;
		if ( maxYIndex < 0 ) maxYIndex = 0;
		if ( maxYIndex > rows - 1 ) maxYIndex = rows - 1;

		console.log("xIndex: " + minXIndex + " ~ " + maxXIndex);
		console.log("yIndex: " + minYIndex + " ~ " + maxYIndex);

		for ( var yIndex = 0 ; yIndex < rows ; yIndex++ )
		{
			for ( var xIndex = 0 ; xIndex < cols ; xIndex++ )
			{
				var modelIndex = yIndex * calXCount() + xIndex;
				if ( minXIndex <= xIndex && xIndex <= maxXIndex
					&& minYIndex <= yIndex && yIndex <= maxYIndex
				)
				{
					//console.log("["+yIndex+"]["+xIndex+"]("+modelIndex+")=>toLoad=true");
					tilesModel.setProperty(modelIndex, "toLoad", true);
					tilesModel.setProperty(modelIndex, "url", calTileUrl(xIndex, yIndex));
				}
				else
				{
					tilesModel.setProperty(modelIndex, "toLoad", false);
					tilesModel.setProperty(modelIndex, "url", "");

				}
			}
		}
	}

	Component.onCompleted: {
		map.set(1);
		map.showOnDemand();
	}
}
