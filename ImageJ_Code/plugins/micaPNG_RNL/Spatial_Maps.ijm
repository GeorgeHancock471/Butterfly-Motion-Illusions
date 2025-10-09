// Produce Sum Channels

if(isOpen("Sum_All")) close("Sum_All");
if(isOpen("Sum_0")) close("Sum_0");
if(isOpen("Sum_45")) close("Sum_45");
if(isOpen("Sum_90")) close("Sum_90");
if(isOpen("Sum_135")) close("Sum_135");
if(isOpen("Gabor output")) close("Gabor output");


run("Gabor ROI Bandpass Smooth", "number_of_angles=4 sigma=2 gamma=1 frequency=3 number_of_octaves=6 label=Gabor");

// Sum All
//+++++++++++++++++++++++
selectImage("Gabor output");
run("Duplicate...", "title=Sum_All duplicate"); nS=nSlices;
for(i=0;i<6;i++){
setSlice(i+1);

for(j=0;j<3;j++){
setSlice(i+1);
run("Copy"); setPasteMode("Add");
run("Delete Slice");
setSlice(i+1); run("Paste");
}
}
run("Multiply...","value=-1 stack");


// Sum 0
//+++++++++++++++++++++++
mArray=newArray(1,0,0,0);
selectImage("Gabor output");
run("Duplicate...", "title=Sum_0 duplicate"); nS=nSlices;
for(i=0;i<6;i++){
setSlice(i+1);
v= mArray[0];
run("Multiply...","value=v");
for(j=0;j<3;j++){
setSlice(i+1);
run("Copy"); setPasteMode("Add");
run("Delete Slice");
setSlice(i+1); 
v= mArray[j+1];
run("Multiply...","value=v");
run("Paste");
}
}
run("Multiply...","value=-1 stack");

// Sum 45
//+++++++++++++++++++++++
mArray=newArray(0,1,0,0);
selectImage("Gabor output");
run("Duplicate...", "title=Sum_45 duplicate"); nS=nSlices;
for(i=0;i<6;i++){
setSlice(i+1);
v= mArray[0];
run("Multiply...","value=v");
for(j=0;j<3;j++){
setSlice(i+1);
run("Copy"); setPasteMode("Add");
run("Delete Slice");
setSlice(i+1); 
v= mArray[j+1];
run("Multiply...","value=v");
run("Paste");
}
}
run("Multiply...","value=-1 stack");

// Sum 90
//+++++++++++++++++++++++
mArray=newArray(0,0,1,0);
selectImage("Gabor output");
run("Duplicate...", "title=Sum_90 duplicate"); nS=nSlices;
for(i=0;i<6;i++){
setSlice(i+1);
v= mArray[0];
run("Multiply...","value=v");
for(j=0;j<3;j++){
setSlice(i+1);
run("Copy"); setPasteMode("Add");
run("Delete Slice");
setSlice(i+1); 
v= mArray[j+1];
run("Multiply...","value=v");
run("Paste");
}
}
run("Multiply...","value=-1 stack");

// Sum 135 //+++++++++++++++++++++++
mArray=newArray(0,0,0,1);
selectImage("Gabor output");
run("Duplicate...", "title=Sum_135 duplicate"); nS=nSlices;
for(i=0;i<6;i++){
setSlice(i+1);
v= mArray[0];
run("Multiply...","value=v");
for(j=0;j<3;j++){
setSlice(i+1);
run("Copy"); setPasteMode("Add");
run("Delete Slice");
setSlice(i+1); 
v= mArray[j+1];
run("Multiply...","value=v");
run("Paste");
}
}
run("Multiply...","value=-1 stack");

close("Gabor output");

