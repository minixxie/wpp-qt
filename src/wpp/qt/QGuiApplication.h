#ifndef __WPP__QT__QGuiApplication_H__
#define __WPP__QT__QGuiApplication_H__

#include <QGuiApplication>
#include "Wpp.h"

namespace wpp {
namespace qt {

class QGuiApplication : public ::QGuiApplication
{
	Q_OBJECT
private:
	bool m_keyboardWasAnimating;

public:
#ifdef Q_QDOC
	QGuiApplication(int &argc, char **argv);
#else
	QGuiApplication(int &argc, char **argv, int = ApplicationFlags);
#endif
	virtual ~QGuiApplication();

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
