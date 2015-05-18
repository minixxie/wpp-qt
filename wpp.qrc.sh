#!/bin/bash

qrc=$(echo "$0" | sed 's/\.sh$//')

cat <<EOF > "$qrc"
<RCC>
	<qresource prefix="/">
EOF

files="$files $(find identified-modules -name "*.qml")"
files="$files $(find identified-modules -name "qmldir")"

qml=$(find identified-modules -name "*.qml")
images=$(grep "\"qrc.*\"" $qml | sed 's/^.*qrc://' | sed 's/".*$//' | sed 's/^\/\/\///' | sed 's/^\/\///' | sed 's/\///')
files="$files
$images"


files=$(echo "$files" | sort | uniq)
for file in $files
do
	echo "		<file>$file</file>" >> "$qrc"
done

cat <<EOF >> "$qrc"
	</qresource>
</RCC>
EOF
