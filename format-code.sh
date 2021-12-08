#!/bin/bash

usage() {
	echo "Usage:"
	echo Run without arguments for intercative mode.
	echo -q :  For non-interactive mode. Files will be modified if code formating is needed.
	echo -h : For usage.
	exit 0
}

interactive=1
while getopts :hq opt; do
	case "$opt" in
	q)
		interactive=0
		;;
	h)
		usage
		;;
	*)
		usage
		;;
	esac
done


git clang-format --style=Google --extensions=c,cc,h,java --diff --commit HEAD~1 > /tmp/clang9876.patch
require_changes=`grep -c "clang-format did not modify any files" /tmp/clang9876.patch`

if [ "$require_changes" -eq 0 ]; then
	if [ "$interactive" -eq 1 ]; then
		cat /tmp/clang9876.patch
		echo -ne "\nApply changes?[y/n] - "
		read input
		if [ "$input" != "y" ]; then
			echo -ne "\nExiting without making any change..\n"
			exit 0
		fi
	fi
	echo -ne "\nUpdating files..\n"
	git apply /tmp/clang9876.patch
	rm -f /tmp/clang9876.patch
else
	echo "No change required."
fi
