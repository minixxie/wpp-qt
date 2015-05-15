#ifndef __WPP__QT__NATIVE_CAMERA_H__
#define __WPP__QT__NATIVE_CAMERA_H__

#include <QQuickItem>
#ifdef Q_OS_ANDROID
	#include <QAndroidActivityResultReceiver>
#endif


namespace wpp {
namespace qt {

#ifdef Q_OS_ANDROID
class NativeCamera : public QQuickItem, QAndroidActivityResultReceiver
#else
class NativeCamera : public QQuickItem
#endif
{
    Q_OBJECT
    Q_PROPERTY(QString imagePath READ imagePath NOTIFY imagePathChanged)

public:
	explicit NativeCamera(QQuickItem *parent = 0);

    QString imagePath() {
        return m_imagePath;
    }

    QString m_imagePath;

signals:
    void imagePathChanged();

public slots:
    void open();

private:
    void *m_delegate;
#ifdef Q_OS_ANDROID
	QAndroidJniObject takePhotoSavedUri;
	void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data);
#endif
};

}
}

#endif
