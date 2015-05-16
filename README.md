# wpp-qt
Web++ framework for Qt

## Introduction

This is a framework supplementary to Qt for mobile, for creating mobile apps for iOS and Android. More platforms support will be added later, currently this library only support iOS and Android.

## Preparation
once you've cloned this project, make sure to download sub-modules:
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

