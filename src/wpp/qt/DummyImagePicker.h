#ifndef WPP__QT__DUMMY_IMAGE_PICKER_H
#define WPP__QT__DUMMY_IMAGE_PICKER_H

#include <QQuickItem>

namespace wpp {
namespace qt {

class DummyImagePicker : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QString imagePath READ imagePath NOTIFY imagePathChanged)
	Q_PROPERTY(int maxPick READ maxPick WRITE setMaxPick NOTIFY maxPickChanged)

public:
	explicit DummyImagePicker(QQuickItem *parent = 0) : QQuickItem(parent) { }

    QString imagePath() {
        return m_imagePath;
    }

    QString m_imagePath;

	int m_maxPick;
	int maxPick() const { return m_maxPick; }
	void setMaxPick(int maxPick) { m_maxPick = maxPick; emit maxPickChanged(); }

signals:
    void imagePathChanged();
	void maxPickChanged();
	void accepted(const QStringList& paths);

public slots:
	void open() { }

};

}
}

#endif // IOSCAMERA_H
