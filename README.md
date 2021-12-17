# pdfResize
Small bash script to resize pdf

pdfResize uses ghostscript to resize the PDF and pdf2djvu to convert a pdf to djvu format.

The options are:
  - ./pdfResize best file.pdf : it produces a file file_best.pdf 
  - ./pdfResize good file.pdf : it produces a file file_good.pdf 
  - ./pdfResize mid file.pdf : it produces a file_mid.pdf
  - ./pdfResize low file.pdf : it produces a file_low.pdf
  - ./pdfResize gray file.pdf : it produces a file_gray.pdf
  - ./pdfResize djvu file.pdf : it produces a file.djvu
  - ./pdfResize qdjvu file.pdf : it produces a file_q.djvu

The only options I have found useful are:
  - ./pdfResize mid file.pdf : it produces a file that is often smaller and of similar quality to the original
  - ./pdfResize gray file.pdf : it produces a file that is gray colors (instead of being of full colors)
  - ./pdfResize djvu file.pdf : the djvu is often smaller than the pdf file

