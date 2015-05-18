#ifndef __WPP__QT__QML_APPLICATION_ENGINE__H__
#define __WPP__QT__QML_APPLICATION_ENGINE__H__

#include <QQmlApplicationEngine>
#include "Application.h"
#include "Resolution.h"
#include <QQmlContext>

namespace wpp {
namespace qt {

class QmlApplicationEngine : public QQmlApplicationEngine
{
	Q_OBJECT
public:
	QmlApplicationEngine(wpp::qt::Application &app)
	{
		this->addImportPath("qrc:/identified-modules");

		wpp::qt::Resolution *reso = new wpp::qt::Resolution( &app, 320 );//create resolution info
		this->rootContext()->setContextProperty("reso", reso);//inject into the QML context

	}
};

}
}


#endif
