#include "Map.h"

#include <QDebug>
#include <QString>
#ifdef Q_OS_ANDROID
	#include <QAndroidJniObject>
#endif

#include <QDesktopServices>
#include <QUrl>


namespace wpp
{
namespace qt
{

Map *Map::singleton = 0;
Map &Map::getInstance()
{
	if ( singleton == 0 )
	{
		static Map singletonInstance;
		singleton = &singletonInstance;
	}
	return *singleton;
}

void Map::loadExternalMap(double longitude, double latitude, const QString& locationName, int zoom)
{
	QString uriStr = QString().sprintf("geo:%lf,%lf?q=%lf,%lf&z=%d", latitude, longitude, latitude, longitude, zoom);

#if defined(Q_OS_ANDROID)
	// http://androidbiancheng.blogspot.hk/2011/06/intent-android.html
	// http://www.qtcentre.org/threads/58668-How-to-use-QAndroidJniObject-for-intent-setData
	// Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse(strUri));
	//startActivity(intent);

	QAndroidJniObject path=QAndroidJniObject::fromString(uriStr); //path is valid
	QAndroidJniObject uri=QAndroidJniObject("java/net/URI","(Ljava/lang/String;)V",path.object<jstring>()); //uri is valid

//	QUrl url;
//	url.toEncoded();

	QAndroidJniObject intent=QAndroidJniObject::callStaticObjectMethod("android/content/Intent","parseUri","(Ljava/lang/String;I)Landroid/content/Intent;",path.object<jstring>(),0x00000000);

	QAndroidJniObject action=QAndroidJniObject::fromString( QString("ACTION_VIEW") ); //path is valid
	intent.callObjectMethod("setAction","(Ljava/net/URI;)Landroid/content/Intent;",action.object<jobject>()); //result is invalid, intent contains type

	QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;"); //activity is valid
	//QAndroidJniObject intent("android/content/Intent","()V"); //intent is valid, but empty

	//QAndroidJniObject type=QAndroidJniObject::fromString("application/vnd.android.package-archive"); //type is valid
	//QAndroidJniObject result=intent.callObjectMethod("setType","(Ljava/lang/String;)Landroid/content/Intent;",type.object<jobject>()); //result is valid, intent contains type

	activity.callObjectMethod("startActivity","(Landroid/content/Intent;)V",intent.object<jobject>()); //works, but shows a selection screen for the intent containing email, bluetooth etc. because intent's data member is missing

#elif defined(Q_OS_IOS)

	//http://stackoverflow.com/questions/12504294/programmatically-open-maps-app-in-ios-6
	/* objective-c:
Class mapItemClass = [MKMapItem class];
if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
{
	// Create an MKMapItem to pass to the Maps app
	CLLocationCoordinate2D coordinate =
				CLLocationCoordinate2DMake(16.775, -3.009);
	MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
											addressDictionary:nil];
	MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
	[mapItem setName:@"My Place"];
	// Pass the map item to the Maps app
	[mapItem openInMapsWithLaunchOptions:nil];
}
	 */

	//ref - Apple URL Scheme Reference
	// https://developer.apple.com/library/ios/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
	// Qt handle URL scheme: http://stackoverflow.com/questions/6561661/url-scheme-qt-and-mac
	// Intent JNI: http://blog.qt.digia.com/blog/2013/12/12/implementing-in-app-purchase-on-android/

	qDebug() << "iOS open external map...";

	uriStr = QString().sprintf("http://maps.apple.com/?q=%lf,%lf&z=%d", latitude, longitude, zoom);
qDebug() << "map uri:" << uriStr;

	QDesktopServices::openUrl(QUrl(uriStr));

#else

	qDebug() << "use desktop service...";
	/*uriStr = QString().sprintf(
		"http://api.map.baidu.com/staticimage?markers=%lf,%lf&zoom=%d&markerStyles=s,A,0xff0000",
		longitude, latitude, zoom);*/
	if ( latitude != 0 && longitude != 0 )
	{
		uriStr = QString().sprintf("http://maps.apple.com/?ll=%lf,%lf&z=%d", latitude, longitude, zoom);
	}
	else
	{
		uriStr = QString().sprintf("http://maps.apple.com/?q=%s&z=%d", locationName.toStdString().c_str(), zoom);
	}
	QDesktopServices::openUrl(QUrl(uriStr));

#endif


}

void Map::loadExternalMap(QString keyword, int zoom)
{
	QString uriStr = QString().sprintf("geo:q=%s,&z=%d", keyword.toStdString().c_str(), zoom);

#if defined(Q_OS_ANDROID)
	// http://androidbiancheng.blogspot.hk/2011/06/intent-android.html
	// http://www.qtcentre.org/threads/58668-How-to-use-QAndroidJniObject-for-intent-setData
	// Intent intent = new Intent(android.content.Intent.ACTION_VIEW, Uri.parse(strUri));
	//startActivity(intent);

	QAndroidJniObject path=QAndroidJniObject::fromString(uriStr); //path is valid
	QAndroidJniObject uri=QAndroidJniObject("java/net/URI","(Ljava/lang/String;)V",path.object<jstring>()); //uri is valid

//	QUrl url;
//	url.toEncoded();

	QAndroidJniObject intent=QAndroidJniObject::QAndroidJniObject::callStaticObjectMethod("android/content/Intent","parseUri","(Ljava/lang/String;I)Landroid/content/Intent;",path.object<jstring>(),0x00000000);

	QAndroidJniObject action=QAndroidJniObject::fromString( QString("ACTION_VIEW") ); //path is valid
	intent.callObjectMethod("setAction","(Ljava/net/URI;)Landroid/content/Intent;",action.object<jobject>()); //result is invalid, intent contains type

	QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;"); //activity is valid
	//QAndroidJniObject intent("android/content/Intent","()V"); //intent is valid, but empty

	//QAndroidJniObject type=QAndroidJniObject::fromString("application/vnd.android.package-archive"); //type is valid
	//QAndroidJniObject result=intent.callObjectMethod("setType","(Ljava/lang/String;)Landroid/content/Intent;",type.object<jobject>()); //result is valid, intent contains type

	activity.callObjectMethod("startActivity","(Landroid/content/Intent;)V",intent.object<jobject>()); //works, but shows a selection screen for the intent containing email, bluetooth etc. because intent's data member is missing

#elif defined(Q_OS_IOS)

	//http://stackoverflow.com/questions/12504294/programmatically-open-maps-app-in-ios-6
	/* objective-c:
Class mapItemClass = [MKMapItem class];
if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
{
	// Create an MKMapItem to pass to the Maps app
	CLLocationCoordinate2D coordinate =
				CLLocationCoordinate2DMake(16.775, -3.009);
	MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
											addressDictionary:nil];
	MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
	[mapItem setName:@"My Place"];
	// Pass the map item to the Maps app
	[mapItem openInMapsWithLaunchOptions:nil];
}
	 */

	//ref - Apple URL Scheme Reference
	// https://developer.apple.com/library/ios/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
	// Qt handle URL scheme: http://stackoverflow.com/questions/6561661/url-scheme-qt-and-mac
	// Intent JNI: http://blog.qt.digia.com/blog/2013/12/12/implementing-in-app-purchase-on-android/

	qDebug() << "iOS open external map...";

	uriStr = QString().sprintf("http://maps.apple.com/?q=%s&z=%d", keyword.toStdString().c_str(), zoom);


	QDesktopServices::openUrl(QUrl(uriStr));

#else

	qDebug() << "use desktop service...";
	/*uriStr = QString().sprintf(
		"http://api.map.baidu.com/staticimage?markers=%lf,%lf&zoom=%d&markerStyles=s,A,0xff0000",
		longitude, latitude, zoom);*/
	uriStr = QString().sprintf("http://maps.apple.com/?q=%s&z=%d", keyword.toStdString().c_str(), zoom);
	QDesktopServices::openUrl(QUrl(uriStr));

#endif


}


}//namespace qt
}//namespace wpp
