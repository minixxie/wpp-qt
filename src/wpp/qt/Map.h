#ifndef QT_APP_BASE_MAP_H
#define QT_APP_BASE_MAP_H

#include <QObject>

namespace wpp
{
namespace qt
{

class Map : public QObject
{
	Q_OBJECT
protected:
	Map() {}
	Map( const Map& ): QObject(0) {}//prevent from copying
	static Map *singleton;
public:
	static Map &getInstance();

private:

public:
	Q_INVOKABLE void loadExternalMap(double longitude, double latitude, const QString& locationName, int zoom);
	Q_INVOKABLE void loadExternalMap(QString keyword, int zoom);

signals:
public slots:
};

}//namespace qt
}//namespace wpp

#endif
