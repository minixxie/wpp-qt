#ifndef QT_APP_BASE_TIME_AGO_H
#define QT_APP_BASE_TIME_AGO_H

#include <QObject>

namespace wpp
{
namespace qt
{

class TimeAgo : public QObject
{
	Q_OBJECT
private:

private:
	static TimeAgo *singleton;
	TimeAgo() : QObject(0) {}
	TimeAgo(const TimeAgo&) : QObject(0) {}//prevent from copying
public:
	static TimeAgo &getInstance();

	Q_INVOKABLE const QString getTimeAgo(int timestamp);
};

}//namespace qt
}//namespace wpp

#endif
