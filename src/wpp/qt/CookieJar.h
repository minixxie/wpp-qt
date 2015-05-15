#ifndef QT_APP_BASE_COOKIE_JAR_H
#define QT_APP_BASE_COOKIE_JAR_H

#include "LocalStorage.h"

#include <QNetworkCookieJar>

namespace wpp
{
namespace qt
{

class CookieJar : public QNetworkCookieJar
{
private:
	LocalStorage &localStorage;

public:
	CookieJar(LocalStorage &localStorage);
public:	
	virtual QList<QNetworkCookie> cookiesForUrl(const QUrl & url) const;
	virtual bool setCookiesFromUrl(const QList<QNetworkCookie> & cookieList, const QUrl & url);
};

}//namespace qt
}//namespace wpp

#endif
