import QtQuick 2.1
import QtWebKit 3.0
import QtWebKit.experimental 1.0
//http://stackoverflow.com/questions/22445960/expose-and-add-qwebview-widget-object-to-qml
//http://rschroll.github.io/beru/2013/08/21/qtwebview.experimental.html
//http://stackoverflow.com/questions/14342220/invoke-c-method-from-webviews-javascript/14365144#14365144


/*
 * Google static map API (v2): https://developers.google.com/maps/documentation/staticmaps/index
 * Google geocoding API (v3): https://developers.google.com/maps/documentation/geocoding/?hl=zh-tw
 * Baidu static map API (v3.0): http://developer.baidu.com/map/staticimg.htm
 * Baidu geocoding API(v2.0): http://developer.baidu.com/map/webservice-geocoding.htm
 * 高德 static map API: http://developer.amap.com/api/static-map-api/guide-2/
 */
Rectangle {
	id: "mapUI"
	clip: true

	WebView {
		id: webView
		anchors.fill: parent
		//url: "http://maps.google.com/"
		url: "qrc:/identified-modules/wpp/qt/qml/google-map.html"

		/*onLoadStarted: {
			webView.evaluateJavaScript("alert('Start!');");

		}*/

		onLoadingChanged: {
			console.log("webview loading changed.");
			if ( loadRequest.status == WebView.LoadSucceededStatus )
			{
				//webView.alertDialog("HI");// evaluateJavaScript("alert('Start!');");
				//webView.experimental.userScripts( "alert('start');" );
				experimental.postMessage("{}");
			}

		}

		experimental.preferences.navigatorQtObjectEnabled: true
		experimental.onMessageReceived: {  // navigator.qt.postMessage('XXX');

			console.debug("get msg from javascript:" + message.data);
			experimental.postMessage("HELLO from QML");
		}

	}
}
