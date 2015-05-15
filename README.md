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

