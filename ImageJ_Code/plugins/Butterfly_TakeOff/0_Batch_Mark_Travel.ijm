D=getDirectory("Select Take Off Directory");
F=getFileList(D);


sD=getDirectory("plugins")+"Butterfly_TakeOff/Flight_Direction.csv";
if(File.exists(sD)) File.delete(sD);

tA = newArray("ID","SubFrame","Heading_X1","Heading_Y1","Heading_X2","Heading_Y2");
tAs = String.join(tA,",");
File.append(tAs,sD);



Dialog.createNonBlocking("Choose Start");
Dialog.addChoice("ChooseStart", F);
Dialog.show();
startID = Dialog.getChoice();
for(f=0;f<F.length;f++){
if(F[f]==startID) sF = f;
}


for(f=sF;f<F.length;f++){
close("*");
D1=D+F[f]+"Rotated_Blank_Natural.tif";

if(File.exists(D1)){

ID=F[f];
ID=replace(ID,"\\","");
ID=replace(ID,"/","");

open(D1);


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

for(i=0;i<nF+1;i++){
tA = newArray(ID, i, xh[i], yh[i], xt[i], yt[i]);
tAs = String.join(tA,",");
File.append(tAs,sD);
}}

}
