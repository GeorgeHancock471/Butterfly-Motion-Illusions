run("32-bit");
setTool("rectangle");
waitForUser("get body colour");
m=getValue("Mean");

run("Threshold...");
waitForUser("adjust threshold");

// Get current threshold values
getThreshold(lower, upper);
run("Select None");
for(i=0;i<nSlices;i++){
setSlice(i+1);
setZCoordinate(i);
changeValues(lower,upper,m);
}

resetThreshold;
run("Select None");
run("Median...", "radius=1.5 stack");
