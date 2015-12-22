#ifndef QT_APP_BASE_LOCAL_STORAGE_H
#define QT_APP_BASE_LOCAL_STORAGE_H

#ifdef Q_OS_IOS//iphone
	#include <QtPlugin>
	//Q_IMPORT_PLUGIN(qsqlite)
#endif

#include <QSqlDatabase>
#include <QNetworkCookie>

namespace wpp
{
namespace qt
{

class LocalStorage
{
protected:
	//static const QString DB_NAME;
	QString dbName;
    QString dbFilePath;
    LocalStorage();
	LocalStorage( const LocalStorage& ) {}//prevent from copying

    void connect();
    void disconnect();

	void updateSchema(int fromVersion);//helper
	void deleteExpiredCookies();//helper
	void deleteSessionCookies();//helper

	void debugSchema(const QString& tableName) const;
	virtual void dumpTable(const QString& tableName, const QString& sqlTail = QString()) const;
	virtual QList< QList<QString> > schemaVersions();
public:
	virtual ~LocalStorage();

public:
	QSqlDatabase conn;

protected:
	static LocalStorage *singleton;
public:
	static LocalStorage &getInstance();
	void updateSchema();

    void dropDB();

	void setCookies(const QList<QNetworkCookie>& cookies);
    void setCookie(const QNetworkCookie& cookie);

	QList<QNetworkCookie> getCookies();
	const QNetworkCookie getCookie(const QString& name);
    const QString getCookieValue(const QString& name);
	void deleteCookie(const QString& name);

	const QString getData(const QString& key) const;
	void setData(const QString& key, const QString& value);

	void addUpDownloadHistory( int bytes, bool isDownload = true );

	void dumpDB();
};

}//namespace qt
}//namespace wpp

#endif
