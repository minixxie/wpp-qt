#include "NativeMap.h"

#ifdef Q_OS_ANDROID
#include <QAndroidJniObject>
#include <QtAndroid>
#include <QAndroidJniEnvironment>
#endif

namespace wpp {
namespace qt {

#ifndef Q_OS_IOS
void NativeMap::open()
{
	qDebug() << "NativeMap::open()...";
#ifdef Q_OS_ANDROID
	qDebug() << "NativeMap::open()...ANDROID";
	QAndroidJniObject activity = QtAndroid::androidActivity();

	if ( activity.isValid() )
	{
		/*QAndroidJniEnvironment env;
		jclass cls = env->FindClass( "wpp.android.AMapActivity" );
		qDebug() << "cls:" << cls;
		QAndroidJniObject anIntent("android/content/Intent","(Landroid/content/Context;Ljava/lang/Class;)V",
								 activity.object<jobject>(), cls);
		qDebug() << "anIntent.isvalid=" << anIntent.isValid();
		*/

		// Equivalent to Jave code: 'Intent intent = new Intent();'
		QAndroidJniObject intent("android/content/Intent","()V");
		if ( intent.isValid() )
		{
			QAndroidJniObject packageName = activity.callObjectMethod("getPackageName","()Ljava/lang/String;");
			qDebug() << "packageName.isValid=" << packageName.isValid();
			qDebug() << "packageName=" << packageName.toString();

			QAndroidJniObject param2 = QAndroidJniObject::fromString("wpp.android.AMapActivity");

			if ( packageName.isValid() && param2.isValid() )
			{
				qDebug() << "111...";
				// Equivalent to Jave code: 'intent.setClassName("com.kuulabu.android.app", "com.kuulabu.android.app.BasicMapActivity");'
				intent.callObjectMethod("setClassName","(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;",packageName.object<jobject>(),param2.object<jobject>());

				qDebug() << "222...";
				// Equivalent to Jave code: 'startActivity(intent);'
				//activity.callMethod<void>("startActivity","(Landroid/content/Intent;)V",intent.object<jobject>());
				//QtAndroid::startActivity(intent, 0, 0);
				int LOCATE_EVENT_VENUE = 1;
				QtAndroid::startActivity(intent, LOCATE_EVENT_VENUE, this);
				qDebug() << "333...";
			}

		}
	}
#endif

}
#endif

#ifdef Q_OS_ANDROID
void NativeMap::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data)
{
	int LOCATE_EVENT_VENUE = 1;

	jint Activity__RESULT_OK = QAndroidJniObject::getStaticField<jint>(
				"android.app.Activity", "RESULT_OK");

	if ( receiverRequestCode == LOCATE_EVENT_VENUE
		 && resultCode == Activity__RESULT_OK )
	{
		QAndroidJniObject addressName = QAndroidJniObject::fromString(QString("addressName"));
		QAndroidJniObject lat = QAndroidJniObject::fromString(QString("latitude"));
		QAndroidJniObject lon = QAndroidJniObject::fromString(QString("longitude"));

		QAndroidJniObject extras = data.callObjectMethod("getExtras","()Landroid/os/Bundle;");
		qDebug() << __FUNCTION__ << "extras.isValid()=" << extras.isValid();
		QAndroidJniObject addressNameObj = extras.callObjectMethod("getString","(Ljava/lang/String;)Ljava/lang/String;",
								addressName.object<jobject>());
		qDebug() << __FUNCTION__ << "addressNameObj.isValid()=" << addressNameObj.isValid();
		QAndroidJniObject latitudeObj = extras.callObjectMethod("getString","(Ljava/lang/String;)Ljava/lang/String;",
								lat.object<jobject>());
		qDebug() << __FUNCTION__ << "latitudeObj.isValid()=" << latitudeObj.isValid();
		QAndroidJniObject longitudeObj = extras.callObjectMethod("getString","(Ljava/lang/String;)Ljava/lang/String;",
								lon.object<jobject>());
		qDebug() << __FUNCTION__ << "longitudeObj.isValid()=" << longitudeObj.isValid();

		qDebug() << __FUNCTION__ << "address=" << addressNameObj.toString();
		//this->setVenue(addressNameObj.toString());
		emit this->locationSelected(
					longitudeObj.toString().toDouble(),
					latitudeObj.toString().toDouble(),
					addressNameObj.toString());

//        double lond = (double)longitudeObj.callMethod<jdouble>("doubleValue", "()D");
//        double latd = (double)latitudeObj.callMethod<jdouble>("doubleValue", "()D");
qDebug() << __FUNCTION__ << "latd.isValid()=" << latitudeObj.toString();
qDebug() << __FUNCTION__ << "lond.isValid()=" << longitudeObj.toString();

		//this->setLatitude(latitudeObj.toString().toDouble());
		//this->setLongitude(longitudeObj.toString().toDouble());

	}
}
#endif


QMap<QString,QString> NativeMap::i18n()
{
	QMap<QString,QString> translation;

	qDebug() << "locale:     " <<  QLocale::system().name();
	QString locale = QLocale::system().name();
	QString map = "Map";
	QString finish = "Finish";
	QString back = "Back";
	QString unknownRegion = "Unknown region";
	QString pleaseSelectVenue = "Please select venue";

	if ( locale == "zh_CN" )
	{
		map = "地图";
		finish = "完成";
		back = "返回";
		unknownRegion = "未知区域";
		pleaseSelectVenue = "请按住选择一个地点";
	}
	else if ( locale == "zh_HK" || locale == "zh_TW" )
	{
		map = "地圖";
		finish = "完成";
		back = "返回";
		unknownRegion = "未知區域";
		pleaseSelectVenue = "請按住選擇一個地點";
	}


	translation["map"] = map;
	translation["finish"] = finish;
	translation["back"] = back;
	translation["unknownRegion"] = unknownRegion;
	translation["pleaseSelectVenue"] = pleaseSelectVenue;

	return translation;

}

}
}
