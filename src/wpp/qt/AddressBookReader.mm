#include "AddressBookReader.h"
#import "AddressBookObjC.h"

namespace wpp
{
namespace qt
{

struct AddressBookReaderImpl
{
	AddressBookObjC *wrapped;
};

AddressBookReader::AddressBookReader()
	: impl(new AddressBookReaderImpl),
	  futureWatcher(0),
	  future(0),
	  asyncLoadSlotReceiver(0), asyncLoadSlotMethod()

{
	impl->wrapped = [[AddressBookObjC alloc] init];
}

AddressBookReader::~AddressBookReader()
{
	if ( impl != 0 )
	{
		//[impl->wrapped release];
		delete impl;
		impl = 0;
	}
}

QList<QObject*> AddressBookReader::fetchAll() throw(ReadAddressBookPermissionDeniedException)
{
	/*if ( contactsLoaded )
		return contacts;

	contacts.clear();
	contacts = [impl->wrapped fetchAll];
	emit this->contactsChanged();
	return contacts;*/
	QList<QObject*> contacts = [impl->wrapped fetchAll];
	addPinyin(contacts);
	sortContacts(contacts);
	groupByStartingLetter(contacts);

	int i = 0;
	for ( QObject *obj: contacts )
	{
		wpp::qt::AddressBookContact *contact = dynamic_cast<wpp::qt::AddressBookContact *>(obj);
		qDebug() << "-->[" << i << "]";
		qDebug() << *contact;
		i++;
	}
	return contacts;
}


}//namespace qt
}//namespace wpp

