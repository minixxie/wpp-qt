#include "AbstractBaseController.h"

#include <QDebug>
#include <QFile>

namespace wpp
{
namespace qt
{

AbstractBaseController::AbstractBaseController()
	: waitingRequestCount(0)
{
	if ( !childControllers.empty() )
	{
		for ( QList<QObject *>::const_iterator it = childControllers.constBegin();
			  it != childControllers.constEnd() ; ++it )
		{
			AbstractBaseController *controller = dynamic_cast<AbstractBaseController *>( *it );
			connect(controller,SIGNAL(waitingRequestCountChanged()),this,SLOT(updateWaitingRequestCount()));
		}
	}
}

void AbstractBaseController::clearQObjectStar(QVariant& var)
{
	if ( var.isValid() && !var.isNull() )
	{
		QObject *obj = var.value<QObject *>();
		delete obj;
		obj = 0;
		var = QVariant();
	}
}

void AbstractBaseController::clearQObjectStarList(QList<QObject*>& list)
{
	for ( QObject *obj : list )
	{
		qDebug() << "list[]:obj--" << (void*)obj << "::" << obj->objectName();
		obj->deleteLater();
		qDebug() << "list[]:obj--delete:" << (void*)obj;
	}
	list.clear();
}

void AbstractBaseController::clearQObjectStarList(QVariant& var)
{
	if ( var.isValid() && !var.isNull() )
	{
		QList<QObject*> list = var.value< QList<QObject*> >();
		qDebug() << "clearQObjectStarList: list length=" << list.length();
		clearQObjectStarList(list);
		/*for ( QObject *obj : list )
		{
			qDebug() << "list[]:obj--" << (void*)obj << "::" << obj->objectName();
			delete obj;
			qDebug() << "list[]:obj--delete:" << (void*)obj;
		}*/
		//qDebug() << "clearQObjectStarList: after for-loop, before qDeleteAll...";
		//qDeleteAll( list );
		//qDebug() << "clearQObjectStarList: after qDeleteAll...";
		//list.clear();
		qDebug() << "clearQObjectStarList: after clear()...";
		var = QVariant::fromValue( list );
	}
}

void AbstractBaseController::removeFiles(const QStringList& paths)
{
	for ( QString path : paths )
	{
		QFile file(path);
		file.setPermissions(QFile::ReadOther | QFile::WriteOther);
		file.remove();
	}
}

void AbstractBaseController::updateWaitingRequestCount()
{
	qDebug() << "AbstractBaseController::updateWaitingRequestCount()...";

	int count = 0;
	for ( QList<QObject *>::const_iterator it = childControllers.constBegin();
		  it != childControllers.constEnd() ; ++it )
	{
		AbstractBaseController *controller = dynamic_cast<AbstractBaseController *>( *it );
		count += controller->getWaitingRequestCount();
	}
	this->waitingRequestCount = count;
	emit waitingRequestCountChanged();
}

void AbstractBaseController::clearChildControllers()
{
	qDebug() << "AbstractBaseController::clearChildControllers()...";

	if ( !childControllers.empty() )
	{
		for ( QList<QObject *>::const_iterator it = childControllers.constBegin();
			  it != childControllers.constEnd() ; ++it )
		{
			AbstractBaseController *controller = dynamic_cast<AbstractBaseController *>( *it );
			disconnect(controller,SIGNAL(waitingRequestCountChanged()),this,SLOT(updateWaitingRequestCount()));
		}
	}

	childControllers.clear();
	updateWaitingRequestCount();
}

void AbstractBaseController::addChildController(AbstractBaseController *controller)
{
	qDebug() << "AbstractBaseController::addChildController()...";
	childControllers.push_back(controller);

	connect(controller,SIGNAL(waitingRequestCountChanged()),this,SLOT(updateWaitingRequestCount()));

	updateWaitingRequestCount();
}

}//namespace qt
}//namespace wpp
