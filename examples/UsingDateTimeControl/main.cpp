#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <wpp/qt/Application.h>
#include <wpp/qt/QmlApplicationEngine.h>
#include <wpp/qt/QuickView.h>

#include <QQmlContext>

int main(int argc, char *argv[])
{
	wpp::qt::Application app(argc, argv);

	//wpp::qt::QmlApplicationEngine engine(app);
	//engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

	wpp::qt::QuickView view(&app);
	view.setSource(QUrl(QStringLiteral("qrc:/main.qml")));
	view.show();

    return app.exec();
}
