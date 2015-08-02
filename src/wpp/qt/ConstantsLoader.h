#ifndef __WPP__QT__CONSTANTS_LOADER_H__
#define __WPP__QT__CONSTANTS_LOADER_H__

#include <QVariantMap>

namespace wpp {
namespace qt {

class ConstantsLoader
{
private:
	QVariantMap variantMap;

public:
	ConstantsLoader(const QString& jsonFilePath);

	const QVariantMap& constants() const { return variantMap; }

};

}
}

#endif
