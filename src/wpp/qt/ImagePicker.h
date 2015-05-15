#ifndef WPP__QT__IMAGE_PICKER_H
#define WPP__QT__IMAGE_PICKER_H

#include <QQuickItem>
#ifdef Q_OS_ANDROID
	#include <QAndroidActivityResultReceiver>
#endif
#include <QFutureWatcher>
#include <QFuture>

namespace wpp {
namespace qt {

#ifdef Q_OS_ANDROID
class ImagePicker : public QQuickItem, QAndroidActivityResultReceiver
#else
class ImagePicker : public QQuickItem
#endif
{
	Q_OBJECT
	Q_PROPERTY(int maxPick READ maxPick WRITE setMaxPick NOTIFY maxPickChanged)

public:
	explicit ImagePicker(QQuickItem *parent = 0);

	int m_maxPick;
	int maxPick() const { return m_maxPick; }
	void setMaxPick(int maxPick) { m_maxPick = maxPick; emit maxPickChanged(); }

signals:
	void imagePathChanged();
	void maxPickChanged();
	void startedImageProcessing();
	void accepted(const QStringList& paths);

public slots:
	void open();

#ifdef Q_OS_IOS
public slots:
	void onProcessImageFinished();
#endif

private:
	void *m_delegate;
public:
#ifdef Q_OS_IOS
	void __hideUI();
	void processImages(void *nsarray);
#endif
#ifdef Q_OS_ANDROID
	virtual void handleActivityResult(int receiverRequestCode, int resultCode, const QAndroidJniObject & data);
#endif

private:
	QFutureWatcher<void> *futureWatcher;
	QFuture<void> * future;
};


}
}

#endif // IOSCAMERA_H
