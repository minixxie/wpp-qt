#ifndef __QT_APP_BASE__ABSTRACT_MAIN_CONTROLLER_H__
#define __QT_APP_BASE__ABSTRACT_MAIN_CONTROLLER_H__

#include "Route.h"

#include <QObject>
#include <QNetworkReply>
#include <QFile>

namespace wpp
{
namespace qt
{

class AbstractMainController : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool toSendAuthReq READ getToSendAuthReq NOTIFY toSendAuthReqChanged)
	Q_PROPERTY(bool isAuthReqEnded READ getIsAuthReqEnded WRITE setIsAuthReqEnded NOTIFY isAuthReqEndedChanged)
	Q_PROPERTY(bool isAuthFailed READ getIsAuthFailed WRITE setIsAuthFailed NOTIFY isAuthFailedChanged)
	Q_PROPERTY(QString qmlFile READ getQmlFile WRITE setQmlFile NOTIFY qmlFileChanged)

	Q_PROPERTY(QString newVerCode READ getNewVerCode WRITE setNewVerCode NOTIFY newVerCodeChanged)
	Q_PROPERTY(QString verCode READ getVerCode WRITE setVerCode NOTIFY verCodeChanged)
	Q_PROPERTY(bool showUpdateDialog READ getShowUpdateDialog WRITE setShowUpdateDialog NOTIFY showUpdateDialogChanged)

	Q_PROPERTY(QString md5sum READ getMd5sum WRITE setMd5sum NOTIFY md5sumChanged)

	Q_PROPERTY(QString log READ getLog WRITE setLog NOTIFY logChanged)


private:
	bool toSendAuthReq;
	bool isAuthReqEnded;
	bool isAuthFailed;
	QString qmlFile;
	QString newVerCode;
	QString verCode;
	bool showUpdateDialog;
	QString md5sum;

	QString log;

protected:
	virtual const Route getRouteForUpdateCheck() = 0;
	virtual const QMap<QString, QVariant> getHttpParamsForUpdateCheck() = 0;
	virtual const QString getAppVersion() const = 0;
	virtual const QString extractVerCode(const QJsonObject& version) const = 0;
	virtual bool shouldUpdate(const QJsonObject& version, const QString& oldVerCode, const QString& newVerCode) const = 0;

	QNetworkReply *networkReplyForAPKDownload;
	QFile *fileStreamForDownloadedAPK;
	virtual const QString getUrlForAPKDownload() = 0;
	virtual const QString getAPKDownloadedPath() = 0;

public:
	AbstractMainController();

	Q_INVOKABLE virtual bool hasRememberedLogin() = 0;

	Q_INVOKABLE QString getQmlFile() { return this->qmlFile; }
	Q_INVOKABLE void setQmlFile(const QString& qmlFile) { this->qmlFile = qmlFile; emit qmlFileChanged(); }

	Q_INVOKABLE bool getToSendAuthReq() { toSendAuthReq = hasRememberedLogin(); return toSendAuthReq; }

	Q_INVOKABLE bool getIsAuthReqEnded() { return this->isAuthReqEnded; }
	Q_INVOKABLE void setIsAuthReqEnded(bool isAuthReqEnded) { this->isAuthReqEnded = isAuthReqEnded; emit isAuthReqEndedChanged(); }

	Q_INVOKABLE bool getIsAuthFailed() { return this->isAuthFailed; }
	Q_INVOKABLE void setIsAuthFailed(bool isAuthFailed) { this->isAuthFailed = isAuthFailed; emit isAuthFailedChanged(); }

	Q_INVOKABLE QString getNewVerCode() { return this->newVerCode; }
	Q_INVOKABLE void setNewVerCode(const QString& newVerCode) { this->newVerCode = newVerCode; emit newVerCodeChanged(); }

	Q_INVOKABLE QString getVerCode() { return this->verCode; }
	Q_INVOKABLE void setVerCode(const QString& verCode) { this->verCode = verCode; emit verCodeChanged(); }

	Q_INVOKABLE bool getShowUpdateDialog() { return this->showUpdateDialog; }
	Q_INVOKABLE void setShowUpdateDialog(bool showUpdateDialog) { this->showUpdateDialog = showUpdateDialog; emit showUpdateDialogChanged(); }

	Q_INVOKABLE QString getMd5sum() { return this->md5sum; }
	Q_INVOKABLE void setMd5sum(const QString& md5sum) { this->md5sum = md5sum; emit md5sumChanged(); }


	Q_INVOKABLE const QString& getLog() { return this->log; }
	Q_INVOKABLE void setLog(const QString& log) { this->log = log; emit this->logChanged(); }
	Q_INVOKABLE void addLog(const QString& text) { this->log = this->log + "\n" + text; emit this->logChanged(); }


signals:
	void toSendAuthReqChanged();
	void isAuthReqEndedChanged();
	void isAuthFailedChanged();
	void qmlFileChanged();
	void newVerCodeChanged();
	void verCodeChanged();
	void showUpdateDialogChanged();
	void md5sumChanged();
	void logChanged();

	void updateCheckFinished(bool needUpdate);
	void updateDownloadFinished(bool successful);

	void apkDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);
public slots:

	Q_INVOKABLE void checkForUpdates();
	Q_INVOKABLE void onResponseCheckForUpdates(QNetworkReply *reply);

	Q_INVOKABLE void linkToAppleStore();
	Q_INVOKABLE void downloadAndroidAPK();
	Q_INVOKABLE void installNewAndroidAPK();

	Q_INVOKABLE void onDownloadProgressPropagation(qint64 bytesReceived, qint64 bytesTotal);
	Q_INVOKABLE void onDownloadStreamReadyRead();
	Q_INVOKABLE void onResponseAPKDownload(QNetworkReply *reply);

	static void parseVersionCode(int result[3], const QString& input);
	static bool versionCodeGreaterThan(const QString& code1, const QString& code2);
};

}//namespace qt
}//namespace wpp

#endif
