#ifndef QT_APP_BASE_NETWORK_ACCESS_MANAGER_H
#define QT_APP_BASE_NETWORK_ACCESS_MANAGER_H

#include <QNetworkAccessManager>
#include <QMap>
#include <QList>
#include <QString>
#include <QVariant>

namespace wpp
{
namespace qt
{

class NetworkAccessManager : public QNetworkAccessManager
{
	Q_OBJECT
private:
	QMap<QString, QVariant> m_reqParams;
	QMap<QString, QVariant> m_args;

public:
	NetworkAccessManager(QObject *parent = 0) : QNetworkAccessManager(parent) {}

	void setReqParams(const QMap<QString, QVariant>& reqParams) { m_reqParams = reqParams; }
	void setArgs( const QMap<QString, QVariant>& args ) { m_args = args; }

public slots:
	void onResponse(QNetworkReply *reply);

signals:
	void responseReadyToDispatch(QNetworkReply*, const QMap<QString, QVariant>&, const QMap<QString, QVariant>& );
};

}//namespace qt
}//namespace wpp

#endif
