#ifndef ROUTE_H
#define ROUTE_H

#include <QString>

namespace wpp
{
namespace qt
{

class Route
{
private:
	QString m_name;
	QString m_method;
	QString m_host;
	QString m_pattern;

public:
	Route() {} //default-constructor needed by QMap, create an INVALID Route

	Route(const QString& name, const QString method, const QString& host, const QString& pattern)
		: m_name(name), m_method(method), m_host(host), m_pattern(pattern)
	{
	}
	Route(const Route& route)//copy-constructor needed by QMap
		//: Route(route.m_name, route.m_method, route.m_pattern)
		: m_name(route.m_name), m_method(route.m_method), m_host(route.m_host), m_pattern(route.m_pattern)
	{
	}

	const QString& name() const { return m_name; }
	const QString& method() const { return m_method; }
	const QString& host() const { return m_host; }
	const QString& pattern() const { return m_pattern; }

	bool isValid() const { return !m_host.isEmpty() && !m_pattern.isEmpty() && !m_method.isEmpty(); }
};

}//namespace qt
}//namespace wpp

#endif
