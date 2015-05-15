#ifndef __WPP__QT__KEYBOARD_H__
#define __WPP__QT__KEYBOARD_H__

#include <QObject>
#include <QRect>
#include <QGuiApplication>

namespace wpp
{
namespace qt
{

class Keyboard: public QObject
{
	Q_OBJECT
	Q_PROPERTY(QRect keyboardRectangle READ getKeyboardRectangle NOTIFY keyboardRectangleChanged)

private:
	QGuiApplication *app;
	QRect keyboardRectangle;

public:
	Keyboard(QGuiApplication *app, QObject *parent = 0)
		: QObject(parent), app(app)
	{
	}

	Q_INVOKABLE const QRect getKeyboardRectangle();

signals:
	void keyboardRectangleChanged();

public slots:

};

}//namespace qt
}//namespace wpp

#endif
