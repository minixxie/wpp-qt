#ifndef WPP__QT__ANDROID_IMAGE_PICKER_H
#define WPP__QT__ANDROID_IMAGE_PICKER_H

#include <QQuickItem>
#include <QAndroidActivityResultReceiver>

namespace wpp {
namespace qt {

class AndroidImagePicker : public QQuickItem, QAndroidActivityResultReceiver
{
    Q_OBJECT
    Q_PROPERTY(QString imagePath READ imagePath NOTIFY imagePathChanged)
	Q_PROPERTY(int maxPick READ maxPick WRITE setMaxPick NOTIFY maxPickChanged)

public:
	explicit AndroidImagePicker(QQuickItem *parent = 0);

    QString imagePath() {
        return m_imagePath;
    }

    QString m_imagePath;

	virtual void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data);

signals:
    void imagePathChanged();
	void accepted(const QStringList& paths);

public slots:
    void open();

};

}
}

#endif // IOSCAMERA_H
