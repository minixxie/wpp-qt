#ifndef __WPP__QT__IOS_TIME_ZONE_PICKER_H__
#define __WPP__QT__IOS_TIME_ZONE_PICKER_H__

#include <QQuickItem>
#ifdef Q_OS_ANDROID
	#include <QAndroidActivityResultReceiver>
#endif
#include <QTimeZone>

namespace wpp {
namespace qt {

#ifdef Q_OS_ANDROID
class IOSTimeZonePicker : public QQuickItem, QAndroidActivityResultReceiver
#else
class IOSTimeZonePicker : public QQuickItem
#endif
{
    Q_OBJECT
	Q_PROPERTY(QString timezoneId READ timezoneId WRITE setTimezoneId NOTIFY timezoneIdChanged)

private:
	QString m_timezoneId;

public:
	explicit IOSTimeZonePicker(QQuickItem *parent = 0);

	const QString& timezoneId() const { return m_timezoneId; }
	void setTimezoneId( const QString& timezoneId ) { this->m_timezoneId = timezoneId; emit timezoneIdChanged(); }

signals:
	void timezoneIdChanged();
	void picked(const QString& timezoneId);

public slots:
	void open();

private:
#ifdef Q_OS_IOS
    void *m_delegate;
#endif
#ifdef Q_OS_ANDROID
	//QAndroidJniObject takePhotoSavedUri;
	void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data);
#endif
};

}
}

#endif
