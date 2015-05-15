#ifndef __WPP__QT__GALLERY_PHOTO_H__
#define __WPP__QT__GALLERY_PHOTO_H__

#include <QObject>
#include <QString>

namespace wpp
{
namespace qt
{

class GalleryPhoto : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString absolutePath READ getAbsolutePath WRITE setAbsolutePath NOTIFY absolutePathChanged)
	Q_PROPERTY(int width READ getWidth WRITE setWidth NOTIFY widthChanged)
	Q_PROPERTY(int height READ getHeight WRITE setHeight NOTIFY heightChanged)
	Q_PROPERTY(int orientation READ getOrientation WRITE setOrientation NOTIFY orientationChanged)
	Q_PROPERTY(bool isSelected READ getIsSelected WRITE setIsSelected NOTIFY isSelectedChanged)

private:
	QString absolutePath;
	int width;
	int height;
	int orientation;//in degree:0, 90, 180, 270
	bool isSelected;

public:
	GalleryPhoto() : QObject(), absolutePath(), width(0), height(0), orientation(0), isSelected(false) {}
	GalleryPhoto( const GalleryPhoto& another )
		: QObject(), absolutePath( another.absolutePath ),
		  width( another.width ),
		  height( another.height ),
		  orientation(another.orientation),
		  isSelected(false)
	{

	}

	Q_INVOKABLE const QString& getAbsolutePath() const { return absolutePath; }
	Q_INVOKABLE void setAbsolutePath(const QString& absolutePath) { this->absolutePath = absolutePath; emit this->absolutePathChanged(); }

	Q_INVOKABLE int getWidth() const { return width; }
	Q_INVOKABLE void setWidth(int width) { this->width = width; emit this->widthChanged(); }

	Q_INVOKABLE int getHeight() const { return height; }
	Q_INVOKABLE void setHeight(int height) { this->height = height; emit this->heightChanged(); }

	Q_INVOKABLE int getOrientation() const { return orientation; }
	Q_INVOKABLE void setOrientation(int orientation) { this->orientation = orientation; emit this->orientationChanged(); }

	Q_INVOKABLE bool getIsSelected() const { return isSelected; }
	Q_INVOKABLE void setIsSelected(bool isSelected) {
		if ( this->isSelected != isSelected )
		{
			this->isSelected = isSelected; emit this->isSelectedChanged();
		}
	}

signals:
	void absolutePathChanged();
	void widthChanged();
	void heightChanged();
	void orientationChanged();
	void isSelectedChanged();
};

}
}

#endif

