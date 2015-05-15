#include "CookieJar.h"

#include <QDebug>
#include <QNetworkCookie>
#include <QElapsedTimer>

namespace wpp
{
namespace qt
{

CookieJar::CookieJar(LocalStorage &localStorage)
	: localStorage(localStorage)
{

}

QList<QNetworkCookie> CookieJar::cookiesForUrl(const QUrl & url) const
{
	//return cookies for attaching to the request header

//	qDebug() << "CookieJar::cookiesForUrl(): url:" << url;
	qDebug() << "Calling CookieJar::cookiesForUrl() url=" << url;

	QElapsedTimer timer;
	timer.start();

	QList<QNetworkCookie> cookies = localStorage.getCookies();

	qint64 nanoSec = timer.nsecsElapsed();
	qDebug() << "get cookies spent(nano-sec):" << nanoSec;

	timer.restart();

	QListIterator<QNetworkCookie> it(cookies);
	while ( it.hasNext() )
	{
		QNetworkCookie cookie = it.next();
		qDebug() << QString("CookieJar::cookiesForUrl(): Cookie: %1 => %2")
				.arg(QString(cookie.name()))
				.arg(QString(cookie.value()));
	}

	nanoSec = timer.nsecsElapsed();
	qDebug() << "get cookies2 spent(nano-sec):" << nanoSec;

	return cookies;
}

bool CookieJar::setCookiesFromUrl(const QList<QNetworkCookie> & cookieList, const QUrl& )
{
	//save cookies extracted from the response header
/*	qDebug() << "CookieJar::setCookiesFromUrl(): url:" << url;
	qDebug() << "CookieJar::setCookiesFromUrl(): cookieList:";

	QListIterator<QNetworkCookie> it(cookieList);
	while ( it.hasNext() )
	{
		QNetworkCookie cookie = it.next();
qDebug() << "Cookie: " << cookie.name() << " => " << cookie.value();
		//lstorage->setCookie(cookie.name(), cookie.value());
	}*/
	localStorage.setCookies(cookieList);
	qDebug() << "After CookieJar::setCookiesFromUrl(), sqlite:...";
	localStorage.dumpDB();
	return true;
}

}//namespace qt
}//namespace wpp
