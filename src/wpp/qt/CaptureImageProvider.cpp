#include "CaptureImageProvider.h"

#include <QImage>
#include <QDebug>

namespace wpp
{
namespace qt
{

CaptureImageProvider::CaptureImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image), id(0)
{
}

int CaptureImageProvider::setImage(const QImage& image)
{
	qDebug() << __FUNCTION__ << "param(image):" << image.size();
	this->image = image;
	qDebug() << __FUNCTION__ << "member(image):" << this->image.size();
	this->id++;
	return this->id;
}

QImage CaptureImageProvider::requestImage(const QString&, QSize*, const QSize& )
{
	qDebug() << __FUNCTION__ << ":image=" << this->getImage().size()
			 << "==" << this->getImage().width() << "x" << this->getImage().height();
	return this->getImage();
}

}
}
