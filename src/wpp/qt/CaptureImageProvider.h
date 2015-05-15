#ifndef __WPP__QT__CAPTURE_IMAGE_PROVIDER_H__
#define __WPP__QT__CAPTURE_IMAGE_PROVIDER_H__

#include <QQuickImageProvider>
#include <QImage>

namespace wpp
{
namespace qt
{

class CaptureImageProvider : public QQuickImageProvider
{
protected:
	QImage image;
    int id;
public:
    CaptureImageProvider();

	const QImage& getImage() { return this->image; }
	int setImage(const QImage& image);

public:
    QImage requestImage(const QString& id, QSize* size, const QSize& requestedSize);
};

}
}

#endif // CAPTUREIMAGEPROVIDER_H
