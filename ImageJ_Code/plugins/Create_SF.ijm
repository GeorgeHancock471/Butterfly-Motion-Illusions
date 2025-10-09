
thresh = 5; // This is the brightness of the false-colour image output 5 for 10:20, 10 for 5:10

sG=3.5;
tG=5;

run("Duplicate...", "title=Temporal duplicate");
run("Gaussian Blur 3D...", "x=0 y=0 z=1");
run("Reduce...", "reduction=2");
run("32-bit");
run("Gaussian Blur 3D...", "x=&sG y=&sG z=&tG");

setBatchMode(true);
run("Elemental Motion Detector2");

//--------------------Measure Motion Detector Profiles---------------------------

selectImage("Left Detectors");
run("Select All");
for(i=0; i<nSlices; i++){
	setSlice(i+1);
	getStatistics(area, mean);
	setResult("Left", i, mean);
}

run("Blue");
setMinAndMax(0, thresh);
run("RGB Color");

selectImage("Right Detectors");
run("Select All");
for(i=0; i<nSlices; i++){
	setSlice(i+1);
	getStatistics(area, mean);
	setResult("Right", i, mean);
}

run("Blue");
setMinAndMax(0, thresh);
run("RGB Color");

selectImage("Up Detectors");
run("Select All");
for(i=0; i<nSlices; i++){
	setSlice(i+1);
	getStatistics(area, mean);
	setResult("Up", i, mean);
}
run("Green");
setMinAndMax(0, thresh);
run("RGB Color");

selectImage("Down Detectors");
run("Select All");
for(i=0; i<nSlices; i++){
	setSlice(i+1);
	getStatistics(area, mean);
	setResult("Down", i, mean);
}
run("BlueRed");
setMinAndMax(0, thresh);
run("RGB Color");

imageCalculator("Add stack", "Left Detectors","Right Detectors");
imageCalculator("Add stack", "Up Detectors","Left Detectors");
//imageCalculator("Add stack", "Up Detectors","Down Detectors");
rename("SF Motion Map");

setBatchMode("show");


