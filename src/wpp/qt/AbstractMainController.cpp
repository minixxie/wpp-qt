#include "AbstractMainController.h"
#include "HttpAgent.h"
#include "Wpp.h"

#include <QNetworkReply>
#include <QNetworkAccessManager>

#include <iostream>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDesktopServices>
#include <QFile>
#include <QCryptographicHash>

#ifdef Q_OS_ANDROID
	#include <QAndroidJniObject>
	#include <QAndroidJniEnvironment>
	#include <QtAndroid>
#endif

#include <sstream>

namespace wpp
{
namespace qt
{

AbstractMainController::AbstractMainController()
	: toSendAuthReq(true),
	  isAuthReqEnded(false),
	  isAuthFailed(false),
	  qmlFile("PreStack.qml"), //qmlFile("PageStack.qml")//, qmlFile("MyKuulabuUI.qml")//qmlFile("SigninUI.qml")
	  showUpdateDialog(false),
	  log("Log:"),
	  networkReplyForAPKDownload(0),
	  fileStreamForDownloadedAPK(0)
{
}

void AbstractMainController::checkForUpdates()
{
	wpp::qt::Wpp &wpp = wpp::qt::Wpp::getInstance();
	Route route = getRouteForUpdateCheck();
qDebug() << "checkForUpdates():route.isValid=" << route.isValid();
//addLog("checkForUpdates()...");

	const QMap<QString, QVariant> reqParams = getHttpParamsForUpdateCheck();

#ifdef QT_DEBUG
	if ( route.isValid() )
#else
	if ( route.isValid() && ( wpp.isAndroid() || wpp.isIOS() ) )
#endif
	{
		qDebug() << "checkForUpdates():send request";
		//addLog("checkForUpdates():send request...");
		wpp::qt::HttpAgent &httpAgent = wpp::qt::HttpAgent::getInstance();
		httpAgent.async(this,SLOT(onResponseCheckForUpdates(QNetworkReply*)),
				"GET",
				route, reqParams);
	}
	else
	{
		emit updateCheckFinished(false);
	}

}

void AbstractMainController::onResponseCheckForUpdates(QNetworkReply *reply)
{
	qDebug() << "onResponseCheckForUpdates()...";
	//addLog("onResponseCheckForUpdates()...");

	if ( wpp::qt::HttpAgent::replyHasError(__FUNCTION__, reply) )
		return;

	QByteArray responseBody = reply->readAll();
	qDebug() << QString(responseBody);
	//addLog(QString(responseBody));

	QJsonObject json( QJsonDocument::fromJson(responseBody).object() );
	QString verName;

	qDebug() << "11111";
	verName = extractVerCode(json);

	qDebug() << "22222";

	setNewVerCode( verName );
	setVerCode( getAppVersion() );
	qDebug() << "33333";

	//addLog("current:" + getAppVersion());
	//addLog("latest:" + verName);
	qDebug() << "App version:" << getAppVersion();
	qDebug() << "APK version:" << verName;

	if ( !getAppVersion().isEmpty() && !verName.isEmpty() && shouldUpdate(json, getAppVersion(), verName) )
	{
		qDebug() << "version code not the same! need download update!";
		//addLog("shouldUpdate!");
		setShowUpdateDialog(true);
		emit updateCheckFinished(true);
	}
	else
	{
		qDebug() << "version codes the same! NO need download update!";
		//addLog("shouldNOTUpdate!");
		setShowUpdateDialog(false);
		emit updateCheckFinished(false);
	}
}

void AbstractMainController::linkToAppleStore()
{
	const QMap<QString, QVariant> reqParams = getHttpParamsForUpdateCheck();

	QString url = QString("http://itunes.apple.com/app/id").append( reqParams["id"].toString() );
	qDebug() << "link to apple store:" << url;
	QDesktopServices::openUrl(QUrl( url ));
}

void AbstractMainController::downloadAndroidAPK()
{
	QString url = getUrlForAPKDownload();
/*	QString baseFilename = url.remove(QRegExp("^.*\/"));
qDebug() << __FUNCTION__ << ":url=" << url;
qDebug() << __FUNCTION__ << ":baseFilename=" << baseFilename;

	QStringList paths = QStandardPaths::standardLocations(QStandardPaths::DataLocation);
	QDir dir( paths.first() );
	QDir parentDir( dir.filePath("..") );
	qDebug() << "parent path: " << parentDir.absolutePath();
	if ( !dir.exists() )
	{
		qDebug() << "dir not exist, make it:" << dir;
		qDebug() << "dir.name: " << dir.dirName();
		qDebug() << "new make dir returns: " << parentDir.mkpath( dir.dirName() );
		//qDebug() << "make dir returns: " << dir.mkdir(".");
	}
	QString downloadedFilename = paths.first().append("/").append(baseFilename);
*/
	QString downloadedFilename = getAPKDownloadedPath();

	wpp::qt::Wpp &wpp = wpp::qt::Wpp::getInstance();
#ifdef QT_DEBUG
	if ( !url.isEmpty() )
#else
	if ( !url.isEmpty() && wpp.isAndroid() )
#endif
	{
		qDebug() << "downloadAndroidAPK():send request";

		QNetworkAccessManager *mgr = new QNetworkAccessManager(this);
		connect(mgr,SIGNAL(finished(QNetworkReply*)),this,SLOT(onResponseAPKDownload(QNetworkReply*)));
		connect(mgr,SIGNAL(finished(QNetworkReply*)),mgr,SLOT(deleteLater()));

		//assume GET
		QNetworkRequest req(url);
		delete networkReplyForAPKDownload;
		networkReplyForAPKDownload = mgr->get(req);
		connect(networkReplyForAPKDownload, SIGNAL(downloadProgress(qint64,qint64)), this, SLOT(onDownloadProgressPropagation(qint64,qint64)));
		connect(networkReplyForAPKDownload, SIGNAL(readyRead()), this, SLOT(onDownloadStreamReadyRead()));

		qDebug() << "fileStreamForDownloadedAPK(ptr)=" << (void*)fileStreamForDownloadedAPK;
		delete fileStreamForDownloadedAPK;
		fileStreamForDownloadedAPK = new QFile( downloadedFilename );
		fileStreamForDownloadedAPK->open(QIODevice::WriteOnly|QIODevice::Truncate);
	}
}

void AbstractMainController::onDownloadProgressPropagation(qint64 bytesReceived, qint64 bytesTotal)
{
	emit this->apkDownloadProgress(bytesReceived, bytesTotal);
}

void AbstractMainController::onDownloadStreamReadyRead()
{
	qDebug() << __FUNCTION__;
	if ( networkReplyForAPKDownload != 0 )
	{
		char buf[4096];
		unsigned bytesRead = networkReplyForAPKDownload->read(buf, sizeof(buf));
		qDebug() << __FUNCTION__ << ":bytesRead=" << bytesRead;
		unsigned bytesWritten = fileStreamForDownloadedAPK->write(buf, bytesRead);
		qDebug() << __FUNCTION__ << ":bytesWritten(to file)=" << bytesWritten;
	}
}

void AbstractMainController::onResponseAPKDownload(QNetworkReply *reply)
{
	qDebug() << __FUNCTION__;
	if ( wpp::qt::HttpAgent::replyHasError(__FUNCTION__, reply) )
		return;

	QByteArray responseBody = reply->readAll();
	qDebug() << __FUNCTION__ << ":readAll-bytes=" << responseBody.length();
	qDebug() << QString(responseBody);

	fileStreamForDownloadedAPK->write(responseBody);

	fileStreamForDownloadedAPK->flush();
	fileStreamForDownloadedAPK->close();

	fileStreamForDownloadedAPK->setPermissions( QFileDevice::ReadUser );
	fileStreamForDownloadedAPK->setPermissions( QFileDevice::ReadOwner );
	fileStreamForDownloadedAPK->setPermissions( QFileDevice::ReadGroup );
	fileStreamForDownloadedAPK->setPermissions( QFileDevice::ReadOther );

	delete fileStreamForDownloadedAPK;
	fileStreamForDownloadedAPK = 0;
	networkReplyForAPKDownload = 0;

	{
		QFile file( getAPKDownloadedPath() );
		file.open(QIODevice::ReadOnly);
		QByteArray fileData = file.readAll();
		QByteArray hashData = QCryptographicHash::hash(fileData, QCryptographicHash::Md5);
		setMd5sum( hashData.toHex() );
		//addLog(QString("download apk md5=").append( hashData.toHex() ));
		//addLog(QString().sprintf("downloaded apk size=%lld", file.size() ));
	}

	emit this->updateDownloadFinished(true);
}

void AbstractMainController::installNewAndroidAPK()
{
/*
Intent intent = new Intent(Intent.ACTION_VIEW);
	intent.setDataAndType(Uri.fromFile(new File
			(Environment.getExternalStorageDirectory()  + "/barcode.apk")), "application/vnd.android.package-archive");
	startActivity(intent);
 */
#ifdef Q_OS_ANDROID

	QAndroidJniObject ACTION_VIEW = QAndroidJniObject::getStaticObjectField(
				"android/content/Intent", "ACTION_VIEW", "Ljava/lang/String;");
	qDebug() << "ACTION_VIEW:isVAlid:" << ACTION_VIEW.isValid();

	QAndroidJniObject intent=QAndroidJniObject("android/content/Intent","(Ljava/lang/String;)V",
											   ACTION_VIEW.object<jstring>());
	qDebug() << __FUNCTION__ << "intent.isValid()=" << intent.isValid();

	QAndroidJniObject filePath = QAndroidJniObject::fromString( getAPKDownloadedPath() );
	qDebug() << __FUNCTION__ << "filePath.isValid()=" << filePath.isValid();

	QAndroidJniObject file=QAndroidJniObject("java/io/File","(Ljava/lang/String;)V",
											   filePath.object<jstring>());
	qDebug() << __FUNCTION__ << "file.isValid()=" << file.isValid();

	QAndroidJniObject fileUri = QAndroidJniObject::callStaticObjectMethod(
				"android/net/Uri", "fromFile", "(Ljava/io/File;)Landroid/net/Uri;",
				file.object<jobject>() );

	QAndroidJniObject contentType = QAndroidJniObject::fromString("application/vnd.android.package-archive");

	intent.callObjectMethod(
				"setDataAndType", "(Landroid/net/Uri;Ljava/lang/String;)Landroid/content/Intent;",
				fileUri.object<jobject>(), contentType.object<jstring>()
	);

	//intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
	jint Intent__FLAG_ACTIVITY_NEW_TASK = QAndroidJniObject::getStaticField<jint>(
				"android/content/Intent", "FLAG_ACTIVITY_NEW_TASK");
	//qDebug() << "FLAG_ACTIVITY_NEW_TASK:isVAlid:" << FLAG_ACTIVITY_NEW_TASK.isValid();

	intent.callObjectMethod(
				"setFlags", "(I)Landroid/content/Intent;",
				Intent__FLAG_ACTIVITY_NEW_TASK
	);

	QtAndroid::startActivity(intent, 0, 0);

#endif
}

void AbstractMainController::parseVersionCode(int result[3], const QString& input)
{
	std::istringstream parser(input.toStdString());
	parser >> result[0];
	for(int idx = 1; idx < 4; idx++)
	{
		parser.get(); //Skip period
		parser >> result[idx];
	}
}
bool AbstractMainController::versionCodeGreaterThan(const QString& code1, const QString& code2)
{
	int parsedA[3], parsedB[3];
	parseVersionCode(parsedA, code1);
	parseVersionCode(parsedB, code2);
	return std::lexicographical_compare(parsedB, parsedB + 3, parsedA, parsedA + 3);
}

}//namespace qt
}//namespace wpp

