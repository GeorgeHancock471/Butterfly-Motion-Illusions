

bD=getDirectory("plugins")+"Butterfly_TakeOff/Backgrounds/"
B = getFileList(bD);

sD=getDirectory("plugins")+"Butterfly_TakeOff/Results.csv";
if(File.exists(sD)) File.delete(sD);


mW=0;
mH=0;

//Load Files
D=getDirectory("Select Take Off Directory");
F=getFileList(D);

for(f=0;f<F.length;f++){
close("*");

D1=D+F[f]+"Rotated_Blank_Natural.tif";
if(File.exists(D1)){
open(D1);

setSlice(1);
setTool("point");
waitForUser("Make Point 1");
Roi.getBounds(x1,y1,w,h);

setSlice(nSlices);
setTool("point");
waitForUser("Make Point 2");
Roi.getBounds(x2,y2,w,h);


distance= pow( pow(x1-x2,2) + pow(y1-y2,2), 0.5);


setSlice(nSlices);
setTool("line");
waitForUser("Draw Body Length");
bodyLength=getValue("Area");




print(F[f],"Distance=",distance);
print(F[f],"Length=",bodyLength);

} //if
} // loop



