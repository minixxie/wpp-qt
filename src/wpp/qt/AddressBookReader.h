#ifndef QT_APP_BASE_ADDRESS_BOOK_READER_H
#define QT_APP_BASE_ADDRESS_BOOK_READER_H

#include "AddressBookContact.h"
#include "ReadAddressBookPermissionDeniedException.h"
#include <QObject>
#include <QList>
#include <QVector>

#include <QFutureWatcher>
#include <QFuture>

namespace wpp
{
namespace qt
{

//ref: http://philjordan.eu/article/strategies-for-using-c++-in-objective-c-projects
//ref: http://philjordan.eu/article/mixing-objective-c-c++-and-objective-c++
//ref: http://el-tramo.be/blog/mixing-cocoa-and-qt/

struct AddressBookReaderImpl;

class AddressBookReader : public QObject
{
	Q_OBJECT
protected:
	AddressBookReader();
	//AddressBookReader( const AddressBookReader& ): QObject(0) {}//prevent from copying
	static AddressBookReader *singleton;
public:
	static AddressBookReader &getInstance();

private:
	AddressBookReaderImpl *impl;

	QFutureWatcher< QList<QObject*> > *futureWatcher;
	QFuture< QList<QObject*> > *future;
	const QObject * asyncLoadSlotReceiver;
	QString asyncLoadSlotMethod;
public:
	~AddressBookReader();

	Q_INVOKABLE bool isAvailable() const;
	/*
	 * Requires <uses-permission android:name="android.permission.READ_CONTACTS" /> in AndroidManifest.xml
	 */
	Q_INVOKABLE QList<QObject*> fetchAll() throw(ReadAddressBookPermissionDeniedException);
	Q_INVOKABLE void asyncFetchAll(const QObject * receiver, const char * method);

signals:
	void finishedAsyncLoadContact(QList<QObject*>);
private slots:
	Q_INVOKABLE void onBridgeAsyncFetchAll();//helper
public:
	static void sortContacts(QList<QObject*>& contacts);//helper
	static QList<QObject*>& addPinyin(QList<QObject*>& contacts);//helper
	static void groupByStartingLetter( QList<QObject*>& contacts );
};

}//namespace qt
}//namespace wpp

#endif
