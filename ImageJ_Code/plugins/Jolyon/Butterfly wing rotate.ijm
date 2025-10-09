
label = getTitle();
label = replace(label, ".tif", "");

//roiManager("Deselect");
//roiManager("Delete");


run("To ROI Manager");
run("From ROI Manager");
oID = getImageID();
run("Duplicate...", " ");
rename("forewing");
fwID = getImageID();

roiManager("select", 0);
fwAngle = getValue("Angle");
roiManager("Deselect");
roiManager("select", 1);
hwAngle = getValue("Angle");

hwAngle = 90-hwAngle;

// "angle" is the angle of a best-fitting ellipse
print("Forewing Angle: " + fwAngle);
print("Hindwing Angle: " + hwAngle);

roiManager("select", newArray(0,1,2));
roiManager("Delete");

run("Select None");
run("Rotate... ", "angle=&fwAngle grid=1 interpolation=None enlarge");

run("To ROI Manager");

run("RGB Stack");
run("32-bit");
run("Linearisation Function", "equation=[JT Linearisation] a=252.285282435 b=1.294312365 c=0.001217645 d=0.028759277 slice=1");
run("Linearisation Function", "equation=[JT Linearisation] a=252.285282435 b=1.294312365 c=0.001217645 d=0.028759277 slice=2");
run("Linearisation Function", "equation=[JT Linearisation] a=252.285282435 b=1.294312365 c=0.001217645 d=0.028759277 slice=3");
run("Butterfly Scanner Linear Bluetit LMS D65 ");
run("Log", "stack");
setSlice(4);
run("Enhance Contrast", "saturated=0.35");

roiManager("select", 0);

ts = label + "_forewing_angle" + fwAngle;

run("Gabor ROI Bandpass", "number_of_angles=4 sigma=3 gamma=1 frequency=2 number_of_octaves=8 label=&ts");

//waitForUser("forewing");
close();
close();
close();

selectImage(oID);

run("Duplicate...", " ");
rename("hindwing");
hwID = getImageID();

run("Select None");
run("Rotate... ", "angle=&hwAngle grid=1 interpolation=None enlarge");

run("To ROI Manager");

run("RGB Stack");
run("32-bit");
run("Linearisation Function", "equation=[JT Linearisation] a=252.285282435 b=1.294312365 c=0.001217645 d=0.028759277 slice=1");
run("Linearisation Function", "equation=[JT Linearisation] a=252.285282435 b=1.294312365 c=0.001217645 d=0.028759277 slice=2");
run("Linearisation Function", "equation=[JT Linearisation] a=252.285282435 b=1.294312365 c=0.001217645 d=0.028759277 slice=3");
run("Butterfly Scanner Linear Bluetit LMS D65 ");
run("Log", "stack");
setSlice(4);
run("Enhance Contrast", "saturated=0.35");

roiManager("select", 1);

ts = label + "_hindwing_angle" + hwAngle;

run("Gabor ROI Bandpass", "number_of_angles=4 sigma=3 gamma=1 frequency=2 number_of_octaves=8 label=&ts");


//waitForUser("hindwing");
close();
close();
close();







