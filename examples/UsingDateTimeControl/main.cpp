#include <wpp/qt/Application.h>
#include <wpp/qt/QmlApplicationEngine.h>

int main(int argc, char *argv[])
{
	wpp::qt::Application app(argc, argv);

	wpp::qt::QmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
