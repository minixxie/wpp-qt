#include "AbstractDataCache.h"

#include <QDebug>
#include <QJsonObject>
#include <QJsonArray>

namespace wpp
{
namespace qt
{

void AbstractDataCache::buildSecondaryIndex(QJsonObject& idx, const QString& indexName, const QString& tableName, const QString& colName)
{
//qDebug() << "AbstractDataCache::buildSecondaryIndex()...";

	if ( tbl.contains( tableName ) )
	{
//qDebug() << "AbstractDataCache::buildSecondaryIndex()...tbl contains " << tableName << "= true";

		QJsonObject index;

		QJsonObject table = tbl[tableName].toObject();
		QJsonObject::const_iterator rowIt;
		for ( rowIt = table.constBegin(); rowIt != table.constEnd(); ++rowIt )
		{
			QString rowKey = rowIt.key();
			QJsonObject row = rowIt.value().toObject();
			QString col = row[colName].toString();
//qDebug() << "rowKey: " << rowKey;
			QJsonValue resultKey = QJsonValue( rowKey );
//qDebug() << "resultKey: " << resultKey.toString();
			QJsonArray resultKeys;
			if ( index.contains(col) )
			{
				resultKeys = index[col].toArray();
			}
			resultKeys.append( resultKey );
			index.insert(col, resultKeys);
			//qDebug() << "index(" << indexName << "): " << index;
		}

		idx.insert(indexName, QJsonValue(index));

	}
}

void AbstractDataCache::debugTbl(const QJsonObject &tbl)
{
	qDebug() << "DataCache::debug()...." << tbl.size() << " tables";

	QJsonObject::const_iterator tableIt;
	for ( tableIt = tbl.constBegin() ; tableIt != tbl.constEnd(); ++tableIt )
	{
		QString tableName = tableIt.key();
		QJsonObject table = tableIt.value().toObject();

		qDebug() << "table: [" << tableName << "] - " << table.size() << " rows";

		QJsonObject::const_iterator rowIt;
		for ( rowIt = table.constBegin() ; rowIt != table.constEnd(); ++rowIt )
		{
			QString rowKey = rowIt.key();
			QJsonObject row = rowIt.value().toObject();

			QString rowOutput;
			rowOutput.append(rowKey).append(" => {");

			QJsonObject::const_iterator colIt;
			int i = 0;
			for ( colIt = row.constBegin(); colIt != row.constEnd(); ++colIt )
			{
				QString colKey = colIt.key();
				QString colVal = colIt.value().toString();
				if ( i > 0 )
				{
					rowOutput.append(",");
				}
				rowOutput.append(colKey).append(":").append(colVal);
				i++;
			}
			rowOutput.append("}");
			qDebug() << rowOutput;
		}
	}
}

void AbstractDataCache::debugIdx(const QJsonObject &idx)
{
	qDebug() << "DataCache::debug()...." << idx.size() << " indices";

	QJsonObject::const_iterator tableIt;
	for ( tableIt = idx.constBegin() ; tableIt != idx.constEnd(); ++tableIt )
	{
		QString tableName = tableIt.key();
		QJsonObject table = tableIt.value().toObject();

		qDebug() << "table: [" << tableName << "] - " << table.size() << " rows";

		QJsonObject::const_iterator rowIt;
		for ( rowIt = table.constBegin() ; rowIt != table.constEnd(); ++rowIt )
		{
			QString rowKey = rowIt.key();
			QJsonArray row = rowIt.value().toArray();

			QString rowOutput;
			rowOutput.append(rowKey).append(" => [");

			QJsonArray::const_iterator colIt;
			int i = 0;
			for ( colIt = row.constBegin(); colIt != row.constEnd(); ++colIt )
			{
				QString colVal = (*colIt).toString();
				if ( i > 0 )
				{
					rowOutput.append(",");
				}
				rowOutput.append(colVal);
				i++;
			}
			rowOutput.append("]");
			qDebug() << rowOutput;
		}
	}
}

AbstractDataCache::~AbstractDataCache()
{
	if ( idx != 0 )
	{
		delete idx;
		idx = 0;
	}
}

const QJsonObject& AbstractDataCache::getIdx()
{
	if ( idx == 0 )
	{
		idx = new QJsonObject;
		buildSecondaryIndices( *idx );
	}
	return *idx;
}

void AbstractDataCache::debug()
{
	debugTbl(tbl);
	debugIdx( getIdx() );
}

}//namespace qt
}//namespace wpp

