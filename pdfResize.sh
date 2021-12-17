#!/bin/bash
help="
	$0 low|mid|good|best|gray file.pdf
		low:	create a low quality version of the PDF file
		mid:	create a mid quality version of the PDF file (often smaller and of enough quality)
		good:	create a good quality version of the PDF file
		best:	create the best quality version of the PDF file
		gray:	create a gray version of the PDF file
		djvu:	create a djvu version of the PDF file
		qdjvu:	create a djvu version of the PDF file optimized for dpi size

		"

#gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen -sOutputFile=
if [ "$#" -ne 2 ]; then
	echo "$help"
	exit 0
fi

in=$2
len=${#in}
ext=${in:(-4)}
ext=`echo $ext|awk '{print toupper($0)}'`
opt=`echo $1|awk '{print tolower($0)}'`

if [ "$ext" != ".PDF" ]; then
	echo "Error: $2 is not a pdf"
	exit 1
fi

case "$opt" in
	"low")
		act="screen"
		type="quality"
		;;
	"mid")
		act="ebook"
		type="quality"
		;;
	"good")
		act="prepress"
		type="quality"
		;;
	"best")
		act="printer"
		type="quality"
		;;
	"gray")
		type="color"
		;;
	"djvu")
		type="djvu"
		;;
	"qdjvu")
		type="qdjvu"
		;;
	*)
		echo Invalid compression
		exit 1;
		;;
esac

len=`expr $len - 4`
oExt="_$opt.pdf"
base=${in:0:$len}
out=$base$oExt;

case "$type" in
	"quality")
		gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/$act -sOutputFile="$out" "$in"
		;;
	"color")
		gs -sDEVICE=pdfwrite -sProcessColorModel=DeviceGray -sColorConversionStrategy=Gray -dOverrideICC -o "$out" -f "$in"
		;;
	"djvu")
		pdf2djvu "$in" -o "$base.djvu"
		;;
	"qdjvu")
		pdf2djvu "$in" --guess-dpi  -o "${base}_q.djvu"
		;;
	*)
		exit 1;
		;;
esac

