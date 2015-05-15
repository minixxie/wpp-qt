#include "GeoPosition.h"

#include "Route.h"
#include "HttpAgent.h"
#include <QJsonDocument>
#include <QJsonObject>

namespace wpp
{
namespace qt
{

//#ifndef Q_OS_IOS
//GeoPosition(QObject *parent = 0)
//	: QObject(parent), geoSource(0),
//	  receiver(0), method(0), m_delegate(0)
//{
//	qDebug() << "GeoPosition()...";
//}
//#endif

#ifndef Q_OS_IOS //ios implementation in GeoPosition.mm
void GeoPosition::requestAuthorization()
{
}
#endif

void GeoPosition::checkCountry(const QString& apiKey)
{
	// http://api.map.baidu.com/location/ip?ak=<key>&coor=bd09ll
	wpp::qt::Route route("", "GET", "api.map.baidu.com", "/location/ip");
	QMap<QString, QVariant> reqParams;
	reqParams["ak"] = apiKey;
	reqParams["coor"] = "bd09ll";

	wpp::qt::HttpAgent &httpAgent = wpp::qt::HttpAgent::getInstance();
	httpAgent.async(this,SLOT(onResponseCheckCountry(QNetworkReply*,const QMap<QString, QVariant>&, const QMap<QString, QVariant>&)),
			"GET",
			route, reqParams);

}

void GeoPosition::onResponseCheckCountry(QNetworkReply* reply, const QMap<QString, QVariant>& reqParams, const QMap<QString, QVariant>& args)
{
	qDebug() << __FUNCTION__;
	if ( wpp::qt::HttpAgent::replyHasError(__FUNCTION__, reply) )
		return;

	QByteArray responseBody = reply->readAll();

	QJsonObject json( QJsonDocument::fromJson(responseBody).object() );
	/*
{
  "address": "HK|香港|香港|None|None|0|0",
  "content": {
	"address": "香港特别行政区",
	"address_detail": {
	  "city": "香港特别行政区",
	  "city_code": 2912,
	  "district": "",
	  "province": "香港特别行政区",
	  "street": "",
	  "street_number": ""
	},
	"point": {
	  "x": "114.xxxxxx",
	  "y": "22.xxxxx"
	}
  },
  "status": 0
}
	 */

	if ( json["status"].toInt() == 0 )
	{
		QString address = json["address"].toString();
		QStringList addressSplits = address.split("|");
		QString countryCode = addressSplits.first();//CN, HK, ...

		qDebug() << "countryCode=" << countryCode;
		setCountryCode(countryCode);
	}
}

}
}
