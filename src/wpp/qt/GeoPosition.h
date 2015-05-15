#ifndef QT_APP_BASE__GEO_POSITION_H
#define QT_APP_BASE__GEO_POSITION_H

#include <QGeoPositionInfo>
#include <QGeoPositionInfoSource>
#include <QDebug>
//#include <QGeoCoordinate>
#include <QNetworkReply>

namespace wpp
{
namespace qt
{

class GeoPosition: public QObject
{
    Q_OBJECT
	Q_PROPERTY(QGeoPositionInfo geoPositionInfo READ getGeoPositionInfo WRITE setGeoPositionInfo NOTIFY geoPositionInfoChanged)
	Q_PROPERTY(double longitude READ getLongitude NOTIFY longitudeChanged)
	Q_PROPERTY(double latitude READ getLatitude NOTIFY latitudeChanged)
	Q_PROPERTY(double altitude READ getAltitude NOTIFY altitudeChanged)
	Q_PROPERTY(QString countryCode READ getCountryCode WRITE setCountryCode NOTIFY countryCodeChanged)
	Q_PROPERTY(int supportedMethodCount READ getSupportedMethodCount NOTIFY supportedMethodCountChanged)

private:
	QGeoPositionInfoSource *geoSource;
	QGeoPositionInfo geoPositionInfo;
	double longitude;
	double latitude;
	double altitude;
	QString countryCode;
	int supportedMethodCount;

	const QObject *receiver;
	const char *method;

//	void *m_delegate;	//object c 调用
	void requestAuthorization();
public:
//	GeoPosition(QObject *parent = 0);	//object c 调用
	GeoPosition(QObject *parent = 0)
		: QObject(parent), geoSource(0),
		  longitude(0), latitude(0), altitude(0),
		  supportedMethodCount(0),
		  receiver(0), method(0)
	{
		qDebug() << "GeoPosition()...";
	}

	Q_INVOKABLE void checkCountry(const QString& apiKey);

	Q_INVOKABLE void enable(const QObject * receiver = 0, const char * method = 0)
	{
		requestAuthorization();

		QStringList sourceList = QGeoPositionInfoSource::availableSources();
		qDebug() << "Position sources list:" << sourceList;

		if ( sourceList.length() == 0 )
			return;

		geoSource = QGeoPositionInfoSource::createDefaultSource(this);
		geoSource->setPreferredPositioningMethods(QGeoPositionInfoSource::AllPositioningMethods);

		QGeoPositionInfoSource::PositioningMethods methods = geoSource->supportedPositioningMethods();
		qDebug() << "methods:" << methods;
		this->supportedMethodCount = 0;
		if ( methods & QGeoPositionInfoSource::NonSatellitePositioningMethods )
		{
			qDebug() << "support: non-satellite";
			this->supportedMethodCount++;
//			geoSource->setPreferredPositioningMethods(QGeoPositionInfoSource::NonSatellitePositioningMethods);
		}
		if ( methods & QGeoPositionInfoSource::SatellitePositioningMethods )
		{
			qDebug() << "support: satellite";
			this->supportedMethodCount++;
//			geoSource->setPreferredPositioningMethods(QGeoPositionInfoSource::SatellitePositioningMethods);
		}
		emit this->supportedMethodCountChanged();

		if (geoSource) {

			connect(geoSource, SIGNAL(positionUpdated(QGeoPositionInfo)),
					this, SLOT(positionUpdated(QGeoPositionInfo)));
			if ( receiver != 0 && method != 0 )
			{
				this->receiver = receiver;
				this->method = method;
				connect(geoSource, SIGNAL(positionUpdated(QGeoPositionInfo)),
						receiver, method);
			}
			//geoSource->setUpdateInterval(1000*60*10);
			geoSource->startUpdates();
		}
		else
		{
			qDebug() << "GeoTest():source NULL!";
		}
	}
	Q_INVOKABLE void disable()
	{
		if ( geoSource == 0 )
			return;

		disconnect(geoSource, SIGNAL(positionUpdated(QGeoPositionInfo)),
				this, SLOT(positionUpdated(QGeoPositionInfo)));
		if ( this->receiver != 0 && this->method != 0 )
		{

			disconnect(geoSource, SIGNAL(positionUpdated(QGeoPositionInfo)),
					this->receiver, this->method);
			this->receiver = 0;
			this->method = 0;
		}

		geoSource->stopUpdates();
		//delete geoSource;
		geoSource->deleteLater();

		geoSource = 0;

	}

	Q_INVOKABLE bool isEnabled()
	{
		return geoSource != 0;
	}

	Q_INVOKABLE double getLongitude() const { return this->longitude; }
	Q_INVOKABLE double getLatitude() const { return this->latitude; }
	Q_INVOKABLE double getAltitude() const { return this->altitude; }

	Q_INVOKABLE int getSupportedMethodCount() const { return this->supportedMethodCount; }

	Q_INVOKABLE const QGeoPositionInfo& getGeoPositionInfo() const { return geoPositionInfo; }
	Q_INVOKABLE void setGeoPositionInfo(const QGeoPositionInfo& geoPositionInfo)
	{
		this->geoPositionInfo = geoPositionInfo;
		emit this->geoPositionInfoChanged();
		this->longitude = geoPositionInfo.coordinate().longitude();
		emit this->longitudeChanged();
		this->latitude = geoPositionInfo.coordinate().latitude();
		emit this->latitudeChanged();
		this->altitude = geoPositionInfo.coordinate().altitude();
		emit this->altitudeChanged();
	}

	Q_INVOKABLE const QString& getCountryCode() const { return countryCode; }
	Q_INVOKABLE void setCountryCode(const QString& countryCode)
	{
		this->countryCode = countryCode;
		emit this->countryCodeChanged();
	}

signals:
	void geoPositionInfoChanged();
	void longitudeChanged();
	void latitudeChanged();
	void altitudeChanged();
	void supportedMethodCountChanged();
	void countryCodeChanged();

private slots:
    void positionUpdated(const QGeoPositionInfo &info)
    {
        qDebug() << "Position updated:" << info;
		this->setGeoPositionInfo( info );
    }

	void onResponseCheckCountry(QNetworkReply* reply, const QMap<QString, QVariant>& reqParams, const QMap<QString, QVariant>& args);

};

}//namespace qt
}//namespace wpp

#endif
