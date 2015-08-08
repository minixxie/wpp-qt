# wpp-qt
Web++ framework for Qt. This is a framework supplementary to Qt for mobile, for creating mobile apps for iOS and Android. More platforms support will be added later, currently this library only support iOS and Android.

* Android support: minSDK: 10, targetSDK: 22
* iOS support: iOS7+

## System Requirements
* Gradle (don't use Apache Ant)
* Android SDK with android-22 installed<br/>
<img src="https://github.com/minixxie/wpp-qt/raw/master/doc/android-sdk-api22.png" height="380"/>
* Android SDK with "Android Support Library" (22.2+) and "Android Support Repository" installed.<br/>
<img src="https://github.com/minixxie/wpp-qt/raw/master/doc/android-sdk-supportv7.png" height="380"/>
* Android SDK with "Android SDK Build-tools" (22.0.1+) installed<br/>
<img src="https://github.com/minixxie/wpp-qt/raw/master/doc/android-sdk-buildtools.png" height="380"/>

## Preparation
You will usually use this project as a git-submodule of your project. Setup with this:
```bash
cd YourQtProject
git submodule add https://github.com/minixxie/wpp-qt.git
```
Once you've cloned this project, make sure to download sub-modules dependencies:
* [B-Sides/ELCImagePickerController](https://github.com/B-Sides/ELCImagePickerController)
* [skywinder/ActionSheetPicker-3.0](https://github.com/skywinder/ActionSheetPicker-3.0)
* [donglua/PhotoPicker](https://github.com/donglua/PhotoPicker.git)
* [leolin310148/ShortcutBadger](https://github.com/leolin310148/ShortcutBadger.git)
```bash
cd wpp-qt
git submodule init
git submodule update
```
Then, remember to include the project file in YourQtProject.pro (assuming wpp-qt folder is under your project folder):
```
## import library project "wpp"
include($$PWD/wpp-qt/wpp.pri)
```
To make sure the android part works, please do this (You can ignore if you don't target to support android):
- create android template folder from Qt Creator, and remember to "Use Gradle" as your packager:

![Create Android template folder](https://github.com/minixxie/wpp-qt/raw/master/doc/android-create-template.png)

The above also help add these lines into the pro file:
```
DISTFILES += \
android/gradle/wrapper/gradle-wrapper.jar \
android/AndroidManifest.xml \
android/res/values/libs.xml \
android/build.gradle \
android/gradle/wrapper/gradle-wrapper.properties \
android/gradlew \
android/gradlew.bat

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
```
- Create the link to the android library project "wpp-android"

YourQtProject/android/settings.gradle:
```bash
include 'wpp-android'
project(':wpp-android').projectDir = new File('../../YourQtProject/wpp-qt/wpp-android')
```
YourQtProject/android/build.gradle:
```bash
dependencies {
    ...
    compile project(':wpp-android')
}
```
YourQtProject/android/AndroidManifest.xml:
```XML
    <uses-sdk android:minSdkVersion="10" android:targetSdkVersion="22"/>
```


## To Begin
To use this library, the first requirement is to substitute QGuiApplication with wpp::qt::QGuiApplication, and QQmlApplicationEngine with wpp::qt::QQmlApplicationEngine:
```c++
#include <wpp/qt/QGuiApplication.h>
#include <wpp/qt/QQmlApplicationEngine.h>

int main(int argc, char *argv[])
{
	wpp::qt::QGuiApplication app(argc, argv);//changed from QGuiApplication

	wpp::qt::QQmlApplicationEngine engine;//changed from QQmlApplicationEngine, which provides "wpp" object in QML
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}

```
The wpp::qt::QGuiApplication class actually inherits from [QGuiApplication](http://doc.qt.io/qt-5/qguiapplication.html) and it registers some wpp library things in addition.
The wpp::qt::QQmlApplicationEngine class inherits from [QQmlApplicationEngine](http://doc.qt.io/qt-5/qqmlapplicationengine.html) and it injects "wpp" object into the QML root context.

## UseCase: density independent pixel
All QML elements only support pixel values for x, y, width, height and all size and dimension related properties. With the main function used in "To Begin", "reso" variable can be used in QML like this:
```QML
Rectange {
	anchors.fill: parent
	anchors.margins: 10*wpp.dp2px //dp2px means changing 10 from "dp" to "px" as all QML properties only accept pixels
}
```
## UseCase: tackle with adjustPan default behaviour
By default, Qt does "adjustPan" of the window content when the soft keyboard comes out. This is not professional as an app.
Normally we would like to keep the title bar not moved, but just the content under the title bar to scroll up.
For android, we can choose "adjustResize" for window:softInputMode in AndroidManifest.xml and Qt has already implemented it since Qt5.3. But for iOS, I still couldn't find a work around. That's why I did this work around myself:

By using wpp::qt::QGuiApplication, the whole app is by default with "adjustResize" characteristics for both iOS and Android. No setting in AndroidManifest.xml is needed for window:softInputMode, this is implemented in QGuiApplication class.

Scenario I: I want to scroll a particular flickable when an input box is clicked, so that it will not be covered by the soft keyboard.
```QML
import wpp.qt 2.0

	TitleBar {
		id: titleBar
		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.right
		label.text: "My App"
	}
	Flickable {
		id: pageScrollable
		anchors.top: titleBar.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom

		TextField {
			id: textfield1
			...
			HandleSoftKeyboardMouseArea {
				anchors.fill: parent
				flickable: pageScrollable  //will scroll this flickable appropriately when keyboard shown, to avoid the who app window to be moved upward
			}
		}

		...
		TextField {
			id: textfield10
			anchors.top: textfield9.bottom
			anchors.left: parent.left
			anchors.right: parent.right
			height: 24*wpp.dp2px

			//has to add this element to each input element (TextInput, TextField, TextEdit, etc)
			HandleSoftKeyboardMouseArea {
				anchors.fill: parent
				flickable: pageScrollable
			}	
		}
	}
```

Scenario II: I want to shorten the app window height, so that it only occupy the space where keyboard doesn't block. This is the same as the "adjustResize" effect implemented by Android.
```QML

	Rectangle {
		//since this is stick to the bottom of the window, it will automatically be raised up to the top of the keyboard, when soft keyboard is shown
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		TextInput {
			...
			HandleSoftKeyboardMouseArea {
				anchors.fill: parent
				//no need to assign "flickable" here as we don't need to scroll anything when this input box is focused
			}
		}
	}
```
Mechansim: HandleSoftKeyboardMouseArea handle the clicking by the user, delay the keyboard from showing up, and delay the input element from acquiring focus, thus avoiding the UI to be pushed upward. And it saves some time for the flickable to scroll up before the keyboard is shown.

see example: [AdjustResize](https://github.com/minixxie/wpp-qt/raw/master/examples/AdjustResize)

## UseCase: TimeAgo
TimeAgo is a class for generating human readable date/time. For example, it shows "2 hours ago", "15 mins ago", etc. By using wpp::qt::QGuiApplication and wpp::qt::QQmlApplicationEngine in main(), timeago can be used in QML:
```QML
Text {
	text: timeago.getTimeAgo(unixTimestamp)
}
```
## UseCase: QML TitleBar
This QML element mimic the TitleBar of NavigationController on iOS.
```QML
TitleBar {
	id: titleBar
	anchors.top: parent.top
	anchors.left: parent.left
	anchors.right: parent.right
	text: "Hello"
}
```
![TitleBar](https://github.com/minixxie/wpp-qt/raw/master/doc/screenshot-titlebar.png)

## UseCase: circular image
We usually need to use rounded corner on images, Qt doesn't support it by default. With this library you can do this. But the current version has a limitation that the image should not lie on a boundary of two differnt colors or other background images:
```QML
Avatar {
	id: profilePhoto
	anchors.left: parent.left
	anchors.top: parent.top
	anchors.margins: 10*reso.dp2px
	height: 40*reso.dp2px
	width: height
	circleMask: true  //this is the main property to make circle
	maskColor: "#ffffff" //assume the background is white, write this to make sure 4 round corners are in white background
	url: "http://xxxxxx/abc.jpg"
	onClicked: {
		//....
	}
}
```

## UseCase: use native camera or image picker to upload profile photo
This is a common use case, which often show a empty photo for clicking to set the profile photo of a user. With this library, you can do this:
```QML
ImageSelector {
	id: imageSelector
	anchors.fill: parent
	maxPick: 1
	onPhotoTaken: { //string imagePath
		console.debug("onPhotoTaken:" + imagePath);
		profilePhoto.url = "file:" + imagePath;
	}
	onPhotoChosen: { //variant imagePaths
		if ( imagePaths.length == 1 )
		{
			var imagePath = imagePaths[0];
			console.debug("onPhotoChosen:" + imagePath);
			profilePhoto.url = "file:" + imagePath;
		}
	}
	onCropFinished: {
	}
	onCropCancelled: {
	}
}

Avatar {
	id: profilePhoto
	anchors.left: parent.left
	anchors.top: parent.top
	anchors.margins: 10*reso.dp2px
	height: 100*reso.dp2px
	width: height
	bgText: qsTr("Upload Image")
	bgTextColor: "#0080ff"
	//url: "http://xxxxxx/abc.jpg"
	onClicked: {
		imageSelector.open();
	}
}
```
```XML
	<!-- android/AndroidManifest.xml: register 2 activities -->
        <activity android:name="me.iwf.photopicker.PhotoPickerActivity" android:theme="@style/Theme.AppCompat.NoActionBar">
            <meta-data android:name="android.app.lib_name" android:value="-- %%INSERT_APP_LIB_NAME%% --"/>
        </activity>
        <activity android:name="me.iwf.photopicker.PhotoPagerActivity" android:theme="@style/Theme.AppCompat.NoActionBar">
            <meta-data android:name="android.app.lib_name" android:value="-- %%INSERT_APP_LIB_NAME%% --"/>
        </activity>
```

![Native Camera and Image Picker](https://github.com/minixxie/wpp-qt/raw/master/doc/screenshot-native-camera-and-image-picker.png)
see example: [UsingNativeCameraAndImagePicker](https://github.com/minixxie/wpp-qt/raw/master/examples/UsingNativeCameraAndImagePicker)

## UseCase: Native DateTime picker
Employed the native DateTime picker UI for you:
```QML
DateTimeControl {
	id: startDateTimeControl
	anchors.top: parent.top
	anchors.left: parent.left; anchors.right: parent.right;
	height: 36*reso.dp2px
	topBorder: true; bottomBorder: true
	title: qsTr("Date/Time")
	dateTime: new Date()
	//timeZoneId: "Asia/Hong_Kong"
	onPicked: {
		dateTime = dateTimePicked;
		console.debug("picked=" + dateTimePicked);
	}
}
```
Screenshot on Android and iOS:

<img src="https://github.com/minixxie/wpp-qt/raw/master/doc/screenshot-titlebar.png" height="380"/>
<img src="https://github.com/minixxie/wpp-qt/raw/master/doc/screenshot-DateTimeControl-android.png" height="380"/>
<img src="https://github.com/minixxie/wpp-qt/raw/master/doc/screenshot-DateTimeControl-ios.png" height="380"/>
<img src="https://github.com/minixxie/wpp-qt/raw/master/doc/screenshot-DateTimeControl.png" />

see example: [UsingDateTimeControl](https://github.com/minixxie/wpp-qt/raw/master/examples/UsingDateTimeControl)

## UseCase: Load Phone Contact
To load phone contact, this library already support both Android and iOS.
```c++
#include <wpp/qt/AddressBookReader.h>
void SomeClass::someFunc()
{
	wpp::qt::AddressBookReader& addressBookReader = wpp::qt::AddressBookReader::getInstance();
	addressBookReader.asyncFetchAll(this, SLOT(onAddressBookLoaded(QList<QObject*>)));
}
void SomeClass::onAddressBookLoaded(QList<QObject*> contacts)
{
	for ( QObject *obj : contacts )
	{
		wpp::qt::AddressBookContact *contact = dynamic_cast<wpp::qt::AddressBookContact *>(obj);
		qDebug() << "first name: " << contact->getFirstName();
		qDebug() << "last name: " << contact->getLastName();
		qDebug() << "latin full name: " << contact->getLatinFullName();
		qDebug() << "full name: " << contact->getFullName();
		for ( QObject *phoneObj : contact->getPhones() )
		{
			wpp::qt::AddressBookContactPhone *phone = dynamic_cast<wpp::qt::AddressBookContactPhone *>(phoneObj);
			qDebug() << "phone label: " << phone->getLabel();
			qDebug() << "phone number: " << phone->getPhone();
		}
		for ( QObject *emailObj : contact->getEmails() )
		{
			wpp::qt::AddressBookContactEmail *email = dynamic_cast<wpp::qt::AddressBookContactEmail *>(emailObj);
			qDebug() << "email label: " << email->getLabel();
			qDebug() << "email address: " << email->getEmail();
		}
	}
}
```
## UseCase: Use SQLite in an easier way
This library provide a very easy way to use sqlite to persist your data. LocalStorage class will create the sqlite db file named "LocalStorage.db" under a suitable writable folder. The SQLite DB was initialized with a "DataMap" table for storing key-value records. As "key" is unique in the table, records with same "key" will be overwritten.
```c++
#include <wpp/qt/LocalStorage.h>
void someFunction()
{
	LocalStorage& localStorage = LocalStorage::getInstance(); //get singleton

	//persist data
	QString userId = ....;
	localStorage.setData("userId", userId);

	//retrieve data
	QString userId = localStorage.getData("userId");

}
```
Since it is just a key-value storage, you have to serialize/de-serialize the data yourself. For example, you can make use of QJsonObject/QJsonDocument to do this, and save the json string.
## UseCase: keep your cookies consistent across all HTTP requests
Qt provides QCookieJar for user to implement how to save the cookies and put the cookies to subsequent HTTP requests. In this library, the class CookieJar is for persisting the HTTP cookies into SQLite thru the class LocalStorage.
```c++
#include <wpp/qt/CookieJar.h>

QNetworkAccessManager *manager = new QNetworkAccessManager(this);
manager->setCookieJar(new wpp::qt::CookieJar);
connect(manager, SIGNAL(finished(QNetworkReply*)),
this, SLOT(replyFinished(QNetworkReply*)));

manager->get(QNetworkRequest(QUrl("http://qt-project.org")));
```
## UseCase: setting unread badge count (app icon)
Supported platforms: Android, iOS

In C++, e.g.:
```c++
#include <wpp/qt/System.h>

	wpp::qt::QGuiApplication app(argc, argv);
	app.registerApplePushNotificationService(); //necessary for iOS, this function does nothing on other platforms

	int count = 7;
	wpp::qt::System::getInstance().setAppIconUnreadCount(count);
```
In QML, e.g.:
```QML
	onClicked: {
		var count = 7;
		wpp.setAppIconUnreadCount(count);
    }
```
see example: [UsingBadgeUnreadCount](https://github.com/minixxie/wpp-qt/raw/master/examples/UsingBadgeUnreadCount)

## UseCase: send SMS using the phone SMS app ##
QML:
```QML
import wpp.qt.SMS 2.0

	SMS {
		id: sms
		onSent: {
			console.log("SMS finished: sent");
		}
		onFailed: {
			console.log("SMS finished: failed");
		}
		onCancelled: {
			console.log("pressed cancel");
		}
	}
	....
	MouseArea {
		onClicked: {
			sms.phones = ["+852XXXXXXXX", "+86138XXXXXXXX"];
			sms.msg = "Thanks for register, your code: 1234";
			sms.open();
		}
	}
```
android/AndroidManifest.xml:
```XML
	<uses-permission android:name="android.permission.SEND_SMS" />
```
see example: [SendSMS](https://github.com/minixxie/wpp-qt/raw/master/examples/SendSMS)

## UseCase: dial phone ##
QML:
```QML
	onClicked: {
		wpp.dial("+86138XXXXXXXX");
		//wpp.dial("+86138XXXXXXXX", true); means dial directly
	}
```
Or C++:
```C++
#include <wpp/qt/Wpp.h>

	wpp::qt::Wpp::getInstance().dial("+86138XXXXXXXX");
```
android/AndroidManifest.xml:
```XML
	<uses-permission android:name="android.permission.CALL_PHONE" />
```
see example: [DialPhone](https://github.com/minixxie/wpp-qt/raw/master/examples/DialPhone)

## UseCase: Vibrate deivice ##
```QML
	onClicked: {
		wpp.vibrate(1000);//for 1 second
	}
```
Or C++
```C++
#include <wpp/qt/Wpp.h>

	wpp::qt::Wpp::getInstance().vibrate(1000);
```
android/AndroidManifest.xml:
```XML
	<uses-permission android:name="android.permission.VIBRATE" />
```
Since Apple doesn't allow control on the length of vibration, the milliseconds parameter of the function will be ignored on iOS platform.

see example: [VibrateDevice](https://github.com/minixxie/wpp-qt/raw/master/examples/VibrateDevice)

## UseCase: using constants ##
Create constants.json in any location (e.g. in root folder of the project):
```JSON
{
	"host": "www.myhost.com"
}
```
By using class "Constants", we can load it into our program and use those constants:
```C++
#include <wpp/qt/Constants.h>

int main()
{
    QQGuiApplication app(argc, argv);

	wpp::qt::Constants::load(":/constants.json"); //meaning qrc:/constants.json

    QQmlApplicationEngine engine;
	engine.rootContext()->setContextProperty("constants", wpp::qt::Constants::getInstance() );
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

	return app.exec();
}
```
Remember to add constants.json into the QRC file:
```XML
<RCC>
	<qresource prefix="/">
	...
	<file>constants.json</file>
	</qresource>
</RCC>
```
Then the constants can be used anywhere in the QML:
```QML
Image {
        source: constants.host + "/img/happy.png";
}
```

## LICENSE

        Copyright 2015 Simon, Tse Chi Ming

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

            http://www.apache.org/licenses/LICENSE-2.0

        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.

## Acknowledgement
Deep thanks to these engineers, they have given me much help and contributed their code into my repository:
- [xiangxi](https://github.com/xiangxi)
- [diablogatox](https://github.com/diablogatox)
- [hongtoushizi](https://github.com/hongtoushizi)

## Contact "Us"
Currently I'm the only author of this project. You may contact me directly via github, or sending issues, or via these QQ groups:
- 345043587 Qt手机app开发Android
- 19346666 Qt5 for Android,iOS
