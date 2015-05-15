#ifndef __WPP__QT__NATIVE_DATE_TIME_PICKER_H__
#define __WPP__QT__NATIVE_DATE_TIME_PICKER_H__

#include <QQuickItem>
#ifdef Q_OS_ANDROID
	#include <QAndroidActivityResultReceiver>
#endif
#include <QDateTime>

namespace wpp {
namespace qt {

#ifdef Q_OS_ANDROID
class NativeDateTimePicker : public QQuickItem, QAndroidActivityResultReceiver
#else
class NativeDateTimePicker : public QQuickItem
#endif
{
    Q_OBJECT
	Q_PROPERTY(QDateTime dateTime READ dateTime WRITE setDateTime NOTIFY dateTimeChanged)
	Q_PROPERTY(QString timezoneId READ timezoneId WRITE setTimezoneId NOTIFY timezoneIdChanged)

private:
	QDateTime m_dateTime;
	QString m_timezoneId;

public:
	explicit NativeDateTimePicker(QQuickItem *parent = 0);

	const QDateTime& dateTime() const { return m_dateTime; }
	void setDateTime( const QDateTime& dateTime ) { this->m_dateTime = dateTime; emit dateTimeChanged(); }

	const QString& timezoneId() const { return m_timezoneId; }
	void setTimezoneId( const QString& timezoneId ) { this->m_timezoneId = timezoneId; emit timezoneIdChanged(); }

signals:
	void dateTimeChanged();
	void timezoneIdChanged();
	void picked(const QDateTime& dateTime);

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
