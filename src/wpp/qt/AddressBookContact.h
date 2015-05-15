#ifndef QT_ADDRESSBOOKCONTACT_H
#define QT_ADDRESSBOOKCONTACT_H

#include "AddressBookContactPhone.h"
#include "AddressBookContactEmail.h"

#include <QObject>
#include <QString>
#include <QList>
#include <QUrl>
#include <QStringList>


namespace wpp {
namespace qt {

class AddressBookContact : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString firstName READ getFirstName WRITE setFirstName NOTIFY firstNameChanged)
	Q_PROPERTY(QString lastName READ getLastName WRITE setLastName NOTIFY lastNameChanged)
	Q_PROPERTY(QString latinFullName READ getLatinFullName WRITE setLatinFullName NOTIFY latinFullNameChanged)
	Q_PROPERTY(QString fullName READ getFullName NOTIFY fullNameChanged)
	Q_PROPERTY(QByteArray profilePhotoData READ getProfilePhotoData WRITE setProfilePhotoData NOTIFY profilePhotoDataChanged)
	Q_PROPERTY(QList<QObject *> phones READ getPhones NOTIFY phonesChanged)
	Q_PROPERTY(int selectedPhonesCount READ getSelectedPhonesCount NOTIFY selectedPhonesCountChanged)
	Q_PROPERTY(QList<QObject *> emails READ getEmails NOTIFY emailsChanged)
	Q_PROPERTY(int selectedEmailsCount READ getSelectedEmailsCount NOTIFY selectedEmailsCountChanged)
	Q_PROPERTY(bool isSelected READ getIsSelected WRITE setIsSelected NOTIFY isSelectedChanged)
	Q_PROPERTY(bool isKeywordMatched READ getIsKeywordMatched WRITE setIsKeywordMatched NOTIFY isKeywordMatchedChanged)
	Q_PROPERTY(QString firstLetter READ getFirstLetter NOTIFY firstLetterChanged)
	Q_PROPERTY(bool isFirstPersonInGroup READ getIsFirstPersonInGroup WRITE setIsFirstPersonInGroup NOTIFY isFirstPersonInGroupChanged)
protected:
	QString firstName;
	QString lastName;
	QString latinFullName;//semi-dummy
	QString fullName;//dummy
	QByteArray profilePhotoData;
	QList<QObject *> phones;
	int selectedPhonesCount;//dummy
	QList<QObject *> emails;
	int selectedEmailsCount;//dummy
	bool isSelected;
	bool isKeywordMatched;
	QString firstLetter;
	bool isFirstPersonInGroup;
public:
	AddressBookContact(QObject *parent = 0): 
		QObject(parent), selectedPhonesCount(0), selectedEmailsCount(0), isSelected(false), isKeywordMatched(false), isFirstPersonInGroup(false)
	{}
	AddressBookContact(
		const QString& firstName, 
		const QString& lastName, 
		const QString& latinFullName,
		const QList<QObject *>& phones,
		const QList<QObject *>& emails,
		QObject *parent = 0
	)
	: QObject(parent),
		firstName(firstName),
		lastName(lastName),
		latinFullName(latinFullName),
		phones(phones), selectedPhonesCount(0),
		emails(emails), selectedEmailsCount(0),
		isSelected(false),
		isKeywordMatched(false),
		isFirstPersonInGroup(false)
	{
	}
	AddressBookContact( const AddressBookContact& copy, QObject *parent = 0 )
		: QObject(parent),
		firstName(copy.firstName),
		lastName(copy.lastName),
		latinFullName(copy.latinFullName),
		phones(copy.phones), selectedPhonesCount(0),
		emails(copy.emails), selectedEmailsCount(0),
		isSelected(copy.isSelected),
		isKeywordMatched(copy.isKeywordMatched),
		isFirstPersonInGroup(copy.isFirstPersonInGroup)
	{
	}
	~AddressBookContact()
	{
		qDeleteAll(phones); phones.clear();
		qDeleteAll(emails); emails.clear();
	}
	AddressBookContact& operator=( const AddressBookContact& copy )
	{
		this->firstName = copy.firstName;
		this->lastName = copy.lastName;
		this->latinFullName = copy.latinFullName;
		this->phones = copy.phones;
		this->selectedPhonesCount = 0;
		this->selectedEmailsCount = 0;
		this->emails = copy.emails;
		this->isSelected = copy.isSelected;
		this->isKeywordMatched = copy.isKeywordMatched;
		this->isFirstPersonInGroup = copy.isFirstPersonInGroup;
		return *this;
	}

	Q_INVOKABLE const QString& getFirstName() const { return firstName; }
	Q_INVOKABLE void setFirstName(const QString& firstName)
	{
		this->firstName = firstName.trimmed();
		emit this->firstNameChanged();
		if ( !latinFullName.isEmpty() )
		{
			latinFullName.clear();//invalidate latin name
			emit latinFullNameChanged();
			emit fullNameChanged();
		}
		emit firstLetterChanged();
	}

	Q_INVOKABLE const QString& getLastName() const { return lastName; }
	Q_INVOKABLE void setLastName(const QString& lastName)
	{
		this->lastName = lastName.trimmed();
		emit this->lastNameChanged();
		if ( !latinFullName.isEmpty() )
		{
			latinFullName.clear();//invalidate latin name
			emit latinFullNameChanged();
			emit fullNameChanged();
		}
		emit firstLetterChanged();
	}

