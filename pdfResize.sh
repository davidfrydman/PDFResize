#!/bin/bash
help="
    $0 argument file.pdf
       argument can be:

        -low:    create a low quality version of the PDF file
        -mid:    create a mid quality version of the PDF file (often smaller and of enough quality)
        -good:   create a good quality version of the PDF file
        -best:   create the best quality version of the PDF file
        -gray:   create a gray version of the PDF file
        -notext: remove the text layer of the PDF
        -zipScreen: compress the pdf for Screen size (72 dpi)
        -zipEbook: compress the pdf for eBook size (150 dpi)
        -zipPress: compress the pdf for Prepress size (300 dpi)
        

    Convert files to PDF:
    $0 argument file.type

        -doc2pdf: convert *.odt, *.doc, *.docx, *.rtf and *.txt files to PDF
        -img2pdf: convert images like *.jpg, *png, *.bmp to PDF
        -ps2pdf: convert postscript file *.ps to PDF
    
    Convert pdf to other format:
    $0 argument file.pdf
    
        -splitPNG: split a PDF to each page and produce a PNG image for each page
        -splitJPG: split a PDF to each page and produce a JPEG image for each page
        -split: split a PDF to each page and produce a PDF file for each page
        -ps: create a postscript version of the PDF
        -doc : create a microsoft word version of the PDF
        -text:   create a text version of the PDF
        -djvu:   create a djvu version of the PDF file
        -qdjvu:  create a djvu version of the PDF file optimized for dpi size
        -ordjvu: create a djvu version of the PDF file optimized for dpi size if and only if it's size is 10% less than the PDF. In that case the PDF file is save in the _PDF_ directory 
     
    Checking PDF
        -menuCheck : check the PDF has a menu, a text (or OCR) and number of pages. The result is return as follow:   PAGE_NB:TEXT:MENU
                if a book of 50 pages, is scanned but not OCR (each page is a picture) and it has a menu, the answer will be:   50::MENU
                if this book has a text but no menu: 50:TEXT:
        -urlList: return all the url within the book
        -jsCheck: check if a PDF has a javascript:
                  - returns 'TRUE' if it contains javascript
                  - returns 'FALSE' if it doesn't
        -pdfCheck: check the pdf for errors
                  - returns 'OK', 'WARNINGS' or 'ERRORS'
    
        -check:  check the needed programs are present
        -help | --help | -?:  this help
        "

function zipPDF(){
: <<'END_COMMENT'
    -dPDFSETTINGS=/screen — Low quality and small size at 72dpi.
    -dPDFSETTINGS=/ebook — Slightly better quality but also a larger file size at 150dpi.
    -dPDFSETTINGS=/prepress — High quality and large size at 300 dpi.
    -dPDFSETTINGS=/default — System chooses the best output, which can create larger PDF files.
END_COMMENT
    gs  -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/$3 -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$2" "$1"
    
}


