#include <wpp/qt/QGuiApplication.h>
#include <wpp/qt/QQmlApplicationEngine.h>

int main(int argc, char *argv[])
{
	wpp::qt::QGuiApplication app(argc, argv);

	app.registerApplePushNotificationService();

	//https://bugreports.qt.io/browse/QTBUG-44867

	wpp::qt::QQmlApplicationEngine engine;
	//QQmlApplicationEngine engine;
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
