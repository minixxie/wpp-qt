#include "QuickView.h"
#include "Resolution.h"
#include "System.h"
#include "Wpp.h"

#include <QGuiApplication>
#include <QScreen>
#include <QQmlEngine>
#include <math.h>
#include <QDebug>
#include <QQmlContext>

namespace wpp {
namespace qt {


void QuickView::init()
{
	this->engine()->addImportPath("qrc:/identified-modules");

	setResizeMode(QQuickView::SizeRootObjectToView);
	if ( app != 0 )
	{
		connect(this->engine(), SIGNAL(quit()), app, SLOT(quit()));
	}

	this->setBaseSize(QSize(320,480));

	bool tablet = false;
#if defined(Q_OS_IOS) || defined(Q_OS_ANDROID)
	QScreen *screen = app->screens()[0];
	const QSizeF screenPhysicalSize = screen->physicalSize();
	qreal diagonalLength = sqrt( screenPhysicalSize.width()*screenPhysicalSize.width() +
								 screenPhysicalSize.height()*screenPhysicalSize.height()
							);
	if ( diagonalLength >= 177.8 )//177.8mm = 7 inch
	{
		qDebug() << "bigger than 7 inch screen!";
		tablet = true;
//		viewer.setBaseSize(QSize(640,480));
//		tablet = false;
		//viewer.setSource(QUrl("qrc:///qml/ui/main.qml"));
		this->setBaseSize(QSize(768,1024));
	}
	else
	{
		qDebug() << "smaller than 7 inch screen!";
		tablet = false;
		//viewer.setSource(QUrl("qrc:///qml/ui/main.qml"));
		this->setBaseSize(QSize(320,480));
	}
#else
	tablet = false;
	this->setBaseSize(QSize(320,480));
#endif

	wpp::qt::Resolution *reso = new wpp::qt::Resolution( app, tablet ? 1024 : 320 );//create resolution info
	this->engine()->rootContext()->setContextProperty("reso", reso);//inject into the QML context
	this->engine()->rootContext()->setContextProperty("sys", &wpp::qt::System::getInstance());
	this->engine()->rootContext()->setContextProperty("timeago", &wpp::qt::TimeAgo::getInstance());

	this->engine()->rootContext()->setContextProperty("wpp", new wpp::qt::Wpp() );

}

void QuickView::show()
{
#ifdef Q_OS_IOS
	QScreen *screen = app->screens()[0];
	const QRect availableGeometry = screen->availableGeometry();
	this->showNormal();
	this->setHeight(availableGeometry.height() + 20);
#else
	QQuickView::show();
#endif
}

}
}
