# wpp-qt
Web++ framework for Qt

## Introduction

This is a framework supplementary to Qt for mobile, for creating mobile apps for iOS and Android. More platforms support will be added later, currently this library only support iOS and Android.

## Preparation
You will usually use this project as a git-submodule of your project. Setup with this:
```
cd YourQtProject
git submodule add https://github.com/minixxie/wpp-qt.git
```
Once you've cloned this project, make sure to download sub-modules dependencies((a) [B-Sides/ELCImagePickerController](https://github.com/B-Sides/ELCImagePickerController), (b) [skywinder/ActionSheetPicker-3.0](https://github.com/skywinder/ActionSheetPicker-3.0)):
```
cd wpp-qt
git submodule init
git submodule update
```
Then, remember to include the project file in YourProject.pro:
```
## import library project "wpp"
include($$PWD/wpp-qt/wpp.pri)
```


## To Begin
To use this library, the first requirement is to substitute QGuiApplication with wpp::qt::Application:
```c++
#include <wpp/qt/Application.h>
int main(int argc, char *argv[])
{
        wpp::qt::Application app(argc, argv);
        ...
```
The Application class actually inherits from [QGuiApplication](http://doc.qt.io/qt-5/qguiapplication.html) and it registers some wpp library things in addition.

## UseCase: density independent pixel
All QML elements only support pixel values for x, y, width, height and all size and dimension related properties. With the following code in main(), we can use dp in QML:
```c++
#include <wpp/qt/Application.h>
#include <wpp/qt/Resolution.h>
int main(int argc, char *argv[])
{
    wpp::qt::Application app(argc, argv);
    QQmlApplicationEngine engine;

    wpp::qt::Resolution reso( &app, 320 );//create resolution info
    engine.rootContext()->setContextProperty("reso", &reso);//inject into the QML context

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
```
Then "reso" variable can be used in QML like this:
```QML
Rectange {
    anchors.fill: parent
    anchors.margins: 10*reso.dp2px //dp2px means changing 10 from "dp" to "px" as all QML properties only accept pixels
}
```
## UseCase: TimeAgo
TimeAgo is a class for generating human readable date/time. For example, it shows "2 hours ago", "15 mins ago", etc. To use it, inject the singleton of this class in main():
```c++
#include <wpp/qt/TimeAgo.h>
int main(int argc, char *argv[])
{
    wpp::qt::Application app(argc, argv);
    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("timeago", &&wpp::qt::TimeAgo::getInstance());//inject into the QML context

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
```
Usage in QML:
```QML
Text {
    text: timeago.getTimeAgo(unixTimestamp)
}
```
## UseCase: rounded image
We usually need to use rounded corner on images, Qt doesn't support it by default. With this library you can do this. But the current version has a limitation that the image should not lie on a boundary of two differnt colors or other background images:
```QML
Avatar {                                        
    id: profilePhoto                                
    anchors.left: parent.left                       
    anchors.top: parent.top          
    anchors.margins: 10*reso.dp2px            
    height: 40*reso.dp2px                           
    width: height
    circleMask: false  //this is the main property to make circle
    maskColor: "#ffffff" //assume the background is white, write this to make sure 4 round corners are in white background
    url: "http://xxxxxx/abc.jpg"
    onClicked: {                                    
        ....                    
    }                                               
}   
```

## UseCase: use native camera or image picker to upload profile photo
This is a common use case, which often show a empty photo for clicking to set the profile photo of a user. With this library, you can do this:
```QML
    SelectPhotoSourceModal {
        id: selectPhotoSourceModal
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
    height: 50*reso.dp2px                           
    width: height    
    bgText: qsTr("Upload Image")
    bgTextColor: "#0080ff"
    //url: "http://xxxxxx/abc.jpg"
    onClicked: {                                    
        selectPhotoSourceModal.visible=true;
    }                                               
}
```
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
Screenshot on iOS:
![DateTimeControl(ios)](https://github.com/minixxie/wpp-qt/raw/master/doc/screenshot-DateTimeControl-ios.jpg)
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
## UseCase: Use SQLite in easier way
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

## Contact "Us"
Currently I'm the only author of this project. You may contact me directly via github, or sending issues, or via 2 QQ groups:
- 345043587 Qt手机app开发Android
- 19346666 Qt5 for Android,iOS