####
# Function: menuCheck
# Action: check the number of page, the menu and if the PDF contains text or only pictures
####
function menuCheck(){

    pdf="$1"

    pageRead=$(pdfinfo "$pdf" 2>/dev/zero )
    pages=$(echo -n "$pageRead"| grep "Pages")
    pages=${pages##* }

    fonts=$(pdffonts -l 5 "$pdf" 2>/dev/zero  | tail -n +3 | cut -d' ' -f1 | sort | uniq)

    if [ "$fonts" == '' ] || [ "$fonts" == '[none]' ]; then
        text=""
    else
        text="TEXT"
    fi

    menuBase=$(pdftk "$pdf" dump_data 2>/dev/zero)
    menuNB=$(echo -n "$menuBase" |grep -c BookmarkTitle)
    if (( "$menuNB" < 3 )); then
        menu=""
    else
        menu="MENU"
    fi

    list=( "$pages" "$text" "$menu" )
    sep=""
    for i in "${list[@]}"; do
        echo -n     "$sep$i"
        if [[ "$i" != "" ]]; then
            sep=":"
        fi
    done
}



function checkApp(){
    app="$1"
    
    if command -v "$app" >/dev/zero; then
        echo -ne "$app: Found"
    else
        echo -ne "$app: Missing"
    fi
}

if [ "$#" -ne 2 ]; then
    if [ "$#" == 1 ]; then
        if [[ "$1" == "-check" ]]; then
        
            echo 
            echo "Checking for missing apps:"
            echo "=========================="
            echo
            
            n=$(checkApp gs); echo "  * $n -  needed for -low, -mid, -good, -best, -gray, -zipScreen, -zipEbook, -zipPress"
            n=$(checkApp pdf2txt); echo "  * $n - needed for -text"
            n=$(checkApp pdftk); echo "  * $n - needed for -notext, -menuCheck"
            n=$(checkApp pdf2djvu); echo "  * $n - needed for -djvu, -qdjvu, -ordjvu"
            n=$(checkApp pdf2ps); echo "  * $n - needed for -ps"
            n=$(checkApp gzip); echo "  * $n - needed for -ps"
            n=$(checkApp pdfseparate); echo "  * $n - needed for -split"
            n=$(checkApp soffice); echo "  * $n - needed for -doc2pdf, -doc" # Note that libreoffice should have a link to soffice
            n=$(checkApp convert); echo "  * $n - needed for -img2pdf"
            n=$(checkApp ps2pdf); echo "  * $n - needed for -ps2pdf"
            n=$(checkApp pdftoppm); echo "  * $n - needed for -splitPNG, -splitJPG"
            n=$(checkApp qpdf); echo  "  * $n - needed for -pdfCheck"
            n=$(checkApp pdfinfo); echo  "  * $n - needed for -jsCheck, -urlList, -menuCheck"
            echo
            exit 0
        fi
    fi
        
    echo "$help"
    exit 0
fi

in=$2
len=${#in}
ext=${in:(-4)}
ext=${ext^^}
opt=${1,,}
#ext=`echo $ext|awk '{print toupper($0)}'`
#opt=`echo $1|awk '{print tolower($0)}'`

fileTYPE="PDF"
case "$opt" in
    "--help" | "-?" | "-help")
        help
        ;;
    "-pdfcheck")
        type="pdfCheck"
        ;;
    "-jscheck")
        type="jsCheck";
        ;;
    "-urllist")
        type="urlList"
        ;;
    "-menucheck")
        type="menuCheck"
        ;;
    "-split")
        type="split";
        ;;
    "-text")
        type="pdfTXT";
        ;;
    "-ps")
        type="pdfPS";
        ;;
    "-low")
        act="screen"
        type="quality"
        ;;
    "-mid")
        act="ebook"
        type="quality"
        ;;
    "-good")
        act="prepress"
        type="quality"
        ;;
    "-best")
        act="printer"
        type="quality"
        ;;
    "-gray")
        type="color"
        ;;
    "-djvu")
        type="djvu"
        ;;
    "-qdjvu")
        type="qdjvu"
        ;;
    "-ordjvu")
        type="ORdjvu"
        ;;
    "-notext")
        type="noText"
        ;;
    "-zipscreen")
        type="compress"
        act="screen"
        ;;
    "-zipebook")
        type="compress"
        act="ebook"
        ;;
    "-zippress")
        type="compress"
        act="prepress"
        ;;
    "-doc2pdf")
        fileTYPE=""
        type="doc2pdf"
        ;;
    "-doc")
        type="pdf2doc"
        ;;
    "-img2pdf")
        fileTYPE=""
        type="img2pdf"
        ;;
    "-ps2pdf")
        fileTYPE=""
        type="ps2pdf"
        ;;
    "-splitpng")
        fileTYPE=""
        type="splitIMG"
        act="-png"
        ;;
    "-splitjpg")
        fileTYPE=""
        type="splitIMG"
        act="-jpeg"
        ;;
    *)
        echo Invalid compression
        exit 1;
        ;;
esac

