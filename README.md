EPrints Plugins to check upload file (size and virus free)
==========================================================
This plugin add function to check upload file maxsize and virus free

Requirements
------------

In order to use the plugin you need the clamAV antivirus (http://www.clamav.net/)

Installation
------------

copy the file in the archive id:

cp cfg/cfg.d/upload.pl $EPRINTSHOME/archives/<archiveid>/cfg/cfg.d/
cp cfg/cfg.d/document_validate.pl $EPRINTSHOME/archives/<archiveid>/cfg/cfg.d/
mkdir -p $EPRINTSHOME/archives/<archiveid>/cfg/lang/{en,it}
cp cfg/lang/en/phrases/validate_upload_file.xml $EPRINTSHOME/archives/<archiveid>/cfg/lang/en/phrases/
cp cfg/lang/it/phrases/validate_upload_file.xml $EPRINTSHOME/archives/<archiveid>/cfg/lang/it/phrases/

reload apache

Configuration
-------------
Configure cfg/cfg.d/upload.pl and cfg/cfg.d/document_validate.pl
