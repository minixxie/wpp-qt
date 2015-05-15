#include "Gallery.h"

#include "GalleryFolder.h"
#include "GalleryPhoto.h"

#ifdef Q_OS_ANDROID
    #include <QAndroidJniObject>
    #include <QAndroidJniEnvironment>
#include <QtAndroid>
#include <QAndroidActivityResultReceiver>

#endif
#include <QDebug>
#include <QtConcurrent>

namespace wpp
{
namespace qt
{


Gallery::Gallery()
	:
	  futureWatcher(0),
	  future(0),
	  asyncLoadSlotReceiver(0), asyncLoadSlotMethod(),
	  loadExternalAlbumFinishedReceiver(0), loadExternalAlbumFinishedMethod(),
	  loadExternalCameraFinishedReceiver(0), loadExternalCameraFinishedMethod()
{
}

Gallery::~Gallery()
{
	delete futureWatcher;
	delete future;
}


int Gallery::getTotalSelectedPhotoCount() const
{
	int count = 0;
	QList<QObject *> folderList = folders.value< QList<QObject *> >();
	for ( QObject *obj : folderList )
	{
		GalleryFolder *f = dynamic_cast<GalleryFolder *>( obj );
		count += f->getSelectedPhotoCount();
	}
	return count;
}

QList<QObject *> Gallery::getTotalSelectedPhoto() const
{
	QList<QObject *> selectedPhotos;

	QList<QObject *> folderList = folders.value< QList<QObject *> >();
	for ( QObject *obj : folderList )
	{
		GalleryFolder *f = dynamic_cast<GalleryFolder *>( obj );
		QList<QObject *> photoList = f->getPhotos().value< QList<QObject *> >();
		for ( QObject *photoObj : photoList )
		{
			GalleryPhoto *p = dynamic_cast<GalleryPhoto *>( photoObj );
			if ( p->getIsSelected() )
			{
				selectedPhotos.push_back( new GalleryPhoto(*p) );
			}
		}
	}
	return selectedPhotos;
}

QList<QObject *> Gallery::fetchAll()
{

#ifdef Q_OS_ANDROID
	//ref(android): http://stackoverflow.com/questions/4195660/get-list-of-photo-galleries-on-android
	//ref(thumbnail): http://stackoverflow.com/questions/5013176/displaying-photo-thumbnails-on-map
	/*
		// which image properties are we querying
			String[] projection = new String[]{
					MediaStore.Images.Media._ID,
					MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
					MediaStore.Images.Media.DATE_TAKEN
			};
	 */
	QAndroidJniObject MediaStore_Images_Media__ID
			= QAndroidJniObject::getStaticObjectField(
			"android/provider/BaseColumns", "_ID", "Ljava/lang/String;");
	qDebug() << "MediaStore_Images_Media__ID.isValid()=" << MediaStore_Images_Media__ID.isValid();

	QAndroidJniObject MediaStore_Images_Media_BUCKET_ID
			= QAndroidJniObject::getStaticObjectField(
			"android/provider/MediaStore$Images$ImageColumns", "BUCKET_ID", "Ljava/lang/String;");
	qDebug() << "MediaStore_Images_Media_BUCKET_ID.isValid()=" << MediaStore_Images_Media_BUCKET_ID.isValid();

	QAndroidJniObject MediaStore_Images_Media_BUCKET_DISPLAY_NAME
			= QAndroidJniObject::getStaticObjectField(
			"android/provider/MediaStore$Images$ImageColumns", "BUCKET_DISPLAY_NAME", "Ljava/lang/String;");
	qDebug() << "MediaStore_Images_Media_BUCKET_DISPLAY_NAME.isValid()=" << MediaStore_Images_Media_BUCKET_DISPLAY_NAME.isValid();

	QAndroidJniObject MediaStore_Images_Media_DATE_TAKEN
			= QAndroidJniObject::getStaticObjectField(
			"android/provider/MediaStore$Images$ImageColumns", "DATE_TAKEN", "Ljava/lang/String;");
	qDebug() << "MediaStore_Images_Media_DATE_TAKEN.isValid()=" << MediaStore_Images_Media_DATE_TAKEN.isValid();

	QAndroidJniObject MediaStore_MediaColumns_DATA
			= QAndroidJniObject::getStaticObjectField(
			"android/provider/MediaStore$MediaColumns", "DATA", "Ljava/lang/String;");
	qDebug() << "MediaStore_MediaColumns_DATA.isValid()=" << MediaStore_MediaColumns_DATA.isValid();

	QAndroidJniObject MediaStore_MediaColumns_WIDTH
			= QAndroidJniObject::getStaticObjectField(
			"android/provider/MediaStore$MediaColumns", "WIDTH", "Ljava/lang/String;");
	qDebug() << "MediaStore_MediaColumns_WIDTH.isValid()=" << MediaStore_MediaColumns_WIDTH.isValid();

	QAndroidJniObject MediaStore_MediaColumns_HEIGHT
			= QAndroidJniObject::getStaticObjectField(
			"android/provider/MediaStore$MediaColumns", "HEIGHT", "Ljava/lang/String;");
	qDebug() << "MediaStore_MediaColumns_HEIGHT.isValid()=" << MediaStore_MediaColumns_HEIGHT.isValid();

	QAndroidJniObject MediaStore_Images_ImageColumns_MINI_THUMB_MAGIC
			= QAndroidJniObject::getStaticObjectField(
			"android/provider/MediaStore$Images$ImageColumns", "MINI_THUMB_MAGIC", "Ljava/lang/String;");
	qDebug() << "MediaStore_Images_ImageColumns_MINI_THUMB_MAGIC.isValid()=" << MediaStore_Images_ImageColumns_MINI_THUMB_MAGIC.isValid();

	jint MediaStore_Images_Thumbnails_MICRO_KIND = QAndroidJniObject::getStaticField<jint>(
				"android/provider/MediaStore$Images$Thumbnails", "MICRO_KIND");
	qDebug() << "MediaStore_Images_Thumbnails_MICRO_KIND=" << MediaStore_Images_Thumbnails_MICRO_KIND;

	QAndroidJniObject MediaStore_Images_Thumbnails_IMAGE_ID
			= QAndroidJniObject::getStaticObjectField(
			"android/provider/MediaStore$Images$Thumbnails", "IMAGE_ID", "Ljava/lang/String;");
	qDebug() << "MediaStore_Images_Thumbnails_IMAGE_ID.isValid()=" << MediaStore_Images_Thumbnails_IMAGE_ID.isValid();

	QAndroidJniObject MediaStore_Images_ImageColumns_ORIENTATION
			= QAndroidJniObject::getStaticObjectField(
			"android/provider/MediaStore$Images$ImageColumns", "ORIENTATION", "Ljava/lang/String;");
	qDebug() << "MediaStore_Images_ImageColumns_ORIENTATION.isValid()=" << MediaStore_Images_ImageColumns_ORIENTATION.isValid();


	QAndroidJniEnvironment env;
	jstring emptyJString = env->NewStringUTF("");

	jobjectArray projection = (jobjectArray)env->NewObjectArray(
		9,
		env->FindClass("java/lang/String"),
		emptyJString
	);
	jobject projection0 = env->NewStringUTF( MediaStore_Images_Media__ID.toString().toStdString().c_str() );
	env->SetObjectArrayElement(
		projection, 0, projection0 );
	jobject projection1 = env->NewStringUTF( MediaStore_Images_Media_BUCKET_ID.toString().toStdString().c_str() );
	env->SetObjectArrayElement(
		projection, 1, projection1 );
	jobject projection2 = env->NewStringUTF( MediaStore_Images_Media_BUCKET_DISPLAY_NAME.toString().toStdString().c_str() );
	env->SetObjectArrayElement(
		projection, 2, projection2 );
	jobject projection3 = env->NewStringUTF( MediaStore_Images_Media_DATE_TAKEN.toString().toStdString().c_str() );
	env->SetObjectArrayElement(
		projection, 3, projection3 );
	jobject projection4 = env->NewStringUTF( MediaStore_MediaColumns_DATA.toString().toStdString().c_str() );
	env->SetObjectArrayElement(
		projection, 4, projection4 );
	jobject projection5 = env->NewStringUTF( MediaStore_MediaColumns_WIDTH.toString().toStdString().c_str() );
	env->SetObjectArrayElement(
		projection, 5, projection5 );
	jobject projection6 = env->NewStringUTF( MediaStore_MediaColumns_HEIGHT.toString().toStdString().c_str() );
	env->SetObjectArrayElement(
		projection, 6, projection6 );
	jobject projection7 = env->NewStringUTF( MediaStore_Images_ImageColumns_MINI_THUMB_MAGIC.toString().toStdString().c_str() );
	env->SetObjectArrayElement(
		projection, 7, projection7 );
	jobject projection8 = env->NewStringUTF( MediaStore_Images_ImageColumns_ORIENTATION.toString().toStdString().c_str() );
	env->SetObjectArrayElement(
		projection, 8, projection8 );


	/*
	// Get the base URI for the People table in the Contacts content provider.
	Uri Images_EXTERNAL_CONTENT_URI = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
	 */
	QAndroidJniObject Images_EXTERNAL_CONTENT_URI
			= QAndroidJniObject::getStaticObjectField(
			"android/provider/MediaStore$Images$Media", "EXTERNAL_CONTENT_URI", "Landroid/net/Uri;");
	qDebug() << "Images_EXTERNAL_CONTENT_URI.isValid()=" << Images_EXTERNAL_CONTENT_URI.isValid();

	/*
	// Make the query.
		Cursor cur = managedQuery(Images_EXTERNAL_CONTENT_URI,
				projection, // Which columns to return
				"",         // Which rows to return (all rows)
				null,       // Selection arguments (none)
				""          // Ordering
				);
	*/
	QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");
	qDebug() << "activity.isValid()=" << activity.isValid();

	QAndroidJniObject contentResolver = activity.callObjectMethod("getContentResolver","()Landroid/content/ContentResolver;");

	QAndroidJniObject emptyString=QAndroidJniObject::fromString(QString("")); //path is valid
	qDebug() << "emptyString.isValid()=" << emptyString.isValid();
	QAndroidJniObject nullObj;

	QAndroidJniObject cur = activity.callObjectMethod("managedQuery",
							"(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;",
							Images_EXTERNAL_CONTENT_URI.object<jobject>(), projection,
							emptyString.object<jstring>(), nullObj.object<jobject>(), emptyString.object<jstring>()
							);
	qDebug() << "cur.isValid()=" << cur.isValid();
	if (env->ExceptionCheck())
	{
		// Handle exception here.
		qDebug() << "Exception when getting \"cur\"....";
		env->ExceptionDescribe();
		env->ExceptionClear();
	}

	QMap<QString, wpp::qt::GalleryFolder> folderList;

	//if (cur.moveToFirst()) {
	if ( cur.callMethod<jboolean>("moveToFirst") )
	{
		/*
		int bucketColumn = cur.getColumnIndex(
			MediaStore.Images.Media.BUCKET_DISPLAY_NAME);
		*/
		jint bucketColumn = cur.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", MediaStore_Images_Media_BUCKET_DISPLAY_NAME.object<jstring>());
		qDebug() << "bucketColumn = " << bucketColumn;
		/*
		 int dateColumn = cur.getColumnIndex(
			MediaStore.Images.Media.DATE_TAKEN);
		*/
		jint dateColumn = cur.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", MediaStore_Images_Media_DATE_TAKEN.object<jstring>());
		qDebug() << "dateColumn = " << dateColumn;


		jint idColumn = cur.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", MediaStore_Images_Media__ID.object<jstring>());
		qDebug() << "idColumn = " << idColumn;

		jint bucketIdColumn = cur.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", MediaStore_Images_Media_BUCKET_ID.object<jstring>());
		qDebug() << "bucketIdColumn = " << bucketIdColumn;

		jint mediaColumnsDataColumn = cur.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", MediaStore_MediaColumns_DATA.object<jstring>());
		qDebug() << "mediaColumnsDataColumn = " << mediaColumnsDataColumn;

		jint widthColumn = cur.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", MediaStore_MediaColumns_WIDTH.object<jstring>());
		qDebug() << "widthColumn = " << widthColumn;

		jint heightColumn = cur.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", MediaStore_MediaColumns_HEIGHT.object<jstring>());
		qDebug() << "heightColumn = " << heightColumn;

		jint thumbIdColumn = cur.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", MediaStore_Images_ImageColumns_MINI_THUMB_MAGIC.object<jstring>());
		qDebug() << "thumbIdColumn = " << thumbIdColumn;

		//jint imageIdColumn = cur.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", MediaStore_Images_Media__ID.object<jstring>());
		//qDebug() << "imageIdColumn = " << imageIdColumn;

		jint orientationColumn = cur.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", MediaStore_Images_ImageColumns_ORIENTATION.object<jstring>());
		qDebug() << "orientationColumn = " << orientationColumn;

		do
		{
			//QAndroidJniObject _id = cur.callObjectMethod("getString","(I)Ljava/lang/String;", idColumn );
			//qDebug() << "_id.isValid()=" << _id.isValid();
			jlong _id = cur.callMethod<jlong>("getLong","(I)J", idColumn );
			qDebug() << "_id=" << _id;

			QAndroidJniObject bucketId = cur.callObjectMethod("getString","(I)Ljava/lang/String;", bucketIdColumn );
			qDebug() << "bucketId.isValid()=" << bucketId.isValid();

			QAndroidJniObject bucket = cur.callObjectMethod("getString","(I)Ljava/lang/String;", bucketColumn );
			qDebug() << "bucket.isValid()=" << bucket.isValid();

			QAndroidJniObject date = cur.callObjectMethod("getString","(I)Ljava/lang/String;", dateColumn );
			qDebug() << "date.isValid()=" << date.isValid();

			QAndroidJniObject mediaColumnsData = cur.callObjectMethod("getString","(I)Ljava/lang/String;", mediaColumnsDataColumn );
			qDebug() << "mediaColumnsData.isValid()=" << mediaColumnsData.isValid();

			QAndroidJniObject width = cur.callObjectMethod("getString","(I)Ljava/lang/String;", widthColumn );
			qDebug() << "width.isValid()=" << width.isValid();

			QAndroidJniObject height = cur.callObjectMethod("getString","(I)Ljava/lang/String;", heightColumn );
			qDebug() << "height.isValid()=" << height.isValid();

			QAndroidJniObject thumbId = cur.callObjectMethod("getString","(I)Ljava/lang/String;", thumbIdColumn );
			qDebug() << "thumbId.isValid()=" << thumbId.isValid();

			//jlong thumbId = cur.callMethod<jlong>("getLong", "(I)J", thumbIdColumn);
			if (env->ExceptionCheck())
			{
				// Handle exception here.
				qDebug() << "Exception when getting \"thumbId\"....";
				env->ExceptionDescribe();
				env->ExceptionClear();
			}
			qDebug() << "thumbId=" << thumbId.toString();

			//QAndroidJniObject imageId = cur.callObjectMethod("getString","(I)Ljava/lang/String;", imageIdColumn );
			//qDebug() << "imageId.isValid()=" << imageId.isValid();



			// MediaStore.Images.Thumbnails.getThumbnail(getContentResolver(), imageID, MediaStore.Images.Thumbnails.MINI_KIND, null);
			/*QAndroidJniObject thumbnailBitmap = QAndroidJniObject::callStaticObjectMethod(
						"android/provider/MediaStore$Images$Thumbnails", "getThumbnail",
						"(Landroid/content/ContentResolver;JILandroid/graphics/BitmapFactory$Options;)Landroid/graphics/Bitmap;",
						contentResolver.object<jobject>(), _id,
						MediaStore_Images_Thumbnails_MICRO_KIND,
						nullObj.object<jobject>()
						);
			qDebug() << "thumbnailBitmap.isValid()=" << thumbnailBitmap.isValid();
			*/

			//QAndroidJniObject orientation = cur.callObjectMethod("getString","(I)Ljava/lang/String;", orientationColumn );
			//qDebug() << "orientation.isValid()=" << orientation.isValid();
			jint orientation = cur.callMethod<jint>("getInt","(I)I", orientationColumn );
			qDebug() << "orientation=" << orientation;



			QAndroidJniObject thumbData = QAndroidJniObject::fromString( QString("") );
			if ( false ) //if ( thumbId > 0 )
			{
				//        String[] args =  new String[]{String.valueOf(thumbId)};
				jobjectArray args = (jobjectArray)env->NewObjectArray(
					1,
					env->FindClass("java/lang/String"),
					emptyJString
				);
				jstring thumbIdJString = env->NewStringUTF( thumbId.toString().toStdString().c_str() );
				env->SetObjectArrayElement(
					//args, 0, env->NewStringUTF( QString().sprintf("%ld",thumbId).toStdString().c_str() ) );
					args, 0, thumbIdJString );

				//        Cursor curThumb = managedQuery(Thumbnails.EXTERNAL_CONTENT_URI, null, Thumbnails._ID + "= ?", args, null);
				QAndroidJniObject Images_Thumbnails__ID
						= QAndroidJniObject::getStaticObjectField(
						"android/provider/BaseColumns", "_ID", "Ljava/lang/String;");
				qDebug() << "Images_Thumbnails__ID.isValid()=" << Images_Thumbnails__ID.isValid();
				QAndroidJniObject selection=QAndroidJniObject::fromString( Images_Thumbnails__ID.toString() + "= ?" ); //path is valid

				QAndroidJniObject curThumb = activity.callObjectMethod("managedQuery",
										"(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;",
										Images_EXTERNAL_CONTENT_URI.object<jobject>(), nullObj.object<jobject>(),
										selection.object<jstring>(), args, nullObj.object<jobject>()
										);
				qDebug() << "curThumb.isValid()=" << curThumb.isValid();

				//if( curThumb.moveToFirst() ){
				if ( curThumb.callMethod<jboolean>("moveToFirst") )
				{
					//            String path = curThumb.getString(curThumb.getColumnIndex(Thumbnails.DATA));
					QAndroidJniObject Images_Thumbnails_DATA
							= QAndroidJniObject::getStaticObjectField(
							"android/provider/MediaStore$Images$Thumbnails", "DATA", "Ljava/lang/String;");
					qDebug() << "Images_Thumbnails_DATA.isValid()=" << Images_Thumbnails_DATA.isValid();

					jint thumbDataColumn = curThumb.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", Images_Thumbnails_DATA.object<jstring>());
					qDebug() << "thumbDataColumn = " << thumbDataColumn;

					thumbData = cur.callObjectMethod("getString","(I)Ljava/lang/String;", thumbDataColumn );
					qDebug() << "thumbData.isValid()=" << thumbData.isValid();

				}
				env->DeleteLocalRef(args);
				env->DeleteLocalRef(thumbIdJString);
			}

			qDebug() << "_id=" << _id
					 << ", bucketId=" << bucketId.toString()
					 << ", bucket=" << bucket.toString()
					 << ", date_taken=" << date.toString()
					 << ", WxH=" << width.toString() << "x" << height.toString()
					 << ", orientation=" << orientation
					 << ", thumbId=" << thumbId.toString()
					 << ", thumbData=" << thumbData.toString()
					 << ", abs_path=" << mediaColumnsData.toString();

			if ( !folderList.contains( bucketId.toString() ) )
			{
				qDebug() << "create folder:" << bucketId.toString();
				GalleryFolder galleryFolder;
				galleryFolder.setId( bucketId.toString() );
				galleryFolder.setName( bucket.toString() );
				folderList.insert(bucketId.toString(), galleryFolder);
			}

			wpp::qt::GalleryPhoto photo;
			photo.setAbsolutePath( mediaColumnsData.toString() );
			photo.setWidth( width.toString().toInt() );
			photo.setHeight( height.toString().toInt() );
			photo.setOrientation( orientation );
			qDebug()<<"orientation===" << photo.getOrientation();
			folderList[ bucketId.toString() ].addPhoto( photo );
		}
		while ( cur.callMethod<jboolean>("moveToNext") );
		//while (cur.moveToNext());
	}

	env->DeleteLocalRef(emptyJString);
	env->DeleteLocalRef(projection);
	env->DeleteLocalRef(projection0);
	env->DeleteLocalRef(projection1);
	env->DeleteLocalRef(projection2);
	env->DeleteLocalRef(projection3);
	env->DeleteLocalRef(projection4);
	env->DeleteLocalRef(projection5);
	env->DeleteLocalRef(projection6);
	env->DeleteLocalRef(projection7);
	env->DeleteLocalRef(projection8);

	//change QMap to QList
	QList<QObject *> finalFolderList;
	for ( wpp::qt::GalleryFolder folder : folderList )
	{
		finalFolderList.push_back( new wpp::qt::GalleryFolder( folder ) );
	}
	this->setFolders( QVariant::fromValue( finalFolderList ) );

	for ( const QObject *obj : finalFolderList )
	{
		const wpp::qt::GalleryFolder *f = dynamic_cast< const wpp::qt::GalleryFolder * >( obj );
		qDebug() << "FOLDER" << f->getPhotos().value< QList<QObject*> >().size() << ":" << f->getName();
	}

	return finalFolderList;

#else
	return QList<QObject *>();
#endif
}

extern QList<QObject*> asyncLoadGallery(Gallery *gallery, QThread *uiThread)
{
	qDebug() << __FUNCTION__;
	QList<QObject*> folders = gallery->fetchAll();
	qDebug() << __FUNCTION__ << ":return folders-size:" << folders.size();
	for ( QObject *obj : folders )
	{
		wpp::qt::GalleryFolder *folder = dynamic_cast<wpp::qt::GalleryFolder *>(obj);
		folder->moveToThread(uiThread);

		QList<QObject*> photos = folder->getPhotos().value< QList<QObject*> >();
		for ( QObject *photo : photos )
			photo->moveToThread(uiThread);
	}
	return folders;
}

void Gallery::asyncFetchAll()
{
	futureWatcher = new QFutureWatcher< QList<QObject*> >;
	//connect(futureWatcher, SIGNAL(finished()), this, SLOT(onBridgeAsyncFetchAll()));

	future = new QFuture< QList<QObject*> >;
	*future = QtConcurrent::run(asyncLoadGallery, this, QThread::currentThread());
	futureWatcher->setFuture(*future);
}
void Gallery::asyncFetchAll(const QObject * receiver, const char * method)
{
	connect(this, SIGNAL(finishedAsyncFetchAll(QList<QObject*>)), receiver, method );
	asyncLoadSlotReceiver = receiver;
	asyncLoadSlotMethod = method;

	futureWatcher = new QFutureWatcher< QList<QObject*> >;
	connect(futureWatcher, SIGNAL(finished()), this, SLOT(onBridgeAsyncFetchAll()));

	future = new QFuture< QList<QObject*> >;
	*future = QtConcurrent::run(asyncLoadGallery, this, QThread::currentThread());
	futureWatcher->setFuture(*future);
}
void Gallery::onBridgeAsyncFetchAll()
{
	qDebug() << __FUNCTION__;
	QList<QObject*> folders = future->result();
	qDebug() << __FUNCTION__ << ":folders-size:" << folders.size();
	emit this->finishedAsyncFetchAll(folders);

	delete future;
	future = 0;
	delete futureWatcher;
	futureWatcher = 0;

	disconnect(this, SIGNAL(finishedAsyncFetchAll(QList<QObject*>)), asyncLoadSlotReceiver, asyncLoadSlotMethod.toStdString().c_str() );
	asyncLoadSlotReceiver = 0;
	asyncLoadSlotMethod.clear();
}

void Gallery::loadExternalAlbumBrowser(const QObject * receiver, const char * method)
{
	loadExternalAlbumFinishedReceiver = receiver;
	loadExternalAlbumFinishedMethod = method;
#if defined(Q_OS_ANDROID)

/*
 *                     Intent intent = new Intent();

					intent.setType("image/*");
					intent.setAction(Intent.ACTION_GET_CONTENT);

					startActivityForResult(Intent.createChooser(intent,
							"请选择"), PICK_FROM_FILE);
 */

	QAndroidJniObject Intent__ACTION_GET_CONTENT = QAndroidJniObject::getStaticObjectField(
				"android/content/Intent", "ACTION_GET_CONTENT", "Ljava/lang/String;");
	qDebug() << __FUNCTION__ << "Intent__ACTION_GET_CONTENT.isValid()=" << Intent__ACTION_GET_CONTENT.isValid();

	QAndroidJniObject activity = QtAndroid::androidActivity();
	qDebug() << __FUNCTION__ << "activity.isValid()=" << activity.isValid();

	QAndroidJniObject intent=QAndroidJniObject("android/content/Intent","()V");
	qDebug() << __FUNCTION__ << "intent.isValid()=" << intent.isValid();

	QAndroidJniObject imageTypeStr = QAndroidJniObject::fromString(QString("image/*"));
	qDebug() << __FUNCTION__ << "imageTypeStr.isValid()=" << imageTypeStr.isValid();

	intent.callObjectMethod("setType","(Ljava/lang/String;)Landroid/content/Intent;",
							imageTypeStr.object<jobject>());

	intent.callObjectMethod("setAction","(Ljava/lang/String;)Landroid/content/Intent;",
							Intent__ACTION_GET_CONTENT.object<jobject>());

	QAndroidJniObject chooseText = QAndroidJniObject::fromString(QString("Please pick on photo"));
	qDebug() << __FUNCTION__ << "chooseText.isValid()=" << chooseText.isValid();

	QAndroidJniObject chooserIntent = QAndroidJniObject::callStaticObjectMethod(
				"android/content/Intent", "createChooser", "(Landroid/content/Intent;Ljava/lang/CharSequence;)Landroid/content/Intent;",
				intent.object<jobject>(), chooseText.object<jobject>());
	qDebug() << __FUNCTION__ << "chooserIntent.isValid()=" << chooserIntent.isValid();

	int PICK_FROM_FILE = 1;
	QtAndroid::startActivity(chooserIntent, PICK_FROM_FILE, this);

#endif
}

void Gallery::loadExternalCameraApp(const QObject * receiver, const char * method)
{
	loadExternalCameraFinishedReceiver = receiver;
	loadExternalCameraFinishedMethod = method;
#if defined(Q_OS_ANDROID)
/*
		String SDState = Environment.getExternalStorageState();
		if(SDState.equals(Environment.MEDIA_MOUNTED))
		{
			Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);//"android.media.action.IMAGE_CAPTURE"
			 //需要说明一下，以下操作使用照相机拍照，拍照后的图片会存放在相册中的
			 //这里使用的这种方式有一个好处就是获取的图片是拍照后的原图
			 //如果不实用ContentValues存放照片路径的话，拍照后获取的图片为缩略图不清晰
			ContentValues values = new ContentValues();
			photoUri = this.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
			intent.putExtra(android.provider.MediaStore.EXTRA_OUTPUT, photoUri);
			startActivityForResult(intent, SELECT_PIC_BY_TACK_PHOTO);
		}else{
			Toast.makeText(this,"内存卡不存在", Toast.LENGTH_LONG).show();
		}
 */

	/*
	//String SDState = Environment.getExternalStorageState();
	QAndroidJniObject SDState = QAndroidJniObject::callStaticObjectMethod(
				"android/os/Environment", "getExternalStorageState", "()Ljava/lang/String;");
	qDebug() << "SDState.isValid()=" << SDState.isValid();
	//Environment.MEDIA_MOUNTED
	QAndroidJniObject Environment__MEDIA_MOUNTED
			= QAndroidJniObject::getStaticObjectField(
				"android/os/Environment", "MEDIA_MOUNTED", "Ljava/lang/String;");
	qDebug() << "Environment__MEDIA_MOUNTED.isValid()=" << Environment__MEDIA_MOUNTED.isValid();
	//MediaStore.ACTION_IMAGE_CAPTURE
	QAndroidJniObject MediaStore__ACTION_IMAGE_CAPTURE
			= QAndroidJniObject::getStaticObjectField(
				"android/provider/MediaStore", "ACTION_IMAGE_CAPTURE", "Ljava/lang/String;");
	qDebug() << "MediaStore__ACTION_IMAGE_CAPTURE.isValid()=" << MediaStore__ACTION_IMAGE_CAPTURE.isValid();
	//MediaStore.Images.Media.EXTERNAL_CONTENT_URI
	QAndroidJniObject MediaStore__Images__Media__EXTERNAL_CONTENT_URI
			= QAndroidJniObject::getStaticObjectField(
				"android/provider/MediaStore$Images$Media", "EXTERNAL_CONTENT_URI", "Landroid/net/Uri;");
	qDebug() << "MediaStore__Images__Media__EXTERNAL_CONTENT_URI.isValid()=" << MediaStore__Images__Media__EXTERNAL_CONTENT_URI.isValid();
	//android.provider.MediaStore.EXTRA_OUTPUT
	QAndroidJniObject MediaStore__EXTRA_OUTPUT
			= QAndroidJniObject::getStaticObjectField(
				"android/provider/MediaStore", "EXTRA_OUTPUT", "Ljava/lang/String;");
	qDebug() << "MediaStore__EXTRA_OUTPUT.isValid()=" << MediaStore__EXTRA_OUTPUT.isValid();

	//if ( SDState.callMethod<jboolean>("equals", "(Ljava/lang/String;)B", Environment__MEDIA_MOUNTED.object<jstring>()) )
	if ( true )
	{
//			Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);//"android.media.action.IMAGE_CAPTURE"
		QAndroidJniObject intent=QAndroidJniObject("android/content/Intent","(Ljava/lang/String;)V",
												   MediaStore__ACTION_IMAGE_CAPTURE.object<jstring>());
		qDebug() << __FUNCTION__ << "intent.isValid()=" << intent.isValid();

		//ContentValues values = new ContentValues();
		QAndroidJniObject contentValues=QAndroidJniObject("android/content/ContentValues","()V");
		qDebug() << __FUNCTION__ << "contentValues.isValid()=" << contentValues.isValid();

		//photoUri = this.getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
		QAndroidJniObject activity = QtAndroid::androidActivity();
		qDebug() << __FUNCTION__ << "activity.isValid()=" << activity.isValid();

		QAndroidJniObject contentResolver = activity.callObjectMethod("getContentResolver","()Landroid/content/ContentResolver;");
		qDebug() << __FUNCTION__ << "contentResolver.isValid()=" << contentResolver.isValid();

		QAndroidJniObject photoUri = contentResolver.callObjectMethod(
					"insert","(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;",
					MediaStore__Images__Media__EXTERNAL_CONTENT_URI.object<jstring>(), contentValues.object<jobject>());
		qDebug() << __FUNCTION__ << "photoUri.isValid()=" << photoUri.isValid();

		//intent.putExtra(android.provider.MediaStore.EXTRA_OUTPUT, photoUri);
		intent.callObjectMethod(
					"putExtra","(Ljava/lang/String;Landroid/os/Parcelable;)Landroid/content/Intent;",
					MediaStore__EXTRA_OUTPUT.object<jstring>(), photoUri.object<jobject>());
		qDebug() << __FUNCTION__ << "intent.isValid()=" << intent.isValid();

		//startActivityForResult(intent, SELECT_PIC_BY_TACK_PHOTO);
		int SHOOT_PHOTO = 2;
		QtAndroid::startActivity(intent, SHOOT_PHOTO, this);
	}
	else
	{
		qDebug() << "SD card not exists!";
	}
*/

/* //http://stackoverflow.com/questions/2729267/android-camera-intent
	Intent intent = new Intent("android.media.action.IMAGE_CAPTURE");
	File photo = new File(Environment.getExternalStorageDirectory(),  "Pic.jpg");
	intent.putExtra(MediaStore.EXTRA_OUTPUT,
			Uri.fromFile(photo));
	imageUri = Uri.fromFile(photo);
	startActivityForResult(intent, TAKE_PICTURE);

 */
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

	int SHOOT_PHOTO = 2;
	QtAndroid::startActivity(intent, SHOOT_PHOTO, this);

#endif

}

#ifdef Q_OS_ANDROID
void Gallery::handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data)
{
	int PICK_FROM_FILE = 1;
	int SHOOT_PHOTO = 2;
	jint Activity__RESULT_OK = QAndroidJniObject::getStaticField<jint>(
				"android.app.Activity", "RESULT_OK");

	if ( receiverRequestCode == PICK_FROM_FILE && resultCode == Activity__RESULT_OK )
	{
		QAndroidJniEnvironment env;
		QAndroidJniObject uri = data.callObjectMethod("getData","()Landroid/net/Uri;");
		qDebug() << __FUNCTION__ << "uri.isValid()=" << uri.isValid();
		qDebug() << __FUNCTION__ << "uri=" << uri.toString();
		/*
		  url is like: "content://media/external/images/media/87332"
		 */
		QAndroidJniObject activity = QtAndroid::androidActivity();
		qDebug() << __FUNCTION__ << "activity.isValid()=" << activity.isValid();

		QAndroidJniObject contentResolver = activity.callObjectMethod("getContentResolver","()Landroid/content/ContentResolver;");
		qDebug() << __FUNCTION__ << "contentResolver.isValid()=" << contentResolver.isValid();

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

		//cursor.close();
		cursor.callMethod<jboolean>("close");


		env->DeleteLocalRef(emptyJString);
		env->DeleteLocalRef(projection);
		env->DeleteLocalRef(projection0);
/*
		QAndroidJniObject inputStream = contentResolver.callObjectMethod(
					"openInputStream","(Landroid/net/Uri;)Ljava/io/InputStream;", uri.object<jobject>());
		qDebug() << __FUNCTION__ << "inputStream.isValid()=" << inputStream.isValid();

		QStringList paths = QStandardPaths::standardLocations(QStandardPaths::DataLocation);
		QDir dir( paths.first() );
		QDir parentDir( dir.filePath("..") );
		qDebug() << "parent path: " << parentDir.absolutePath();
		if ( !dir.exists() )
		{
			qDebug() << "dir not exist, make it:" << dir;
			qDebug() << "dir.name: " << dir.dirName();
			qDebug() << "new make dir returns: " << parentDir.mkpath( dir.dirName() );
			//qDebug() << "make dir returns: " << dir.mkdir(".");
		}
		QString pickFile = paths.first().append("/").append("PickFile");

		QAndroidJniEnvironment env;
		jbyteArray byteArray = env->NewByteArray(1024);

		jint fileSize = inputStream.callMethod<jint>(
					"available","()I");
		qDebug() << "fileSize=" << fileSize;

		QFile file( pickFile );
		file.open(QIODevice::WriteOnly);
		jint bytesRead = 0;
		do
		{
			bytesRead = inputStream.callMethod<jint>(
						"read","([B)I", byteArray);
			qDebug() << "bytes read:" << bytesRead;
			if ( bytesRead > 0 )
			{
				jboolean isCopy;
				jbyte* a = env->GetByteArrayElements(byteArray,&isCopy);
				file.write((char *)a, bytesRead);
				env->ReleaseByteArrayElements(byteArray, a, 0);
			}
		}
		while ( bytesRead > 0 );
		file.close();

		qDebug() << "output file size:" << file.size();
*/

		//env->Delete

		//QAndroidJniObject absPath = uri.callObjectMethod("getPath","()Ljava/lang/String;");
		//qDebug() << __FUNCTION__ << "absPath.isValid()=" << absPath.isValid();
		//qDebug() << __FUNCTION__ << "absPath=" << absPath.toString();

		connect(this, SIGNAL(finishedPickPhoto(const QString&)), loadExternalAlbumFinishedReceiver, loadExternalAlbumFinishedMethod.toStdString().c_str());
		emit this->finishedPickPhoto(filePath);
		disconnect(this, SIGNAL(finishedPickPhoto(const QString&)), loadExternalAlbumFinishedReceiver, loadExternalAlbumFinishedMethod.toStdString().c_str());
	}
	else if ( receiverRequestCode == SHOOT_PHOTO && resultCode == Activity__RESULT_OK )
	{
		/*
		qDebug() << __FUNCTION__ << "data.isValid()=" << data.isValid();

		//picPath = data.getStringExtra(SelectPicActivity.KEY_PHOTO_PATH);
		QAndroidJniObject picPath = data.callObjectMethod(
					"getStringExtra","(Ljava/lang/String;)Ljava/lang/String;");
		qDebug() << __FUNCTION__ << "picPath.isValid()=" << picPath.isValid();
		qDebug() << __FUNCTION__ << "picPath=" << picPath.toString();

		connect(this, SIGNAL(finishedShootPhoto(const QString&)), loadExternalCameraFinishedReceiver, loadExternalCameraFinishedMethod.toStdString().c_str());
		emit this->finishedShootPhoto(picPath.toString());
		disconnect(this, SIGNAL(finishedShootPhoto(const QString&)), loadExternalCameraFinishedReceiver, loadExternalCameraFinishedMethod.toStdString().c_str());
		*/

		qDebug() << "takePhotoSavedUri:" << takePhotoSavedUri.toString();

		QAndroidJniObject absPath = takePhotoSavedUri.callObjectMethod("getPath","()Ljava/lang/String;");
		qDebug() << __FUNCTION__ << "absPath.isValid()=" << absPath.isValid();

		connect(this, SIGNAL(finishedShootPhoto(const QString&)), loadExternalCameraFinishedReceiver, loadExternalCameraFinishedMethod.toStdString().c_str());
		emit this->finishedShootPhoto(absPath.toString());
		disconnect(this, SIGNAL(finishedShootPhoto(const QString&)), loadExternalCameraFinishedReceiver, loadExternalCameraFinishedMethod.toStdString().c_str());
	}

}
#endif


}
}
