/*
Title: Manual Measure EMD
Author: George Hancock & Jolyon Troscianko
Date: 03/03/2026

This script allows the user to measure the EMD as part of a batch script.

It does not output the motion colour maps.

The EMD script for ImageJ was created by Jolyon Troscianko

Results are output as a table which can be saved as a .csv file or extracted.

..................................................................
*/
run("32-bit");

thresh = 1; // This is the brightness of the false-colour image output 5 for 10:20, 10 for 5:10
setBatchMode(true);
run("Elemental Motion Detector Jolyon");

//--------------------Measure Motion Detector Profiles---------------------------
selectImage("Left Detectors");
run("Select All");
for(i=0; i<nSlices; i++){
	setSlice(i+1);
	getStatistics(area, mean);
	setResult("Left", i, mean);
}
selectImage("Right Detectors");
run("Select All");
for(i=0; i<nSlices; i++){
	setSlice(i+1);
	getStatistics(area, mean);
	setResult("Right", i, mean);
}
selectImage("Up Detectors");
run("Select All");
for(i=0; i<nSlices; i++){
	setSlice(i+1);
	getStatistics(area, mean);
	setResult("Up", i, mean);
}
selectImage("Down Detectors");
run("Select All");
for(i=0; i<nSlices; i++){
	setSlice(i+1);
	getStatistics(area, mean);
	setResult("Down", i, mean);
}

close("Right Detectors");
close("Up Detectors");
close("Down Detectors");
close("Left Detectors");



