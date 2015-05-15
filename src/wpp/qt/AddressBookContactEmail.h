#ifndef __WPP__QT__ADDRESS_BOOK_CONTACT_EMAIL_H__
#define __WPP__QT__ADDRESS_BOOK_CONTACT_EMAIL_H__

#include <QObject>
#include <QString>
#include <QLocale>

namespace wpp {
namespace qt {

class AddressBookContactEmail : public QObject
{
	Q_OBJECT
	Q_PROPERTY(int type READ getType WRITE setType NOTIFY typeChanged)
	Q_PROPERTY(QString email READ getEmail WRITE setEmail NOTIFY emailChanged)
	Q_PROPERTY(QString label READ getLabel WRITE setLabel NOTIFY labelChanged)
	Q_PROPERTY(bool isSelected READ getIsSelected WRITE setIsSelected NOTIFY isSelectedChanged)
public:
	enum {
		TYPE_CUSTOM = 0,
		TYPE_HOME,
		TYPE_WORK,
		TYPE_OTHER,
		TYPE_MOBILE
	};

private:
	QString email;
	int type;
	QString label;
	bool isSelected;
public:
	AddressBookContactEmail(): type(TYPE_OTHER), isSelected(false) { }
	AddressBookContactEmail(const QString& email, int type)
		: email(email), type(type), label(), isSelected(false)
	{
	}
	AddressBookContactEmail(const QString& email, const QString& label)
		: email(email), type(0), label(label), isSelected(false)
	{
	}

	Q_INVOKABLE int getType() const { return type; }
	Q_INVOKABLE void setType(int type) { this->type = type; emit this->typeChanged(); }

	Q_INVOKABLE const QString& getEmail() const { return email; }
	Q_INVOKABLE void setEmail(const QString& email) { this->email = email; emit this->emailChanged(); }

	Q_INVOKABLE const QString getLabel() const {
		if ( type != TYPE_CUSTOM && label.isEmpty() )
		{
			static const char typeStrings_en_US[][40] = {
				"", //TYPE_CUSTOM
				"Home", //TYPE_HOME
				"Work", //TYPE_WORK
				"Other", //TYPE_OTHER
				"Mobile", //TYPE_MOBILE
			};
			static const char typeStrings_zh_CN[][40] = {
				"", //TYPE_CUSTOM
				"住宅", //TYPE_HOME
				"单位", //TYPE_WORK
				"其他", //TYPE_OTHER
				"移动电话", //TYPE_MOBILE
			};
			static const char typeStrings_zh_HK[][40] = {
				"", //TYPE_CUSTOM
				"住宅", //TYPE_HOME
				"工作", //TYPE_WORK
				"其他", //TYPE_OTHER
				"流動電話", //TYPE_MOBILE
			};

			QString locale = QLocale::system().name();
			if ( locale == "zh_CN" )
				return typeStrings_zh_CN[ this->getType() ];
			else if ( locale == "zh_HK" || locale == "zh_TW")
				return typeStrings_zh_HK[ this->getType() ];
			else
				return typeStrings_en_US[ this->getType() ];
		}
		else
		{
			return label;
		}
	}
	Q_INVOKABLE void setLabel(const QString& label) { this->label = label; emit this->labelChanged(); }

	Q_INVOKABLE bool getIsSelected() const { return this->isSelected; }
	Q_INVOKABLE void setIsSelected(bool isSelected) { this->isSelected = isSelected; emit this->isSelectedChanged(); }

signals:
	void typeChanged();
	void emailChanged();
	void labelChanged();
	void isSelectedChanged();
};

}
}

#endif
