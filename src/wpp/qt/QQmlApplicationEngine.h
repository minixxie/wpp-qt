#ifndef __WPP__QT__QML_APPLICATION_ENGINE__H__
#define __WPP__QT__QML_APPLICATION_ENGINE__H__

#include <QQmlApplicationEngine>
#include "QGuiApplication.h"
#include "Resolution.h"
#include <QQmlContext>
#include <wpp/qt/Wpp.h>

namespace wpp {
namespace qt {
class QQmlApplicationEngine : public ::QQmlApplicationEngine
{
	Q_OBJECT
public:
	QQmlApplicationEngine(QObject *parent=0)
		: ::QQmlApplicationEngine(parent)
	{
		this->addImportPath("qrc:/identified-modules");
		this->rootContext()->setContextProperty("wpp", &wpp::qt::Wpp::getInstance());
	}
};

}
}


#endif
