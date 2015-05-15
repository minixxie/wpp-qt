#ifndef __WPP__QT__QOBJECT_STAR_LIST__H__
#define __WPP__QT__QOBJECT_STAR_LIST__H__

#include <QObject>
#include <QList>

namespace wpp {
namespace qt {

class QObjectStarList : public QList<QObject*>
{
public:
	QObjectStarList()
		:QList<QObject*>()
	{

	}
	~QObjectStarList()
	{
		for ( QObject *obj : *this )
		{
			delete obj;
		}
		qDeleteAll(*this);
	}
};

}
}
#endif
