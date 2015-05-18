#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <wpp/qt/Application.h>
#include <wpp/qt/QmlApplicationEngine.h>

#include <QQmlContext>

int main(int argc, char *argv[])
{
	wpp::qt::Application app(argc, argv);

	wpp::qt::QmlApplicationEngine engine(app);

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
