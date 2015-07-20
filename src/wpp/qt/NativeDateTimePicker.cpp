#include "NativeDateTimePicker.h"

#include "Wpp.h"

#ifdef Q_OS_ANDROID
#include <QtAndroid>
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#endif

void __NativeDateTimePicker__setDateTimeSelected(const QString& iso8601, void *qmlDateTimePickerPtr )
{
	if ( qmlDateTimePickerPtr != 0 )
	{
		wpp::qt::NativeDateTimePicker *p = (wpp::qt::NativeDateTimePicker *)qmlDateTimePickerPtr;
		QDateTime dateTime = QDateTime::fromString(iso8601, Qt::ISODate);
		qDebug() << "dateTime selected is!!!! ==== " << dateTime << "(" << dateTime.toMSecsSinceEpoch() << ")";
		//p->setDateTime( dateTime );
		p->setMsecSinceEpoch( dateTime.toMSecsSinceEpoch() );
		p->picked( dateTime.toMSecsSinceEpoch() );
	}
}

namespace wpp {
namespace qt {

#ifndef Q_OS_IOS
NativeDateTimePicker::NativeDateTimePicker(QQuickItem *parent)
	: QQuickItem(parent),
	  m_msecSinceEpoch(0),
	  m_timeZoneId( QTimeZone::systemTimeZoneId() )
{
	//uint initTS = QDateTime::currentDateTime().toTime_t();
	//initTS -= initTS % 60;//assign seconds to 0
	//m_dateTime.setTime_t( initTS );
	m_msecSinceEpoch = QDateTime::currentMSecsSinceEpoch();

	connect(this, SIGNAL(timeZoneIdChanged()), this, SLOT(onTimeZoneIdChanged()));
}

void NativeDateTimePicker::open()
{
#ifdef Q_OS_ANDROID
	QAndroidJniObject activity = QtAndroid::androidActivity();
	qDebug() << __FUNCTION__ << "activity.isValid()=" << activity.isValid();

	//QAndroidJniObject str = QAndroidJniObject::callStaticObjectMethod(
	//			"wpp/android/DatePickerDialog", "show", "(Landroid/content/Context;)Ljava/lang/String;", activity.object<jobject>());
	//qDebug() << "str.isValid()=" << str.isValid();

	QDateTime dateTime;
	dateTime.setTimeZone(QTimeZone("UTC"));
	dateTime.setTimeSpec(Qt::UTC);
	//dateTime.setTime_t( this->dateTime().toTime_t() );
	dateTime.setMSecsSinceEpoch( this->msecSinceEpoch() );

	QAndroidJniObject initDateISO8601 = QAndroidJniObject::fromString( dateTime.toString(Qt::ISODate) );
	qDebug() << "QT--initDateISO8601=" << initDateISO8601.toString();
	qDebug() << "QT--ts=" << dateTime.toTime_t();

	QAndroidJniObject timezoneId = QAndroidJniObject::fromString( this->timeZoneId() );
	qDebug() << "QT--timezoneId=" << timezoneId.toString();

	jlong qmlDateTimePickerPtr = (jlong)this;

	QAndroidJniObject jsonStr =
			QAndroidJniObject::callStaticObjectMethod(
				"wpp/android/DatePickerDialog", "show",
				"(Landroid/app/Activity;Ljava/lang/String;Ljava/lang/String;J)Ljava/lang/String;",
				activity.object<jobject>(),
				initDateISO8601.object<jstring>(),
				timezoneId.object<jstring>(),
				qmlDateTimePickerPtr
				);
	/*QAndroidJniObject jsonStr = activity.callObjectMethod(
		"showDatePickerDialog", "()Ljava/lang/String;"
	);*/
			/*QAndroidJniObject::callStaticObjectMethod(
				"com/kuulabu/android/app/MainActivity", "showDatePickerDialog",
				"()Ljava/lang/String;",
				activity.object<jobject>());*/
	qDebug() << "jsonStr.isValid()=" << jsonStr.isValid() << ",jsonStr=" << jsonStr.toString();

	//QAndroidJniObject dialog( "wpp/android/DatePickerDialog", "(Landroid/content/Context;)V", activity.object<jobject>() );
	//qDebug() << "dialog.isValid()=" << dialog.isValid();

	//dialog.callMethod<void>("show","()V");
	//qDebug() << "dialog show ends...";

	QAndroidJniEnvironment env;
	if (env->ExceptionCheck())
	{
		// Handle exception here.
		qDebug() << "Exception 1....";
		env->ExceptionDescribe();
		env->ExceptionClear();
	}

	/*QAndroidJniObject::callStaticObjectMethod(
				"wpp/android/DatePickerDialog", "show",
				"(Landroid/content/Context;)V",
				activity.object<jobject>()
	);*/


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
void NativeDateTimePicker::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data)
{

}

#endif

void NativeDateTimePicker::onTimeZoneIdChanged()
{
	qDebug() << __FUNCTION__ ;
}

}
}
