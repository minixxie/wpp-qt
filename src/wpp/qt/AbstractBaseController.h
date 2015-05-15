#ifndef ABSTRACT_BASE_CONTROLLER_H
#define ABSTRACT_BASE_CONTROLLER_H

#include <QObject>
#include <QString>
#include <QList>

namespace wpp
{
namespace qt
{

class AbstractBaseController: public QObject
{
	Q_OBJECT
	Q_PROPERTY(int waitingRequestCount READ getWaitingRequestCount WRITE setWaitingRequestCount NOTIFY waitingRequestCountChanged)
	QList<QObject*> childControllers;
private:
	int waitingRequestCount;
protected:
	AbstractBaseController();

	void clearQObjectStar(QVariant& var);
	void clearQObjectStarList(QVariant& var);
	void clearQObjectStarList(QList<QObject*>& list);
	void removeFiles(const QStringList& paths);

public:
	void clearChildControllers();
	void addChildController(AbstractBaseController *controller);


	Q_INVOKABLE int getWaitingRequestCount() { return this->waitingRequestCount; }
	Q_INVOKABLE void setWaitingRequestCount(int waitingRequestCount) { this->waitingRequestCount = waitingRequestCount; emit this->waitingRequestCountChanged(); }
	Q_INVOKABLE void incrementWaitingRequestCount() { this->waitingRequestCount++; emit this->waitingRequestCountChanged(); }
	Q_INVOKABLE void decrementWaitingRequestCount() { if ( this->waitingRequestCount > 0 ) this->waitingRequestCount--; emit this->waitingRequestCountChanged(); }

signals:
	void waitingRequestCountChanged();

public slots:
	void updateWaitingRequestCount();

};

}//namespace qt
}//namespace wpp

#endif
