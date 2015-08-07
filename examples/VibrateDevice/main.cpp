#include <wpp/qt/QGuiApplication.h>
#include <wpp/qt/QQmlApplicationEngine.h>

int main(int argc, char *argv[])
{
	wpp::qt::QGuiApplication app(argc, argv);

	wpp::qt::QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
