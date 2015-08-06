#ifndef __WPP__QT__APPLICATION_H__
#define __WPP__QT__APPLICATION_H__

#include <QGuiApplication>
#include "Wpp.h"

namespace wpp {
namespace qt {

class Application : public QGuiApplication
{
	Q_OBJECT
private:
	bool m_keyboardWasAnimating;

public:
#ifdef Q_QDOC
	Application(int &argc, char **argv);
#else
	Application(int &argc, char **argv, int = ApplicationFlags);
#endif
	virtual ~Application();

	void loadTranslations(const QString& qmFilenameNoExtension);
	void enableQtWebEngineIfPossible();
	void registerApplePushNotificationService();

	void enableAutoScreenOrientation(bool autoRotate)
	{
		wpp::qt::Wpp::getInstance().enableAutoScreenOrientation(true);
	}


private://helpers
	void init();

private:
	Q_SLOT void onFocusWindowYChanged();
	Q_SLOT void onInputMethodVisibleChanged();

};

}
}
#endif
