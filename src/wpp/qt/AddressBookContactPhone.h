#ifndef __WPP__QT__ADDRESS_BOOK_CONTACT_PHONE_H__
#define __WPP__QT__ADDRESS_BOOK_CONTACT_PHONE_H__

#include <QObject>
#include <QString>
#include <QLocale>
#include <QDebug>

namespace wpp {
namespace qt {

class AddressBookContactPhone : public QObject
{
	Q_OBJECT
	Q_PROPERTY(int type READ getType WRITE setType NOTIFY typeChanged)
	Q_PROPERTY(QString phone READ getPhone WRITE setPhone NOTIFY phoneChanged)
	Q_PROPERTY(QString label READ getLabel WRITE setLabel NOTIFY labelChanged)
	Q_PROPERTY(bool isSelected READ getIsSelected WRITE setIsSelected NOTIFY isSelectedChanged)

public:
	enum {
		TYPE_CUSTOM = 0,
		TYPE_HOME,
		TYPE_MOBILE,
		TYPE_WORK,
		TYPE_FAX_WORK,
		TYPE_FAX_HOME,
		TYPE_PAGER,
		TYPE_OTHER,
		TYPE_CALLBACK,
		TYPE_CAR,
		TYPE_COMPANY_MAIN,
		TYPE_ISDN,
		TYPE_MAIN,
		TYPE_OTHER_FAX,
		TYPE_RADIO,
		TYPE_TELEX,
		TYPE_TTY_TDD,
		TYPE_WORK_MOBILE,
		TYPE_WORK_PAGER,
		TYPE_ASSISTANT,
		TYPE_MMS
	};

	static const QString normalize(const QString& phoneNum)
	{
		const char countryCodes[][8] = {
			"+1", "+86", "+886", "+852"
		};
		QString trimmed = phoneNum.trimmed();
		if ( trimmed.length() > 0 && trimmed.at(0) == '+' )//has country code
		{
			for ( unsigned int i = 0 ; i < sizeof(countryCodes) ; i++ )
			{
				qDebug() << countryCodes[i] << "==" << trimmed;
				if ( trimmed.startsWith( countryCodes[i] ) )
				{
					QString numberPart = trimmed.remove( countryCodes[i] ).remove(QRegExp("[^0-9\\*#]")).trimmed();
					return QString( countryCodes[i] ).append("-").append( numberPart );
				}
			}
			return trimmed.remove(QRegExp("[^0-9\\*#]")).trimmed();
		}
		else
		{
			return trimmed.remove(QRegExp("[^0-9\\*#]")).trimmed();
		}
	}

private:
	QString phone;
	int type;
	QString label;
	bool isSelected;
public:
	AddressBookContactPhone(): type(TYPE_OTHER) { }
	AddressBookContactPhone(const QString& phone, int type)
		: phone(normalize(phone)), type(type), label(), isSelected(false)
	{
	}
	AddressBookContactPhone(const QString& phone, const QString& label)
		: phone(normalize(phone)), type(0), label(label), isSelected(false)
	{
	}

	Q_INVOKABLE int getType() const { return type; }
	Q_INVOKABLE void setType(int type) { this->type = type; emit this->typeChanged(); }

	Q_INVOKABLE const QString& getPhone() const { return phone; }
	Q_INVOKABLE void setPhone(const QString& phone) { this->phone = normalize(phone); emit this->phoneChanged(); }

	Q_INVOKABLE const QString getLabel() const {
		if ( type != TYPE_CUSTOM && label.isEmpty() )
		{
			static const char typeStrings_en_US[][40] = {
				"", //TYPE_CUSTOM
				"Home", //TYPE_HOME
				"Mobile", //TYPE_MOBILE
				"Work", //TYPE_WORK
				"Work Fax", //TYPE_FAX_WORK
				"Home Fax", //TYPE_FAX_HOME
				"Pager", //TYPE_PAGER
				"Other", //TYPE_OTHER
				"", //TYPE_CALLBACK
				"", //TYPE_CAR
				"", //TYPE_COMPANY_MAIN
				"", //TYPE_ISDN
				"", //TYPE_MAIN
				"", //TYPE_OTHER_FAX
				"", //TYPE_RADIO
				"", //TYPE_TELEX
				"", //TYPE_TTY_TDD
				"", //TYPE_WORK_MOBILE
				"", //TYPE_WORK_PAGER
				"", //TYPE_ASSISTANT
				"", //TYPE_MMS
			};
			static const char typeStrings_zh_CN[][40] = {
				"", //TYPE_CUSTOM
				"住宅", //TYPE_HOME
				"移动电话", //TYPE_MOBILE
				"单位", //TYPE_WORK
				"单位传真", //TYPE_FAX_WORK
				"住宅传真", //TYPE_FAX_HOME
				"寻呼机", //TYPE_PAGER
				"其他", //TYPE_OTHER
				"", //TYPE_CALLBACK
				"", //TYPE_CAR
				"", //TYPE_COMPANY_MAIN
				"", //TYPE_ISDN
				"", //TYPE_MAIN
				"", //TYPE_OTHER_FAX
				"", //TYPE_RADIO
				"", //TYPE_TELEX
				"", //TYPE_TTY_TDD
				"", //TYPE_WORK_MOBILE
				"", //TYPE_WORK_PAGER
				"", //TYPE_ASSISTANT
				"", //TYPE_MMS
			};
			static const char typeStrings_zh_HK[][40] = {
				"", //TYPE_CUSTOM
				"住宅", //TYPE_HOME
				"流動電話", //TYPE_MOBILE
				"工作", //TYPE_WORK
				"工作傳真", //TYPE_FAX_WORK
				"住宅傳真", //TYPE_FAX_HOME
				"尋呼機", //TYPE_PAGER
				"其他", //TYPE_OTHER
				"", //TYPE_CALLBACK
				"", //TYPE_CAR
				"", //TYPE_COMPANY_MAIN
				"", //TYPE_ISDN
				"", //TYPE_MAIN
				"", //TYPE_OTHER_FAX
				"", //TYPE_RADIO
				"", //TYPE_TELEX
				"", //TYPE_TTY_TDD
				"", //TYPE_WORK_MOBILE
				"", //TYPE_WORK_PAGER
				"", //TYPE_ASSISTANT
				"", //TYPE_MMS
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

	Q_INVOKABLE int getIsSelected() const { return isSelected; }
	Q_INVOKABLE void setIsSelected(int isSelected) { this->isSelected = isSelected; emit this->isSelectedChanged(); }

signals:
	void typeChanged();
	void phoneChanged();
	void labelChanged();
	void isSelectedChanged();
};

}
}

#endif
