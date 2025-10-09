//Temp
//............................................................................................
if(isOpen("Temp")) close("Temp");



//ROI
//............................................................................................
if(selectionType==-1){ // If no selection select the first ROI
roiManager(select",0);
}
rIndex = roiManager("index");

for(i=0;i<roiManager("count");i++){
    roiManager("select",i);
    name =  getMetadata("Label"); 
	print(name);
    if(name=="measureROI"){
    roiManager("select",i);
    roiManager("delete");
    i=roiManager("count");
}

roiManager("select",rIndex);

//New Image New Scale
//............................................................................................
run("Duplicate...", "title=Temp duplicate");

wl=getValue("Minor")/2;
minS = Math.pow(2,(6));
rescale=minS/(wl);

w=getWidth()*rescale;
r=getHeight()/getWidth();
h=w*r;

run("Size...", "width=&w height=&h depth=1 average interpolation=Bilinear");

roiManager("select",rIndex);
run("Scale... ", "x=&rescale y=&rescale");
Roi.move(0,0);
run("Enlarge...", "enlarge=-1");
roiManager("Add");
roiManager("select",roiManager("count")-1);
roiManager("rename","measureROI");
