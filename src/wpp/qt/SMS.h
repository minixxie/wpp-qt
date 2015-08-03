#ifndef __WPP__QT__SMS_H__
#define __WPP__QT__SMS_H__

#include <QQuickItem>
#ifdef Q_OS_ANDROID
	#include <QAndroidActivityResultReceiver>
#endif


namespace wpp {
namespace qt {

#ifdef Q_OS_ANDROID
class SMS : public QQuickItem, QAndroidActivityResultReceiver
#else
class SMS : public QQuickItem
#endif
{
	Q_OBJECT
	Q_PROPERTY(QStringList phones READ phones WRITE setPhones NOTIFY phonesChanged)
	Q_PROPERTY(QString msg READ msg WRITE setMsg NOTIFY msgChanged)

private:
	QStringList m_phones;
	QString m_msg;

public:
	explicit SMS(QQuickItem *parent = 0);

	Q_INVOKABLE const QStringList& phones() const { return m_phones; }
	Q_INVOKABLE void setPhones(const QStringList& phones) { if ( m_phones == phones ) return; m_phones = phones; emit phonesChanged(); }
	Q_SIGNAL void phonesChanged();

	Q_INVOKABLE const QString& msg() const { return m_msg; }
	Q_INVOKABLE void setMsg(const QString& msg) { if ( m_msg == msg ) return; m_msg = msg; emit msgChanged(); }
	Q_SIGNAL void msgChanged();

	Q_INVOKABLE void open();
	Q_SIGNAL void cancelled();
	Q_SIGNAL void sent();
	Q_SIGNAL void failed();

private:
	void *m_delegate;
#ifdef Q_OS_ANDROID
	//QAndroidJniObject takePhotoSavedUri;
	void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data);
#endif
};

}
}

#endif
