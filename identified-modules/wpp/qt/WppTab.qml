import QtQuick 2.1

import "./"

Item {
	id: "tab"
	property Item title
	property Item content
	property bool isSelected: false
	property bool hasNew: false

	signal selected
}
