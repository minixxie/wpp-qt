#include "Keyboard.h"

#include <QDebug>

#ifdef Q_OS_ANDROID
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#include <QtAndroid>
#endif
#include <QScreen>
#include <QWindow>


namespace wpp
{
namespace qt
{
const QRect Keyboard::getKeyboardRectangle()
{
	qDebug() << __FUNCTION__;

	int menuheight = 0;
#ifdef Q_OS_ANDROID
	/*Rect r = new Rect();
	Window window = ACTIVITY.getWindow();
	View rootview = window.getDecorView();
	rootview.getWindowVisibleDisplayFrame(r);*/

	//menuheight = (int)QAndroidJniObject::callStaticMethod<jint>("org.qtproject.example.Demo2.JavaInterface", "getHeight");
#endif

	QScreen *screen = app->screens()[0];
	//screen.setOrientationUpdateMask(0);
	QRect geom = screen->availableGeometry();

	QWindow *window = app->allWindows()[0];
	QRect rect = window->geometry();
	qDebug() << "screen gemo:" << geom;
	qDebug() << "window gemo:" << rect;

qDebug() << "screen->availableVirtualGeometry():" << screen->availableVirtualGeometry();
qDebug() << "screen->virtualGeometry():" << screen->virtualGeometry();
qDebug() << "screen->geometry():" << screen->geometry();

	//qDebug() << "available:" << widget->availableGeometry();
	//qDebug() << "screen:" << widget->screenGeometry();
	//QRect rect = widget.availableGeometry();
	//QRect geom = widget.screenGeometry();
	rect.moveTop(rect.top() + menuheight);
	geom.setTop(geom.top() + menuheight);

	this->keyboardRectangle = QRect();
	if (rect != geom)
	{
		int ftop, fleft, fwidth, fheight;
		geom.getRect(&fleft, &ftop, &fwidth, &fheight);
		if (rect.top() != ftop)
		fheight = rect.top();
		else if (rect.left() != fleft)
		fwidth = rect.left();
		else if (rect.height() != fheight)
		ftop = rect.height();
		else if (rect.width() != fwidth)
		fleft = rect.width();
		this->keyboardRectangle = QRect(fleft, ftop, fwidth - fleft, fheight - ftop);
	}
	return this->keyboardRectangle;
}

}//namespace qt
}//namespace wpp
