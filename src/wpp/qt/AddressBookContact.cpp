#include "AddressBookContact.h"

#include <QDebug>

namespace wpp
{
namespace qt
{

int AddressBookContact::selectOnePhone()
{
	qDebug() << "A1....";
	if ( getPhones().length() > 0 )
	{
		qDebug() << "A2....";
		if ( getSelectedPhonesCount() == 1 )
			return 0;

		qDebug() << "A3....";
		clearSelectedPhones();
		qDebug() << "A4....";
		wpp::qt::AddressBookContactPhone *phone = dynamic_cast<wpp::qt::AddressBookContactPhone *>(phones.first());
		qDebug() << "A5....";
		phone->setIsSelected(true);
		qDebug() << "A6....";
		return 1;
	}
	else
	{
		qDebug() << "A7....";
		return -1;
	}
}

int AddressBookContact::selectOneEmail()
{
	qDebug() << "B1....";
	if ( getEmails().length() > 0 )
	{
		qDebug() << "B2....";
		if ( getSelectedEmailsCount() == 1 )
			return 0;

		qDebug() << "B3....";
		clearSelectedEmails();
		qDebug() << "B4....";
		wpp::qt::AddressBookContactEmail *email = dynamic_cast<wpp::qt::AddressBookContactEmail *>(emails.first());
		qDebug() << "B5....";
		email->setIsSelected(true);
		qDebug() << "B6....";
		return 1;
	}
	else
	{
		qDebug() << "B7....";
		return -1;
	}
}

int AddressBookContact::selectOnePhoneOrEmail()
{
	if ( phones.length() > 0 && emails.length() == 0 )//has phones
	{
		if ( getSelectedPhonesCount() != 1 )
		{
			clearSelectedPhones();
			return selectOnePhone();
		}
	}
	else if ( phones.length() == 0 && emails.length() > 0 )//has emails
	{
		if ( getSelectedEmailsCount() != 1 )
		{
			clearSelectedEmails();
			return selectOneEmail();
		}
	}
	else if ( phones.length() > 0 && emails.length() > 0 )//has both
	{
		if ( getSelectedPhonesCount() + getSelectedPhonesCount() == 1 )
		{
			//NOP
			return 0;
		}
		else
		{
			clearSelectedPhones();
			clearSelectedEmails();
			return selectOnePhone();
		}
	}
	else//has none
	{
		//NOP
		return 0;
	}
	return 0;
/*
	qDebug() << "1111";
	int selectedEmailCount = getSelectedEmailsCount();
	qDebug() << "emailSelected=" << selectedEmailCount;
	int selectedPhoneCount = ;
	if ( selectedPhoneCount > 1 )
	{
		qDebug() << "2222";
		clearSelectedEmails();
		return selectOnePhone();
	}
	else if ( selectedPhoneCount < 1 )
	{
		qDebug() << "3333";
		int selectedEmailCount = getSelectedEmailsCount();
		qDebug() << "selectedEmailCount=" << selectedEmailCount;
		if ( selectedEmailCount > 1 )
		{
			qDebug() << "4444";
			return selectOneEmail();
		}
		else if ( selectedEmailCount < 1 )
		{
			qDebug() << "5555";
			return selectOnePhone();
		}
		else
		{
			qDebug() << "666";
			return 0;
		}
	}
	else
	{
		//qDebug() << "777";
		clearSelectedEmails();
		return 0;
	}
*/
}


void AddressBookContact::keywordMatching(const QString& keywordLowercase)
{
	QString fn = getFirstName().toLower();
	QString ln = getLastName().toLower();
	QString latin = getLatinFullName().toLower();
	int indexInFirstname = fn.indexOf( keywordLowercase );
	int indexInLastname = ln.indexOf( keywordLowercase );
	int indexInLatinName = latin.indexOf( keywordLowercase );
	qDebug() << "keywordMatching():fn=" << fn
			 << ",ln=" << ln
			 << ",latin=" << latin;
	qDebug() << "keywordMatching():indexInFirstname=" << indexInFirstname
			 << ":indexInLastname=" << indexInLastname
			 << ":indexInLatinName=" << indexInLatinName;
	if ( indexInFirstname >= 0 || indexInLastname >= 0 || indexInLatinName >= 0 )
	{
		setIsKeywordMatched(true);
	}
	else
	{
		setIsKeywordMatched(false);
	}
}

}
}

QDebug operator<<( QDebug qdebug, const wpp::qt::AddressBookContact& contact )
{
	qdebug << "firstName: " << contact.getFirstName();
	qdebug << "lastName: " << contact.getLastName();
	qdebug << "fullName: " << contact.getFullName();
	qdebug << "latinFullName: " << contact.getLatinFullName();
	qdebug << "firstLetter: " << contact.getFirstLetter();
	qdebug << "isFirstPersonInGroup: " << contact.getIsFirstPersonInGroup();
	return qdebug;
}
