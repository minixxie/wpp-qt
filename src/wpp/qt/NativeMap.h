#ifndef WPP__QT__NATIVE_MAP_H
#define WPP__QT__NATIVE_MAP_H

#include <QQuickItem>

#ifdef Q_OS_ANDROID
#include <QAndroidActivityResultReceiver>
#endif


namespace wpp {
namespace qt {

class NativeMap : public QQuickItem
#ifdef Q_OS_ANDROID
	, QAndroidActivityResultReceiver
#endif
{
	Q_OBJECT
	Q_PROPERTY(QString location READ getLocation WRITE setLocation NOTIFY locationChanged)
	Q_PROPERTY(double longitude READ getLongitude WRITE setLongitude NOTIFY longitudeChanged)
	Q_PROPERTY(double latitude READ getLatitude WRITE setLatitude NOTIFY latitudeChanged)
	Q_PROPERTY(int zoom READ getZoom WRITE setZoom NOTIFY zoomChanged)

private:
	QString location;
	double longitude;
	double latitude;
	int zoom;
//	void *m_delegate;

#ifdef Q_OS_ANDROID
	virtual void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data);
#endif

public:
	explicit NativeMap(QQuickItem *parent = 0)
		: QQuickItem(parent), location(""), longitude(0), latitude(0)
	{ }

	const QString& getLocation() const { return this->location; }
	void setLocation(const QString& location) { this->location = location; emit this->locationChanged(); }

	double getLongitude() const { return this->longitude; }
	void setLongitude(double longitude) { this->longitude = longitude; emit this->longitudeChanged(); }

	double getLatitude() const { return this->latitude; }
	void setLatitude(double latitude) { this->latitude = latitude; emit this->latitudeChanged(); }

	int getZoom() const { return this->zoom; }
	void setZoom(int zoom) { this->zoom = zoom; emit this->zoomChanged(); }

signals:
	void locationChanged();
	void longitudeChanged();
	void latitudeChanged();
	void zoomChanged();
	void locationSelected(double longitude, double latitude, const QString& location);

public slots:
	void open();
	QMap<QString,QString> i18n();

};

}
}

#endif
