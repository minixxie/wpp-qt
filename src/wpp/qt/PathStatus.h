#ifndef __WPP__QT__PATH_STATUS_H__
#define __WPP__QT__PATH_STATUS_H__

#include <QObject>
#include <QStringList>

namespace wpp {
namespace qt {

class PathStatus: public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString path READ getPath WRITE setPath NOTIFY pathChanged)
	Q_PROPERTY(bool isDone READ getIsDone WRITE setIsDone NOTIFY isDoneChanged)
private:
	QString path;
	bool isDone;
public:
	PathStatus() : isDone(false) {}
	PathStatus(const QString& path) : path(path), isDone(false) {}

	Q_INVOKABLE const QString& getPath() const { return this->path; }
	Q_INVOKABLE void setPath(const QString& path) { if ( this->path != path ) { this->path = path; emit this->pathChanged(); } }
	Q_SIGNAL void pathChanged();

	Q_INVOKABLE bool getIsDone() const { return this->isDone; }
	Q_INVOKABLE void setIsDone(bool isDone) { if ( this->isDone != isDone ) { this->isDone = isDone; emit this->isDoneChanged(); } }
	Q_SIGNAL void isDoneChanged();

	Q_INVOKABLE void done(const QString& newPath)
	{
		this->isDone = true;
		this->path = newPath;
		emit this->isDoneChanged();
		emit this->pathChanged();
	}

	static QStringList toStringList(const QList<QObject*>& list)
	{
		QStringList result;
		for ( QObject *obj : list )
		{
			PathStatus *status = qobject_cast<PathStatus *>(obj);
			result.append(status->path);
		}
		return result;
	}
};

}
}

#endif
