/*
Title: Manual Measure EMD
Author: George Hancock & Jolyon Troscianko
Date: 03/03/2026

This script allows the user to measure the EMD output for a .avi file or imageJ stack they have 
open in imageJ. It also outputs a colour map for the EMD for the consecutive frame paris
(nframes -1).

Green = Forwards
Purple = Backwards

Users can apply temporal and spatial blurring using the function:
run("Gaussian Blur 3D...", "x=2 y=2 z=2");

Where Z is time / frame.

The EMD script for ImageJ was created by Jolyon Troscianko

Results are output as a table which can be saved as a .csv file or extracted.

..................................................................
*/

waitForUser("Make sure you have an .avi or image stack open and selected");
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

run("Red");
//setMinAndMax(0, thresh);
run("RGB Color");

selectImage("Right Detectors");
run("Select All");
for(i=0; i<nSlices; i++){
	setSlice(i+1);
	getStatistics(area, mean);
	setResult("Right", i, mean);
}

run("Blue");
//setMinAndMax(0, thresh);
run("RGB Color");

selectImage("Up Detectors");
run("Select All");
for(i=0; i<nSlices; i++){
	setSlice(i+1);
	getStatistics(area, mean);
	setResult("Up", i, mean);
}
run("Green");
//setMinAndMax(0, thresh);
run("RGB Color");

selectImage("Down Detectors");
run("Select All");
for(i=0; i<nSlices; i++){
	setSlice(i+1);
	getStatistics(area, mean);
	setResult("Down", i, mean);
}
run("Magenta");
//setMinAndMax(0, thresh);
run("RGB Color");

imageCalculator("Add stack", "Left Detectors","Right Detectors");
imageCalculator("Add stack", "Left Detectors","Down Detectors");
imageCalculator("Add stack", "Left Detectors","Up Detectors");



selectImage("Right Detectors");
close();
selectImage("Up Detectors");
close();
selectImage("Down Detectors");
close();
selectImage("Left Detectors");
rename("Motion Map");

setBatchMode("show");



