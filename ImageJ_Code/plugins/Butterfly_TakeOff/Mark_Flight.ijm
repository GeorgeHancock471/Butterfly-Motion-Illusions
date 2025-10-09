nF=15;

xh=newArray(nF);
yh=newArray(nF);
waitForUser("Mark Centre Head");
for(i=0;i<nF+1;i++){
s=i*(nSlices/nF)+1;
if(s>nSlices) s=nSlices;
setSlice(s);
run("Select None");
setTool("point");
while(selectionType==-1){
wait(500);
}
Roi.getCoordinates(x1,y1);
xh[i]=x1[0];
yh[i]=y1[0];
}


xt=newArray(nF);
yt=newArray(nF);
waitForUser("Mark Base Head");
for(i=0;i<nF+1;i++){
s=i*(nSlices/nF)+1;
if(s>nSlices) s=nSlices;
setSlice(s);
run("Select None");
setTool("point");
while(selectionType==-1){
wait(500);
}
Roi.getCoordinates(x1,y1);
xt[i]=x1[0];
yt[i]=y1[0];
}


makeSelection("polyline", xh, yh);
roiManager("Add");
makeSelection("polyline", xt, yt);
roiManager("Add");
