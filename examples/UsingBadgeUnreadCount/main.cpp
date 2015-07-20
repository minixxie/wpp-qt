#include <wpp/qt/Application.h>
#include <wpp/qt/QmlApplicationEngine.h>

int main(int argc, char *argv[])
{
	wpp::qt::Application app(argc, argv);

	app.registerApplePushNotificationService();

	//https://bugreports.qt.io/browse/QTBUG-44867

	wpp::qt::QmlApplicationEngine engine;
	//QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
