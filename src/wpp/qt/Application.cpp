#include "Application.h"

#include <QTranslator>
#include <QScreen>
#include <QQuickWindow>

//#if defined(Q_OS_MAC) || defined(Q_OS_WIN) || defined(Q_OS_LINUX)
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
#include <QtWebEngine>
#endif
#ifdef Q_OS_ANDROID
	#include <QtAndroid>
#endif

#include <wpp/qt/IOS.h>

#include <wpp/qt/Wpp.h>
//#include <wpp/qt/LocalStorage.h>
#include <wpp/qt/HttpAgent.h>
#include <wpp/qt/Resolution.h>

#include <wpp/qt/NativeCamera.h>
#include <wpp/qt/ImagePicker.h>
#include <wpp/qt/NativeMap.h>
#include <wpp/qt/NativeDateTimePicker.h>
#include <wpp/qt/IOSTimeZonePicker.h>
#include <wpp/qt/SMS.h>


namespace wpp {
namespace qt {

Application::~Application() {}

#ifdef Q_QDOC
Application::Application(int &argc, char **argv)
	: QGuiApplication(argc, argv), m_keyboardWasAnimating(false)
{
	init();
}
#else
Application::Application(int &argc, char **argv, int flags)
	: QGuiApplication(argc, argv, flags), m_keyboardWasAnimating(false)
{
	init();
}
#endif

void Application::init()
{
#ifdef Q_OS_IOS
	wpp::qt::IOS::documentsDirectoryExcludeICloudBackup();
#endif

	//register singletons
	//wpp::qt::LocalStorage::getInstance();
	wpp::qt::Wpp::getInstance();
	//wpp::qt::HttpAgent& httpAgent = wpp::qt::HttpAgent::getInstance();
	//httpAgent.setDefaultParam("_locale", QLocale::system().name());

	//register QML types
	qmlRegisterType<wpp::qt::NativeCamera>("wpp.qt.NativeCamera", 1, 0, "NativeCamera");
	qmlRegisterType<wpp::qt::ImagePicker>("wpp.qt.ImagePicker", 1, 0, "ImagePicker");
	qmlRegisterType<wpp::qt::NativeMap>("wpp.qt.NativeMap", 1, 0, "NativeMap");
	qmlRegisterType<wpp::qt::NativeDateTimePicker>("wpp.qt.NativeDateTimePicker", 1, 0, "NativeDateTimePicker");
	qmlRegisterType<wpp::qt::IOSTimeZonePicker>("wpp.qt.IOSTimeZonePicker", 1, 0, "IOSTimeZonePicker");
	qmlRegisterType<wpp::qt::SMS>("wpp.qt.SMS", 1, 0, "SMS");

	qmlRegisterType<wpp::qt::NativeCamera>("wpp.qt.NativeCamera", 2, 0, "NativeCamera");
	qmlRegisterType<wpp::qt::ImagePicker>("wpp.qt.ImagePicker", 2, 0, "ImagePicker");
	qmlRegisterType<wpp::qt::NativeMap>("wpp.qt.NativeMap", 2, 0, "NativeMap");
	qmlRegisterType<wpp::qt::NativeDateTimePicker>("wpp.qt.NativeDateTimePicker", 2, 0, "NativeDateTimePicker");
	qmlRegisterType<wpp::qt::IOSTimeZonePicker>("wpp.qt.IOSTimeZonePicker", 2, 0, "IOSTimeZonePicker");
	qmlRegisterType<wpp::qt::SMS>("wpp.qt.SMS", 2, 0, "SMS");

	enableAutoScreenOrientation(true);

//#ifdef Q_OS_IOS
	//qDebug() << __FUNCTION__ << ":connect inputMethod visible changed";
	//QInputMethod *inputMethod = this->inputMethod();
	//connect(inputMethod, SIGNAL(visibleChanged()), this, SLOT(onInputMethodVisibleChanged()), Qt::QueuedConnection);

	//connect(inputMethod, SIGNAL(animatingChanged()), this, SLOT(onFocusWindowYChanged()) );
	//QWindow *focusWindow = QGuiApplication::focusWindow();
	//connect(focusWindow, SIGNAL(yChanged()), this, SLOT(onFocusWindowYChanged()) );




//#endif
//#ifdef Q_OS_ANDROID
//	wpp::qt::Wpp::getInstance().setSoftInputMode(Wpp::ADJUST_RESIZE);
//#endif
}

void Application::onFocusWindowYChanged()
{
	QWindow *focusWindow = QGuiApplication::focusWindow();
	//qDebug() << __FUNCTION__ << ":focusWindow.y=" << focusWindow->y();

	QInputMethod *inputMethod = this->inputMethod();
	qDebug() << __FUNCTION__ << ":animating=" << inputMethod->isAnimating() << ":focusWindow.y=" << focusWindow->y();
	qDebug() << __FUNCTION__ << ":focusWindow.frameGeometry=" << focusWindow->frameGeometry();
}

void Application::onInputMethodVisibleChanged()
{	
#if defined(Q_OS_IOS) || defined(Q_OS_ANDROID)
	QInputMethod *inputMethod = this->inputMethod();
	qDebug() << __FUNCTION__ << ":inputMethod visible:" << inputMethod->isVisible();
	qDebug() << __FUNCTION__ << ":inputMethod animating:" << inputMethod->isAnimating();

	QScreen *screen = QGuiApplication::primaryScreen();
	QWindow *window = QGuiApplication::focusWindow();
	connect(window, &QWindow::yChanged, [=]() {
		qDebug() << "window->yChanged: y=" << window->y();
	});

	QQuickWindow *quickWindow = qobject_cast<QQuickWindow*>(window);
	QQuickItem *contentItem = quickWindow->contentItem();
	qDebug() << __FUNCTION__ << ":contentItem.coord=" << contentItem->x() << "," << contentItem->y();
	connect(contentItem, &QQuickItem::yChanged, [=]() {
		qDebug() << "contentItem->yChanged: y=" << contentItem->y();
	});


	if ( inputMethod->isVisible() )
	{
		if ( window != 0 )
		{
			qDebug() << "window coord:" << window->x() << "," << window->y();
			qDebug() << "window geometry:" << window->geometry();
			qDebug() << "window frame geometry:" << window->frameGeometry();
			/*if ( !inputMethod->isAnimating() && !m_keyboardWasAnimating )//keyboard about to show
			{
				qDebug() << __FUNCTION__ << ":keyboard about to show";
				return;
			}
			else if ( inputMethod->isAnimating() )//keyboard sliding up
			{
				qDebug() << __FUNCTION__ << ":keyboard sliding up";
				m_keyboardWasAnimating = true;
			}
			else if ( !inputMethod->isAnimating() && m_keyboardWasAnimating )//keyboard slide up completed
			{
				qDebug() << __FUNCTION__ << ":keyboard slide up completed";
			*/
#ifdef Q_OS_IOS
				QRectF kbRect = inputMethod->keyboardRectangle();
#endif
#ifdef Q_OS_ANDROID
				/*
				Rect r = new Rect();
				View rootview = this.getWindow().getDecorView(); // this = activity
				rootview.getWindowVisibleDisplayFrame(r);
				*/
				QAndroidJniObject visibleFrameRect("android/graphics/Rect","()V");
				qDebug() << __FUNCTION__ << "visibleFrameRect.isValid()=" << visibleFrameRect.isValid();

				QAndroidJniObject activity = QtAndroid::androidActivity();
				qDebug() << __FUNCTION__ << "activity.isValid()=" << activity.isValid();

				QAndroidJniObject androidWindow = activity.callObjectMethod(
							"getWindow","()Landroid/view/Window;");
				qDebug() << __FUNCTION__ << "androidWindow.isValid()=" << androidWindow.isValid();

				QAndroidJniObject rootview = androidWindow.callObjectMethod(
							"getDecorView","()Landroid/view/View;");
				qDebug() << __FUNCTION__ << "rootview.isValid()=" << rootview.isValid();

				//rootview.callMethod<void>("getWindowVisibleDisplayFrame","(Landroid/graphics/Rect;)V",visibleFrameRect.object<jobject>());
				rootview.callMethod<jboolean>("getLocalVisibleRect","(Landroid/graphics/Rect;)Z",visibleFrameRect.object<jobject>());
				qDebug() << __FUNCTION__ << "rootview.isValid()=" << rootview.isValid();
				qDebug() << __FUNCTION__ << "visibleFrameRect.isValid()=" << visibleFrameRect.isValid();

				jint visibleFrameTop = visibleFrameRect.getField<jint>("top");
				qDebug() << __FUNCTION__ << "visibleFrameRect.visibleFrameTop=" << visibleFrameTop;
				jint visibleFrameLeft = visibleFrameRect.getField<jint>("left");
				qDebug() << __FUNCTION__ << "visibleFrameRect.visibleFrameLeft=" << visibleFrameLeft;
				jint visibleFrameWidth = visibleFrameRect.callMethod<jint>("width","()I");
				qDebug() << __FUNCTION__ << "visibleFrameRect.width()=" << visibleFrameWidth;
				jint visibleFrameHeight = visibleFrameRect.callMethod<jint>("height","()I");
				qDebug() << __FUNCTION__ << "visibleFrameRect.height()=" << visibleFrameHeight;

				int keyboardHeight = 0;
				if ( screen != 0 )
				{
					qDebug() << __FUNCTION__ << "screen.height()=" << screen->size().height();
					keyboardHeight = screen->size().height() - visibleFrameHeight;
					qDebug() << __FUNCTION__ << "keyboardHeight=" << keyboardHeight;
				}
				QRectF kbRect(0, visibleFrameHeight, visibleFrameWidth, keyboardHeight);//assume keyboard from bottom side
#endif
				qDebug() << __FUNCTION__ << "kbRect=" << kbRect;

				if ( window->height() == screen->size().height() )
				{
					qDebug() << __FUNCTION__ << ":origSize=" << window->size();

					Q_ASSERT( kbRect.width() == (qreal)window->width() );//assume keyboard appears from bottom side of app window

					window->setHeight( window->height() - kbRect.height() );
					qDebug() << __FUNCTION__ << ":resize-ok-to:" << window->size();
				}

#ifdef Q_OS_IOS
				window->setY(window->y() + kbRect.height());
#endif
				wpp::qt::Wpp::getInstance().setStatusBarVisible(true);
				m_keyboardWasAnimating = false;
			//}
		}//if ( window != 0 )

	}
	else//visible == false
	{
		if ( window != 0 )
		{
			/*if ( !inputMethod->isAnimating() && !m_keyboardWasAnimating )//keyboard about to hide
			{
				qDebug() << __FUNCTION__ << ":keyboard about to hide";
				return;
			}
			else if ( inputMethod->isAnimating() )//keyboard sliding down
			{
				qDebug() << __FUNCTION__ << ":keyboard sliding down";
				m_keyboardWasAnimating = true;
			}
			else if ( !inputMethod->isAnimating() && m_keyboardWasAnimating )//keyboard slide down completed
			{
				qDebug() << __FUNCTION__ << ":keyboard slide down completed";
				*/
				if ( screen != 0 )
				{
					window->resize( screen->size() );
					qDebug() << __FUNCTION__ << ":resize-ok-to:" << screen->size();
				}
			//}
#ifdef Q_OS_IOS
				window->setY(0);
#endif

		}
	}
#endif
#ifdef Q_OS_ANDROID

#endif
}


void Application::loadTranslations(const QString& qmFilenameNoExtension)
{
	QTranslator *translator = new QTranslator(this);
	QString transFilename( QString(":/%1.").arg(qmFilenameNoExtension) + QLocale::system().name() );
	//QString transFilename( QString(":/i18n.en_US") );
	if ( !translator->load( transFilename ) )
	{
		qDebug() << "[ERR] " << __FUNCTION__ << ": Load translation error! filename:" << transFilename;
	}
	else
	{
		qDebug() << "[OK] " << __FUNCTION__ << ": Translations loaded successfully: " << transFilename;
	}
	this->installTranslator(translator);
}

void Application::enableQtWebEngineIfPossible()
{
//#ifdef Q_OS_MAC | Q_OS_WIN | Q_OS_LINUX
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
	QtWebEngine::initialize();
#endif
}

void Application::registerApplePushNotificationService()
{
	wpp::qt::Wpp::getInstance().registerApplePushNotificationService();
}

}
}

