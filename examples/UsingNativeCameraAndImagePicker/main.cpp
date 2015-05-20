#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <wpp/qt/Application.h>
#include <wpp/qt/QuickView.h>

int main(int argc, char *argv[])
{
	wpp::qt::Application app(argc, argv);

	wpp::qt::QuickView view(&app);
	view.setSource(QUrl(QStringLiteral("qrc:/main.qml")));
	view.show();

    return app.exec();
}
