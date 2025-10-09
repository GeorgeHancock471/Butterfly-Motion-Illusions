imageDIR = getDirectory("Directory: Select a 'folder of mspecs' or 'folder of mspec folders'");
setBatchMode(true);

fileList=getFileList(imageDIR);


FolderID=File.getName(imageDIR);


nOctaves=4;
nAngles=4;


for(F=0;F<fileList.length;F++){

while(roiManager("count")>0){
roiManager("select", newArray(roiManager("count")));
roiManager("delete");
}
close("*");

if(endsWith(fileList[F],".png")){

open(imageDIR+fileList[F]);

ImageID = getTitle();



run("Duplicate...", " ");
run("8-bit");
setThreshold(255,255);
run("Create Selection");
run("Make Inverse");
wl = getValue("Minor")/4;
roiManager("Add");
close();

roiManager("select",0);
run("Crop");

//makeRectangle(0,0,getWidth()/2,getHeight());
//run("Flip Horizontally", "slice");

//exit

minS = Math.pow(2,(nOctaves));
rescale=minS/(wl);

w = getWidth();
h = getHeight();

w= w*(rescale);
h=h*(rescale);
run("Select None");

run("Select None");
run("Size...", "width=&w height=&h constrain average interpolation=Bilinear");


for(i=0; i<roiManager("count"); i++){
roiManager("select", i);
run("Scale... ", "x=&rescale y=&rescale");	
Roi.move(0,0);
if(selectionType != -1) roiManager("Update");
}//i

run("RGB Stack");
setSlice(3);
run("Add Slice");
run("Set Label...", "label=alpha");
run("Set...","value=255");

saveAs("PNG", imageDIR+fileList[F]);


}}
setBatchMode(false);
waitForUser("Done");


