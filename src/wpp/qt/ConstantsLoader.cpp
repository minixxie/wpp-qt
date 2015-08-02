#include "ConstantsLoader.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlContext>
#include <QDebug>

namespace wpp {
namespace qt {

ConstantsLoader::ConstantsLoader(const QString& jsonFilePath)
{
	QFile constantsFile(jsonFilePath);
	constantsFile.open(QIODevice::ReadOnly | QIODevice::Text);
	QByteArray jsonFileContent = constantsFile.readAll();
	qDebug() << __FUNCTION__ << ":readAll=" << jsonFileContent;
	QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonFileContent);
	qDebug() << __FUNCTION__ << ":jsonDoc=" << jsonDoc;
	QJsonObject constants = jsonDoc.object();
	qDebug() << __FUNCTION__ << ":constants=" << constants;
	variantMap = constants.toVariantMap();
	qDebug() << __FUNCTION__ << ":variantMap=" << variantMap;
}

}
}
