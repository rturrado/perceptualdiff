#!/bin/bash -ex

# Script to run pdiff against a set of image file pairs, and check that the
# PASS or FAIL status is as expected.

#------------------------------------------------------------------------------
# Image files and expected perceptualdiff PASS/FAIL status.  Line format is
# (PASS|FAIL) image1.(tif|png) image2.(tif|png)
#
# Edit the following lines to add additional tests.
all_tests () {
cat <<EOF
FAIL Bug1102605_ref.tif Bug1102605.tif
PASS Bug1471457_ref.tif Bug1471457.tif
PASS cam_mb_ref.tif cam_mb.tif
FAIL fish2.png fish1.png
PASS square.png square_scaled.png
EOF
}

# Modify pdiffBinary to point to your compiled pdiff executable if desired.
pdiffBinary=../perceptualdiff

#------------------------------------------------------------------------------

totalTests=0
numTestsFailed=0

# Change to test directory
cd "$(dirname $0)"

# Run all tests.
while read expectedResult image1 image2 ; do
	if $pdiffBinary -verbose -scale "$image1" "$image2" | grep -q "^$expectedResult" ; then
		totalTests=$((totalTests+1))
	else
		numTestsFailed=$((numTestsFailed+1))
		echo "Regression failure: expected $expectedResult for \"$pdiffBinary $image1 $image2\"" >&2
	fi
done <<EOF
$(all_tests)
EOF
# (the above with the EOF's is a stupid bash trick to stop while from running
# in a subshell)

# Give some diagnostics:
if [[ $numTestsFailed == 0 ]] ; then
	echo "*** all $totalTests tests passed"
else
	echo "*** $numTestsFailed failed tests of $totalTests"
	exit $numTestsFailed
fi

# Run additional tests.
rm -f diff.png
$pdiffBinary -output diff.png -verbose fish[12].png || true
ls diff.png
rm -f diff.png
$pdiffBinary -verbose -scale fish1.png Aqsis_vase.png || true
$pdiffBinary -verbose -downsample 2 fish1.png Aqsis_vase.png || true
$pdiffBinary -verbose -sum-errors cam_mb_ref.tif cam_mb.tif
$pdiffBinary -verbose -colorfactor .5 -threshold 1000 -gamma 3 -luminance 90 cam_mb_ref.tif cam_mb.tif
$pdiffBinary -verbose -downsample 3 -scale -luminanceonly -fov 80 cam_mb_ref.tif cam_mb.tif
