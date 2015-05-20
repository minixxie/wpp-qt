#ifndef __WPP__QT__QUICK_VIEW_H__
#define __WPP__QT__QUICK_VIEW_H__

#include <QQuickView>
#include <QGuiApplication>

namespace wpp {
namespace qt {

class QuickView : public QQuickView
{
protected:
	QGuiApplication *app;

public:
	explicit QuickView(QGuiApplication *app, QWindow *parent = 0)
		: QQuickView(parent), app(app)
	{
		init();
	}

	QuickView(QGuiApplication *app, QQmlEngine* engine, QWindow *parent)
		: QQuickView(engine, parent), app(app)
	{
		init();
	}

	QuickView(QGuiApplication *app, const QUrl &source, QWindow *parent = 0)
		: QQuickView(source, parent), app(app)
	{
		init();
	}

	virtual ~QuickView()
	{

	}
	void show();

private:
	void init(); //helper

};

}
}

#endif