	Q_INVOKABLE const QString getLatinFullName() const
	{
		if ( !latinFullName.isEmpty() )
		{
			//qDebug() << "return latinFullName:" << latinFullName;
			return latinFullName;
		}
		else if ( lastName.isEmpty() )
		{
			return firstName;
		}
		else if ( firstName.isEmpty() )
		{
			return lastName;
		}
		else
		{
			return firstName + " " + lastName;
		}
	}
	Q_INVOKABLE void setLatinFullName(const QString& latinFullName)
	{
		//qDebug() << "setLatinFullName...";
		this->latinFullName = latinFullName.trimmed();
		emit this->latinFullNameChanged();
		emit fullNameChanged();
		emit firstLetterChanged();
	}

	Q_INVOKABLE const QString getFullName() const
	{
		//qDebug() << "getFullName..." << firstName << " " << lastName;
		//qDebug() << "latinFullName:" << latinFullName;
		if ( this->latinFullName.isEmpty() )
		{
			//qDebug() << "getFullName...1";
			return getLatinFullName();
		}
		else
		{
			//qDebug() << "getFullName...2";
			return lastName + firstName;
		}
	}

	Q_INVOKABLE const QByteArray& getProfilePhotoData() const { return profilePhotoData; }
	Q_INVOKABLE void setProfilePhotoData(const QByteArray& profilePhotoData) { this->profilePhotoData = profilePhotoData; emit this->profilePhotoDataChanged(); }

	Q_INVOKABLE const QList<QObject *>& getPhones() const { return phones; }
	Q_INVOKABLE QList<QObject *>& getPhones() { return phones; }
	Q_INVOKABLE int getSelectedPhonesCount() const
	{
		int count = 0;
		for ( QObject *obj: phones )
		{
			wpp::qt::AddressBookContactPhone *phone = dynamic_cast<wpp::qt::AddressBookContactPhone *>(obj);
			if ( phone->getIsSelected() )
				count++;
		}
		return count;
	}
	Q_INVOKABLE int selectOnePhone();
	Q_INVOKABLE void clearSelectedPhones()
	{
		for ( QObject *obj: phones )
		{
			wpp::qt::AddressBookContactPhone *phone = dynamic_cast<wpp::qt::AddressBookContactPhone *>(obj);
			phone->setIsSelected(false);
		}
	}

	Q_INVOKABLE const QList<QObject *>& getEmails() const { return emails; }
	Q_INVOKABLE QList<QObject *>& getEmails() { return emails; }
	Q_INVOKABLE int getSelectedEmailsCount() const
	{
		qDebug() << "getSelectedEmailsCount...";
		qDebug() << "getSelectedEmailsCount...emails.length=" << emails.length();
		int count = 0;
		for ( QObject *obj: emails )
		{
			qDebug() << "loop email...";
			wpp::qt::AddressBookContactEmail *email = dynamic_cast<wpp::qt::AddressBookContactEmail *>(obj);
			qDebug() << "loop email...222";
			if ( email->getIsSelected() )
				count++;
			qDebug() << "loop email...333";
		}
		qDebug() << "getSelectedEmailsCount...return=" << count;
		return count;
	}
	Q_INVOKABLE int selectOneEmail();
	Q_INVOKABLE void clearSelectedEmails()
	{
		for ( QObject *obj: emails )
		{
			wpp::qt::AddressBookContactEmail *email = dynamic_cast<wpp::qt::AddressBookContactEmail *>(obj);
			email->setIsSelected(false);
		}
	}

	Q_INVOKABLE int selectOnePhoneOrEmail();

	Q_INVOKABLE bool getIsSelected() const { return this->isSelected; }
	Q_INVOKABLE void setIsSelected(bool isSelected) { this->isSelected = isSelected; emit this->isSelectedChanged(); }

	Q_INVOKABLE bool getIsKeywordMatched() const { return this->isKeywordMatched; }
	Q_INVOKABLE void setIsKeywordMatched(bool isKeywordMatched) { this->isKeywordMatched = isKeywordMatched; emit this->isKeywordMatchedChanged(); }

	Q_INVOKABLE void keywordMatching(const QString& keywordLowercase);

	Q_INVOKABLE const QString getFirstLetter() const
	{
		QString latinFullName = this->getLatinFullName();
		if ( latinFullName.isEmpty() )
			return QString();

		QChar firstChar = latinFullName.at(0);
		return QString(firstChar);
	}

	Q_INVOKABLE bool getIsFirstPersonInGroup() const { return isFirstPersonInGroup; }
	Q_INVOKABLE void setIsFirstPersonInGroup(bool isFirstPersonInGroup) { this->isFirstPersonInGroup = isFirstPersonInGroup; emit this->isFirstPersonInGroupChanged(); }

signals:
	void firstNameChanged();
	void lastNameChanged();
	void latinFullNameChanged();
	void fullNameChanged();
	void profilePhotoDataChanged();
	void phonesChanged();
	void emailsChanged();
	void isSelectedChanged();
	void selectedPhonesCountChanged();
	void selectedEmailsCountChanged();
	void isKeywordMatchedChanged();
	void firstLetterChanged();
	void isFirstPersonInGroupChanged();

};//end of class

}
}

QDebug operator<<( QDebug qdebug, const wpp::qt::AddressBookContact& contact );

#endif
