import QtQuick 2.4

ListModel {
	id: phoneNumberCountryCodeModel
	ListElement { text: QT_TR_NOOP("+852 (Hong Kong)"); countryCode: "852" }
	ListElement { text: QT_TR_NOOP("+86 (P.R.C)"); countryCode: "86" }
	ListElement { text: QT_TR_NOOP("+886 (Taiwan)"); countryCode: "886" }
}