if [[ "$fileTYPE" == "PDF" &&  "$ext" != ".PDF" ]]; then
    echo "Error: $2 is not a pdf"
    exit 1
fi


len=`expr $len - 4`
oExt="_${opt:1}.pdf"
base=${in:0:$len}
out=$base$oExt;

case "$type" in
    "pdfCheck")
        rc=$(qpdf --check "$in" 2> /dev/zero)
        #warning=$(echo "$rc"|grep -c -e WARNING -e ERROR)
        error=$(echo -n "$rc" |grep -c "ERROR:")
        warning=$(echo -n "$rc" |grep -c "WARNING:")
        if [[ "$warning" == 0 && "$error" == 0 ]]; then
            echo -n "OK"
        elif [[ "$error" == 0 ]]; then
            echo -n "WARNINGS"
        else
            echo -n "ERRORS"
        fi
        exit 0
        ;;
    "jsCheck")
        pdfinfo -js "$in" 2>/dev/zero 
        exit 0
        ;;
    "urlList")
        pdfinfo -url "$in" 2>/dev/zero 
        exit 0
        ;;
    "menuCheck")
        menuCheck "$in" 2>/dev/zero 
        exit 0
        ;;
    "doc2pdf")
        soffice --headless --convert-to pdf "$in"
        ;;
    "pdf2doc")
        soffice --infilter=="writer_pdf_import" --headless --convert-to doc:"writer_pdf_Export"  "$in"
        ;;
    "img2pdf")
        convert "$in" "$base.pdf"
        ;;
    "ps2pdf")
        ps2pdf "$in" 
        ;;
    "splitIMG")
        pdftoppm "$act" "$in" "$base"
        ;;
    "split")
        pdfseparate "$in" "$base.page.%d.pdf"
        ;;
    "compress")
        zipPDF  "$in" "$base.compress.$act.pdf" $act 
        ;;
    "noText")
        pdftk "$in" output - uncompress | sed -e 's/\[.*\]TJ/()Tj/' -e 's/(.*)Tj/()TJ/' | pdftk - output "$base.notext.pdf" compress
        ;;
    "quality")
        #gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/$act -sOutputFile="$out" "$in"
        gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sPAPERSIZE=a4 -dFIXEDMEDIA -dPDFFitPage -dCompatibilityLevel=1.4 -dPDFSETTINGS=/$act -sOutputFile="$out" "$in"
        #gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sPAPERSIZE=a4 -dCompatibilityLevel=1.4 -dPDFSETTINGS=/$act -sOutputFile="$out" "$in"
        ;;
    "color")
        #gs -sDEVICE=pdfwrite -sProcessColorModel=DeviceGray -sColorConversionStrategy=Gray -dOverrideICC -o "$out" -f "$in"
        gs -sDEVICE=pdfwrite -sPAPERSIZE=a4 -dFIXEDMEDIA -dPDFFitPage -sProcessColorModel=DeviceGray -sColorConversionStrategy=Gray -dOverrideICC -o "$out" -f "$in"
        ;;
    "pdfTXT")
        pdf2txt "$in" -o "$base.txt"
        ;;
    "pdfPS")
        pdf2ps "$in" 
        if [ -f "$base.ps" ]; then
            gzip -9 "$base.ps"
        fi
        ;;
    "djvu")
        pdf2djvu "$in" -o "$base.djvu"
        ;;
    "qdjvu")
        pdf2djvu "$in" --guess-dpi  -o "${base}_q.djvu"
        ;;
    "ORdjvu")
        pdf2djvu "$in" -o "$base.djvu"
        nDJVU=`stat -c %s "$base.djvu"`
        nPDF=`stat -c %s "$in"`

        # add 10% to the size of djvu so the size of djvu needs to be 10% less thant he size of PDF
        nDJVU=$((nDJVU*11/10))

        mkdir -p __PDF__
        if (( nPDF > nDJVU )); then
            mkdir -p __PDF__
            mv "$in" __PDF__
        else
            rm "$base.djvu"
        fi
        ;;

    *)
        exit 1;
        ;;
esac

