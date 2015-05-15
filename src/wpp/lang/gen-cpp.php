#!/usr/bin/env php
<?php

$fp = fopen(__DIR__."/uc-to-py.tbl","r");

if ( $fp === FALSE )
{
	fprintf(STDERR, "Error opening file\n");
	exit(-1);
}

$lineLen = 50;
$lastLongestLen = 0;

echo "#include \"Pinyin.h\"\n";
echo "\n";
echo "namespace wpp {\n";
echo "namespace lang {\n";
echo "char Pinyin::DATA[][$lineLen] = {\n";

$lineCount = 0;
while ( !feof( $fp ) )
{
	$line = fgets($fp);
	if ( preg_match( '/# Punctuation/', $line ) )
		break;
	$line = rtrim( trim( preg_replace('/#.*$/','',$line) ) );
	if ( strlen($line) != 0 )
	{
		list($ucs4, $pys) = explode(' ', $line);
		if ( $pys == "(none0)" )
			continue;

		$pylist = str_replace(',', ' ', preg_replace('/^\(/','', preg_replace( '/\)$/', '', $pys ) ) );
#var_dump($pylist);
#echo "$pylist...\n";
		list($byte1, $byte2) = str_split($ucs4, 2);
		$line = "$ucs4 $pylist";
		echo "\t\"\x$byte2\x$byte1 $pylist\",\n";
		$lineCount++;
		if ( strlen($line) > $lastLongestLen )
			$lastLongestLen = strlen($line);
	}
}

echo "};\n";
echo "int Pinyin::DATA_COUNT = $lineCount;\n";

echo "}//namespace\n";
echo "}//namespace\n";

echo  "// longest line: $lastLongestLen characters.\n";
if ( $lineLen < $lastLongestLen + 1 )
{
	echo "// Warning: lineLen=$lineLen which is NOT enough! correct the script!\n";
}
fclose($fp);

?>
