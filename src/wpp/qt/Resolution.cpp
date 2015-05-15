#include "Resolution.h"

#include <QDebug>
#include <QScreen>
#include <cmath>

namespace wpp
{
namespace qt
{

/*
Resolution::Resolution( QWindow *window, int horizontalDips )
	: window(window), app(0), horizontalDips( horizontalDips ), screenWidth(0), screenHeight(0),
	  isLandscape(false), isPortrait(true), dp2px(0), px2dp(0), diagonalLength(0)
{
	//onWindowWidthChanged( window->width() );
	if ( window->width() > window->height() )
	{
		screenWidth = horizontalDips * 480/320;//window->width();
		screenHeight = screenWidth*(320/480);
	}
	else
	{
		screenWidth = horizontalDips;//window->width();
		screenHeight = screenWidth*(480/320);
	}

	Q_ASSERT_X(screenWidth != 0, "Resolution()", "zero screenWidth");

	dp2px = (double)screenWidth/(double)horizontalDips;
	px2dp = (double)horizontalDips/(double)screenWidth;

	qDebug() << "horizontalDips = " << horizontalDips;
	qDebug() << "screenWidth = " << screenWidth;
	qDebug() << "dp2px = " << dp2px;
	qDebug() << "px2dp = " << px2dp;

	connect(window,SIGNAL(widthChanged(int)),this,SLOT(onWindowWidthChanged(int)));
	connect(window,SIGNAL(heightChanged(int)),this,SLOT(onWindowHeightChanged(int)));

	initScreenSize();
}*/

Resolution::Resolution( QGuiApplication *app, int horizontalDips )
	: window(0), app(app), horizontalDips( horizontalDips ), screenWidth(0), screenHeight(0),
	  isLandscape(false), isPortrait(true), dp2px(0), px2dp(0), diagonalLength(0)
{

	//onWindowWidthChanged( window->width() );
	screenWidth = horizontalDips;//window->width();
	screenHeight = screenWidth*(480/320);

	Q_ASSERT_X(screenWidth != 0, "Resolution()", "zero screenWidth");

	onWindowGeometryChanged(screenWidth, screenHeight);


	/*dp2px = (double)screenWidth/(double)horizontalDips;
	px2dp = (double)horizontalDips/(double)screenWidth;

	qDebug() << "horizontalDips = " << horizontalDips;
	qDebug() << "screenWidth = " << screenWidth;
	qDebug() << "dp2px = " << dp2px;
	qDebug() << "px2dp = " << px2dp;*/

	//connect(app,SIGNAL(focusWindowChanged(QWindow*)),this,SLOT(onFocusWindowChanged(QWindow*)));

	//QScreen *screen = app->screens()[0];
	//connect(screen,SIGNAL(orientationChanged(Qt::ScreenOrientation)), this, SLOT(onOrientationChanged(Qt::ScreenOrientation)));

	QWindowList windowList = app->allWindows();
	qDebug() << "windowList count=" << windowList.count();
	if ( windowList.count() > 0 )
	{
		window = windowList[0];
		connect(window,SIGNAL(widthChanged(int)),this,SLOT(onWindowWidthChanged(int)));
		connect(window,SIGNAL(heightChanged(int)),this,SLOT(onWindowHeightChanged(int)));
	}

	initScreenSize();
}

void Resolution::initScreenSize()
{
	QScreen *screen = app->screens()[0];
	const QSizeF screenPhysicalSize = screen->physicalSize();
	this->diagonalLength = sqrt( screenPhysicalSize.width()*screenPhysicalSize.width() +
								 screenPhysicalSize.height()*screenPhysicalSize.height()
							);
	qDebug() << "diagonalLength:" << diagonalLength;
	emit diagonalLengthChanged();
	//177.8mm = 7 inch

	double dpi = screen->physicalDotsPerInch();
	qDebug() << "dpi:" << screen->physicalDotsPerInch();

	//http://developer.android.com/guide/practices/screens_support.html
	if ( dpi >= 640 )
		dpiLevel = "xxxhdpi";
	else if ( dpi >= 480 )
		dpiLevel = "xxhdpi";
	else if ( dpi >= 320 )
		dpiLevel = "xhdpi";
	else if ( dpi >= 240 )
		dpiLevel = "hdpi";
	else if ( dpi >= 160 )
		dpiLevel = "mdpi";
	else if ( dpi >= 120 )
		dpiLevel = "ldpi";
	else
		dpiLevel = "ldpi";
	emit dpiLevelChanged();

	qDebug() << "dpiLevel:" << dpiLevel;
}

void Resolution::onOrientationChanged(Qt::ScreenOrientation orientation)
{
	/*
	if ( orientation == Qt::PortraitOrientation )
	{

	}
	else if ( orientation == Qt::InvertedPortraitOrientation )
	{

	}
	if ( orientation == Qt::LandscapeOrientation )
	{

	}
	else if ( orientation == Qt::InvertedLandscapeOrientation )
	{

	}*/
}

void Resolution::onFocusWindowChanged(QWindow *focusedWindow)
{/*
	qDebug() << "onFocusWindowChanged...";
	if ( window != 0 )
	{
		disconnect(window,SIGNAL(widthChanged(int)),this,SLOT(onWindowWidthChanged(int)));
		disconnect(window,SIGNAL(heightChanged(int)),this,SLOT(onWindowHeightChanged(int)));
		window = 0;
	}
	if ( focusedWindow != 0 )
	{
		window = focusedWindow;
		screenWidth = window->width();
		screenHeight = window->height();
		onWindowGeometryChanged(screenWidth, screenHeight);
		qDebug() << "hello...";
		connect(window,SIGNAL(widthChanged(int)),this,SLOT(onWindowWidthChanged(int)));
		connect(window,SIGNAL(heightChanged(int)),this,SLOT(onWindowHeightChanged(int)));
	}*/
}

void Resolution::onWindowGeometryChanged(int newWidth, int newHeight)
{
	QScreen *screen = app->screens()[0];
#if defined(Q_OS_IOS) || defined(Q_OS_ANDROID)
	if ( screen->orientation() == Qt::LandscapeOrientation || screen->orientation() == Qt::InvertedLandscapeOrientation )
#else
	if( newWidth >= newHeight )
#endif
	{
		qDebug() << "landscape...";
		dp2px = (double)newHeight/(double)horizontalDips;
		px2dp = (double)horizontalDips/(double)newHeight;
		qDebug() << "dp2px=" << dp2px << ",px2dp=" << px2dp;
	}
	else
	{
		qDebug() << "portrait...";
		dp2px = (double)newWidth/(double)horizontalDips;
		px2dp = (double)horizontalDips/(double)newWidth;
		qDebug() << "dp2px=" << dp2px << ",px2dp=" << px2dp;
	}

	emit dp2pxChanged();
	emit px2dpChanged();
	emit isLandscapeChanged();
	emit isPortraitChanged();
}


void Resolution::onWindowWidthChanged(int newWidth)
{
	screenWidth = newWidth;
	qDebug() << "new screenWidth:" << screenWidth;
	onWindowGeometryChanged(screenWidth, screenHeight);
}

void Resolution::onWindowHeightChanged(int newHeight)
{
	screenHeight = newHeight;
	qDebug() << "new screenHeight:" << screenHeight;
	onWindowGeometryChanged(screenWidth, screenHeight);
}

bool Resolution::getIsLandscape() const
{
	QScreen *screen = app->screens()[0];
	return ( screen->orientation() == Qt::LandscapeOrientation || screen->orientation() == Qt::InvertedLandscapeOrientation );
}


}//namespace qt
}//namespace wpp
