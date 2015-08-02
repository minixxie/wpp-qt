#ifndef __WPP__QT__CONSTANTS_H__
#define __WPP__QT__CONSTANTS_H__

#include <QVariantMap>

namespace wpp {
namespace qt {

class Constants : public QVariantMap
{
public:
	Constants(const QString& jsonFilePath);
};

}
}

#endif
