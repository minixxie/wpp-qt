#ifndef __WPP__QT__WPP_H__
#define __WPP__QT__WPP_H__

#include <QObject>
#include "TimeAgo.h"

namespace wpp {
namespace qt {

class Wpp : public QObject
{
	Q_OBJECT
/*	Q_PROPERTY(TimeAgo timeago READ timeago)
private:
	TimeAgo& m_timeago;

public:
	Wpp()
		: m_timeago(TimeAgo::getInstance())
	{
	}

	Q_INVOKABLE const TimeAgo& timeago() const { return m_timeago; }*/
};

}
}


#endif
