#!/bin/bash
INFO="Script calls scanimage to scan many images. Saves images in specified
directory, with specified name containing timestamp.
Script supports delay between scanning next image (gives you time to put next
page on the scanner).
Scanning can be stopped with CTRL+C keystrokes. After scanning, script generates
PDF file from scanned images.
Script handles errors in communication between host and a scanner, even if
script will be interrupted, it can be continued and valid PDF file will be
generated (it sorts images by creation date, excluding empty files).
"

USAGE="USAGE: $0 -o=OUTPUT_NAME -d=OUTPUT_DIR [-r=RESOLUTION] [-m=MODE] [-e=DELAY]"

out_dir="$1"
out_name="$2"
resolution=75
delay=3
mode='Gray'
i=0

function on_exit() {
	echo "Scanned $i files stored in $out_dir, finishing ..."
	find "$out_dir" -size  0 -print -delete
	out_pdf_path="${out_dir}/${out_name}.pdf"
	# img2pdf --output "$out_pdf_path" "$out_dir"/*.tiff
	# get list of files sorted by creation date
	img2pdf --output "$out_pdf_path" $(find "$out_dir" -type f -name '*.tiff' -printf '%T@ %p\0' \
		| sort -zk 1n | sed -z 's/^[^ ]* //' | tr '\0' ' ')
	echo "PDF file $out_pdf_path generated"
	echo "exiting ..."
	exit 1
}

function wait_notify() {
	# write the dot n times, wait 1 sec after writing every dot,
	# write newline char at the end
	seq $1 | xargs -I% bash -c 'printf "." && sleep 1' && echo
}


# parse parameters
for i in "$@"
do
case $i in
    -o=* | --output-name=*) # base name for output files
    out_name="${i#*=}"
    ;;
    -d=* | --output-dir=*)  # directory, where files will be stored. Will be
							# created, if not exist
    out_dir=$(realpath "${i#*=}")
    ;;
    -r=* | --resolution=*)
    resolution="${i#*=}"
    ;;
	-m=* | --mode=*)  # scanning mode: Gray / Color / Lineart
	mode="${i#*=}"
	;;
    -e | --delay)  # delay (in seconds) between each scan
    delay="${i#*=}"
    ;;
    -h | --help)
    echo "$INFO"
    echo "$USAGE"
    exit 0
    ;;
    *)
    echo "ERROR: Unknown option."
    echo "$USAGE"
    # unknown option
    ;;
esac
done


trap on_exit INT

mkdir -p "$out_dir"
while true
do
	echo "Scanning page $((i + 1)) ..."
	out_path="${out_dir}/${out_name}_${i}_`date +"%Y_%m_%d_%I_%M_%p"`.tiff"
	scanimage --format tiff \
		--resolution "$resolution" \
		--mode "$mode" \
	> "$out_path"
	echo "Page scanned. Prepare next page"
	wait_notify $delay
	i=$((i + 1))
done
