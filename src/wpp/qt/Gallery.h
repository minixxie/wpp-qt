#ifndef QT_APP_BASE_GALLERY_H
#define QT_APP_BASE_GALLERY_H

#include <QObject>
#include <QVariant>

#include <QFutureWatcher>
#include <QFuture>

#ifdef Q_OS_ANDROID
#include <QAndroidActivityResultReceiver>
#endif
namespace wpp
{
namespace qt
{

//struct AddressBookImpl;

class Gallery : public QObject
#ifdef Q_OS_ANDROID
		, QAndroidActivityResultReceiver
#endif
{
	Q_OBJECT
	Q_PROPERTY(QVariant folders READ getFolders WRITE setFolders NOTIFY foldersChanged)

private:
	QVariant folders;

	QFutureWatcher< QList<QObject*> > *futureWatcher;
	QFuture< QList<QObject*> > *future;
	const QObject * asyncLoadSlotReceiver;
	QString asyncLoadSlotMethod;

	const QObject * loadExternalAlbumFinishedReceiver;
	QString loadExternalAlbumFinishedMethod;

#ifdef Q_OS_ANDROID
	QAndroidJniObject takePhotoSavedUri;
#endif
	const QObject * loadExternalCameraFinishedReceiver;
	QString loadExternalCameraFinishedMethod;

public:
	Gallery();
	~Gallery();

	Q_INVOKABLE const QVariant& getFolders() const { return folders; }
	Q_INVOKABLE void setFolders(const QVariant& folders) { this->folders = folders; emit this->foldersChanged(); }

	Q_INVOKABLE int getTotalSelectedPhotoCount() const;
	Q_INVOKABLE QList<QObject *> getTotalSelectedPhoto() const;


    /*
     shall need: <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
     */
    Q_INVOKABLE QList<QObject *> fetchAll();
	Q_INVOKABLE void asyncFetchAll(const QObject * receiver, const char * method);
	Q_INVOKABLE void asyncFetchAll();

	Q_INVOKABLE void loadExternalAlbumBrowser(const QObject * receiver, const char * method);
	Q_INVOKABLE void loadExternalCameraApp(const QObject * receiver, const char * method);

signals:
	void foldersChanged();
	void finishedAsyncFetchAll(QList<QObject*>);

	void finishedPickPhoto(const QString&);
	void finishedShootPhoto(const QString&);

private slots:
	Q_INVOKABLE void onBridgeAsyncFetchAll();//helper

private:
#ifdef Q_OS_ANDROID
	virtual void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data);
#endif
};

}//namespace qt
}//namespace wpp

#endif
