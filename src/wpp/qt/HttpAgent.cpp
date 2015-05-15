#include "HttpAgent.h"
#include "LocalStorage.h"
#include "System.h"
#include "NetworkAccessManager.h"
#include "Route.h"

#include "CookieJar.h"

#include <QUrl>
#include <QUrlQuery>
#include <QNetworkReply>
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkCookie>
//#include <QNetworkAccessManager>
#include <QNetworkDiskCache>
#include <QStandardPaths>

#include <QSqlError>
#include <QSqlQuery>
#include <QMimeDatabase>
#include <QMimeType>
#include <QHttpMultiPart>
#include <QFile>
#include <QFileInfo>

namespace wpp
{
namespace qt
{

HttpAgent *HttpAgent::singleton = 0;

HttpAgent::HttpAgent(LocalStorage *localStorage)
	: cookieJar(0), defaultHost(), defaultProtocol("http"), isCacheEnabled(false), maxCacheSize(0)
{
	qDebug() << "HttpAgent()...";
	cookieJar = new CookieJar(*localStorage);

	defaultParams["_locale"] = "en_US";
	defaultParams["_format"] = "json";
}

HttpAgent::~HttpAgent()
{
	delete cookieJar ; cookieJar = 0;
}

HttpAgent &HttpAgent::getInstance(LocalStorage *localStorage)
{
	qDebug() << "HttpAgent::getInstance()...";
	if ( singleton == 0 )
	{
		static HttpAgent singletonInstance(localStorage);
		singleton = &singletonInstance;
	}
	return *singleton;
}

bool HttpAgent::sendRequest(
	const QString& getOrPost,
	const QString& url,
	const QMap<QString, QVariant>& reqParams, //e.g. a=1&b=2
	const QMap<QString, QString>& filePaths,
	const QMap<QString, QString>& headers,
	const QObject * receiver, const char * method,
	const QMap<QString, QVariant>& extraArgsToSlot,
	const QObject * downloadProgressReceiver, const char * downloadProgressMethod
)
{
	qDebug() << "Checking whether system has network...";
	/*if ( !System::getInstance().getHasNetwork() )
	{
		qDebug() << "System has NO network!";
		return false;
	}*/

	NetworkAccessManager *mgr = new NetworkAccessManager(this);
	if ( this->isCacheEnabled )
	{
		qDebug() << "HttpAgent::using diskCache at: " << QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
		QNetworkDiskCache *diskCache = new QNetworkDiskCache(this);
		diskCache->setCacheDirectory( QStandardPaths::writableLocation(QStandardPaths::CacheLocation) );
		if ( maxCacheSize > 0 )
		{
			diskCache->setMaximumCacheSize(maxCacheSize); //bytes
		}
		mgr->setCache(diskCache);
	}
	mgr->setCookieJar(this->cookieJar);
	this->cookieJar->setParent(0);//don't give ownership of cookieJar to mgr

	if ( filePaths.empty() )//not multipart
	{
		mgr->setReqParams(reqParams);
	}
	mgr->setArgs(extraArgsToSlot);
	/*for ( QList<QObject *>::const_iterator
		it = extraArgsToSlot.constBegin() ; it != extraArgsToSlot.constEnd() ; ++it )
	{
		QObject *argObj = *it;
		mgr->addArg(argObj);
	}*/

	connect(mgr,SIGNAL(finished(QNetworkReply*)),this,SLOT(onResponse(QNetworkReply*)));
	connect(mgr,SIGNAL(finished(QNetworkReply*)),this,SLOT(debugResponse(QNetworkReply*)));
	connect(mgr,SIGNAL(finished(QNetworkReply*)),mgr,SLOT(onResponse(QNetworkReply*)));
	connect(mgr,SIGNAL(responseReadyToDispatch(QNetworkReply*, const QMap<QString, QVariant>&, const QMap<QString, QVariant>&)),
		receiver,method);
	//connect(mgr,SIGNAL(finished(QNetworkReply*)),receiver,method);
	connect(mgr,SIGNAL(finished(QNetworkReply*)),mgr,SLOT(deleteLater()));


	QString params;
	if ( filePaths.empty() )//not multipart
	{
		QUrlQuery query;
		int paramCount = 0;
		QMapIterator<QString, QVariant> i(reqParams);
		while ( i.hasNext() )
		{
			i.next();

			QString value = QString( QUrl::toPercentEncoding( i.value().toString(), "", "+" ) );

			query.addQueryItem(i.key(), value);

			paramCount++;
		}
		params = query.query(QUrl::FullyEncoded);
	}

	QNetworkReply *networkReply = 0;
	if ( getOrPost.toUpper() == "POST" )
	{
		QUrl httpUrl( url );
		QNetworkRequest req(httpUrl);
		if ( System::getInstance().getHasNetwork() )
			req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
		else
			req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferNetwork);

		QMapIterator<QString, QString> it(headers);
		while ( it.hasNext() )
		{
			it.next();
			req.setRawHeader(QByteArray(it.key().toUtf8()), QByteArray(it.value().toUtf8()));
		}
		//req.setHeader(QNetworkRequest::CookieHeader, cookieVariants);

		int bytesTotal = 0;
		//header
		QList<QByteArray> rawHeaderList = req.rawHeaderList();
		for ( QList<QByteArray>::const_iterator headerIt = rawHeaderList.constBegin();
			  headerIt != rawHeaderList.constEnd(); ++headerIt )
		{
			bytesTotal += (*headerIt).size();
		}

		//content
		QByteArray httpParams = params.toUtf8();
qDebug() << "POST-params:" << httpParams;
		//record size
		bytesTotal += req.url().path().length();
		bytesTotal += httpParams.size();
		//LocalStorage::getInstance().addUpDownloadHistory( bytesTotal, false );

		if ( !filePaths.empty() )//multipart
		{
			QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

			QMapIterator<QString, QVariant> i(reqParams);
			while ( i.hasNext() )
			{
				i.next();

				QString value = QString( QUrl::toPercentEncoding( i.value().toString(), "", "+" ) );

				QHttpPart textPart;
				QString formDataDescription = QString("form-data; name=\"%1\"").arg( i.key() );
				textPart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(formDataDescription));
				textPart.setBody( value.toUtf8() );
				multiPart->append(textPart);
			}

			QMapIterator<QString, QString> fileIt(filePaths);
			while ( fileIt.hasNext() )
			{
				fileIt.next();

				QString fileVarName = fileIt.key();
				QString filePath = fileIt.value();
				QString fileName = QFileInfo(filePath).fileName();
qDebug() << "fileName:" << fileName;
				QMimeDatabase db;
				QMimeType mimeType = db.mimeTypeForFile(filePath);

				QHttpPart filePart;
				filePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant(mimeType.name() /*"image/jpeg"*/));
				QString formDataDescription = QString("form-data; name=\"%1\"; filename=\"%2\"").arg( fileVarName ).arg( fileName );
				filePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant(formDataDescription));
				QFile *file = new QFile(filePath);
				file->open(QIODevice::ReadOnly);
				filePart.setBodyDevice(file);
				file->setParent(multiPart);
				multiPart->append(filePart);
			}
			networkReply = mgr->post(req, multiPart);
			//qDebug() << *multiPart;
		}
		else
		{
			req.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("application/x-www-form-urlencoded; charset=UTF-8") );
			networkReply = mgr->post(req, httpParams);
		}
	}
	else//GET
	{
		QUrl httpUrl( url + "?" + params );
		QNetworkRequest req(httpUrl);
		if ( System::getInstance().getHasNetwork() )
			req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
		else
			req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferNetwork);

		QMapIterator<QString, QString> it(headers);
		while ( it.hasNext() )
		{
			it.next();
			req.setRawHeader(QByteArray(it.key().toUtf8()), QByteArray(it.value().toUtf8()));
		}
		//req.setHeader(QNetworkRequest::CookieHeader, cookieVariants);

		//QByteArray httpParams( params );

		int bytesTotal = 0;
		//header
		QList<QByteArray> rawHeaderList = req.rawHeaderList();
		for ( QList<QByteArray>::const_iterator headerIt = rawHeaderList.constBegin();
			  headerIt != rawHeaderList.constEnd(); ++headerIt )
		{
			bytesTotal += (*headerIt).size();
		}
		//content
		bytesTotal += req.url().path().length();

		//LocalStorage::getInstance().addUpDownloadHistory( bytesTotal, false );
		networkReply = mgr->get(req);
	}

	if ( networkReply != 0 && downloadProgressReceiver != 0 && downloadProgressMethod != 0 )
	{
		connect(networkReply,SIGNAL(downloadProgress(qint64,qint64)), downloadProgressReceiver, downloadProgressMethod);
	}

	return true;
}

