#include "Constants.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QQmlContext>
#include <QDebug>

namespace wpp {
namespace qt {

Constants *Constants::singleton = 0;

void Constants::load(const QString& jsonFilePath)
{
	static Constants singletonObj;

	singleton = &singletonObj;

	QFile constantsFile(jsonFilePath);
	constantsFile.open(QIODevice::ReadOnly | QIODevice::Text);
	QByteArray jsonFileContent = constantsFile.readAll();
	qDebug() << __FUNCTION__ << ":readAll=" << jsonFileContent;
	QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonFileContent);
	qDebug() << __FUNCTION__ << ":jsonDoc=" << jsonDoc;
	QJsonObject constants = jsonDoc.object();
	qDebug() << __FUNCTION__ << ":constants=" << constants;
	singletonObj.QVariantMap::operator=( constants.toVariantMap() );
	qDebug() << __FUNCTION__ << ":variantMap=" << singletonObj;
}

}
}
