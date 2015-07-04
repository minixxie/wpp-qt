#include "IOSTimeZonePicker.h"

#include "System.h"

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#endif

namespace wpp {
namespace qt {

#ifndef Q_OS_IOS
IOSTimeZonePicker::IOSTimeZonePicker(QQuickItem *parent)
	: QQuickItem(parent),
	  m_timezoneId( QTimeZone::systemTimeZoneId() )
{

}

void IOSTimeZonePicker::open()
{
#ifdef Q_OS_ANDROID
	QAndroidJniObject activity = QtAndroid::androidActivity();
	qDebug() << __FUNCTION__ << "activity.isValid()=" << activity.isValid();


	/*

	//android.provider.MediaStore.EXTRA_OUTPUT
	QAndroidJniObject MediaStore__EXTRA_OUTPUT
			= QAndroidJniObject::getStaticObjectField(
				"android/provider/MediaStore", "EXTRA_OUTPUT", "Ljava/lang/String;");
	qDebug() << "MediaStore__EXTRA_OUTPUT.isValid()=" << MediaStore__EXTRA_OUTPUT.isValid();


	QAndroidJniObject action = QAndroidJniObject::fromString("android.media.action.IMAGE_CAPTURE");
	QAndroidJniObject intent=QAndroidJniObject("android/content/Intent","(Ljava/lang/String;)V",
											   action.object<jstring>());
	qDebug() << __FUNCTION__ << "intent.isValid()=" << intent.isValid();

	QAndroidJniObject extDir = QAndroidJniObject::callStaticObjectMethod(
				"android/os/Environment", "getExternalStorageDirectory", "()Ljava/io/File;");
	qDebug() << "extDir.isValid()=" << extDir.isValid();

	QAndroidJniObject filename = QAndroidJniObject::fromString("camera.jpg");

	QAndroidJniObject photo=QAndroidJniObject("java/io/File","(Ljava/io/File;Ljava/lang/String;)V",
											   extDir.object<jobject>(), filename.object<jstring>());
	qDebug() << __FUNCTION__ << "photo.isValid()=" << photo.isValid();

	takePhotoSavedUri = QAndroidJniObject::callStaticObjectMethod(
				"android/net/Uri", "fromFile", "(Ljava/io/File;)Landroid/net/Uri;", photo.object<jobject>());
	qDebug() << "takePhotoSavedUri.isValid()=" << takePhotoSavedUri.isValid();

	intent.callObjectMethod(
				"putExtra","(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;",
				MediaStore__EXTRA_OUTPUT.object<jstring>(), takePhotoSavedUri.object<jobject>());
	qDebug() << __FUNCTION__ << "intent.isValid()=" << intent.isValid();

	int SHOOT_PHOTO = 1;
	QtAndroid::startActivity(intent, SHOOT_PHOTO, this);*/
#endif

}
#endif

#ifdef Q_OS_ANDROID
void IOSTimeZonePicker::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data)
{

}

#endif

}
}