void HttpAgent::onResponse(QNetworkReply *)
{
	//LocalStorage::getInstance().addUpDownloadHistory( reply->size(), true );
}

void HttpAgent::debugResponse(QNetworkReply *reply)
{
	//qDebug() << "HttpAgent::debugResponse()";

	if ( !reply )
	{
		qDebug() << "HTTP Response: null!!";
	}

	qDebug() << __FUNCTION__ << ":reply from cache?="
			 << reply->attribute(QNetworkRequest::SourceIsFromCacheAttribute).toBool()
			 << ":" << reply->url();

	QNetworkRequest req = reply->request();
	qDebug() << "HTTP Request: " << req.url();

	wpp::qt::System &system = wpp::qt::System::getInstance();

	if (reply->error() != QNetworkReply::NoError)
	{
		QNetworkReply::NetworkError error = reply->error();
		QString errStr("Unknown");
		switch ( error )
		{
		case QNetworkReply::ConnectionRefusedError:
			errStr = "the remote server refused the connection (the server is not accepting requests)";
		break;
		case QNetworkReply::RemoteHostClosedError:
			errStr = "the remote server closed the connection prematurely, before the entire reply was received and processed";
		break;
		case QNetworkReply::HostNotFoundError:
			errStr = "the remote host name was not found (invalid hostname)";
			system.setHasNetwork(false);
			qDebug() << "system.setHasNetwork(false)";
		break;
		case QNetworkReply::TimeoutError:
			errStr = "the connection to the remote server timed out";
		break;
		case QNetworkReply::OperationCanceledError:
			errStr = "the operation was canceled via calls to abort() or close() before it was finished.";
		break;
		case QNetworkReply::SslHandshakeFailedError:
			errStr = "the SSL/TLS handshake failed and the encrypted channel could not be established. The sslErrors() signal should have been emitted.";
		break;
		case QNetworkReply::TemporaryNetworkFailureError:
			errStr = "the connection was broken due to disconnection from the network, however the system has initiated roaming to another access point. The request should be resubmitted and will be processed as soon as the connection is re-established.";
		break;
		case QNetworkReply::NetworkSessionFailedError:
			errStr = "the connection was broken due to disconnection from the network or failure to start the network.";
		break;
		case QNetworkReply::BackgroundRequestNotAllowedError:
			errStr = "the background request is not currently allowed due to platform policy.";
		break;
		case QNetworkReply::ProxyConnectionRefusedError:
			errStr = "the connection to the proxy server was refused (the proxy server is not accepting requests)";
		break;
		case QNetworkReply::ProxyConnectionClosedError:
			errStr = "the proxy server closed the connection prematurely, before the entire reply was received and processed";
		break;
		case QNetworkReply::ProxyNotFoundError:
			errStr = "the proxy host name was not found (invalid proxy hostname)";
		break;
		case QNetworkReply::ProxyTimeoutError:
			errStr = "the connection to the proxy timed out or the proxy did not reply in time to the request sent";
		break;
		case QNetworkReply::ProxyAuthenticationRequiredError:
			errStr = "the proxy requires authentication in order to honour the request but did not accept any credentials offered (if any)";
		break;
		case QNetworkReply::ContentAccessDenied:
			errStr = "the access to the remote content was denied (similar to HTTP error 401)";
		break;
		case QNetworkReply::ContentOperationNotPermittedError:
			errStr = "the operation requested on the remote content is not permitted";
		break;
		case QNetworkReply::ContentNotFoundError:
			errStr = "the remote content was not found at the server (similar to HTTP error 404)";
		break;
		case QNetworkReply::AuthenticationRequiredError:
			errStr = "the remote server requires authentication to serve the content but the credentials provided were not accepted (if any)";
		break;
		case QNetworkReply::ContentReSendError:
			errStr = "the request needed to be sent again, but this failed for example because the upload data could not be read a second time.";
		break;
		case QNetworkReply::ProtocolUnknownError:
			errStr = "the Network Access API cannot honor the request because the protocol is not known";
		break;
		case QNetworkReply::ProtocolInvalidOperationError:
			errStr = "the requested operation is invalid for this protocol";
		break;
		case QNetworkReply::UnknownNetworkError:
			errStr = "an unknown network-related error was detected";
		break;
		case QNetworkReply::UnknownProxyError:
			errStr = "an unknown proxy-related error was detected";
		break;
		case QNetworkReply::UnknownContentError:
			errStr = "an unknown error related to the remote content was detected";
		break;
		case QNetworkReply::ProtocolFailure:
			errStr = "a breakdown in protocol was detected (parsing error, invalid or unexpected responses, etc.)";
		break;
		case QNetworkReply::ContentConflictError:
			errStr = "ContentConflictError";
		break;
		case QNetworkReply::ContentGoneError:
			errStr = "ContentGoneError";
		break;
		case QNetworkReply::InternalServerError:
			errStr = "InternalServerError";
		break;
		case QNetworkReply::OperationNotImplementedError:
			errStr = "OperationNotImplementedError";
		break;
		case QNetworkReply::ServiceUnavailableError:
			errStr = "ServiceUnavailableError";
		break;
		case QNetworkReply::UnknownServerError:
			errStr = "UnknownServerError";
		break;
		case QNetworkReply::NoError:
			//not possible to enter this
		break;
		}

		qDebug() << "[ERR] Http has error(" << reply->error() << "): " << errStr;
	}

//	QByteArray bts = reply->readAll();
	//QString str(bts);

	qDebug() << "HTTP Response: status (" << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute ).toString() << "):";

}

