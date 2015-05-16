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
Once you've cloned this project, make sure to download sub-modules dependencies:
```
cd wpp-qt
git submodule init
git submodule update
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
## Contact "Us"
Currently I'm the only author of this project. You may contact me directly via github, or sending issues, or via 2 QQ groups:
- 345043587 Qt手机app开发Android
- 19346666 Qt5 for Android,iOS

