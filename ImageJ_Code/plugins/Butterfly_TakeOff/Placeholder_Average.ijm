
run("32-bit");
setSlice(1);
roiManager("select",roiManager("count")-1);
m=getValue("Mean");
run("Select None");
for(i=0;i<nSlices;i++){
setSlice(i+1);
setZCoordinate(i);
changeValues(0,45,m);
changeValues(67,9999,m);
}
run("Median...", "radius=1 stack");
