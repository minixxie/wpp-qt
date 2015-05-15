#include "NetworkAccessManager.h"

#include <QDebug>

namespace wpp
{
namespace qt
{

void NetworkAccessManager::onResponse(QNetworkReply *reply)
{
	qDebug() << "emit responseReadyToDispatch...";
	emit this->responseReadyToDispatch(reply, m_reqParams, m_args);
}

}//namespace qt
}//namespace wpp

