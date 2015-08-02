#include "SMS.h"

#ifdef Q_OS_ANDROID
#include <QAndroidJniEnvironment>
#include <QAndroidJniObject>
#include <QtAndroid>
#endif

namespace wpp {
namespace qt {

#ifndef Q_OS_IOS

SMS::SMS(QQuickItem *parent) :
	QQuickItem(parent)
{
}

void SMS::open()
{
#ifdef Q_OS_ANDROID
	/*
		//http://examples.javacodegeeks.com/android/core/telephony/smsmanager/android-sending-sms-example/
		// add the phone number in the data
		Uri uri = Uri.parse("smsto:" + phoneNumber.getText().toString());
		Intent smsSIntent = new Intent(Intent.ACTION_SENDTO, uri);
		// add the message at the sms_body extra field
		smsSIntent.putExtra("sms_body", smsBody.getText().toString());
		try{
			startActivity(smsSIntent);
		} catch (Exception ex) {
			Toast.makeText(MainActivity.this, "Your sms has failed...",
					Toast.LENGTH_LONG).show();
			ex.printStackTrace();
		}
	 */
	QString uriString("smsto:");
	uriString.append( phone() );
	QAndroidJniObject uri = QAndroidJniObject::fromString(uriString);

	QAndroidJniObject Intent__ACTION_SENDTO
			= QAndroidJniObject::getStaticObjectField(
				"android/content/Intent", "ACTION_SENDTO", "Ljava/lang/String;");
	qDebug() << "Intent__ACTION_SENDTO.isValid()=" << Intent__ACTION_SENDTO.isValid();

	QAndroidJniObject intent=QAndroidJniObject("android/content/Intent","(Ljava/lang/String;Landroid/net/Uri;)V",
											   Intent__ACTION_SENDTO.object<jstring>(), uri.object<jobject>());
	qDebug() << __FUNCTION__ << "intent.isValid()=" << intent.isValid();

	QAndroidJniObject extraName = QAndroidJniObject::fromString("sms_body");
	QAndroidJniObject msgObj = QAndroidJniObject::fromString( msg() );

	intent.callObjectMethod(
				"putExtra","(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;",
				extraName.object<jstring>(), msgObj.object<jstring>());
	qDebug() << __FUNCTION__ << "intent.isValid()=" << intent.isValid();

	//QtAndroid::startActivity(intent, 8003, this);

	QAndroidJniObject activity = QtAndroid::androidActivity();
	qDebug() << __FUNCTION__ << "activity.isValid()=" << activity.isValid();

	activity.callMethod<void>(
				"startActivity","(Landroid/content/Intent;)V", intent.object<jobject>());
	qDebug() << __FUNCTION__ << "activity.isValid()=" << activity.isValid();

#endif
}

#endif


#ifdef Q_OS_ANDROID
void SMS::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data)
{
	jint Activity__RESULT_OK = QAndroidJniObject::getStaticField<jint>(
				"android.app.Activity", "RESULT_OK");

	if ( receiverRequestCode == 8003 )
	{
		if ( resultCode == Activity__RESULT_OK )
		{
			emit this->sent();
		}
		else
		{
			emit this->failed();
		}
	}
}
#endif


}
}
