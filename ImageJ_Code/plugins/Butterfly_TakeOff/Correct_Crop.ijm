//Create Crop Area

while(roiManager("count")>0){
roiManager("select",0);
roiManager("delete");
}

run("Select None");

selectImage("Rotated_Blank_Natural.tif");

run("Duplicate...", "title=Temp duplicate");
for(i=0;i<nSlices-1;i++){
setSlice(i+1);
run("Copy"); setPasteMode("Add");
setSlice(i+2); run("Paste");
}
setThreshold(0,0);
run("Create Selection");
run("Make Inverse");
run("Fit Ellipse");
run("Scale... ", "x=2.5 y=2.5 centered");
roiManager("Add");
close();
roiManager("select",roiManager("count")-1);
run("Crop");
run("Save");

selectImage("Rotated_BackgroundMask.tif");
roiManager("select",roiManager("count")-1);
run("Crop");
run("Save");

close("*");
