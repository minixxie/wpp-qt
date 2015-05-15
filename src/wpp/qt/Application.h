#ifndef __WPP__QT__APPLICATION_H__
#define __WPP__QT__APPLICATION_H__

#include <QGuiApplication>

namespace wpp {
namespace qt {

class Application : public QGuiApplication
{
public:
#ifdef Q_QDOC
	Application(int &argc, char **argv);
#else
	Application(int &argc, char **argv, int = ApplicationFlags);
#endif

	void loadTranslations(const QString& qmFilenameNoExtension);
	void enableQtWebEngineIfPossible();
	void registerApplePushNotificationService();

private://helpers
	void init();
};

}
}
#endif
