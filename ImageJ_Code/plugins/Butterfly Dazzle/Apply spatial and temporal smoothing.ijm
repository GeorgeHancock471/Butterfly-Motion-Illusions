sG = 8; // spatial Gaussian blur sigma (low pass only)
tG = 5; // temporal blur


run("Gaussian Blur 3D...", "x=0 y=0 z=1");
run("Reduce...", "reduction=2");
run("32-bit");
run("Gaussian Blur 3D...", "x=&sG y=&sG z=&tG");

oID = getImageID();
run("Duplicate...", "duplicate range=10-88");
dID = getImageID();

selectImage(oID);
close();

selectImage(dID);


//ts = "label=[" + imageName + "] generemfileloc=[" + geneRemFileLoc + "] row=" + row;
//run("Run Elemental Motion Detector  Butterflies GA", ts);
