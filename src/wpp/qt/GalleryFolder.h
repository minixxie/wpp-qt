#ifndef __WPP__QT__GALLERY_FOLDER_H__
#define __WPP__QT__GALLERY_FOLDER_H__

#include <QObject>
#include <QString>
#include <QVariant>

#include "GalleryPhoto.h"

namespace wpp
{
namespace qt
{

class GalleryFolder : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString id READ getId WRITE setId NOTIFY idChanged)
	Q_PROPERTY(QString name READ getName WRITE setName NOTIFY nameChanged)
	Q_PROPERTY(QVariant photos READ getPhotos WRITE setPhotos NOTIFY photosChanged)
	Q_PROPERTY(bool isSelected READ getIsSelected WRITE setIsSelected NOTIFY isSelectedChanged)

private:
	QString id;
	QString name;
	QVariant photos;//QList<QObject *> -> GalleryPhoto
	bool isSelected;

public:
	GalleryFolder()
		: isSelected(false)
	{
		photos.setValue( QVariant::fromValue( QList<QObject *>() ) );//empty list
	}
	GalleryFolder( const GalleryFolder& another )
		:
		QObject(),
		id( another.id ),
		name( another.name ),
		photos( another.photos ),
		isSelected( another.isSelected )
	{
	}

	GalleryFolder& operator=(const GalleryFolder& another)
	{
		id = another.id;
		name = another.name;
		photos = another.photos;
		isSelected = another.isSelected;
		return *this;
	}

	Q_INVOKABLE const QString& getId() const { return id; }
	Q_INVOKABLE void setId(const QString& id) { this->id = id; emit this->idChanged(); }

	Q_INVOKABLE const QString& getName() const { return name; }
	Q_INVOKABLE void setName(const QString& name) { this->name = name; emit this->nameChanged(); }

	Q_INVOKABLE const QVariant& getPhotos() const { return photos; }
	Q_INVOKABLE void setPhotos(const QVariant& photos) { this->photos = photos; emit this->photosChanged(); }
	Q_INVOKABLE void addPhoto(const GalleryPhoto& photo)
	{
		QList<QObject *> photoList = this->photos.value< QList<QObject *> >();
		photoList.push_front( new GalleryPhoto(photo) );
		setPhotos( QVariant::fromValue( photoList ) );
	}

	Q_INVOKABLE bool getIsSelected() const { return isSelected; }
	Q_INVOKABLE void setIsSelected(bool isSelected) { this->isSelected = isSelected; emit this->isSelectedChanged(); }

	Q_INVOKABLE void clearAllPhotoSelected()
	{
		QList<QObject *> photoList = this->photos.value< QList<QObject *> >();
		for ( QObject *obj : photoList )
		{
			GalleryPhoto *photo = dynamic_cast<GalleryPhoto *>( obj );
			photo->setIsSelected(false);
		}
	}

	Q_INVOKABLE int getSelectedPhotoCount()
	{
		int count = 0;
		QList<QObject *> photoList = this->photos.value< QList<QObject *> >();
		for ( QObject *obj : photoList )
		{
			GalleryPhoto *photo = dynamic_cast<GalleryPhoto *>( obj );
			if ( photo->getIsSelected() )
				count++;
		}
		return count;
	}

signals:
	void idChanged();
	void nameChanged();
	void photosChanged();
	void isSelectedChanged();

};

}
}

#endif
