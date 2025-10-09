//Functions
function x_gradient() {
x=Array.getSequence(getWidth());
y=newArray(getWidth());
for(r=0;r<getWidth();r++){
makeRectangle(r,0,1,getHeight());
y[r]=getValue("Mean");
}
Fit.doFit("Straight Line", x, y);
return Fit.p(1);
}


function y_gradient() {
x=Array.getSequence(getHeight());
y=newArray(getHeight());
for(r=0;r<getHeight;r++){
makeRectangle(0,i,getWidth(),1);
y[r]=-getValue("Mean");
}
Fit.doFit("Straight Line", x, y);
return Fit.p(1);
}



//Directory
D=getDirectory("Butterfly Directory");

Population=File.getName(D);

close("*");

F1=getFileList(D);

//Pop Settings
PS=File.openAsString(D+"Settings_Population.txt");
PS=split(PS,"\n");

TargetType = split(PS[0],"\t");
TargetType=TargetType[1];

nGen = split(PS[1],"\t"); 
nGen = nGen[1]; 


TargetDirectory = getDirectory("plugins")+ "1 CamoEvo/Targets/";
TargetSettings = File.openAsString(TargetDirectory+"Target_Settings.txt");
TargetSettingsRows = split(TargetSettings, "\n");

for(i=0; i<TargetSettingsRows.length; i++){
temp = TargetSettingsRows[i];
if(startsWith(temp,TargetType)){
TargetSetting = temp;
}

}
TargetChoiceSettings = split(TargetSetting, "\t");
TargetChoiceShape = TargetChoiceSettings[1];

print(TargetChoiceShape);

while(roiManager("count")>0){
roiManager("select",0);
roiManager("delete");
}

roiDirectory = getDirectory("plugins") +"1 CamoEvo/Targets/"+TargetChoiceShape+"/RoiSet.zip";
print(roiDirectory);
open(roiDirectory);

newImage("ForewingMask", "32-bit black", 400, 400, 1);
roiManager("select",0);
run("Set...","value=1");
run("Select None");
run("Flip Horizontally");

newImage("HindwingMask", "32-bit black", 400, 400, 1);
roiManager("select",1);
run("Set...","value=1");
run("Select None");
run("Flip Horizontally");

while(roiManager("count")>0){
roiManager("select",0);
roiManager("delete");
}


selectImage("ForewingMask"); 
run("Flip Horizontally");
setThreshold(1,1); run("Create Selection"); roiManager("Add");
selectImage("HindwingMask"); 
run("Select None");
run("Flip Horizontally");
setThreshold(1,1); run("Create Selection"); roiManager("Add");



close("*");

Titles=newArray("Population","Generation","ID","Wing");

Channels = newArray("L","P","E","VH","OA","DR");
Measures = newArray("mean","stdev","x","y");
// L = luminance
// P = periodicity
// E = energy
// VH = vertical-horizontal
// OA = orthogonal-acute
// DR = Directionality

// Add additional Titles
for(i=0;i<Channels.length;i++){
for(j=0;j<Measures.length;j++){
Titles=Array.concat(Titles,Channels[i]+"_"+Measures[j]);
}
}





TitlesS = String.join(Titles,",");


//Directory
SaveD=File.getParent(D)+"/"+Population+"_Pattern.csv";
if(File.exists(SaveD)) File.delete(SaveD);
File.append(TitlesS,SaveD);


//Generations
gInt=19;

for(g=0;g<=parseFloat(nGen)/gInt;g++){

Gen = g*gInt;
S = File.openAsString(D+"gen_"+Gen+"_genes.txt");
P = split(S,"\n");

//Population
for(p=1;p<P.length;p++){
Ind = split(P[p],"\t");

getGen=split(Ind[0],"_");
getGen=replace(getGen[0],"Gen","");



d  = D+"/GenPat_"+getGen+"/"+Ind[0]+".tif";
print(d);
close("*");
open(d);
run("Select All");
run("Flip Horizontally");
run("Convert to DBL");

wingArray=newArray("forewing","hindwing");
roiIndexes = newArray(0,1);

for(i=0;i<2;i++){

roiTitle = wingArray[i];

run("Select None");

roiManager("select",roiIndexes[i]);
run("Crop Rescale ROI", " ");
//rename("crop");



roiManager("select",roiManager("count")-1);
run("Make Inverse");
run("Set...","value=87");
run("Select None");
run("Gaussian Blur...", "sigma=6");
roiManager("select",roiManager("count")-1);



run("Butterfly Stat Measures");

Results=newArray(Population,Gen,Ind[0],wingArray[i]);

selectImage("Temp");
rename("L");

//Metrics
for(c=0;c<Channels.length;c++){
selectImage(Channels[c]);
roiManager("select",roiManager("count")-1);
m=getValue("Mean");
d=getValue("StdDev");
x = parseFloat(x_gradient());
y= parseFloat(y_gradient());
Results=Array.concat(Results,m,d,x,y);
}


ResultsS = String.join(Results,",");

File.append(ResultsS,SaveD);

roiManager("select",roiManager("count")-1);
roiManager("delete");
close("L");
selectImage("dbl");
}//Rois


}//p
}//g






