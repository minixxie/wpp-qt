#ifndef QT_APP_BASE_SYSTEM_H
#define QT_APP_BASE_SYSTEM_H

#include <QObject>
#include <QVariant>
#include <QNetworkConfigurationManager>
#include <QLocale>
#include <QDebug>
#include <QTimeZone>

namespace wpp
{
namespace qt
{

class System: public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool m_isDesktop READ isDesktop)
	Q_PROPERTY(bool m_isAndroid READ isAndroid)
	Q_PROPERTY(bool m_isIOS READ isIOS)
	Q_PROPERTY(bool m_isQtDebug READ isQtDebug)
	Q_PROPERTY(QVariant m_network READ getNetwork WRITE setNetwork NOTIFY networkChanged)
	Q_PROPERTY(bool hasNetwork READ getHasNetwork WRITE setHasNetwork NOTIFY hasNetworkChanged)
	Q_PROPERTY(bool slowNetwork READ isSlowNetwork WRITE setIsSlowNetwork NOTIFY isSlowNetworkChanged)
	Q_PROPERTY(QString deviceId READ getDeviceId NOTIFY deviceIdChanged)

private:
	bool m_isDesktop;
	bool m_isAndroid;
	bool m_isIOS;
	bool m_isQtDebug;
	QVariant m_network;
	bool hasNetwork;
	bool slowNetwork;
	QString deviceId;
	QNetworkConfigurationManager networkConfigurationManager;

private:
	static System *singleton;

	void initDeviceId();

	System();

public:
	bool __IMPLEMENTATION_DETAIL_ENABLE_AUTO_ROTATE;

	static System &getInstance();

	Q_INVOKABLE int getIOSVersion();
/*
	static System *getInstance()
	{
		if ( singleton == 0 )
		{
			singleton = new System();
		}
		return singleton;
	}*/


	Q_INVOKABLE const QString getDownloadPath() const;

	Q_INVOKABLE bool isDesktop() { return m_isDesktop; }
	Q_INVOKABLE bool isAndroid() { return m_isAndroid; }
	Q_INVOKABLE bool isIOS() { return m_isIOS; }
	Q_INVOKABLE bool isQtDebug() {
#ifdef QT_DEBUG
		m_isQtDebug = true;
#else
		m_isQtDebug = false;
#endif
		return m_isQtDebug;
	}

	Q_INVOKABLE QVariant getNetwork() const { return m_network; }
	Q_INVOKABLE void setNetwork( const QVariant& network ) { m_network = network; emit networkChanged(); }

	Q_INVOKABLE bool getHasNetwork() const { return hasNetwork; }
	Q_INVOKABLE void setHasNetwork( bool hasNetwork ) { this->hasNetwork = hasNetwork; emit hasNetworkChanged(); }

	Q_INVOKABLE bool isSlowNetwork() const { return slowNetwork; }
	Q_INVOKABLE void setIsSlowNetwork( bool slowNetwork ) { this->slowNetwork = slowNetwork; emit isSlowNetworkChanged(); }

	Q_INVOKABLE QString getDeviceId() const { return deviceId; }

	enum SoftInputMode { ADJUST_NOTHING, ADJUST_UNSPECIFIED, ADJUST_RESIZE, ADJUST_PAN };
	Q_INVOKABLE void setSoftInputMode(SoftInputMode softInputMode);
	Q_INVOKABLE void setSoftInputModeAdjustNothing() { setSoftInputMode(ADJUST_NOTHING); }
	Q_INVOKABLE void setSoftInputModeAdjustUnspecified() { setSoftInputMode(ADJUST_UNSPECIFIED); }
	Q_INVOKABLE void setSoftInputModeAdjustResize() { setSoftInputMode(ADJUST_RESIZE); }
	Q_INVOKABLE void setSoftInputModeAdjustPan() { setSoftInputMode(ADJUST_PAN); }

	/*
	 * This function call requires permission (on android):
	 * <uses-permission android:name="android.permission.WRITE_SETTINGS" />
	 */
	Q_INVOKABLE void enableAutoScreenOrientation(bool enable = true);

	Q_INVOKABLE void downloadURL(const QString& url);

	/*Q_INVOKABLE QString saveQMLImage(QObject *qmlImage, //id of Image instance
								  const QString& fileBaseName, //e.g. "abc.jpg"
								  const QString& albumName, //e.g. "My Photos"
								  QString albumParentPath = QString() //e.g. "/mnt/sdcard"
	);*/

	//e.g. sys.determineGalleryPath("My Photos")
	Q_INVOKABLE QString createAlbumPath(const QString& albumName);
	Q_INVOKABLE void addToImageGallery(const QString& imageFullPath);

	Q_INVOKABLE void registerApplePushNotificationService();

	Q_INVOKABLE void test();

	//Q_INVOKABLE QDateTime makeDateTime(const QString& ianaId, qint64 msecsSinceEpoch);
	//Q_INVOKABLE QDateTime currentDateTime(const QString& ianaId);
	Q_INVOKABLE QString formatDateTime(qint64 msecsSinceEpoch, const QString& format, const QString& ianaId = QTimeZone::systemTimeZoneId());

	//Q_INVOKABLE static QTimeZone createTimeZone(const QString& ianaId = QTimeZone::systemTimeZoneId());

	//Q_INVOKABLE static QByteArray getSystemTimezoneId();
	//Q_INVOKABLE static QTimeZone getSystemTimezone()
	//{
	//	return QTimeZone(getSystemTimezoneId()); //createTimeZone(getSystemTimezoneId());
	//}
	Q_INVOKABLE QString timezoneAbbreviation(qint64 msecsSinceEpoch, const QString& ianaId = QTimeZone::systemTimeZoneId());
	Q_INVOKABLE QString timezoneShortName(qint64 msecsSinceEpoch, const QString& ianaId = QTimeZone::systemTimeZoneId());
	Q_INVOKABLE QString timezoneLongName(qint64 msecsSinceEpoch, const QString& ianaId = QTimeZone::systemTimeZoneId(), const QLocale& locale = QLocale());


signals:
	void networkChanged();
	void hasNetworkChanged();
	void isSlowNetworkChanged();
	void deviceIdChanged();

public slots:
	Q_INVOKABLE void onNetworkOnlineStateChanged(bool isOnline);
	Q_INVOKABLE void onNetworkConfigurationChanged(QNetworkConfiguration networkConfig);
	Q_INVOKABLE void onNetworkConfigurationUpdateCompleted();

};

}//namespace qt
}//namespace wpp

#endif
