#!/bin/bash

qrc=$(echo "$0" | sed 's/\.sh$//')

cat <<EOF > "$qrc"
<RCC>
	<qresource prefix="/">
EOF

files="qmldir"
files="$files $(find qml -name "*.qml")"

qml=$(find qml -name "*.qml")
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
