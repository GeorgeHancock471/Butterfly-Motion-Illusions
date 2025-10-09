//Set Colours
setBackgroundColor(0, 0, 0);
setForegroundColor(0, 0, 0);


//Initiate loop
goingGate=1;

while(goingGate){
close("*");
//Delete Rois
while(roiManager("count")>0){
roiManager("select",Array.getSequence(roiManager("count")-1));
roiManager("delete");
}


D = File.openDialog("Select Tif");

sD1 = File.getParent(D)+"/Rotated_Blank_Natural.tif";
sD2 = File.getParent(D)+"/Rotated_BackgroundMask.tif";


open(D);
t=getTitle();
run("32-bit");
run("Select None");


Dialog.createNonBlocking("Choose Slices to keep");
Dialog.addNumber("Start Slice", 1);
Dialog.addNumber("End Slice",nSlices);
Dialog.show();
keepStart = Dialog.getNumber();
keepEnd = Dialog.getNumber();

oEnd=nSlices;

for(i=0; i<oEnd-keepEnd;i++){
setSlice(nSlices);
run("Delete Slice");
}

for(i=0; i<keepStart-1;i++){
setSlice(1);
run("Delete Slice");
}



v=getValue(0,0);
for(i=0;i<nSlices;i++){
setSlice(i+1);
setThreshold(v,v);
run("Create Selection");
run("Set...","value=0");
run("Make Inverse");
//run("Set...","value=1");
}

run("Select None");
setTool("point");
setSlice(1);
waitForUser("Add Start ROI");
roiManager("Add");

setTool("point");
setSlice(nSlices);
waitForUser("Add End ROI");
roiManager("Add");


roiManager("select",0);
Roi.getCoordinates(x0,y0);

roiManager("select",1);
Roi.getCoordinates(x1,y1);


makeLine(x0[0],y0[0],x1[0],y1[0]);
waitForUser("Does this line make sense?");

A=getValue("Angle")-90;
run("Rotate... ", "angle=&A grid=1 interpolation=None fill enlarge stack");

//Crop

run("Duplicate...", "title=Temp duplicate");
for(i=0;i<nSlices-1;i++){
setSlice(i+1);
run("Copy"); setPasteMode("Add");
setSlice(i+2); run("Paste");
}
waitForUser(" Rectangle");
roiManager("Add");
close();
roiManager("select",roiManager("count")-1);
run("Crop");

//SAVE
save(sD1);


//BACKGROUND MASK
for(i=0;i<nSlices;i++){
setSlice(i+1);
setThreshold(0,0);
run("Create Selection");
run("Set...","value=1");
run("Make Inverse");
run("Set...","value=0");
}

//SAVE
save(sD2);


//CONTINUE
goingGate=getBoolean("Keep going?","Yes","No");
}
