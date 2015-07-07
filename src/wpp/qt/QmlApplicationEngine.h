#ifndef __WPP__QT__QML_APPLICATION_ENGINE__H__
#define __WPP__QT__QML_APPLICATION_ENGINE__H__

#include <QQmlApplicationEngine>
#include "Application.h"
#include "Resolution.h"
#include <QQmlContext>
#include <wpp/qt/Wpp.h>

namespace wpp {
namespace qt {
class Application;
class QmlApplicationEngine : public QQmlApplicationEngine
{
	Q_OBJECT
private:
	Application *app;
public:
	QmlApplicationEngine(QObject *parent=0)
		: QQmlApplicationEngine(parent), app(0)
	{
		this->addImportPath("qrc:/identified-modules");
	}
	QmlApplicationEngine(Application *app, QObject *parent=0)
		: QQmlApplicationEngine(parent), app(app)
	{
		this->addImportPath("qrc:/identified-modules");

		this->rootContext()->setContextProperty("wpp", new wpp::qt::Wpp(app));

		//backward compatibility
		wpp::qt::Resolution *reso = new wpp::qt::Resolution( app, 320 );//create resolution info
		this->rootContext()->setContextProperty("reso", reso);//inject into the QML context
	}
};

}
}


#endif
