# Overview
Script calls ```scanimage``` to scan many images. Saves images in specified
directory, with specified name containing timestamp.
Script supports delay between scanning next image (gives you time to put next
page on the scanner).
Scanning can be stopped with CTRL+C keystrokes. After scanning, script generates
PDF file from scanned images.
Script handles errors in communication between host and a scanner, even if
script will be interrupted, it can be continued and valid PDF file will be
generated (it sorts images by creation date, excluding empty files).

# Usage
```
USAGE: ./batch_scanning.sh -o=OUTPUT_NAME -d=OUTPUT_DIR [-r=RESOLUTION] [-m=MODE] [-e=DELAY]
```