bool HttpAgent::replyHasError(const QString& funcName, QNetworkReply *reply)
{
	if (!reply)
	{
		qDebug() << funcName << ": empty reply";
		return true;
	}
	if (reply->error())
	{
		qDebug() << funcName << ": ERR:" << reply->error() << "... HTTP-status:"
					 << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute ).toString();
		return true;
	}
	return false;
}

bool HttpAgent::async(const QObject * receiver, const char * method,
	const QString& httpMethod, const Route& route, const QMap<QString, QVariant>& params,
	const QMap<QString, QString>& filePaths,
	const QMap<QString, QVariant>& argsToSlot,
	const QObject * downloadProgressReceiver, const char * downloadProgressMethod
)
{
	//在路由里取出url规则
	QString routePattern = route.pattern();
qDebug() << "Services::async():" << routePattern;

	//遍历所有"默认参数"（如：_format, _locale）, 做替换
	QMapIterator<QString, QVariant> defaultParamIterator(defaultParams);
	while ( defaultParamIterator.hasNext() )
	{
		defaultParamIterator.next();
		QString toReplace = QString("{") + defaultParamIterator.key() + QString("}");
		routePattern.replace( toReplace, defaultParamIterator.value().toString() );
qDebug() << "Services::async():replace("<< defaultParamIterator.key() << "," << defaultParamIterator.value() << "):" << routePattern;
	}
qDebug() << "Services::async():" << routePattern;


	//QString paramsString;
	QUrlQuery query;
	int paramCount = 0;
	QMapIterator<QString, QVariant> i(params);
	while ( i.hasNext() )
	{
		i.next();

		/*if ( paramCount > 0 )
		{
			paramsString += "&";
		}
		paramsString += i.key();
		paramsString += '=';
		paramsString += i.value();*/
		QString value = QString( QUrl::toPercentEncoding( i.value().toString(), "", "+" ) );

		query.addQueryItem(i.key(), value);

		//replace if found in urlPattern
		QString toReplace = QString("{") + i.key() + QString("}");
		routePattern.replace( toReplace, i.value().toString() );

		paramCount++;
	}

	/*QString paramString = query.query(QUrl::FullyEncoded);
	QByteArray ba = QUrl::toPercentEncoding(paramString, "&=", "+");
	qDebug() << "BA ==== " << ba;*/

qDebug() << "Services::async(): paramsString: \"" << query.query(QUrl::FullyEncoded) << "\""; //paramsString << "\"";

	QString host = !route.host().isEmpty() ? route.host() : defaultHost;
	QString url(defaultProtocol + "://" + host + routePattern);

	//req.setRawHeader(QByteArray("X-Requested-With"), QByteArray("XMLHttpRequest"));
	QMap<QString, QString> headers;
	headers[ "X-Requested-With" ] = "XMLHttpRequest";

	return sendRequest(httpMethod,
		url,
		params, //query.query(QUrl::FullyEncoded), //paramsString, //"email="+loginName+"&password="+password,
		filePaths,
		headers,
		receiver, method, argsToSlot, downloadProgressReceiver, downloadProgressMethod );

}

}//namespace qt
}//namespace wpp

