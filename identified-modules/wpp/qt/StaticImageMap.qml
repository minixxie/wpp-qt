import QtQuick 2.1
//import QtLocation 5.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

/*
 * Google static map API (v2): https://developers.google.com/maps/documentation/staticmaps/index
 * Google geocoding API (v3): https://developers.google.com/maps/documentation/geocoding/?hl=zh-tw
 * Baidu static map API (v3.0): http://developer.baidu.com/map/staticimg.htm
 * Baidu geocoding API(v2.0): http://developer.baidu.com/map/webservice-geocoding.htm
 * 高德 static map API: http://developer.amap.com/api/static-map-api/guide-2/
 */
Rectangle {
	id: mapUI
	anchors.fill: parent
	clip: true

	property string locale: "en_US"
	property string src: "GOOGLE"  //GOOGLE, BAIDU, AMAP
	property bool selectSource: false
	property string googleApiKey: ""
	property string baiduApiKey: ""
	property string amapApiKey: ""
	property string httpReferer: ""
	property int bufferNum: 1  //1 or 2

	property bool selectPlace: false
	signal placeSelected

	function setBuffer(num)
	{
		console.log("using buffer no." + num);
		bufferNum = num;
		if ( bufferNum == 1 )
		{
			longitude = longitude1;
			latitude = latitude1;
			zoom = zoom1;
			mapImageBuffer1.visible = true;
			mapImageBuffer2.visible = false;
			scaleAnimation2.stop();
			mapImageBuffer2.state = "noZoom";
		}
		else
		{
			longitude = longitude2;
			latitude = latitude2;
			zoom = zoom2;
			mapImageBuffer1.visible = false;
			mapImageBuffer2.visible = true;
			scaleAnimation1.stop();
			mapImageBuffer1.state = "noZoom";
		}

		/*zoom1 = zoom;
		zoom2 = zoom;
		longitude1 = longitude;
		latitude1 = latitude;
		longitude2 = longitude2;
		latitude2 = latitude2;*/


		mapImageBuffer1.scale = 1;
		mapImageBuffer2.scale = 1;

		mapImageBuffer1.x = 0;
		mapImageBuffer1.y = 0;
		mapImageBuffer2.x = 0;
		mapImageBuffer2.y = 0;
	}
	function incZoom(zoom)
	{
		var z = zoom + 1;
		return z;
	}
	function decZoom(zoom)
	{
		var z = zoom - 1;
		return z;
	}

	property string url1: mapUrl(latitude1, longitude1, zoom1, false, 0, 0, function(url){
							if (mapUI.src == "BAIDU") mapUI.url1 = url;
						})
	property string url2: mapUrl(latitude2, longitude2, zoom2, false, 0, 0, function(url){
		if (mapUI.src == "BAIDU") mapUI.url2 = url;
	})
	Component.onCompleted: {
		longitude1 = longitude;
		latitude1 = latitude;
		zoom1 = zoom;

		longitude2 = longitude;
		latitude2 = latitude;
		zoom2 = zoom;

		mapImageBuffer1.visible = true;
		mapImageBuffer2.visible = false;

	}

	function getDefaultCoordinates()
	{
		/*
		  东方明珠塔
			baidu: 121.506332,31.245287
			google: (31.239884601420133, 121.49967759847641)
			google -> baidu:
			http://api.map.baidu.com/geoconv/v1/?coords=31.239884601420133,121.49967759847641&from=3&ak=28rBUIs23mHGRDzUXAPAleLU&output=json
			{"status":0,"result":[{"x":31.246565024311,"y":121.50563155675}]}
		*/
		//if ( mapUI.src == "GOOGLE" )
			return {"lng": 121.49967759847641, "lat": 31.239884601420133 };
		//else
			//return {"lng": 121.506332, "lat": 31.245287 };
	}

	property bool useSensor: false
	property double locatedLongitude: 0
	property double locatedLatitude: 0

	property double longitude: locatedLongitude != 0 ? locatedLongitude : mapUI.getDefaultCoordinates().lng
	property double latitude: locatedLatitude != 0 ? locatedLatitude : mapUI.getDefaultCoordinates().lat

	property double longitude1: locatedLongitude != 0 ? locatedLongitude : mapUI.getDefaultCoordinates().lng
	property double latitude1: locatedLatitude != 0 ? locatedLatitude : mapUI.getDefaultCoordinates().lat

	property double longitude2: locatedLongitude != 0 ? locatedLongitude : mapUI.getDefaultCoordinates().lng
	property double latitude2: locatedLatitude != 0 ? locatedLatitude : mapUI.getDefaultCoordinates().lat

	property double selectedLatitude: 0
	property double selectedLongitude: 0
	property string selectedPlaceName: ""

	property bool showPressAndHoldMarker1: false
	property double pressAndHoldMarkerLongitude1: 121.486816
	property double pressAndHoldMarkerLatitude1: 31.237756

	property bool showPressAndHoldMarker2: false
	property double pressAndHoldMarkerLongitude2: 121.486816
	property double pressAndHoldMarkerLatitude2: 31.237756

	property int zoom: 10
	property int zoom1: 10
	property int zoom2: 10

	property int numTiles: 1 << zoom;

	readonly property int tileSize: 256
	readonly property double pixelOriginX: tileSize/2
	readonly property double pixelOriginY: tileSize/2
	readonly property double pixelsPerLonDegree: tileSize / 360
	readonly property double pixelsPerLonRadian: tileSize / (2 * Math.PI)

	function mapUrl(latitude, longitude, zoom, showPressAndHoldMarker, pressAndHoldMarkerLatitude, pressAndHoldMarkerLongitude, callback)
	{
		var url = "";
		if ( width > 0 && height > 0 )
		{
			if ( src == "GOOGLE" )
			{
				url = "http://maps.googleapis.com/maps/api/staticmap?"
					+"language="+locale
					+"&sensor="+(useSensor?"true":"false")
					+"&center="
					+latitude+","+longitude+"&zoom="+zoom+"&size="+width+"x"+height;
				if ( useSensor )
					url = url + "&markers=size:mid%7Ccolor:0x84B6E8%7Clabel:ME%7C"+locatedLatitude+","+locatedLongitude //显示自己的定位
				if ( showPressAndHoldMarker )
					url = url + "&markers=color:green%7Clabel:A%7C"+pressAndHoldMarkerLatitude+","+pressAndHoldMarkerLongitude;
				if ( googleApiKey != "" )
					url = url + "&key="+googleApiKey;
			}
			else if ( src == "BAIDU" )
			{
				/*baiduConvertCoordinates(longitude, latitude, function(lng, lat){
					console.log("baiduConverted:(google){" + longitude + "," + latitude + "}=>(baidu){" + lng + "," + lat + "}");
					url = "http://api.map.baidu.com/staticimage?"
						+"center="+lng+","+lat
						+"&width="+width
						+"&height="+height
						+"&zoom="+zoom;
					if ( useSensor )
						url = url +"&markers="+locatedLongitude+","+locatedLatitude+"&markerStyles=l,ME,0x84B6E8" //显示自己的定位
					if ( showPressAndHoldMarker )
						url = url + "&markers="+pressAndHoldMarkerLongitude+","+pressAndHoldMarkerLatitude;
					if ( baiduApiKey != "" )
						url = url + "&key="+baiduApiKey;
					callback(url);
				});
				return "";
				*/

				url = "http://api.map.baidu.com/staticimage?"
					+"center="+longitude+","+latitude
					+"&width="+width
					+"&height="+height
					+"&zoom="+zoom;
				if ( useSensor )
					url = url +"&markers="+locatedLongitude+","+locatedLatitude+"&markerStyles=l,ME,0x84B6E8" //显示自己的定位
				if ( showPressAndHoldMarker )
					url = url + "&markers="+pressAndHoldMarkerLongitude+","+pressAndHoldMarkerLatitude;
				if ( baiduApiKey != "" )
					url = url + "&key="+baiduApiKey;

			}
			else if ( src == "AMAP" )//高德
			{
				url = "http://restapi.amap.com/v3/staticmap?"
					+"location="+longitude+","+latitude
					+"&size="+width+"*"+height
					+"&zoom="+zoom;
				if ( useSensor )
					url = url +"&markers=mid,,M:"+locatedLongitude+","+locatedLatitude //显示自己的定位
				if ( showPressAndHoldMarker )
					url = url + "&markers=mid,,A:"+pressAndHoldMarkerLongitude+","+pressAndHoldMarkerLatitude;
				if ( amapApiKey != "" )
					url = url + "&key="+amapApiKey;
			}
		}
		return url;
	}

	function fromLatLngToPoint(latitude, longitude)
	{
		var point = {"x": 0, "y": 0};
		var origin = {"x": pixelOriginX, "y": pixelOriginY};
		point.x = origin.x + longitude * pixelsPerLonDegree;

		// Truncating to 0.9999 effectively limits latitude to 89.189. This is
		// about a third of a tile past the edge of the world tile.
		var siny = bound(Math.sin(degreesToRadians(latitude)), -0.9999,
			  0.9999);
		point.y = origin.y + 0.5 * Math.log((1 + siny) / (1 - siny)) *
			  -pixelsPerLonRadian;
		return point;
	}
	function fromPointToLatLng(point) {
		var origin = {
			"x": pixelOriginX,
			"y": pixelOriginY
		};
		var lng = (point.x - origin.x) / pixelsPerLonDegree;
		var latRadians = (point.y - origin.y) / -pixelsPerLonRadian;
		var lat = radiansToDegrees(2 * Math.atan(Math.exp(latRadians)) -
			Math.PI / 2);
		return {
			"lat": lat,
			"lng": lng
		};
	}
	function bound(value, opt_min, opt_max) {
		if (opt_min != null) value = Math.max(value, opt_min);
		if (opt_max != null) value = Math.min(value, opt_max);
		return value;
	}
	function degreesToRadians(deg) { return deg * (Math.PI / 180); }
	function radiansToDegrees(rad) { return rad / (Math.PI / 180); }



	Image {
		id: mapImageBuffer1
		cache: false
		source: mapUI.url1
		onProgressChanged: {
			if ( progress == 1.0 )//source load complete
			{
				mapUI.setBuffer(1);
			}
		}
		onSourceChanged: {
			console.log("image source changed (buffer1): url: " + source);
			//mapImage.state = "noZoom";
			//mapImage.scale = 1;
		}
/*Component.onCompleted: {
	console.log("MapImage: width x height:" + width + " x " + height);
	console.log("lat,lng: " + latitude + "," + longitude);
	var worldCoordinate = fromLatLngToPoint(latitude, longitude);
	console.log("worldCoordinate:x,y: " + worldCoordinate.x + "," + worldCoordinate.y);
	var latlng = fromPointToLatLng(worldCoordinate);
	console.log("new: lat,lng: " + latlng.lat + "," + latlng.lng);

}*/
		/*Component.onCompleted: {
			console.log("Image.source function...:lat,lng:("+latitude+","+longitude+")");
			var numTiles = 1 << zoom;
			var worldCoordinate = fromLatLngToPoint(latitude, longitude);
			var pixelCoordinate = {
				"x": worldCoordinate.x * numTiles,
				"y": worldCoordinate.y * numTiles
			};
			var tileCoordinate = {
				  "x": Math.floor(pixelCoordinate.x / tileSize),
				  "y": Math.floor(pixelCoordinate.y / tileSize)
			};
			console.log("numTiles:" + numTiles);
			console.log("worldCoordinate:("+worldCoordinate.x+","+worldCoordinate.y+")");
			console.log("pixelCoordinate:("+pixelCoordinate.x+","+pixelCoordinate.y+")");
			console.log("tileCoordinate:("+tileCoordinate.x+","+tileCoordinate.y+")");


			source = "http://maps.googleapis.com/maps/api/staticmap?center="+latitude+","+longitude+"&zoom="+zoom+"&size="+mapUI.width+"x"+mapUI.height;
		}*/
		//anchors.fill: parent
		width:parent.width //*3
		height:parent.height //*3
		x: 0 //-parent.width
		y: 0 //-parent.height


		states: [
			State { name: "noZoom";
				PropertyChanges { target: mapImageBuffer1; scale: 1 }
			},
			State { name: "zoomIn";
				PropertyChanges { target: mapImageBuffer1; scale: 2 }
			},
			State { name: "zoomOut";
				PropertyChanges { target: mapImageBuffer1; scale: 0.5 }
			}
		]
		transitions: [
			Transition {
				NumberAnimation { id:scaleAnimation1; properties: "scale"; duration: 200; easing.type: Easing.Linear; }
			}
		]
	}
	Image {
		id: mapImageBuffer2
		cache: false
		source: mapUI.url2
		onProgressChanged: {
			if ( progress == 1.0 )//source load complete
			{
				mapUI.setBuffer(2);
			}
		}
		onSourceChanged: {
			console.log("image source changed (buffer2): url: " + source);
			//mapImage.state = "noZoom";
			//mapImage.scale = 1;
		}
/*Component.onCompleted: {
	console.log("MapImage: width x height:" + width + " x " + height);
	console.log("lat,lng: " + latitude + "," + longitude);
	var worldCoordinate = fromLatLngToPoint(latitude, longitude);
	console.log("worldCoordinate:x,y: " + worldCoordinate.x + "," + worldCoordinate.y);
	var latlng = fromPointToLatLng(worldCoordinate);
	console.log("new: lat,lng: " + latlng.lat + "," + latlng.lng);

}*/
		/*Component.onCompleted: {
			console.log("Image.source function...:lat,lng:("+latitude+","+longitude+")");
			var numTiles = 1 << zoom;
			var worldCoordinate = fromLatLngToPoint(latitude, longitude);
			var pixelCoordinate = {
				"x": worldCoordinate.x * numTiles,
				"y": worldCoordinate.y * numTiles
			};
			var tileCoordinate = {
				  "x": Math.floor(pixelCoordinate.x / tileSize),
				  "y": Math.floor(pixelCoordinate.y / tileSize)
			};
			console.log("numTiles:" + numTiles);
			console.log("worldCoordinate:("+worldCoordinate.x+","+worldCoordinate.y+")");
			console.log("pixelCoordinate:("+pixelCoordinate.x+","+pixelCoordinate.y+")");
			console.log("tileCoordinate:("+tileCoordinate.x+","+tileCoordinate.y+")");


			source = "http://maps.googleapis.com/maps/api/staticmap?center="+latitude+","+longitude+"&zoom="+zoom+"&size="+mapUI.width+"x"+mapUI.height;
		}*/
		//anchors.fill: parent
		width:parent.width //*3
		height:parent.height //*3
		x: 0 //-parent.width
		y: 0 //-parent.height

		states: [
			State { name: "noZoom";
				PropertyChanges { target: mapImageBuffer2; scale: 1 }
			},
			State { name: "zoomIn";
				PropertyChanges { target: mapImageBuffer2; scale: 2 }
			},
			State { name: "zoomOut";
				PropertyChanges { target: mapImageBuffer2; scale: 0.5 }
			}
		]
		transitions: [
			Transition {
				NumberAnimation { id:scaleAnimation2; properties: "scale"; duration: 200; easing.type: Easing.Linear; }
			}
		]
	}

	function baiduConvertCoordinates(lng, lat, callback)
	{
		var httpConvert = new XMLHttpRequest();
		var urlConvert = "http://api.map.baidu.com/geoconv/v1/?coords="+lng+","+lat+"&from=3&ak="+baiduApiKey+"&output=json";
		console.log("to visit url:" + urlConvert);
		httpConvert.onreadystatechange = function() {//Call a function when the state changes.
			if(httpConvert.readyState === XMLHttpRequest.DONE)
			{
				console.log("BAIDU:: convert coordinates response...state:"+httpConvert.readyState+",status:"+httpConvert.status);
				if (httpConvert.readyState == 4) {
					if (httpConvert.status == 200) {
						console.log("BAIDU:: convert coordinates response:"+httpConvert.responseText);
						var jsonObject = JSON.parse(httpConvert.responseText);
						if ( jsonObject.status == 0 )
						{
							callback( jsonObject.result[0].x, jsonObject.result[0].y );
						}
					}
					else
					{
						console.log("error: " + httpConvert.status);
					}
				}
			}
		}
		httpConvert.open("GET", urlConvert);
		httpConvert.setRequestHeader("Referer", mapUI.httpReferer);
		//httpConvert.setRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:28.0) Gecko/20100101 Firefox/28.0");
		httpConvert.send();

	}

	/*MultiPointTouchArea {
		anchors.fill: parent
		touchPoints: [
			TouchPoint { id: point1 },
			TouchPoint { id: point2 }
		]
		onTouchUpdated: { //list<TouchPoint> touchPoints
			console.log("multi-touch(onTouchUpdated):");
			for ( var i = 0 ; i < touchPoints.length ; i++ )
			{
				console.log("onTouchUpdated["+i+"]:(" + touchPoints[i].x + "," + touchPoints[i].y + ")");
			}
		}
		onPressed: {//list<TouchPoint> touchPoints
			console.log("multi-touch(onPressed):");
			for ( var i = 0 ; i < touchPoints.length ; i++ )
			{
				console.log("onPressed["+i+"]:(" + touchPoints[i].x + "," + touchPoints[i].y + ")");
			}
		}
		onReleased: { //list<TouchPoint> touchPoints
			console.log("multi-touch(onReleased):");
			for ( var i = 0 ; i < touchPoints.length ; i++ )
			{
				console.log("onReleased["+i+"]:(" + touchPoints[i].x + "," + touchPoints[i].y + ")");
			}
		}
		onUpdated: {//list<TouchPoint> touchPoints
			console.log("multi-touch(onUpdated):");
			for ( var i = 0 ; i < touchPoints.length ; i++ )
			{
				console.log("onUpdated["+i+"]:(" + touchPoints[i].x + "," + touchPoints[i].y + ")");
			}

		}
	}*/
	MouseArea {
		//visible: false
		id: mapMouseArea
		anchors.fill: parent
		drag.target: mapUI.bufferNum == 1 ? mapImageBuffer1 : mapImageBuffer2
		drag.axis: Drag.XAndYAxis
		drag.minimumX: -mapUI.width //-mapUI.width*2
		drag.maximumX: mapUI.width //0 //
		drag.minimumY: -mapUI.height //-mapUI.height*2 //
		drag.maximumY: mapUI.height //0 //

		onPressAndHold: {
			if ( parent.selectPlace )
			{
				console.log("press and hold!! at:("+mouseX+","+mouseY+")");

				var worldCoordinate = mapUI.fromLatLngToPoint(mapUI.latitude, mapUI.longitude);
				console.log("worldCoordinate:("+worldCoordinate.x+","+worldCoordinate.y+")");

				var pixelCoordinate = {
					"x": worldCoordinate.x * numTiles,
					"y": worldCoordinate.y * numTiles
				};
				var topLeftPixelCoordinate = {
					"x": pixelCoordinate.x - mapUI.width/2,
					"y": pixelCoordinate.y - mapUI.height/2
				}
				var pressAndHoldPixelCoordinate = {
					"x": topLeftPixelCoordinate.x + mouseX,
					"y": topLeftPixelCoordinate.y + mouseY
				}

				var pressAndHoldWorldCoordinate = {
					"x": pressAndHoldPixelCoordinate.x / numTiles,
					"y": pressAndHoldPixelCoordinate.y / numTiles,
				};
				var pressAndHoldLatLng = mapUI.fromPointToLatLng(pressAndHoldWorldCoordinate);

				if ( mapUI.bufferNum == 1 )
				{
					mapUI.latitude2 = mapUI.latitude1;
					mapUI.longitude2 = mapUI.longitude1;
					mapUI.zoom2 = mapUI.zoom1;
					mapUI.showPressAndHoldMarker2 = true;
					mapUI.pressAndHoldMarkerLatitude2 = pressAndHoldLatLng.lat;
					mapUI.pressAndHoldMarkerLongitude2 = pressAndHoldLatLng.lng;

					mapImageBuffer2.x = 0;
					mapImageBuffer2.y = 0;
					mapImageBuffer2.source = "";
					mapImageBuffer2.source = mapUI.mapUrl(mapUI.latitude2, mapUI.longitude2, mapUI.zoom2,
									mapUI.showPressAndHoldMarker2, mapUI.pressAndHoldMarkerLatitude2, mapUI.pressAndHoldMarkerLongitude2,
									function(url){
										if ( mapUI.src == "BAIDU" )
											mapImageBuffer2.source = url;
									});
				}
				else
				{
					mapUI.latitude1 = mapUI.latitude2;
					mapUI.longitude1 = mapUI.longitude2;
					mapUI.zoom1 = mapUI.zoom2;
					mapUI.showPressAndHoldMarker1 = true;
					mapUI.pressAndHoldMarkerLatitude1 = pressAndHoldLatLng.lat;
					mapUI.pressAndHoldMarkerLongitude1 = pressAndHoldLatLng.lng;

					mapImageBuffer1.x = 0;
					mapImageBuffer1.y = 0;
					mapImageBuffer1.source = "";
					mapImageBuffer1.source = mapUI.mapUrl(mapUI.latitude1, mapUI.longitude1, mapUI.zoom1,
									mapUI.showPressAndHoldMarker1, mapUI.pressAndHoldMarkerLatitude1, mapUI.pressAndHoldMarkerLongitude1,
									function(url){
										if ( mapUI.src == "BAIDU" )
											mapImageBuffer1.source = url;
									});
				}
				mapUI.selectedLatitude = pressAndHoldLatLng.lat;
				mapUI.selectedLongitude = pressAndHoldLatLng.lng;

				/*if ( src == "BAIDU" )
				{
					console.log("BAIDU:: convert coordinates");
					var httpConvert = new XMLHttpRequest();
					var urlConvert = "http://api.map.baidu.com/geoconv/v1/?coords="+pressAndHoldLatLng.lng+","+pressAndHoldLatLng.lat+"&ak="+baiduApiKey+"&output=json";
					console.log("to visit url:" + urlConvert);
					httpConvert.onreadystatechange = function() {//Call a function when the state changes.
						console.log("BAIDU:: convert coordinates response...state:"+httpConvert.readyState+",status:"+httpConvert.status);
						if (httpConvert.readyState == 4) {
							if (httpConvert.status == 200) {
								console.log("BAIDU:: convert coordinates response:"+httpConvert.responseText);
								var jsonObject = JSON.parse(httpConvert.responseText);
								if ( jsonObject.status == 0 )
								{
									mapUI.selectedLatitude = jsonObject.result.location.lat;
									mapUI.selectedLongitude = jsonObject.result.location.lng;
									console.log("lat,lng(baidu):" + mapUI.selectedLatitude + "," + mapUI.selectedLongitude);
								}
							}
							else
							{
								console.log("error: " + httpConvert.status);
							}
						}
					}
					httpConvert.open("GET", urlConvert);
					httpConvert.setRequestHeader("Referer", mapUI.httpReferer);
					//httpConvert.setRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:28.0) Gecko/20100101 Firefox/28.0");
					httpConvert.send();
				}*/

				var http = new XMLHttpRequest();
				var url = null;
				if ( src == "BAIDU" )
				{
					url = "http://api.map.baidu.com/geocoder/v2/?"
					+"ak="+baiduApiKey
					+"&location="+pressAndHoldLatLng.lat+","+pressAndHoldLatLng.lng+"&output=json&pois=0";
					/*
						curl --referer "http://developer.baidu.com/map/webservice-geocoding.htm" \
						"http://api.map.baidu.com/geocoder/v2/?ak=E4805d16520de693a3fe707cdc962045&location=31.23021229857433,121.53357360865212&output=json&pois=0"
						{"status":0,
						"result":{
							"location":{
								"lng":121.51634172458,
								"lat":31.236392497831
							},
							"formatted_address":"上海市浦东新区人民路隧道",
							"business":"陆家嘴,东外滩,梅园",
							"addressComponent":{
								"city":"上海市",
								"district":"浦东新区",
								"province":"上海市",
								"street":"人民路隧道",
								"street_number":""
							},
						"cityCode":289}}
					 */
				}
				else if ( src == "AMAP" )
				{
					url = "http://restapi.amap.com/v3/geocode/regeo?"
						+"location="+pressAndHoldLatLng.lng+","+pressAndHoldLatLng.lat
						+"&key="+amapApiKey
						+"&radius=2800&s=rsv3";
				}
				else //GOOGLE
				{
					/*url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
					+"location="+pressAndHoldLatLng.lat+","+pressAndHoldLatLng.lng
					+"&radius=500&types=food&name=harbour&sensor=false&key=" + googleApiKey;*/

					url = "http://maps.googleapis.com/maps/api/geocode/json?"
					+"latlng="+pressAndHoldLatLng.lat+","+pressAndHoldLatLng.lng
					+"&sensor=false"
					+"&language="+locale;
					/*
						http://maps.googleapis.com/maps/api/geocode/json?latlng=31.23021229857433,121.53357360865212&sensor=false

					 */
				}

				console.log("url:"+url);
				http.onreadystatechange = function() {//Call a function when the state changes.
					if (http.readyState == 4) {
						if (http.status == 200) {
							console.log("ret:" + http.responseText)
							var jsonObject = JSON.parse(http.responseText);

							if ( mapUI.src == "BAIDU" )
							{
								if ( jsonObject.status == 0 )
								{
									console.log("addr:" + jsonObject.result.formatted_address);
									placesListModel.clear();
									placesListModel.insert(0, {"name": jsonObject.result.formatted_address});
									placesToChooseDialog.visible = true;//open dialog
								}
							}
							else if ( mapUI.src == "AMAP" )//高德
							{
								if ( jsonObject.status == "1" && jsonObject.info == "OK" )
								{
									console.log("addr:" + jsonObject.regeocode.formatted_address);
									placesListModel.clear();
									placesListModel.insert(0, {"name": jsonObject.regeocode.formatted_address});
									placesToChooseDialog.visible = true;//open dialog
								}
							}
							else
							{
								if ( jsonObject.status == "OK" )
								{
									console.log("addr:" + jsonObject.results[0].formatted_address);
									placesListModel.clear();
									placesListModel.insert(0, {"name": jsonObject.results[0].formatted_address});
									placesToChooseDialog.visible = true;//open dialog
								}
							}

						}
						else
						{
							console.log("error: " + http.status);
						}
					}
				}
				http.open("GET", url);
				http.setRequestHeader("Referer", mapUI.httpReferer);
				//http.setRequestHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:28.0) Gecko/20100101 Firefox/28.0");
				http.send();
			}
		}//onPressAndHold

		onReleased: {
			//ref: http://www.qtcentre.org/archive/index.php/t-34612.html
			//ref: Static Maps API V2: https://developers.google.com/maps/documentation/staticmaps/
			//Mercator projection:
			//  -http://wiki.openstreetmap.org/wiki/Mercator
			//  -https://developers.google.com/maps/documentation/javascript/examples/map-coordinates
			//orthographic projections
			//Platte-Carre projection

			var currentBuffer = mapUI.bufferNum == 1 ? mapImageBuffer1 : mapImageBuffer2;
			var newBuffer = mapUI.bufferNum == 1 ? mapImageBuffer2 : mapImageBuffer1;

			if ( currentBuffer.x != 0 || currentBuffer.y != 0 )//dragged
			//if ( mapImage.x != -parent.width || mapImage.y != -parent.height )//dragged
			{
				console.log("releast at: ("+currentBuffer.x+","+currentBuffer.y+")");
				var numTiles = 1 << mapUI.zoom;

				var worldCoordinate = mapUI.fromLatLngToPoint(mapUI.latitude, mapUI.longitude);
				console.log("worldCoordinate:("+worldCoordinate.x+","+worldCoordinate.y+")");

				var pixelCoordinate = {
					"x": worldCoordinate.x * numTiles,
					"y": worldCoordinate.y * numTiles
				};

				pixelCoordinate.x = pixelCoordinate.x - currentBuffer.x;
				pixelCoordinate.y = pixelCoordinate.y - currentBuffer.y;
				console.log("new pixelCoordinate:("+pixelCoordinate.x+","+pixelCoordinate.y+")");

				worldCoordinate = {
					"x": pixelCoordinate.x / numTiles,
					"y": pixelCoordinate.y / numTiles,
				};
				console.log("new worldCoordinate:("+worldCoordinate.x+","+worldCoordinate.y+")");

				var newOriginInLatLng = mapUI.fromPointToLatLng(worldCoordinate);

				console.log("new origin lat,lng:("+newOriginInLatLng.lat+","+newOriginInLatLng.lng+")");
					//reload
					if ( mapUI.bufferNum == 1 )
					{
						mapUI.latitude2 = newOriginInLatLng.lat;
						mapUI.longitude2 = newOriginInLatLng.lng;
						mapUI.zoom2 = mapUI.zoom1;
						mapImageBuffer2.x = 0;
						mapImageBuffer2.y = 0;
						mapImageBuffer2.source = "";
						mapImageBuffer2.source = mapUI.mapUrl(mapUI.latitude2, mapUI.longitude2, mapUI.zoom2, false, 0, 0,
															  function(url){
																  if ( mapUI.src == "BAIDU" )
																	  mapImageBuffer2.source = url;
															  });
					}
					else
					{
						mapUI.latitude1 = newOriginInLatLng.lat;
						mapUI.longitude1 = newOriginInLatLng.lng;
						mapUI.zoom1 = mapUI.zoom2;
						mapImageBuffer1.x = 0;
						mapImageBuffer1.y = 0;
						mapImageBuffer1.source = "";
						mapImageBuffer1.source = mapUI.mapUrl(mapUI.latitude1, mapUI.longitude1, mapUI.zoom1, false, 0, 0,
															  function(url){
																  if ( mapUI.src == "BAIDU" )
																	  mapImageBuffer1.source = url;
															  });
					}
			}
		}
		onDoubleClicked: {
			console.log("double-click at: ("+mouseX+","+mouseY+")");
			/*var pixelCoordinate = {
				"x": worldCoordinate.x * numTiles,
				"y": worldCoordinate.y * numTiles
			};*/
			//mapImage.state = "zoomIn"
			//mapImage.scale = 2;
			//mapUI.zoom++;
			mapUI.zoomIn();
		}
	}



	function zoomIn()
	{
		console.log("zoomIn");
		var currentBuffer = mapUI.bufferNum == 1 ? mapImageBuffer1 : mapImageBuffer2;
		var newBuffer = mapUI.bufferNum == 1 ? mapImageBuffer2 : mapImageBuffer1;

		//currentBuffer.scale = 2;
		currentBuffer.state = "zoomIn";
		if ( mapUI.bufferNum == 1 )
		{
			mapUI.latitude2 = mapUI.latitude1;
			mapUI.longitude2 = mapUI.longitude1;
			mapUI.zoom2 = mapUI.zoom1 + 1;
			//var z = {"z": mapUI.zoom + 1};
			//mapUI.zoom2 = z.z
			mapImageBuffer2.x = 0;
			mapImageBuffer2.y = 0;
			mapImageBuffer2.source = "";
			mapImageBuffer2.source = mapUI.mapUrl(mapUI.latitude2, mapUI.longitude2, mapUI.zoom2, false, 0, 0,
												  function(url){
													  if ( mapUI.src == "BAIDU" )
														  mapImageBuffer2.source = url;
												  });
			//console.log("buffer2 url becomes:" + mapImageBuffer2.source);
		}
		else
		{
			mapUI.latitude1 = mapUI.latitude2;
			mapUI.longitude1 = mapUI.longitude2;
			mapUI.zoom1 = mapUI.zoom2 + 1;
			//var z = {"z": mapUI.zoom + 1};
			//mapUI.zoom1 = z.z;
			mapImageBuffer1.x = 0;
			mapImageBuffer1.y = 0;
			mapImageBuffer1.source = "";
			mapImageBuffer1.source = mapUI.mapUrl(mapUI.latitude1, mapUI.longitude1, mapUI.zoom1, false, 0, 0,
												  function(url){
													  if ( mapUI.src == "BAIDU" )
														  mapImageBuffer1.source = url;
												  });
			//console.log("buffer1 url becomes:" + mapImageBuffer1.source);
		}
	}
	function zoomOut()
	{
		console.log("zoomOut");
		var currentBuffer = mapUI.bufferNum == 1 ? mapImageBuffer1 : mapImageBuffer2;
		var newBuffer = mapUI.bufferNum == 1 ? mapImageBuffer2 : mapImageBuffer1;

		//currentBuffer.scale = 0.5;
		currentBuffer.state = "zoomOut";
		if ( mapUI.bufferNum == 1 )
		{
			mapUI.latitude2 = mapUI.latitude1;
			mapUI.longitude2 = mapUI.longitude1;
			mapUI.zoom2 = mapUI.zoom1 - 1;
			//var z = {"z": mapUI.zoom - 1};
			//mapUI.zoom2 = z.z;
			//console.log("zoomOut: zoom2 become:" + mapUI.zoom2);
			mapImageBuffer2.x = 0;
			mapImageBuffer2.y = 0;
			mapImageBuffer2.source = "";
			mapImageBuffer2.source = mapUI.mapUrl(mapUI.latitude2, mapUI.longitude2, mapUI.zoom2, false, 0, 0,
												  function(url){
													  if ( mapUI.src == "BAIDU" )
														  mapImageBuffer2.source = url;
												  });
			//console.log("buffer2 url becomes:" + mapImageBuffer2.source);
		}
		else
		{
			mapUI.latitude1 = mapUI.latitude2;
			mapUI.longitude1 = mapUI.longitude2;
			mapUI.zoom1 = mapUI.zoom2 - 1;
			//var z = {"z": mapUI.zoom - 1};
			//mapUI.zoom1 = z.z;
			//console.log("zoomOut: zoom1 become:" + mapUI.zoom1);
			mapImageBuffer1.x = 0;
			mapImageBuffer1.y = 0;
			mapImageBuffer1.source = "";
			mapImageBuffer1.source = mapUI.mapUrl(mapUI.latitude1, mapUI.longitude1, mapUI.zoom1, false, 0, 0,
												  function(url){
													  if ( mapUI.src == "BAIDU" )
														  mapImageBuffer1.source = url;
												  });
			//console.log("buffer1 url becomes:" + mapImageBuffer1.source);
		}
	}
	function goBackToMyPosition(myLongitude, myLatitude)
	{
		if ( mapUI.bufferNum == 1 )
		{
			mapUI.latitude2 = myLatitude;
			mapUI.longitude2 = myLongitude;
			mapUI.zoom2 = mapUI.zoom1;
			mapImageBuffer2.x = 0;
			mapImageBuffer2.y = 0;
			mapImageBuffer2.source = "";
			mapImageBuffer2.source = mapUI.mapUrl(mapUI.latitude2, mapUI.longitude2, mapUI.zoom2, false, 0, 0,
												  function(url){
													  if ( mapUI.src == "BAIDU" )
														  mapImageBuffer2.source = url;
												  });
		}
		else
		{
			mapUI.latitude1 = myLatitude;
			mapUI.longitude1 = myLongitude;
			mapUI.zoom1 = mapUI.zoom2;
			mapImageBuffer1.x = 0;
			mapImageBuffer1.y = 0;
			mapImageBuffer1.source = "";
			mapImageBuffer1.source = mapUI.mapUrl(mapUI.latitude1, mapUI.longitude1, mapUI.zoom1, false, 0, 0,
												  function(url){
													  if ( mapUI.src == "BAIDU" )
														  mapImageBuffer1.source = url;
												  });
		}
	}

	Rectangle {
		id: zoomInButton
		anchors.top: parent.top
		anchors.topMargin: 20*wpp.dp2px
		anchors.right: parent.right
		anchors.rightMargin: 10*wpp.dp2px
		color: Qt.rgba(1,1,1,0.6)
		border.color: "#7f7f7f"
		border.width: 1
		radius:2*wpp.dp2px
		width: 40*wpp.dp2px
		height: 40*wpp.dp2px
		Text {
			color: "#999999"
			anchors.fill: parent
			text: "+"
			font.pixelSize: 32*wpp.dp2px
			font.bold: true
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}
		MouseArea {
			id: zoomInButtonMouseArea
			z: mapMouseArea.z+1
			anchors.fill: parent
			onClicked: mapUI.zoomIn()
			Overlay {
				target: parent
				isTargetMouseArea: true
			}
		}
	}
	Rectangle {
		id: zoomOutButton
		anchors.top: zoomInButton.bottom
		anchors.topMargin: 10*wpp.dp2px
		anchors.right: parent.right
		anchors.rightMargin: 10*wpp.dp2px
		color: Qt.rgba(1,1,1,0.6)
		border.color: "#7f7f7f"
		border.width: 1
		radius:2*wpp.dp2px
		width: 40*wpp.dp2px
		height: 40*wpp.dp2px
		Text {
			color: "#999999"
			anchors.fill: parent
			text: "-"
			font.pixelSize: 32*wpp.dp2px
			font.bold: true
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}
		MouseArea {
			z: mapMouseArea.z+1
			anchors.fill: parent
			onClicked: mapUI.zoomOut()
			Overlay {
				target: parent
				isTargetMouseArea: true
			}
		}
	}

	Rectangle {
		id: locationSearchButton
		x: zoomInButton.x
		y: parent.height - 20*wpp.dp2px - height
		color: Qt.rgba(1,1,1,0.6)
		border.color: "#7f7f7f"
		border.width: 1
		radius:2*wpp.dp2px
		width: 40*wpp.dp2px
		height: 40*wpp.dp2px
		visible: geoPosition.isEnabled()
		Image {
			anchors.centerIn: parent
			width: 32*wpp.dp2px
			height: 32*wpp.dp2px
			source: "qrc:/img/android-icons/All_Icons/holo_light/mdpi/10-device-access-location-searching.png"
			smooth: true
			fillMode: Image.PreserveAspectFit
		}
		MouseArea {
			z: mapMouseArea.z+1
			anchors.fill: parent
			onClicked: {
				console.log("location search button...");
				mapUI.locatedLongitude = geoPosition.longitude;
				mapUI.locatedLatitude = geoPosition.latitude;
				mapUI.goBackToMyPosition(mapUI.locatedLongitude, mapUI.locatedLatitude);
			}

			Overlay {
				target: parent
				isTargetMouseArea: true
			}
		}
	}

	SelectionList {
		id: chooseMapSourceButton
		anchors.left: parent.left
		anchors.leftMargin: 5*wpp.dp2px
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 5*wpp.dp2px
		width: 80*wpp.dp2px
		height: 30*wpp.dp2px
		//anchors.top: titleBar.bottom
		border.color: "#7f7f7f"
		border.width: 1
		radius: 2*wpp.dp2px
		ListModel {
			id: mapSourcelistData
			ListElement { value: "Google"; key: "GOOGLE"; }
			ListElement { value: "Baidu"; key: "BAIDU"; }
			ListElement { value: "高德"; key: "AMAP"; }
		}
		model: mapSourcelistData
		currentIndex: {
			console.log("currentIndex func...model length:" + mapSourcelistData.count);
			for ( var i = 0 ; i < mapSourcelistData.count; i++ )
			{
				console.log("i=" + i + ", key=" + mapSourcelistData.get(i).key + ", src=" + mapUI.src ) ;
				if ( mapSourcelistData.get(i).key == mapUI.src )
				{
					return i;
				}
			}
			return i;
		}
		arrowDirection: 1
		modal: true
		//fullScreenParent: parent
		onSelected: {
			mapUI.src = currentItem.key;
		}
	}

	/*ComboBox {
		id: mapSourceList
		currentIndex: 0
		model: ListModel {
			id: mapSources
			ListElement { text: "Google"; value: "GOOGLE" }
			ListElement { text: "Baidu"; value: "BAIDU" }
		}
		width: 80*wpp.dp2px
		height: 30*wpp.dp2px
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.leftMargin: 10*wpp.dp2px
		anchors.bottomMargin: 10*wpp.dp2px
		onCurrentIndexChanged: {
			mapUI.src = mapSources.get(currentIndex).value;
		}
		style: ComboBoxStyle {
			renderType: Text.QtRendering
		}
	}*/

	/*Rectangle {
		id: mapSourceList
		width: 80*wpp.dp2px
		height: mapSourceListColumn.height
		color: "#ffffff"
		border.color: "#dddddd"
		border.width: 2
		radius:2*wpp.dp2px
		visible: false
		anchors.bottom: chooseMapSourceButton.top
		anchors.left: chooseMapSourceButton.left
		anchors.leftMargin: chooseMapSourceButton.leftMargin
		Column {
			id: mapSourceListColumn
			Rectangle {
				width: mapSourceList.width
				height: 30*wpp.dp2px
				Text {
					width: parent.width
					height: 30*wpp.dp2px
					text: qsTr("Google")
					verticalAlignment: Text.AlignVCenter
					font.pixelSize: 16*wpp.dp2px
					color: "#555555"
					anchors.left: parent.left
					anchors.leftMargin: 5*wpp.dp2px
					anchors.rightMargin: anchors.leftMargin
				}
				MouseArea {
					z: mapMouseArea.z+1
					anchors.fill: parent
					onClicked: {
						mapUI.src = "GOOGLE";
						mapSourceList.visible = false;
					}
					Overlay {
						target: parent
						isTargetMouseArea: true
					}
				}
			}
			Line {
				width: mapSourceList.width
				height: 1
				color: "#dddddd"
			}
			Rectangle {
				width: mapSourceList.width
				height: 30*wpp.dp2px
				Text {
					width: parent.width
					height: 30*wpp.dp2px
					text: qsTr("Baidu")
					verticalAlignment: Text.AlignVCenter
					font.pixelSize: 16*wpp.dp2px
					color: "#555555"
					anchors.left: parent.left
					anchors.leftMargin: 5*wpp.dp2px
					anchors.rightMargin: anchors.leftMargin
				}
				MouseArea {
					z: mapMouseArea.z+1
					anchors.fill: parent
					onClicked: {
						mapUI.src = "BAIDU";
						mapSourceList.visible = false;
					}
					Overlay {
						target: parent
						isTargetMouseArea: true
					}
				}
			}
		}
	}
	Rectangle {
		id: chooseMapSourceButton
		anchors.left: parent.left
		anchors.leftMargin: 5*wpp.dp2px
		anchors.bottom: parent.bottom
		anchors.bottomMargin: 5*wpp.dp2px
		color: "#ffffff"
		border.color: "#dddddd"
		border.width: 2
		radius:2*wpp.dp2px
		//width: 40*wpp.dp2px
		width: chooseMapSourceButtonText.width + 2*chooseMapSourceButtonText.anchors.leftMargin
		height: 30*wpp.dp2px
		visible: mapUI.selectSource
		Text {
			id: chooseMapSourceButtonText
			color: "#555555"
			height: parent.height
			anchors.left: parent.left
			anchors.leftMargin: 5*wpp.dp2px
			anchors.rightMargin: anchors.leftMargin
			verticalAlignment: Text.AlignVCenter
			font.pixelSize: 16*wpp.dp2px
			text: mapUI.src == "BAIDU" ? qsTr("Baidu") : qsTr("Google")
		}
		MouseArea {
			z: mapMouseArea.z+1
			anchors.fill: parent
			onClicked: {
				mapSourceList.visible = !mapSourceList.visible;
			}
			Overlay {
				target: parent
				isTargetMouseArea: true
			}
		}
	}*/

	Rectangle {
		width: parent.width
		height: 20*wpp.dp2px
		anchors.top: parent.top
		visible: selectPlace
		color: Qt.rgba(1,1,0,1)
		Text {
			visible: parent.visible
			anchors.fill: parent
			color: "#0080ff"
			font.pixelSize: 12*wpp.dp2px
			text: qsTr("Press and Hold to select a place.")
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}
	}


	WppDialog {
		id: placesToChooseDialog
		//text: "Test Test"
		property int listViewCurrentIndex: 0
		z: mapMouseArea.z + 1
		ListModel {
			id: placesListModel
			/*ListElement {
				pk: 1
				name: "Hong Kong"
			}
			ListElement {
				pk: 2
				name: "China, PRC"
			}
			ListElement {
				pk: 3
				name: "Shanghai pudong"
			}
			ListElement {
				pk: 4
				name: "Shanghai People's Square"
			}
			ListElement {
				pk: 5
				name: "Hangzhou"
			}
			ListElement {
				pk: 6
				name: "SuZhou"
			}
			ListElement {
				pk: 7
				name: "Wu-xi"
			}
			ListElement {
				pk: 8
				name: "Pudong International Airport"
			}
			ListElement {
				pk: 9
				name: "Shanghai Train Station"
			}
			ListElement {
				pk: 10
				name: "Shanghai South Train Station"
			}
			ListElement {
				pk: 11
				name: "明珠塔"
			}
			ListElement {
				pk: 12
				name: "正大广场"
			}
			ListElement {
				pk: 13
				name: "外滩"
			}*/
		}
		contentComponent: Component {
			Rectangle {
				width: placesToChooseDialog.contentWidth
				height: placesListView.y + placesListView.height
				color: "transparent"
				Image {
					id: markerIcon
					source: "qrc:/img/android-icons/All_Icons/holo_light/mdpi/7-location-place.png"
					x: 0
					y: 0
					width: 20*wpp.dp2px
					height: width
					smooth: true
					fillMode: Image.PreserveAspectFit
				}
				Text {
					id: placesCountText
					x: markerIcon.width
					width: placesToChooseDialog.contentWidth - x
					height: 20*wpp.dp2px
					verticalAlignment: Text.AlignVCenter
					text: qsTr("%1 place(s) to choose").arg(placesListView.model.count)
				}
				Rectangle {
					id: dialogTitleSeparator
					y: placesCountText.y + placesCountText.height
					width: parent.width
					height: 1
					color: Qt.rgba(0,0,0,0.5)
				}
				ListView {
					id: placesListView
					y: dialogTitleSeparator.y + dialogTitleSeparator.height
					width: placesToChooseDialog.contentWidth
					height: 300*wpp.dp2px
					clip: true
					model: placesListModel
					delegate: Rectangle {
						id: placesListViewItem
						width: placesToChooseDialog.contentWidth
						height: 30*wpp.dp2px
						color: model.index == placesToChooseDialog.listViewCurrentIndex ? Qt.rgba(0,0.796,0,0.3) : "transparent"
						Text {
							anchors.fill: parent
							verticalAlignment: Text.AlignVCenter
							anchors.leftMargin: 10*wpp.dp2px
							anchors.rightMargin: anchors.leftMargin
							text: name
						}
						Rectangle {
							y: parent.height - 1
							width: parent.width
							height: 1
							color: Qt.rgba(1,1,1,0.5)
						}
						MouseArea {
							anchors.fill: parent
							onClicked: {
								placesToChooseDialog.listViewCurrentIndex = model.index;
							}
						}
					}
				}
			}//Rectangle
		}//contentComponent
		type: "CONFIRM"
		bgColor: Qt.rgba(1,1,1,0.5)
		onAccepted: {
			console.log("OK");
			visible = false;

			mapUI.selectedPlaceName = placesListModel.get( placesToChooseDialog.listViewCurrentIndex ).name;
			mapUI.placeSelected();//emit signal
		}
		onRejected: {
			console.log("Cancel...");
			visible = false;
		}
		visible: false
	}//Dialog




	/*PositionSource {
		id: positionSource
	}
	Map {
		id: map
		property MapCircle circle
		Component.onCompleted: {
			circle = Qt.createQmlObject('import QtLocation 5.0; MapCircle {}')
			circle.center = positionSource.position.coordinate
			circle.radius = 5000.0
			circle.color = 'green'
			circle.border.width = 3
			map.addMapItem(circle)
		}
	}*/
}
