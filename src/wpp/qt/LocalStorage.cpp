#include "LocalStorage.h"

#include <QStandardPaths>
#include <QFileInfo>
#include <QDir>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QDateTime>

namespace wpp
{
namespace qt
{

LocalStorage *LocalStorage::singleton = 0;
LocalStorage &LocalStorage::getInstance()
{
	qDebug() << "LocalStorage::getInstance()...";
	if ( singleton == 0 )
	{
		static LocalStorage singletonInstance;
		qDebug() << "localstorage singleton is a base class";
		singleton = &singletonInstance;
	}
	qDebug() << QString().sprintf("LocalStorage::getInstance(), return: %p, conn:", singleton) << singleton->conn;
	return *singleton;
}

void LocalStorage::connect()
{
    qDebug() << "LocalStorage():b4 calling SqlDatabase::addDatabase()...";
    conn = QSqlDatabase::addDatabase("QSQLITE", dbName);
/*#ifdef Q_OS_ANDROID
    qDebug() << "LocalStorage(): this is Android...";
    QString dbFile = QString("assets:/database/") + dbName + ".db";
    QFile dbFilePath(dbFile);
    QDir parentDir( dbFilePath. )
#else*/
    qDebug() << "LocalStorage(): this is iOS and others...";
    QStringList paths = QStandardPaths::standardLocations(QStandardPaths::DataLocation);
    QDir dir( paths.first() );
    //dir.setFilter(QDir::Writable | QDir::Readable);
    QDir parentDir( dir.filePath("..") );
    qDebug() << "parent path: " << parentDir.absolutePath();
    if ( !dir.exists() )
    {
        parentDir.mkpath( dir.dirName() );
        qDebug() << "dir not exist, make it:" << dir;
        qDebug() << "dir.name: " << dir.dirName();
        //qDebug() << "new make dir returns: " << parentDir.mkpath( dir.dirName() );
        //qDebug() << "make dir returns: " << dir.mkdir(".");
    }
    QString dbFile = paths.first().append("/").append(dbName).append(".db");
    dbFilePath = dbFile;
//#endif


    qDebug() << "LocalStorage(): dbFile=" << dbFile;

//this 2 lines of code is used to unconditionally re-construct the sqlite db file (for development only)
//should comment out on production
//QFile::remove(dbFile);
//qDebug() << "dbFile removed successfully.";

    conn.setDatabaseName(dbFile);//android

    qDebug() << "LocalStorage():after calling SqlDatabase::addDatabase()...";

    //=== check if db file exists ===//
    //bool requireInitiation = false;
    QFileInfo dbFileInfo(dbFile);
    if ( !dbFileInfo.exists() )
    {
        //requireInitiation = true;
    }
    //remember to fix the permission
    QFile::setPermissions(dbFile, QFile::ReadOwner | QFile::WriteOwner);


    if(!conn.open())
    {
        qCritical() << "couldn't connect to database Error[" <<
            conn.lastError().text() << "]";
        return;
    }

    //init pragma "user_version"
    /*{
        QSqlQuery query(conn);
        if ( !query.exec("PRAGMA user_version = 1;") )
        {
            qDebug() << "Setting pragma user_version failed.";
        }
    }*/

    //test the sqlite "user_version"
    {
        int sqliteUserVersion = 0;
        QSqlQuery query(conn);
        query.exec("PRAGMA user_version;");
        while (query.next())
        {
            sqliteUserVersion = query.value(0).toInt();
            //qDebug() << "sqliteUserVersion: " << sqliteUserVersion;
        }
        qDebug() << "final sqliteUserVersion: " << sqliteUserVersion;

        updateSchema(sqliteUserVersion);
    }

    deleteSessionCookies();
    deleteExpiredCookies();
//debugSchema("HttpCookie");
//debugSchema("UpDownloadStat");

/*	{
        QSqlQuery query(conn);
        bool ret = query.exec("create table HttpCookie (name varchar(255) not null primary key, value varchar(255) not null)");
        if ( !ret )
        {
            qDebug() << "create table failed!";
        }
    }*/

    qDebug() << "LocalStorage() constructor, dumpDB...";
    dumpDB();

}

LocalStorage::LocalStorage()
	: dbName("LocalStorage")
{
    connect();
}
void LocalStorage::dropDB()
{
    QSqlDatabase::removeDatabase(dbName);

    QFile file(dbFilePath);
    file.remove();

    connect();
}

void LocalStorage::disconnect()
{
    deleteSessionCookies();
    deleteExpiredCookies();

    conn.close();
    //QSqlDatabase::removeDatabase(dbName);
}


LocalStorage::~LocalStorage()
{
    disconnect();
}

QList< QList<QString> > LocalStorage::schemaVersions()
{
	QList< QList<QString> > versions;

	{//version1
		QList<QString> version1;
		version1.append("create table IF NOT EXISTS HttpCookie (name varchar(255) not null primary key, value varchar(255) not null, path varchar(255) not null, expirationDate UNSIGNED INTEGER default null, isHttpOnly boolean not null default 0 check (isHttpOnly in (0,1)), isSecure boolean not null default 0 check (isSecure in (0,1)));");
		version1.append("create table IF NOT EXISTS UpDownloadStat (id INTEGER PRIMARY KEY AUTOINCREMENT, isDownload boolean not null default 1 check (isDownload in (0,1)), bytes UNSIGNED INTEGER not null, time UNSIGNED INTEGER not null);");
		versions.append(version1);
	}
	{//version2
		QList<QString> version2;
		version2.append("create table IF NOT EXISTS DataMap (`key` varchar(255) not null primary key, `value` varchar(255) not null);");
		versions.append(version2);
	}

	return versions;
}

void LocalStorage::updateSchema()
{
	int sqliteUserVersion = 0;
	QSqlQuery query(conn);
	query.exec("PRAGMA user_version;");
	while (query.next())
	{
		sqliteUserVersion = query.value(0).toInt();
		//qDebug() << "sqliteUserVersion: " << sqliteUserVersion;
	}
	qDebug() << "final sqliteUserVersion: " << sqliteUserVersion;

	updateSchema(sqliteUserVersion);
}

//ref: http://stackoverflow.com/questions/989558/best-practices-for-in-app-database-migration-for-sqlite
void LocalStorage::updateSchema(int fromVersion)
{
	QList< QList<QString> > schemaVersions = this->schemaVersions();
	int latestVersion = schemaVersions.length();
	int version = fromVersion;
	qDebug() << __FUNCTION__ << ":version=" << version;
	qDebug() << __FUNCTION__ << ":latestVersion=" << latestVersion;

	if ( version < latestVersion )//update needed
	{
		QSqlQuery query(conn);
		while ( version < latestVersion )
		{
			QList<QString> sqls = schemaVersions.at( version );
			for ( QString sql : sqls )
			{
				qDebug() << "upgrading schema: " << sql;
				if ( !query.exec(sql) )
				{
					qDebug() << "ERR(schema):" << sql << "--" << query.lastError();
					return;//error
				}
			}

			version++;
			if ( !query.exec( QString("PRAGMA user_version = %1;").arg(version) ) )
			{
				qDebug() << "ERR(update-schema-ver):" << query.lastError();
				return;//error
			}
		}
	}

	/*switch (fromVersion)
	{
	case 0:
	{
		//=== schema needed to become 1 ===//
		QSqlQuery query(conn);
		//bool ret = false;
		if (! query.exec("create table HttpCookie (name varchar(255) not null primary key, value varchar(255) not null, path varchar(255) not null, expirationDate UNSIGNED INTEGER default null, isHttpOnly boolean not null default 0 check (isHttpOnly in (0,1)), isSecure boolean not null default 0 check (isSecure in (0,1)));")
		)
		{
			qDebug() << "ERR: create table HttpCookie failed:" << query.lastError();
		}
		if (! query.exec("create table UpDownloadStat (id INTEGER PRIMARY KEY AUTOINCREMENT, isDownload boolean not null default 1 check (isDownload in (0,1)), bytes UNSIGNED INTEGER not null, time UNSIGNED INTEGER not null);")
		)
		{
			qDebug() << "ERR: create table UpDownloadStat failed:" << query.lastError();
		}
		if (! query.exec("create table DataMap (k varchar(255) not null primary key, v varchar(255) not null);")
		)
		{
			qDebug() << "ERR: create table DataMap failed:" << query.lastError();
		}

		query.exec( QString("PRAGMA user_version = %1;").arg(fromVersion + 1) );
		//break;//fall-thru
	}
	case 1:
	{
		//=== schema needed to become 2 ===//
		QSqlQuery query(conn);
		if (! query.exec("create table DataMap (k varchar(255) not null primary key, v varchar(255) not null);")
		)
		{
			qDebug() << "ERR: create table DataMap failed:" << query.lastError();
		}
		query.exec( QString("PRAGMA user_version = %1;").arg(fromVersion + 1) );
		//break;//fall-thru
	}
	default://no need to update
	{
		;
		break;
	}
	}*/
}

void LocalStorage::deleteExpiredCookies()//helper
{
	//qDebug() << "Before deleteExpiredCookies():";
	//dumpTable("HttpCookie");

	//delete expired cookies
	QSqlQuery query(conn);
	query.prepare("DELETE FROM `HttpCookie` where expirationDate <= strftime('%s','now');");
	if ( !query.exec() )
	{
		qDebug() << "delete expired HttpCookie failed:" << query.lastError();
	}

	//qDebug() << "After deleteExpiredCookies():";
	//dumpTable("HttpCookie");

}

void LocalStorage::deleteSessionCookies()//helper
{
	//qDebug() << "Before deleteSessionCookies():";
	//dumpTable("HttpCookie");

	//delete session cookies
	QSqlQuery query(conn);
	query.prepare("DELETE FROM `HttpCookie` where expirationDate is null;");
	if ( !query.exec() )
	{
		qDebug() << "delete session HttpCookie failed:" << query.lastError();
	}
	//qDebug() << "After deleteSessionCookies():";
	//dumpTable("HttpCookie");
}

void LocalStorage::debugSchema(const QString& tableName) const
{
	QSqlQuery query(conn);
	query.exec(QString("PRAGMA table_info(%1);").arg(tableName));
	qDebug() << QString("[%1 table]").arg(tableName);
	QString tableLine("+-----+----------------------+----------------------+----------+-----------+-----+");
	qDebug() << tableLine;
	//qDebug() << "| num\t| colName\t\t| type\t\t| required\t| default\t| pk\t|";
	QString row;
	row.sprintf("| %3s | %20s | %20s | %8s | %9s | %3s |", "num", "colName", "type", "required", "default", "pk");
	qDebug() << row;
	qDebug() << tableLine;

	while (query.next())
	{
		QString col0 = query.value(0).toString();
		QString col1 = query.value(1).toString();
		QString col2 = query.value(2).toString();
		QString col3 = query.value(3).toString();
		QString col4 = query.value(4).toString();
		QString col5 = query.value(5).toString();

		QString row;
		row.sprintf("| %3s | %20s | %20s | %8s | %9s | %3s |",
			col0.toStdString().c_str(),
			col1.toStdString().c_str(),
			col2.toStdString().c_str(),
			col3.toStdString().c_str(),
			col4.toStdString().c_str(),
			col5.toStdString().c_str());
		qDebug() << row;
		//qDebug() << "| " << col0 << "\t| " << col1 << "\t\t| " << col2 << "\t\t| " << col3 << "\t| " << col4 << "\t| " << col5 << "\t|";
	}
	qDebug() << tableLine;


}

void LocalStorage::setCookies(const QList<QNetworkCookie>& cookies)
{
	QListIterator<QNetworkCookie> it(cookies);
	while ( it.hasNext() )
	{
		QNetworkCookie cookie = it.next();
//qDebug() << "LocalStorage::setCookie(): Cookie: " << cookie.name() << " => " << cookie.value();

		this->setCookie( cookie );
	}
	//dumpDB();
}

void LocalStorage::dumpTable(const QString& tableName, const QString& sqlTail) const
{
	QSqlQuery query(conn);
	if ( !query.exec(QString("select * from %1 %2").arg(tableName).arg(sqlTail)) )
	{
		qDebug() << __FUNCTION__ << ":select error:" << query.lastError();
		return;
	}
	qDebug() << QString("[%1 - table data]").arg(tableName);

	if ( tableName == "HttpCookie" )
	{
		char format[] = "| %15s | %40s | %4s | %20s | %10s | %8s |";
		QString tableLine("+-----------------+------------------------------------------+------+----------------------+------------+----------+");
		qDebug() << tableLine;
		QString row;
		row.sprintf(format,
			"name", "value", "path", "expirationDate", "isHttpOnly", "isSecure");
		qDebug() << row;
		qDebug() << tableLine;
		while ( query.next() )
		{
			QString row;
			row.sprintf(format,
				query.value(0).toString().toStdString().c_str(),
				query.value(1).toString().toStdString().c_str(),
				query.value(2).toString().toStdString().c_str(),
				query.value(3).toString().toStdString().c_str(),
				query.value(4).toString().toStdString().c_str(),
				query.value(5).toString().toStdString().c_str()
			);
			qDebug() << row;
		}
		qDebug() << tableLine;
	}
	else if ( tableName == "UpDownloadStat" )
	{
		char format[] = "| %5s | %10s | %8s | %20s |";
		QString tableLine("+--------------+------------------------------------------+------+----------------------+------------+----------+");
		qDebug() << tableLine;
		QString row;
		row.sprintf(format,
			"id", "isDownload", "bytes", "time");
		qDebug() << row;
		qDebug() << tableLine;
		while ( query.next() )
		{
			QString row;
			row.sprintf(format,
				query.value(0).toString().toStdString().c_str(),
				query.value(1).toString().toStdString().c_str(),
				query.value(2).toString().toStdString().c_str(),
				query.value(3).toString().toStdString().c_str()
			);
			qDebug() << row;
		}
		qDebug() << tableLine;
	}
	else if ( tableName == "DataMap" )
	{
		char format[] = "| %30s | %80s |";
		QString tableLine("+--------------------------------+----------------------------------------------------------------------------------+");
		qDebug() << tableLine;
		QString row;
		row.sprintf(format,
			"key", "value");
		qDebug() << row;
		qDebug() << tableLine;
		while ( query.next() )
		{
			QString row;
			row.sprintf(format,
				query.value(0).toString().toStdString().c_str(),
				query.value(1).toString().toStdString().c_str()
			);
			qDebug() << row;
		}
		qDebug() << tableLine;
	}

}
void LocalStorage::dumpDB()
{
	dumpTable("HttpCookie");
	dumpTable("UpDownloadStat", "order by id desc limit 10");
	dumpTable("DataMap");

}

QList<QNetworkCookie> LocalStorage::getCookies()
{
	deleteExpiredCookies();

	QList<QNetworkCookie> cookies;

	QSqlQuery query(conn);
	query.exec("select * from HttpCookie");
	while ( query.next() )
	{
		QString name = query.value("name").toString();
		QString value = query.value("value").toString();
		QString path = query.value("path").toString();
		int expirationDate = query.value("expirationDate").toInt();
		bool isHttpOnly = query.value("isHttpOnly").toBool();
		bool isSecure = query.value("isSecure").toBool();

		QNetworkCookie cookie(name.toUtf8(), value.toUtf8());
		cookie.setPath(path);
		cookie.setExpirationDate(QDateTime::fromTime_t(expirationDate));
		cookie.setHttpOnly(isHttpOnly);
		cookie.setSecure(isSecure);

		cookies << cookie;
	}
	return cookies;
}

const QNetworkCookie LocalStorage::getCookie(const QString& name)
{
	QList<QNetworkCookie> cookies = this->getCookies();
	QListIterator<QNetworkCookie> it(cookies);
	while ( it.hasNext() )
	{
		QNetworkCookie cookie = it.next();
		if ( cookie.name() == name )
		{
			return cookie;
		}
	}
	return QNetworkCookie();
}

const QString LocalStorage::getCookieValue(const QString& name)
{
	const QNetworkCookie cookie = getCookie(name);
	return QString::fromUtf8( cookie.value().constData() );
}

void LocalStorage::deleteCookie(const QString& name)
{
	QNetworkCookie cookie = getCookie(name);
	cookie.setValue("");
	setCookie(cookie);
}

void LocalStorage::addUpDownloadHistory( int bytes, bool isDownload )
{
	//qDebug() << "LocalStorage::addUpDownloadHistory():conn:" << conn;
	QSqlQuery query(conn);
	if ( isDownload )
	{
		query.prepare("insert into UpDownloadStat (isDownload, bytes, time) values (1, :bytes, strftime('%s','now'));");
	}
	else
	{
		query.prepare("insert into UpDownloadStat (isDownload, bytes, time) values (0, :bytes, strftime('%s','now'));");
	}

	query.bindValue(":bytes", bytes);

	if ( !query.exec() )
	{
		qDebug() << "insert into UpDownloadStat failed:" << query.lastError();
	}

	//qDebug() << "After LocalStorage::addUpDownloadHistory():";
	//dumpDB();
}

void LocalStorage::setCookie(const QNetworkCookie& cookie)
{
    QSqlQuery query(conn);
    //query.prepare("insert into HttpCookie (name, value) values (:name, :value);");
    if ( !cookie.isSessionCookie() )
    {
qDebug() << "Non-Session cookie: REPLACE INTO `HttpCookie` (name, value, path, expirationDate, isHttpOnly, isSecure) VALUES (" << cookie.name() << ", " << cookie.value() << ", :path, :expirationDate, :isHttpOnly, :isSecure);";
		query.prepare("REPLACE INTO `HttpCookie` (name, value, path, expirationDate, isHttpOnly, isSecure) VALUES (:name, :value, :path, :expirationDate, :isHttpOnly, :isSecure);");
    }
    else
    {
qDebug() << "Session cookie(exp="<< cookie.expirationDate() <<"): REPLACE INTO `HttpCookie` (name, value, path, isHttpOnly, isSecure) VALUES (" << cookie.name() << ", " << cookie.value() << ", :path, :isHttpOnly, :isSecure);";
        query.prepare("REPLACE INTO `HttpCookie` (name, value, path, isHttpOnly, isSecure) VALUES (:name, :value, :path, :isHttpOnly, :isSecure);");
    }
    query.bindValue(":name", cookie.name());
    query.bindValue(":value", cookie.value());
    //query.bindValue(":domain", cookie.domain());
    //qDebug() << "cookie domain: " << cookie.domain();
    query.bindValue(":path", cookie.path());
    if ( !cookie.isSessionCookie() )
    {
        query.bindValue(":expirationDate", cookie.expirationDate().toTime_t());
    }
    query.bindValue(":isHttpOnly", cookie.isHttpOnly());
    query.bindValue(":isSecure", cookie.isSecure());
    if ( !query.exec() )
    {
        qDebug() << "insert into HttpCookie failed:" << query.lastError();
    }

}

const QString LocalStorage::getData(const QString& key) const
{
	QSqlQuery query(conn);

	query.prepare("select * from DataMap where `key` = :k;");
	query.bindValue(":k", key);
	query.exec();
	QString value;
	if ( query.next() )
	{
		value = query.value("value").toString();
	}

	return value;
}
void LocalStorage::setData(const QString& key, const QString& value)
{
	QSqlQuery query(conn);
	qDebug() << __FUNCTION__ << ":key=" << key;
	qDebug() << __FUNCTION__ << ":value=" << value;

	query.prepare("REPLACE INTO `DataMap` (`key`, `value`) VALUES (:k, :v);");
	query.bindValue(":k", key);
	query.bindValue(":v", value);
	if ( !query.exec() )
	{
		qDebug() << "ERR: setData failed:" << query.lastError();
	}
	qDebug() << "after setData(), dumpTable:";
	dumpTable("DataMap");
}

}//namespace qt
}//namespace wpp
