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
	Q_PROPERTY(qint64 msecSinceEpoch READ msecSinceEpoch WRITE setMsecSinceEpoch NOTIFY msecSinceEpochChanged)
	Q_PROPERTY(QString timeZoneId READ timeZoneId WRITE setTimeZoneId NOTIFY timeZoneIdChanged)

private:
	qint64 m_msecSinceEpoch;
	QString m_timeZoneId;

public:
	explicit NativeDateTimePicker(QQuickItem *parent = 0);

	qint64 msecSinceEpoch() const { return m_msecSinceEpoch; }
	void setMsecSinceEpoch( qint64 msecSinceEpoch )
	{ if ( this->m_msecSinceEpoch == msecSinceEpoch ) return; this->m_msecSinceEpoch = msecSinceEpoch; emit msecSinceEpochChanged(); }

	const QString& timeZoneId() const { return m_timeZoneId; }
	void setTimeZoneId( const QString& timeZoneId )
	{ if ( this->m_timeZoneId == timeZoneId ) return; this->m_timeZoneId = timeZoneId; emit timeZoneIdChanged(); }

signals:
	void msecSinceEpochChanged();
	void timeZoneIdChanged();
	void picked(qint64 msecSinceEpoch);

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
	Q_SLOT void onTimeZoneIdChanged();
};

}
}

#endif
