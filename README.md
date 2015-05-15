# wpp-qt
Web++ framework for Qt

## Introduction

This is a framework supplementary to Qt for mobile, for creating mobile apps for iOS and Android. More platforms support will be added later, currently this library only support iOS and Android.

To use this library, the first requirement is to substitue QGuiApplication with wpp::qt::Application:
```c++
#include <wpp/qt/Application.h>
int main()
{
        wpp::qt::Application app(argc, argv);
        ...
```
Application class actually inherits from QGuiApplication and it registers some wpp library things in addition.

