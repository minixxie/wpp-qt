#ifndef __WPP__QT__CONSTANTS_H__
#define __WPP__QT__CONSTANTS_H__

#include <QVariantMap>

namespace wpp {
namespace qt {

class Constants : public QVariantMap
{
private:
	static Constants *singleton;
	Constants() {}

public:
	static const Constants& getInstance() { return *singleton; }

	static void load(const QString& jsonFilePath);

public:
};

}
}

#endif
