#include "TimeAgo.h"

#include <QDebug>
#include <QDateTime>

namespace wpp
{
namespace qt
{

TimeAgo *TimeAgo::singleton= 0;

TimeAgo &TimeAgo::getInstance()
{
	if ( singleton == 0 )
	{
		static TimeAgo singletonInstance;
		singleton = &singletonInstance;
	}
	return *singleton;
}

const QString TimeAgo::getTimeAgo(int timestamp)
{
	QDateTime currentDateTime = QDateTime::currentDateTime();
	int currentTimestamp = currentDateTime.toTime_t();

	bool isFuture = false;
	int secDiff = 0;
	if ( timestamp > currentTimestamp )//future
	{
		isFuture = true;
		secDiff = timestamp - currentTimestamp;
	}
	else if ( timestamp < currentTimestamp )//past
	{
		isFuture = false;
		secDiff = currentTimestamp - timestamp;
	}
	else//the same
	{
		return QString(tr("Just now"));
	}

	QString ret;

	if ( secDiff > 365*24*60*60 )//longer than 1 year
	{
		int years = secDiff / (365*24*60*60);
		if ( isFuture )
		{
			ret = tr("%1+ years in the future").arg(years);
		}
		else
		{
			ret = tr("%1+ years ago").arg(years);
		}
	}
	else if ( secDiff <= 365*24*60*60 && 30*24*60*60 < secDiff )//shorter than 1 year and longer than 1 month
	{
		int months = secDiff / (30*24*60*60);
		if ( isFuture )
		{
			ret = tr("%1+ months in the future").arg(months);
		}
		else
		{
			ret = tr("%1+ months ago").arg(months);
		}
	}
	else if ( secDiff <= 30*24*60*60 && 24*60*60 < secDiff )//shorter than 1 month and longer than 1 day
	{
		int days = secDiff / (24*60*60);
		if ( isFuture )
		{
			ret = tr("%1+ days in the future").arg(days);
		}
		else
		{
			ret = tr("%1+ days ago").arg(days);
		}
	}
	else if ( secDiff <= 24*60*60 && 60*60 < secDiff )//shorter than 1 day and longer than 1 hour
	{
		int hours = secDiff / (60*60);
		if ( isFuture )
		{
			ret = tr("%1+ hours in the future").arg(hours);
		}
		else
		{
			ret = tr("%1+ hours ago").arg(hours);
		}
	}
	else if ( secDiff <= 60*60 && 60 < secDiff )//shorter than 1 hour and longer than 1 minute
	{
		int minutes = secDiff / (60);
		if ( isFuture )
		{
			ret = tr("%1+ minutes in the future").arg(minutes);
		}
		else
		{
			ret = tr("%1+ minutes ago").arg(minutes);
		}
	}
	else if ( secDiff <= 60 )//shorter than 1 minute
	{
		if ( isFuture )
		{
			ret = tr("less than 1 minute in the future");
		}
		else
		{
			ret = tr("less than 1 minute ago");
		}
	}
	return ret;
}

}//namespace qt
}//namespace wpp
