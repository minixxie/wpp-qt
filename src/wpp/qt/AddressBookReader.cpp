#include "AddressBookReader.h"
#include "ReadAddressBookPermissionDeniedException.h"
#include "AddressBookContact.h"
#include "AddressBookContactPhone.h"
#include "AddressBookContactEmail.h"
#include "../lang/Pinyin.h"

#include <QDebug>
#include <QString>
#ifdef Q_OS_ANDROID
	#include <QtAndroid>
    #include <QAndroidJniObject>
    #include <QAndroidJniEnvironment>
#endif

#include <QDesktopServices>
#include <QUrl>
#include <QtConcurrent>
#include <QtAlgorithms>
#include <QVector>



namespace wpp
{
namespace qt
{


AddressBookReader *AddressBookReader::singleton = 0;
AddressBookReader &AddressBookReader::getInstance()
{
    if ( singleton == 0 )
    {
        static AddressBookReader singletonInstance;
        singleton = &singletonInstance;
    }
    return *singleton;
}

bool AddressBookReader::isAvailable() const
{
#if defined(Q_OS_IOS)
    return true;
#elif defined(Q_OS_ANDROID)
    return true;
#else
#ifdef QT_DEBUG
    return true;
#else
    return false;
#endif
#endif
}


#if !defined(Q_OS_IOS)

AddressBookReader::AddressBookReader()
    : impl(0),
      futureWatcher(0),
      future(0),
      asyncLoadSlotReceiver(0), asyncLoadSlotMethod()
{

}
AddressBookReader::~AddressBookReader()
{
    delete futureWatcher;
    delete future;
//	loadAddresBookThread.quit();
//	loadAddresBookThread.wait();
}

QList<QObject*> AddressBookReader::fetchAll() throw(ReadAddressBookPermissionDeniedException)
{
    //JNI ERROR (app bug): local reference table overflow (max=512): http://www.cnblogs.com/androidwsjisji/archive/2012/05/11/2495399.html

//	if ( contactsLoaded )
//		return contacts;

    QList<QObject*> contacts;
//	contacts.clear();
#ifdef Q_OS_ANDROID

	{
		QAndroidJniObject activity = QtAndroid::androidActivity();
		qDebug() << __FUNCTION__ << "activity.isValid()=" << activity.isValid();

		QAndroidJniObject readContactPermission = QAndroidJniObject::fromString("android.permission.READ_CONTACTS");
		jint permissionCheckResult = activity.callMethod<jint>("checkCallingOrSelfPermission", "(Ljava/lang/String;)I", readContactPermission.object<jstring>());
		jint permissionGrantedCode = QAndroidJniObject::getStaticField<jint>("android.content.pm.PackageManager", "PERMISSION_GRANTED");
		if ( permissionCheckResult == permissionGrantedCode )
		{
			qDebug() << "android.permission.READ_CONTACTS GRANTED for this app!";
		}
		else
		{
			qDebug() << "android.permission.READ_CONTACTS DENIED for this app!";
			qDebug() << "Add this into AndroidManifest.xml: <uses-permission android:name=\"android.permission.READ_CONTACTS\" />";
			//throw exception here
			ReadAddressBookPermissionDeniedException().raise();
		}

		QAndroidJniObject jsonStr =
				QAndroidJniObject::callStaticObjectMethod(
					"wpp/android/AddressBookReader", "fetchAddressBook",
					"(Landroid/content/Context;)Ljava/lang/String;",
					activity.object<jobject>());

	//QAndroidJniObject jsonStr = activity.callObjectMethod("fetchAddressBook", "()Ljava/lang/String;");
	//qDebug() << "jsonStr:isValid:" << jsonStr.isValid() << ":toString:" << jsonStr.toString();

		QByteArray jsonBytes = jsonStr.toString().toUtf8();
		qDebug() << "jsonBytes.length = " << jsonBytes.length();

		QJsonArray json( QJsonDocument::fromJson( jsonBytes ).array() );
		for ( QJsonValue val : json )//for each person
		{
			QJsonObject personJson = val.toObject();

			QJsonArray phonesJson = personJson["p"].toArray();
			QList<QObject*> phones;
			for ( QJsonValue pVal : phonesJson )
			{
				QJsonObject phoneJson = pVal.toObject();
				int phoneType = phoneJson["t"].toInt();
				if ( phoneType == 0/*TYPE_CUSTOM*/ )
				{
					phones.append(
						new wpp::qt::AddressBookContactPhone(
							phoneJson["p"].toString(),
							phoneJson["l"].toString()
						)
					);
				}
				else
				{
					phones.append(
						new wpp::qt::AddressBookContactPhone(
							phoneJson["p"].toString(),
							phoneType
						)
					);
				}
			}

			QJsonArray emailsJson = personJson["e"].toArray();
			QList<QObject*> emails;
			for ( QJsonValue eVal : emailsJson )
			{
				QJsonObject emailJson = eVal.toObject();
				int emailType = emailJson["t"].toInt();
				if ( emailType == 0/*TYPE_CUSTOM*/ )
				{
					emails.append(
						new wpp::qt::AddressBookContactEmail(
							emailJson["p"].toString(),
							emailJson["l"].toString()
						)
					);
				}
				else
				{
					emails.append(
						new wpp::qt::AddressBookContactEmail(
							emailJson["p"].toString(),
							emailType
						)
					);
				}
			}

			contacts.append(
				new wpp::qt::AddressBookContact(
					personJson["fn"].toString(),
					personJson["ln"].toString(),
					"",
					phones,
					emails
				)
			);
		}

	}
	addPinyin(contacts);
	sortContacts(contacts);
	groupByStartingLetter(contacts);

	return contacts;


    /* http://examples.javacodegeeks.com/android/core/provider/android-contacts-example/
     * ContentResolver cr = getContentResolver();
        Cursor cur = cr.query(ContactsContract.Contacts.CONTENT_URI, null, null, null, null);
        if (cur.getCount() > 0) {
                while (cur.moveToNext()) {
                     ........
        }
    }
objAdapter = new ContanctAdapter(ContactsCheckList.this, R.layout.alluser_row, list);
    */
    //use JNI here

//qDebug() << "AddressBook::fetchAll()...1";

    QAndroidJniObject activity = QAndroidJniObject::callStaticObjectMethod("org/qtproject/qt5/android/QtNative", "activity", "()Landroid/app/Activity;");
    //qDebug() << "AddressBook::fetchAll()...2";

//    QAndroidJniObject contextResources = activity.callObjectMethod("getResources", "()Landroid/content/res/Resources");
//    qDebug() << "contextResources:isValid:" << contextResources.isValid() << ":toString:" << contextResources.toString();

    //=== check for permission: http://stackoverflow.com/questions/7203668/how-permission-can-be-checked-at-runtime-without-throwing-securityexception
    /*String permission = "android.permission.READ_CONTACTS";
    int res = getContext().checkCallingOrSelfPermission(permission);
    return (res == PackageManager.PERMISSION_GRANTED);   */

    QAndroidJniObject readContactPermission = QAndroidJniObject::fromString("android.permission.READ_CONTACTS");
    jint permissionCheckResult = activity.callMethod<jint>("checkCallingOrSelfPermission", "(Ljava/lang/String;)I", readContactPermission.object<jstring>());
    jint permissionGrantedCode = QAndroidJniObject::getStaticField<jint>("android.content.pm.PackageManager", "PERMISSION_GRANTED");
    if ( permissionCheckResult == permissionGrantedCode )
    {
        qDebug() << "android.permission.READ_CONTACTS GRANTED for this app!";
    }
    else
    {
        qDebug() << "android.permission.READ_CONTACTS DENIED for this app!";
        qDebug() << "Add this into AndroidManifest.xml: <uses-permission android:name=\"android.permission.READ_CONTACTS\" />";
        //throw exception here
        ReadAddressBookPermissionDeniedException().raise();
    }

    QAndroidJniObject contentResolver = activity.callObjectMethod("getContentResolver","()Landroid/content/ContentResolver;");

    /*
     *     static QAndroidJniObject getStaticObjectField(const char *className,
                                           const char *fieldName,
                                           const char *sig);
    */
//QAndroidJniObject CONTENT_URI = QAndroidJniObject::getStaticObjectField<jobject>("android/provider/ContactsContract/Contacts", "CONTENT_URI");

    QAndroidJniObject AUTHORITY_URI = QAndroidJniObject::getStaticObjectField(
                "android/provider/ContactsContract", "AUTHORITY_URI", "Landroid/net/Uri;");
    //qDebug() << "AUTHORITY_URI:isValid:" << AUTHORITY_URI.isValid() << ":toString:" << AUTHORITY_URI.toString();

    //qDebug() << "AddressBook::fetchAll()...3";

    QAndroidJniObject CONTENT_URI = QAndroidJniObject::getStaticObjectField(
                "android/provider/ContactsContract$Contacts", "CONTENT_URI", "Landroid/net/Uri;");
    //qDebug() << "AddressBook::fetchAll()...4";
    //qDebug() << "CONTENT_URI:isValid:" << CONTENT_URI.isValid() << ":toString:" << CONTENT_URI.toString();

    //QAndroidJniObject CONTENT_URI_String = CONTENT_URI.callObjectMethod("toString", "()Ljava/lang/String;");
    //qDebug() << "CONTENT_URI:isValid:" << CONTENT_URI.isValid() << ":toString:" << CONTENT_URI_String.toString();

    /*jobjectArray projection = (jobjectArray)NULL;
    jstring selection = (jstring)NULL;
    jobjectArray selectionArgs = (jobjectArray)NULL;
    jstring sortOrder = (jstring)NULL;
    jobject cancellationSignal = (jobject)NULL;*/
    QAndroidJniObject nullObj;

    //qDebug() << "AddressBook::fetchAll()...5";
    //qDebug() << "contentResolver:isValid:" << contentResolver.isValid() << ":toString:" << contentResolver.toString();

    QAndroidJniEnvironment env;
    if (env->ExceptionCheck())
    {
        // Handle exception here.
        qDebug() << "Exception 1....";
        env->ExceptionDescribe();
        env->ExceptionClear();
    }

    //http://stackoverflow.com/questions/12932111/how-to-prevent-gmail-contacts-in-contentresolver-query-in-android
    //java: String IN_VISIBLE_GROUP = ContactsContract.Contacts.IN_VISIBLE_GROUP;
    QAndroidJniObject IN_VISIBLE_GROUP = QAndroidJniObject::getStaticObjectField(
                "android/provider/ContactsContract$ContactsColumns", "IN_VISIBLE_GROUP", "Ljava/lang/String;");
    qDebug() << "IN_VISIBLE_GROUP:isValid:" << IN_VISIBLE_GROUP.isValid() << ":" << IN_VISIBLE_GROUP.toString();

    QAndroidJniObject visibleGroupContactSelection = QAndroidJniObject::fromString( IN_VISIBLE_GROUP.toString() + "='1'" );
    QAndroidJniObject cursor = contentResolver.callObjectMethod("query",
        "(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;",
        //CONTENT_URI.object<jobject>(), projection, selection, selectionArgs, sortOrder);
        CONTENT_URI.object<jobject>(), nullObj.object<jobjectArray>(), visibleGroupContactSelection.object<jstring>(), nullObj.object<jobjectArray>(), nullObj.object<jstring>());
    //qDebug() << "cursor:isValid:" << cursor.isValid() << ":toString:" << cursor.toString();

    if (env->ExceptionCheck())
    {
        // Handle exception here.
        qDebug() << "Exception 2....";
        env->ExceptionDescribe();
        env->ExceptionClear();
    }

    jint resultCount = cursor.callMethod<jint>("getCount");
//	cursor.callObjectMethod("getCount", "()I");
//	QAndroidJniObject resultCount = cursor.callObjectMethod("getCount", "()I");
qDebug() << "addressbook-resultCount:" << resultCount;

    if ( resultCount > 0 )
    {
        //java: String _ID = ContactsContract.Contacts._ID;
//        QAndroidJniObject _ID = QAndroidJniObject::getStaticObjectField(
//                    "android/provider/ContactsContract$Contacts", "_ID", "Ljava/lang/String;");
//        qDebug() << "_ID:isVAlid:" << _ID.isValid();
        QAndroidJniObject _ID = QAndroidJniObject::fromString("_id");
        qDebug() << "_ID:isVAlid:" << _ID.isValid();

        //java: String DISPLAY_NAME = ContactsContract.ContactsColumns.DISPLAY_NAME;
        QAndroidJniObject DISPLAY_NAME = QAndroidJniObject::getStaticObjectField(
                    "android/provider/ContactsContract$ContactsColumns", "DISPLAY_NAME", "Ljava/lang/String;");
        qDebug() << "DISPLAY_NAME:isVAlid:" << DISPLAY_NAME.isValid();

        //java: String HAS_PHONE_NUMBER = ContactsContract.ContactsColumns.HAS_PHONE_NUMBER;
        QAndroidJniObject HAS_PHONE_NUMBER = QAndroidJniObject::getStaticObjectField(
                    "android/provider/ContactsContract$ContactsColumns", "HAS_PHONE_NUMBER", "Ljava/lang/String;");
        qDebug() << "HAS_PHONE_NUMBER:isVAlid:" << HAS_PHONE_NUMBER.isValid();

        //java: Uri PhoneCONTENT_URI = ContactsContract.CommonDataKinds.Phone.CONTENT_URI;
        QAndroidJniObject PhoneCONTENT_URI = QAndroidJniObject::getStaticObjectField(
                    "android/provider/ContactsContract$CommonDataKinds$Phone", "CONTENT_URI", "Landroid/net/Uri;");
        qDebug() << "PhoneCONTENT_URI:isVAlid:" << PhoneCONTENT_URI.isValid();

        //java: String Phone_CONTACT_ID = ContactsContract.CommonDataKinds.Phone.CONTACT_ID;
        QAndroidJniObject Phone_CONTACT_ID = QAndroidJniObject::getStaticObjectField(
                    "android/provider/ContactsContract$RawContactsColumns", "CONTACT_ID", "Ljava/lang/String;");
        qDebug() << "Phone_CONTACT_ID:isVAlid:" << Phone_CONTACT_ID.isValid();

        //java: String PHONE_TYPE = ContactsContract.CommonDataKinds.Phone.TYPE;
        QAndroidJniObject PHONE_TYPE = QAndroidJniObject::getStaticObjectField(
                    "android/provider/ContactsContract$CommonDataKinds$CommonColumns", "TYPE", "Ljava/lang/String;");
        qDebug() << "PHONE_TYPE:isVAlid:" << PHONE_TYPE.isValid();

/*		//java: int PHONE_TYPE_HOME = ContactsContract.CommonDataKinds.Phone.TYPE_HOME;
        jint PHONE_TYPE_HOME = QAndroidJniObject::getStaticField<jint>("android/provider/ContactsContract$CommonDataKinds$Phone", "TYPE_HOME");
        //java: int PHONE_TYPE_MOBILE = ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE;
        jint PHONE_TYPE_MOBILE = QAndroidJniObject::getStaticField<jint>("android/provider/ContactsContract$CommonDataKinds$Phone", "TYPE_MOBILE");
        //java: int PHONE_TYPE_WORK = ContactsContract.CommonDataKinds.Phone.TYPE_WORK;
        jint PHONE_TYPE_WORK = QAndroidJniObject::getStaticField<jint>("android/provider/ContactsContract$CommonDataKinds$Phone", "TYPE_WORK");
*/

        //java: String NUMBER = ContactsContract.CommonDataKinds.Phone.NUMBER;
        QAndroidJniObject NUMBER = QAndroidJniObject::getStaticObjectField(
                    "android/provider/ContactsContract$CommonDataKinds$Phone", "NUMBER", "Ljava/lang/String;");
        qDebug() << "NUMBER:isVAlid:" << NUMBER.isValid();

        //java: String PHONE_LABEL = ContactsContract.CommonDataKinds.Phone.LABEL;
        QAndroidJniObject PHONE_LABEL = QAndroidJniObject::getStaticObjectField(
                    "android/provider/ContactsContract$CommonDataKinds$CommonColumns", "LABEL", "Ljava/lang/String;");
        qDebug() << "PHONE_LABEL:isVAlid:" << PHONE_LABEL.isValid();

        //java: Uri EmailCONTENT_URI =  ContactsContract.CommonDataKinds.Email.CONTENT_URI;
        QAndroidJniObject EmailCONTENT_URI = QAndroidJniObject::getStaticObjectField(
                    "android/provider/ContactsContract$CommonDataKinds$Email", "CONTENT_URI", "Landroid/net/Uri;");
        qDebug() << "EmailCONTENT_URI:isVAlid:" << EmailCONTENT_URI.isValid();

        //java:         String EmailCONTACT_ID = ContactsContract.CommonDataKinds.Email.CONTACT_ID;
        QAndroidJniObject EmailCONTACT_ID = QAndroidJniObject::getStaticObjectField(
                    "android/provider/ContactsContract$RawContactsColumns", "CONTACT_ID", "Ljava/lang/String;");
        qDebug() << "EmailCONTACT_ID:isVAlid:" << EmailCONTACT_ID.isValid();

        //java: String Email_DATA = ContactsContract.CommonDataKinds.Email.DATA;
        QAndroidJniObject Email_DATA = QAndroidJniObject::getStaticObjectField(
                    "android/provider/ContactsContract$CommonDataKinds$CommonColumns", "DATA", "Ljava/lang/String;");
        qDebug() << "Email_DATA:isVAlid:" << Email_DATA.isValid();

        //java: String EMAIL_TYPE = ContactsContract.CommonDataKinds.Email.TYPE;
//        QAndroidJniObject EMAIL_TYPE = QAndroidJniObject::getStaticObjectField(
//                    "android/provider/ContactsContract$CommonDataKinds$Email", "TYPE", "Ljava/lang/String;");
        QAndroidJniObject EMAIL_TYPE = QAndroidJniObject::fromString("data2");
        qDebug() << "EMAIL_TYPE:isVAlid:" << EMAIL_TYPE.isValid();

        //java: String EMAIL_LABEL = ContactsContract.CommonDataKinds.Email.LABEL;
        QAndroidJniObject EMAIL_LABEL = QAndroidJniObject::getStaticObjectField(
                    "android/provider/ContactsContract$CommonDataKinds$CommonColumns", "LABEL", "Ljava/lang/String;");
        qDebug() << "EMAIL_LABEL:isVAlid:" << EMAIL_LABEL.isValid();


        while ( cursor.callMethod<jboolean>("moveToNext") )
        {
            qDebug() << "cursor:moveToNext";

            wpp::qt::AddressBookContact *addressBookContact = new wpp::qt::AddressBookContact();
            //qDebug() << "next phone contact...";

            //java: String contact_id = cursor.getString(cursor.getColumnIndex( _ID ));
            QAndroidJniObject contact_id = cursor.callObjectMethod("getString", "(I)Ljava/lang/String;",
                cursor.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", _ID.object<jstring>())
            );
            //qDebug() << "contact_id:isVAlid:" << contact_id.isValid();

            //java: String name = cursor.getString(cursor.getColumnIndex( DISPLAY_NAME ));
            QAndroidJniObject name = cursor.callObjectMethod("getString", "(I)Ljava/lang/String;",
                cursor.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", DISPLAY_NAME.object<jstring>())
            );
            //qDebug() << "name:isVAlid:" << name.isValid();
            if (env->ExceptionCheck())
            {
                // Handle exception here.
                qDebug() << "Exception when getting \"name\"....";
                env->ExceptionDescribe();
                env->ExceptionClear();
            }
            //qDebug() << "Contact==============";
            //qDebug() << "Name: " << name.toString();

            addressBookContact->setFirstName( name.toString() );

            //java: int hasPhoneNumber = Integer.parseInt(cursor.getString(cursor.getColumnIndex( HAS_PHONE_NUMBER )));
            QAndroidJniObject hasPhoneNumberString = cursor.callObjectMethod("getString", "(I)Ljava/lang/String;",
                cursor.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", HAS_PHONE_NUMBER.object<jstring>())
            );
            int hasPhoneNumber = hasPhoneNumberString.toString().toInt();
            if (env->ExceptionCheck())
            {
                // Handle exception here.
                qDebug() << "Exception when getting \"hasPhoneNumber\"....";
                env->ExceptionDescribe();
                env->ExceptionClear();
            }

            jclass elementClass = env->GetObjectClass( contact_id.object<jstring>() );
            //jobjectArray NewObjectArray(JNIEnv *env, jsize length, jclass elementClass, jobject initialElement);
            jobjectArray selectionArgs = env->NewObjectArray(
                                            1,
                                            elementClass, //jclass GetObjectClass(JNIEnv *env, jobject obj);
                                            contact_id.object<jstring>() );
//            QAndroidJniObject selectionArgsObj(selectionArgs);
            //qDebug() << "selectionArgsObj:isValid:" << selectionArgsObj.isValid() << ":toString:" << selectionArgsObj.toString();


            qDebug() << "hasPhoneNumber:" << hasPhoneNumber;
            if ( hasPhoneNumber > 0 )
            {
                // Query and loop for every phone number of the contact
                //java: Cursor phoneCursor = contentResolver.query(PhoneCONTENT_URI, null, Phone_CONTACT_ID + " = ?", new String[] { contact_id }, null);
                QAndroidJniObject Phone_CONTACT_ID_EQUALS = QAndroidJniObject::fromString( Phone_CONTACT_ID.toString() + " = ?" );
                //qDebug() << "Phone_CONTACT_ID:isValid:" << Phone_CONTACT_ID.isValid() << ":toString:" << Phone_CONTACT_ID.toString();
                //qDebug() << "Phone_CONTACT_ID_EQUALS:isValid:" << Phone_CONTACT_ID_EQUALS.isValid() << ":toString:" << Phone_CONTACT_ID_EQUALS.toString();

                QAndroidJniObject phoneCursor = contentResolver.callObjectMethod("query",
                    "(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;",
                    PhoneCONTENT_URI.object<jobject>(), nullObj.object<jobjectArray>(), Phone_CONTACT_ID_EQUALS.object<jstring>(), selectionArgs, nullObj.object<jstring>());
                //qDebug() << "phoneCursor:isValid:" << phoneCursor.isValid() << ":toString:" << phoneCursor.toString();

                //java: while (phoneCursor.moveToNext())
                while ( phoneCursor.callMethod<jboolean>("moveToNext") )
                {
                    //phoneNumber = phoneCursor.getString(phoneCursor.getColumnIndex(NUMBER));
                    QAndroidJniObject phoneNumber = phoneCursor.callObjectMethod("getString", "(I)Ljava/lang/String;",
                        phoneCursor.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", NUMBER.object<jstring>())
                    );
                    //qDebug() << "phoneNumber:=== " << phoneNumber.toString();

                    //java: int phoneType = phoneCursor.getInt(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.TYPE));
                    jint phoneType = phoneCursor.callMethod<jint>("getInt", "(I)I",
                        phoneCursor.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", PHONE_TYPE.object<jstring>())
                    );

                    //java: String phoneCustomLabel = phoneCursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.LABEL));
                    QString phoneCustomLabelString;
                    jint phoneCustomLabelColIndex = phoneCursor.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", PHONE_LABEL.object<jstring>());
                    //qDebug() << phoneNumber.toString() << ">>phoneType:" << phoneType << ", phoneCustomLabelColIndex:" << phoneCustomLabelColIndex;
                    if ( phoneType == 0/*TYPE_CUSTOM*/ && phoneCustomLabelColIndex >= 0 )
                    {
                        QAndroidJniObject phoneCustomLabel = phoneCursor.callObjectMethod("getString", "(I)Ljava/lang/String;",
                            phoneCustomLabelColIndex
                        );
                        //qDebug() << "phoneCustomLabel:isVAlid:" << phoneCustomLabel.isValid() << ":" << phoneCustomLabel.toString();

                        //qDebug() << "phone custom label:" << phoneNumber.toString() << "=>" << phoneCustomLabel.toString();

                        phoneCustomLabelString = phoneCustomLabel.toString();
                    }

                    if ( phoneType == 0 )//TYPE_CUSTOM
                    {
                        addressBookContact->getPhones().push_back(
                            new wpp::qt::AddressBookContactPhone( phoneNumber.toString(), phoneCustomLabelString )
                        );
                    }
                    else
                    {
                        addressBookContact->getPhones().push_back(
                            new wpp::qt::AddressBookContactPhone( phoneNumber.toString(), phoneType )
                        );
                    }
                }
                //java: phoneCursor.close();
                phoneCursor.callMethod<void>("close");
            }//if ( hasPhoneNumber > 0 )

            //java: Cursor emailCursor = contentResolver.query(EmailCONTENT_URI,    null, EmailCONTACT_ID+ " = ?", new String[] { contact_id }, null);
            QAndroidJniObject Email_CONTACT_ID_EQUALS = QAndroidJniObject::fromString( EmailCONTACT_ID.toString() + " = ?" );
            QAndroidJniObject emailCursor = contentResolver.callObjectMethod("query",
                "(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;",
                EmailCONTENT_URI.object<jobject>(), nullObj.object<jobjectArray>(), Email_CONTACT_ID_EQUALS.object<jstring>(), selectionArgs, nullObj.object<jstring>());
            qDebug() << "emailCursor:isValid:" << emailCursor.isValid() << ":toString:" << emailCursor.toString();

            //java: while (emailCursor.moveToNext()) {
            while ( emailCursor.callMethod<jboolean>("moveToNext") )
            {
                //java: email = emailCursor.getString(emailCursor.getColumnIndex(DATA));

                QAndroidJniObject email = emailCursor.callObjectMethod("getString", "(I)Ljava/lang/String;",
                    emailCursor.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", Email_DATA.object<jstring>())
                );
                qDebug() << "email:=== " << email.toString();

                //java: int emailType = emailCursor.getInt(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.TYPE));
                jint emailType = emailCursor.callMethod<jint>("getInt", "(I)I",
                    emailCursor.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", EMAIL_TYPE.object<jstring>())
                );
                qDebug() << "emailType:" << emailType;

                //java: String emailCustomLabel = emailCursor.getString(emailCursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.LABEL));
                QString emailCustomLabelString;
                jint emailCustomLabelColIndex = emailCursor.callMethod<jint>("getColumnIndex", "(Ljava/lang/String;)I", EMAIL_LABEL.object<jstring>());
                qDebug() << email.toString() << ">>emailType:" << emailType << ", emailCustomLabelColIndex:" << emailCustomLabelColIndex;
                if ( emailType == 0/*TYPE_CUSTOM*/ && emailCustomLabelColIndex >= 0 )
                {
                    QAndroidJniObject emailCustomLabel = emailCursor.callObjectMethod("getString", "(I)Ljava/lang/String;",
                        emailCustomLabelColIndex
                    );
                    qDebug() << "emailCustomLabel:isVAlid:" << emailCustomLabel.isValid() << ":" << emailCustomLabel.toString();
                    if ( !emailCustomLabel.isValid() )
                    {
                        emailType = wpp::qt::AddressBookContactEmail::TYPE_OTHER;
                    }
                    else
                    {
                        emailCustomLabelString = emailCustomLabel.toString();
                    }
                }

                if ( emailType == 0 )//TYPE_CUSTOM
                {
                    addressBookContact->getEmails().push_back(
                        new wpp::qt::AddressBookContactEmail( email.toString(), emailCustomLabelString )
                    );
                }
                else
                {
                    addressBookContact->getEmails().push_back(
                        new wpp::qt::AddressBookContactEmail( email.toString(), emailType )
                    );
                }

            }

            env->DeleteLocalRef(elementClass);
            env->DeleteLocalRef(selectionArgs);

            //java: emailCursor.close();
            emailCursor.callMethod<void>("close");

            qDebug() << "contacts++:" << contacts.size();
            contacts.push_back( addressBookContact );
        }
    }

    //java: cursor.close();
    cursor.callMethod<void>("close");

	addPinyin(contacts);
	sortContacts(contacts);
	groupByStartingLetter(contacts);

	int i = 0;
	for ( QObject *obj: contacts )
	{
		wpp::qt::AddressBookContact *contact = dynamic_cast<wpp::qt::AddressBookContact *>(obj);
		qDebug() << "-->[" << i << "]";
		qDebug() << *contact;
		i++;
	}

    //setContactsLoaded(true);
    //emit this->contactsChanged();
    return contacts;
#else
    return contacts;
#endif
}

#endif

/*void AddressBookReader::resetSelection()
{
    for ( QObject *obj : contactsForSelect )
    {
        AddressBookContactForSelect *contactForSelect = dynamic_cast<AddressBookContactForSelect *>( obj );
        contactForSelect->setIsMark(false);
    }
    emit this->contactsForSelectChanged();
}*/

extern QList<QObject*> asyncLoadContacts(QThread *uiThread)
{
    qDebug() << __FUNCTION__;
    wpp::qt::AddressBookReader& addressBookReader = wpp::qt::AddressBookReader::getInstance();
    QList<QObject*> contacts = addressBookReader.fetchAll();
    qDebug() << __FUNCTION__ << ":return contacts-size:" << contacts.size();
    for ( QObject *obj : contacts )
    {
        wpp::qt::AddressBookContact *contact = dynamic_cast<wpp::qt::AddressBookContact *>(obj);
        contact->moveToThread(uiThread);

        for ( QObject *phone : contact->getPhones() )
            phone->moveToThread(uiThread);
        for ( QObject *email : contact->getEmails() )
            email->moveToThread(uiThread);
    }
    return contacts;
}

void AddressBookReader::asyncFetchAll(const QObject * receiver, const char * method)
{
    connect(this, SIGNAL(finishedAsyncLoadContact(QList<QObject*>)), receiver, method );
    asyncLoadSlotReceiver = receiver;
    asyncLoadSlotMethod = method;

    futureWatcher = new QFutureWatcher< QList<QObject*> >;
    connect(futureWatcher, SIGNAL(finished()), this, SLOT(onBridgeAsyncFetchAll()));

    future = new QFuture< QList<QObject*> >;
    *future = QtConcurrent::run(asyncLoadContacts, QThread::currentThread());
    futureWatcher->setFuture(*future);
}
void AddressBookReader::onBridgeAsyncFetchAll()
{
    qDebug() << __FUNCTION__;
    QList<QObject*> contacts = future->result();
    qDebug() << __FUNCTION__ << ":contacts-size:" << contacts.size();
    emit this->finishedAsyncLoadContact(contacts);

    delete future;
    future = 0;
    delete futureWatcher;
    futureWatcher = 0;

    disconnect(this, SIGNAL(finishedAsyncLoadContact(QList<QObject*>)), asyncLoadSlotReceiver, asyncLoadSlotMethod.toStdString().c_str() );
    asyncLoadSlotReceiver = 0;
    asyncLoadSlotMethod.clear();
}

bool addressBookContactLessThan(const QObject* obj1, const QObject *obj2)
{
	const wpp::qt::AddressBookContact *contact1 =
			dynamic_cast<const wpp::qt::AddressBookContact *>(obj1);
	const wpp::qt::AddressBookContact *contact2 =
			dynamic_cast<const wpp::qt::AddressBookContact *>(obj2);

	QString firstLetter1 = contact1->getFirstLetter();
	QString firstLetter2 = contact2->getFirstLetter();

	if ( firstLetter1.isEmpty() && firstLetter2.isEmpty() )
		return true;//order doesn't matter

	if ( firstLetter1.isEmpty() )
		return false;//2 should be < 1
	if ( firstLetter2.isEmpty() )
		return true;//1 should be < 2

	//now both non-empty
	QChar firstChar1 = firstLetter1.at(0).toUpper();
	QChar firstChar2 = firstLetter2.at(0).toUpper();

	bool fullStringCompare = contact1->getLatinFullName().toLower() < contact2->getLatinFullName().toLower();

	if ( firstChar1.isDigit() && firstChar2.isDigit() )
		return fullStringCompare;
	if ( firstChar1.isLetter() && firstChar2.isLetter() )
		return fullStringCompare;
	if ( firstChar1.isDigit() && firstChar2.isLetter() )
		return false;//2 should be < 1
	if ( firstChar1.isLetter() && firstChar2.isDigit() )
		return true;//1 should be < 2

	return true;//unknown, do nothing
}

void AddressBookReader::sortContacts(QList<QObject*>& contacts)
{
	qSort(contacts.begin(), contacts.end(), addressBookContactLessThan);
}

QList<QObject*>& AddressBookReader::addPinyin(QList<QObject*>& contacts)
{
	for ( QObject *obj : contacts )
	{
		qDebug() << "1......";
		wpp::qt::AddressBookContact *contact = dynamic_cast<wpp::qt::AddressBookContact *>(obj);
		qDebug() << "2......";
		QString chineseName = contact->getLastName() + contact->getFirstName();
		qDebug() << "3......";
		int strlen = chineseName.length();
		qDebug() << "4......";
		wchar_t *nameBuf = new wchar_t [ strlen ];
		qDebug() << "5......";
		chineseName.toWCharArray(nameBuf);

		qDebug() << "6......";
		QString pinyin( wpp::lang::Pinyin::from(nameBuf, strlen).c_str() );
		qDebug() << "7......";

		delete [] nameBuf;
		nameBuf = 0;

		qDebug() << chineseName << " => " << pinyin;
		if ( !pinyin.isEmpty() )
			contact->setLatinFullName( pinyin );

		//qDebug() << "contact latin:" << contact->getLatinFullName();
	}
	return contacts;
}


void AddressBookReader::groupByStartingLetter( QList<QObject*>& contacts )
{
	QChar currentLetter('!');//random letter not in A-Z,#,?
	for ( QObject *obj : contacts )
	{
		wpp::qt::AddressBookContact *contact = dynamic_cast<wpp::qt::AddressBookContact *>(obj);
		qDebug() << "==== loop.... contacts...:" << contact->getLatinFullName();
		qDebug() << "currentLetter:" << currentLetter;

		QString contactFirstLetter = contact->getFirstLetter();
		qDebug() << "contactFirstLetter:" << contactFirstLetter;
		if ( contactFirstLetter.isEmpty() )
		{
			if ( currentLetter != '?' )
			{
				qDebug() << "FIRST ?";
				currentLetter = '?';
				contact->setIsFirstPersonInGroup(true);
			}
		}
		else
		{
			QChar startingLetter = contactFirstLetter.at(0).toUpper();
			qDebug() << "startingLetter:" << startingLetter;
			if ( startingLetter.isLetter() )
			{
				if ( startingLetter != currentLetter )
				{
					qDebug() << "FIRST LETTER:" << startingLetter;
					currentLetter = startingLetter;
					contact->setIsFirstPersonInGroup(true);
				}

			}
			else if ( startingLetter.isDigit() )
			{
				if ( currentLetter != '#' )
				{
					qDebug() << "FIRST DIGIT";
					currentLetter = '#';
					contact->setIsFirstPersonInGroup(true);
				}
			}
			else
			{
				if ( currentLetter != '?' )
				{
					qDebug() << "FIRST UNKNOWN";
					currentLetter = '?';
					contact->setIsFirstPersonInGroup(true);
				}
			}
		}
		qDebug() << "final:isFirstPersonInGroup:" << contact->getIsFirstPersonInGroup();

	}
}

}//namespace qt
}//namespace wpp
