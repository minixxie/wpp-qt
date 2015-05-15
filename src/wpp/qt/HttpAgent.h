#ifndef QT_APP_BASE_HTTP_AGENT_H
#define QT_APP_BASE_HTTP_AGENT_H

#include "CookieJar.h"

#include <QObject>
#include <QNetworkReply>
#include <QList>
#include <QVariant>

namespace wpp
{
namespace qt
{

class Route;//forward declaration

class HttpAgent : public QObject
{
	Q_OBJECT
private:
	static HttpAgent *singleton;

	CookieJar *cookieJar;
	//QNetworkAccessManager * mgr;
	QMap<QString, QVariant> defaultParams;
	QString defaultHost;
	QString defaultProtocol;

	bool isCacheEnabled;
	unsigned long maxCacheSize;

	HttpAgent(LocalStorage *localStorage);
	HttpAgent( const HttpAgent& ) : QObject() {}//prevent from copying
public:
	~HttpAgent();
	static HttpAgent &getInstance(LocalStorage *localStorage = 0);

	void setDefaultParam(const QString& key, const QVariant& value)
	{
		defaultParams[key] = value;
	}
	void setDefaultHost(const QString& host) { defaultHost = host; }
	void setDefaultProtocol(const QString& protocol) { defaultProtocol = protocol; }

	void enableCache(bool enabled) { isCacheEnabled = enabled; }

	unsigned long getMaxCacheSize() const { return this->maxCacheSize; }
	void setMaxCacheSize(unsigned long maxCacheSize) { this->maxCacheSize = maxCacheSize; }

	bool sendRequest(
		const QString& getOrPost,
		const QString& url,
		const QMap<QString, QVariant>& reqParams, //e.g. a=1&b=2
		const QMap<QString, QString>& filePaths,
		const QMap<QString, QString>& headers,
		const QObject * receiver, const char * method, //func(QNetworkReply* reply, const QList<QObject *>& args)
		const QMap<QString, QVariant>& extraArgsToSlot = QMap<QString, QVariant>(),
		const QObject * downloadProgressReceiver = 0, const char * downloadProgressMethod = 0
	);
	/*
	 * @param route use public constants from class RouteMap, e.g. RouteMap._User_signin
	 */
	bool async(const QObject * receiver, const char * method, //func(QNetworkReply* reply, const QList<QObject *>& args)
		const QString& httpMethod, const Route& route, const QMap<QString, QVariant>& params = QMap<QString, QVariant>(),
		const QMap<QString, QString>& filePaths = QMap<QString, QString>(),
		const QMap<QString, QVariant>& argsToSlot = QMap<QString, QVariant>(),
		const QObject * downloadProgressReceiver = 0, const char * downloadProgressMethod = 0
	);

	static bool replyHasError(const QString& funcName, QNetworkReply *reply);

public slots:
	void onResponse(QNetworkReply *reply);
	void debugResponse(QNetworkReply *reply);
	//void disconnectLater(const QObject *receiver, const char * method);
};

}//namespace qt
}//namespace wpp

#endif
