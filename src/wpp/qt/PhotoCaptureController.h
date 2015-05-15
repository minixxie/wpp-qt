#ifndef PHOTO_CAPTURE_CONTROLLER_H
#define PHOTO_CAPTURE_CONTROLLER_H

#include "CaptureImageProvider.h"

#include <QQuickImageProvider>
#include <QObject>
#include <QString>
#include <QList>

namespace wpp
{
namespace qt
{

class PhotoCaptureController: public QObject
{
	Q_OBJECT
	Q_PROPERTY(QImage image READ getImage WRITE setImage NOTIFY imageChanged)
private:
	CaptureImageProvider *imageProvider;
	QQmlEngine *engine;
	QImage image;
public:
	PhotoCaptureController(
			CaptureImageProvider *imageProvider, //croped image saved into this provider
			QQmlEngine *engine)
		: imageProvider(imageProvider), engine(engine)
	{
	}

	Q_INVOKABLE const QImage& getImage() { return this->image; }
	Q_INVOKABLE void setImage(const QImage& image) { this->image = image; emit this->imageChanged(); }

	Q_INVOKABLE void saveCapture(QString requestId, int width, int height);
	Q_INVOKABLE void saveCaptureFromFile(const QString& fileAbsPath);
	Q_INVOKABLE int crop(double scaledImageWidth, double scaledImageHeight,
		double cropX, double cropY, double cropWidth, double cropHeight,
						 double afterCropScaleWidth = 0, double afterCropScaleHeight = 0);

signals:
	void imageChanged();

public slots:

};

}//namespace qt
}//namespace wpp

#endif
