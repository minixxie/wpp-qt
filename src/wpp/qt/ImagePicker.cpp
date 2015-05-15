#include "ImagePicker.h"

#ifdef Q_OS_ANDROID
#include <QAndroidJniEnvironment>
#include <QAndroidJniObject>
#include <QtAndroid>
#endif

namespace wpp {
namespace qt {

#ifndef Q_OS_IOS
ImagePicker::ImagePicker(QQuickItem *parent)
	: QQuickItem(parent),
	  m_maxPick(-1),
	  m_delegate(0)
{
}

void ImagePicker::open()
{
#ifdef Q_OS_ANDROID

		/*
if (Build.VERSION.SDK_INT <19){
	Intent intent = new Intent();
	intent.setType("image/jpeg");
	intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);***
	intent.setAction(Intent.ACTION_GET_CONTENT);
	startActivityForResult(Intent.createChooser(intent, "Pick a photo"),PICK_FROM_FILE);
} else {
	Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
	intent.addCategory(Intent.CATEGORY_OPENABLE);
	intent.setType("image/jpeg");
	intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);***
	startActivityForResult(intent, PICK_FROM_FILE_KITKAT);
}
		*/

	QAndroidJniObject Intent__EXTRA_ALLOW_MULTIPLE = QAndroidJniObject::getStaticObjectField(
				"android/content/Intent", "EXTRA_ALLOW_MULTIPLE", "Ljava/lang/String;");
	qDebug() << __FUNCTION__ << "Intent__EXTRA_ALLOW_MULTIPLE.isValid()=" << Intent__EXTRA_ALLOW_MULTIPLE.isValid();

		jint Build__VERSION__SDK_INT = QAndroidJniObject::getStaticField<jint>(
					"android/os/Build$VERSION", "SDK_INT");
		qDebug() << "Build__VERSION__SDK_INT=" << Build__VERSION__SDK_INT;
		if ( Build__VERSION__SDK_INT < 19 )
		{
			QAndroidJniObject Intent__ACTION_GET_CONTENT = QAndroidJniObject::getStaticObjectField(
						"android/content/Intent", "ACTION_GET_CONTENT", "Ljava/lang/String;");
			qDebug() << __FUNCTION__ << "Intent__ACTION_GET_CONTENT.isValid()=" << Intent__ACTION_GET_CONTENT.isValid();

			//QAndroidJniObject activity = QtAndroid::androidActivity();
			//qDebug() << __FUNCTION__ << "activity.isValid()=" << activity.isValid();

			QAndroidJniObject intent=QAndroidJniObject("android/content/Intent","()V");
			qDebug() << __FUNCTION__ << "intent.isValid()=" << intent.isValid();

			QAndroidJniObject imageTypeStr = QAndroidJniObject::fromString(QString("image/*"));
			qDebug() << __FUNCTION__ << "imageTypeStr.isValid()=" << imageTypeStr.isValid();

			intent.callObjectMethod("setType","(Ljava/lang/String;)Landroid/content/Intent;",
									imageTypeStr.object<jobject>());

			if ( maxPick() != 1 )
			{
				intent.callObjectMethod("putExtra","(Ljava/lang/String;Z)Landroid/content/Intent;",
									Intent__EXTRA_ALLOW_MULTIPLE.object<jobject>(), true);
			}

			intent.callObjectMethod("setAction","(Ljava/lang/String;)Landroid/content/Intent;",
									Intent__ACTION_GET_CONTENT.object<jobject>());

			QAndroidJniObject chooseText = QAndroidJniObject::fromString(QString("Please pick on photo"));
			qDebug() << __FUNCTION__ << "chooseText.isValid()=" << chooseText.isValid();

			QAndroidJniObject chooserIntent = QAndroidJniObject::callStaticObjectMethod(
						"android/content/Intent", "createChooser", "(Landroid/content/Intent;Ljava/lang/CharSequence;)Landroid/content/Intent;",
						intent.object<jobject>(), chooseText.object<jobject>());
			qDebug() << __FUNCTION__ << "chooserIntent.isValid()=" << chooserIntent.isValid();

			int PICK_FROM_FILE = 2;
			QtAndroid::startActivity(chooserIntent, PICK_FROM_FILE, this);
		}
		else
		{
			QAndroidJniObject Intent__ACTION_PICK = QAndroidJniObject::getStaticObjectField(
						"android/content/Intent", "ACTION_PICK", "Ljava/lang/String;");
			qDebug() << __FUNCTION__ << "Intent__ACTION_PICK.isValid()=" << Intent__ACTION_PICK.isValid();
			
			QAndroidJniObject EXTERNAL_CONTENT_URI= QAndroidJniObject::getStaticObjectField(
						"android/provider/MediaStore$Images$Media", "EXTERNAL_CONTENT_URI", "Landroid/net/Uri;");
			qDebug() << __FUNCTION__ << "EXTERNAL_CONTENT_URI.isValid()=" << EXTERNAL_CONTENT_URI.isValid();

			QAndroidJniObject intent=QAndroidJniObject("android/content/Intent",
                "(Ljava/lang/String;Landroid/net/Uri;)V",
                Intent__ACTION_PICK.object<jstring>(),
                EXTERNAL_CONTENT_URI.object<jobject>()
            );
			qDebug() << __FUNCTION__ << "intent.isValid()=" << intent.isValid();

			if ( maxPick() != 1 )
			{
				intent.callObjectMethod("putExtra","(Ljava/lang/String;Z)Landroid/content/Intent;",
									Intent__EXTRA_ALLOW_MULTIPLE.object<jobject>(), true);
			}

			/*
			QAndroidJniObject Intent__CATEGORY_OPENABLE = QAndroidJniObject::getStaticObjectField(
						"android/content/Intent", "CATEGORY_OPENABLE", "Ljava/lang/String;");
			qDebug() << __FUNCTION__ << "Intent__CATEGORY_OPENABLE.isValid()=" << Intent__CATEGORY_OPENABLE.isValid();

			intent.callObjectMethod("addCategory","(Ljava/lang/String;)Landroid/content/Intent;",
									Intent__CATEGORY_OPENABLE.object<jstring>());

			QAndroidJniObject imageTypeStr = QAndroidJniObject::fromString(QString("image/*"));
			qDebug() << __FUNCTION__ << "imageTypeStr.isValid()=" << imageTypeStr.isValid();

			intent.callObjectMethod("setType","(Ljava/lang/String;)Landroid/content/Intent;",
									imageTypeStr.object<jobject>());
			*/

			int PICK_FROM_FILE_KITKAT = 3;
			QtAndroid::startActivity(intent, PICK_FROM_FILE_KITKAT, this);

		}
#endif
}
#endif

#ifdef Q_OS_ANDROID
void ImagePicker::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data)
{
	int PICK_FROM_FILE = 2;
	int PICK_FROM_FILE_KITKAT = 3;
	jint Activity__RESULT_OK = QAndroidJniObject::getStaticField<jint>(
				"android.app.Activity", "RESULT_OK");

	if ( ( receiverRequestCode == PICK_FROM_FILE || receiverRequestCode == PICK_FROM_FILE_KITKAT )
		 && resultCode == Activity__RESULT_OK )
	{
		QAndroidJniEnvironment env;
		QAndroidJniObject uri = data.callObjectMethod("getData","()Landroid/net/Uri;");
		qDebug() << __FUNCTION__ << "uri.isValid()=" << uri.isValid();
		qDebug() << __FUNCTION__ << "uri=" << uri.toString();
		/*
		  url is like: "content://media/external/images/media/87332"
		  for KitKat(android 4.4), uri is like: "content://com.android.providers.media.documents/document/image:3951"
		 */
		QAndroidJniObject activity = QtAndroid::androidActivity();
		qDebug() << __FUNCTION__ << "activity.isValid()=" << activity.isValid();

		QAndroidJniObject contentResolver = activity.callObjectMethod("getContentResolver","()Landroid/content/ContentResolver;");
		qDebug() << __FUNCTION__ << "contentResolver.isValid()=" << contentResolver.isValid();

		/*if ( receiverRequestCode == PICK_FROM_FILE_KITKAT )
		{
			jint Intent__FLAG_GRANT_READ_URI_PERMISSION = QAndroidJniObject::getStaticField<jint>(
						"android.content.Intent", "FLAG_GRANT_READ_URI_PERMISSION");
			jint Intent__FLAG_GRANT_WRITE_URI_PERMISSION = QAndroidJniObject::getStaticField<jint>(
						"android.content.Intent", "FLAG_GRANT_WRITE_URI_PERMISSION");
			jint takeFlags = data.callMethod<jint>("getFlags","()I");
			takeFlags = takeFlags & ( Intent__FLAG_GRANT_READ_URI_PERMISSION | Intent__FLAG_GRANT_WRITE_URI_PERMISSION );

			contentResolver.callMethod<void>("takePersistableUriPermission","(Landroid/net/Uri;I)V",
															  uri.object<jobject>(), takeFlags);
		}*/
/*
String [] proj={MediaStore.Images.Media.DATA};
	Cursor cursor = getContentResolver().query(uri, proj,  null, null, null);
	int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
	cursor.moveToFirst();
	String path = cursor.getString(column_index);
	cursor.close();
 */
		QAndroidJniObject MediaStore_Images_Media_DATA
				= QAndroidJniObject::getStaticObjectField(
					"android/provider/MediaStore$MediaColumns", "DATA", "Ljava/lang/String;");
					//"android/provider/MediaStore$Images$Media", "DATA", "Ljava/lang/String;");
		qDebug() << "MediaStore_Images_Media_DATA.isValid()=" << MediaStore_Images_Media_DATA.isValid();

		QAndroidJniObject nullObj;
		jstring emptyJString = env->NewStringUTF("");
		jobjectArray projection = (jobjectArray)env->NewObjectArray(
			1,
			env->FindClass("java/lang/String"),
			emptyJString
		);
		jobject projection0 = env->NewStringUTF( MediaStore_Images_Media_DATA.toString().toStdString().c_str() );
		env->SetObjectArrayElement(
			projection, 0, projection0 );

		//	Cursor cursor = getContentResolver().query(uri, proj,  null, null, null);
		QAndroidJniObject cursor = contentResolver.callObjectMethod("query",
			"(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;",
			uri.object<jobject>(), projection, nullObj.object<jstring>(), nullObj.object<jobjectArray>(), nullObj.object<jstring>());
		qDebug() << __FUNCTION__ << "cursor.isValid()=" << cursor.isValid();

		//int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
		jint column_index = cursor.callMethod<jint>(
					"getColumnIndexOrThrow","(Ljava/lang/String;)I", MediaStore_Images_Media_DATA.object<jstring>());
		qDebug() << "column_index=" << column_index;

		//cursor.moveToFirst();
		cursor.callMethod<jboolean>("moveToFirst");

		//	String path = cursor.getString(column_index);
		QAndroidJniObject path = cursor.callObjectMethod(
					"getString",
					"(I)Ljava/lang/String;", column_index );
		qDebug() << __FUNCTION__ << "path.isValid()=" << path.isValid();
		QString filePath = path.toString();
		qDebug() << "filePath=" << filePath;
		//cursor.close();
		cursor.callMethod<jboolean>("close");


		env->DeleteLocalRef(emptyJString);
		env->DeleteLocalRef(projection);
		env->DeleteLocalRef(projection0);

		QStringList paths;
		paths.append(filePath);
		emit this->accepted(paths);
		//m_imagePath = filePath;
		//emit this->imagePathChanged();
	}
}
#endif

}
}
