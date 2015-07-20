#ifndef __WPP__QT__WPP_H__
#define __WPP__QT__WPP_H__

#include <QObject>
#include "TimeAgo.h"
#include "System.h"

namespace wpp {
namespace qt {

class Application;
class Wpp : public QObject
{
	Q_OBJECT
	Q_PROPERTY(double dp2px READ dp2px NOTIFY dp2pxChanged)
private:
	Application *app;
	double m_dp2px;
public:
	Wpp(Application *app);
	Q_INVOKABLE double dp2px() const { return m_dp2px; }
	Q_SIGNAL void dp2pxChanged();


	Q_INVOKABLE void setAppIconUnreadCount(int count) { System::getInstance().setAppIconUnreadCount(count); }

/*	Q_PROPERTY(TimeAgo timeago READ timeago)
private:
	//TimeAgo& m_timeago;

public:
	Wpp()
		//: m_timeago(TimeAgo::getInstance())
	{
	}

	Q_INVOKABLE const TimeAgo& timeago() const { return m_timeago; }*/
};

}
}


#endif
