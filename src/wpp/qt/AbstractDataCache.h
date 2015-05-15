#ifndef QT_APP_BASE_ABSTRACT_DATA_CACHE_H
#define QT_APP_BASE_ABSTRACT_DATA_CACHE_H

#include <QJsonObject>

namespace wpp
{
namespace qt
{

class AbstractDataCache
{
private:
	//const QJsonObject& tbl;
	QJsonObject tbl;
	QJsonObject* idx;

protected:
	virtual void buildSecondaryIndex(QJsonObject& idx, const QString& indexName, const QString& tableName, const QString& colName);
	virtual void buildSecondaryIndices(QJsonObject &idx) = 0;

public:
	static void debugTbl(const QJsonObject &tbl);
	static void debugIdx(const QJsonObject &idx);

	AbstractDataCache(const QJsonObject& tbl) : tbl(tbl), idx(0)
	{
	}
	virtual ~AbstractDataCache();

	const QJsonObject& getTbl() const { return tbl; }
	const QJsonObject& getIdx();

	void debug();

};

}//namespace qt
}//namespace wpp

#endif
