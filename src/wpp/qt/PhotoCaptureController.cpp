#include "PhotoCaptureController.h"

#include <QSize>
#include <QDebug>
#include <QFile>
#include <QCryptographicHash>

namespace wpp
{
namespace qt
{

void PhotoCaptureController::saveCapture(QString requestId, int width, int height)
{
	QQmlImageProviderBase* imageProviderBase = engine->imageProvider("camera");
	QQuickImageProvider* imageProvider = dynamic_cast<QQuickImageProvider*>(imageProviderBase);

//    QQuickImageProvider *p =
//            dynamic_cast<QQuickImageProvider*>(
//                engine->imageProvider("camera")
//            );
	this->image = imageProvider->requestImage(QString("preview_") + requestId, 0, QSize(width, height));
}

void PhotoCaptureController::saveCaptureFromFile(const QString& fileAbsPath)
{
	QString imagePath = fileAbsPath;

	QFile imageFile(imagePath);
	bool openResult = imageFile.open(QIODevice::ReadOnly);
	qDebug() << "saveCaptureFromFile:(" << imagePath << ")open-returns:" << openResult;
	QByteArray fileData = imageFile.readAll();
   //QByteArray hashData = QCryptographicHash::hash(fileData, QCryptographicHash::Md5);
   //qDebug() << "saveCaptureFromFile:file-MD5=" << hashData.toHex();

	qDebug() << "saveCaptureFromFile:file-size=" << imageFile.size();
	qDebug() << "saveCaptureFromFile:filepath:" << fileAbsPath;
	if ( imagePath.startsWith("file:///") )
		imagePath = imagePath.remove(QRegExp("^file:\\/\\/"));
	else if ( fileAbsPath.startsWith("file:") )
		imagePath = imagePath.remove(QRegExp("^file:"));
	qDebug() << "saveCaptureFromFile:filepath(processed):" << imagePath;

	this->image = QImage(imagePath);
	qDebug() << "saveCaptureFromFile:image:" << this->image.size();
}

int PhotoCaptureController::crop(double scaledImageWidth, double scaledImageHeight,
	double cropX, double cropY, double cropWidth, double cropHeight,
	double afterCropScaleWidth, double afterCropScaleHeight)
{
	qDebug() << "image========================>" << this->image;
	QImage image = this->image;
	qDebug() << "realImageWidth===>" << image.width();
	qDebug() << "realImageHeight===>" << image.height();
	int realImageWidth = image.width();
	int realImageHeight = image.height();

	double realCropX = cropX*realImageWidth/scaledImageWidth;
	double realCropY = cropY*realImageHeight/scaledImageHeight;
	double realCropWidth = cropWidth*realImageWidth/scaledImageWidth;
	double realCropHeight = cropHeight*realImageHeight/scaledImageHeight;

	qDebug() << "realCropX===>" << realCropX;
	qDebug() << "realCropY===>" << realCropY;
	qDebug() << "realCropWidth===>" << realCropWidth;
	qDebug() << "realCropHeight===>" << realCropHeight;
	QImage copy = image.copy(
		realCropX,
		realCropY,
		realCropWidth,
		realCropHeight
	);
	qDebug() << "after crop, image=" << copy.size();

	int id = -1;
	if ( afterCropScaleWidth > 0 && afterCropScaleHeight > 0 )
	{
		QImage scaledCopy = copy.scaled(afterCropScaleWidth, afterCropScaleHeight, Qt::KeepAspectRatio);
		id = imageProvider->setImage(scaledCopy);
		qDebug() << "id=======>" << id;
		qDebug() << "scaledCopy=======>" << scaledCopy;

	}
	else
	{
		id = imageProvider->setImage(copy);
		qDebug() << "id=======>" << id;
		qDebug() << "aaaaaaaaaaaaaaaaaaaaaaaaaaaaa" << copy;
	}

		//this->setProvider("");
	//this->setProvider(QString("image://capture/crop_")+id);
	//emit this->providerChanged();
	return id;
}


}//namespace qt
}//namespace wpp
