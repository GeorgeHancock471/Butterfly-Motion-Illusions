D=getDirectory("Butterfly Directory");
F=getFileList(D);
Array.show(F);


Titles=newArray("genus","species","genusSpecies","sex","wing");

Channels = newArray("P","E","VH","OA","DR");
Measures = newArray("mean","stdev","x","y");
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




TitlesS = String.join(Titles,",");

SaveD=File.getParent(D)+"/Hancock_Butterfly_Measures.csv";
if(File.exists(SaveD)) File.delete(SaveD);
File.append(TitlesS,SaveD);


for(j=0;j<F.length;j++){
close("*");
if(endsWith(F[j],".tif")){
open(D+F[j]);
T=getTitle();
T=replace(T,".tif","");
sT=split(T,"_");

genus=sT[0];
species=sT[1];
genusSpecies=sT[0]+"_"+sT[1];
sex =sT[2];

print(genus);
print(species);
print(genusSpecies);
print(sex);




setBatchMode(false);

t=getTitle();

run("Overlay To ROI");
run("Convert to DBL");

roiManager("Select", newArray(0,1));
roiManager("Combine");
roiManager("Add");


wingArray=newArray("forewing","hindwing","both");
roiIndexes = newArray(0,1,3);

for(i=0;i<3;i++){

roiTitle = wingArray[i];

roiManager("select",roiIndexes[i]);
run("Crop Rescale ROI", " ");
//rename("crop");


run("Butterfly Stat Measures");

Results=newArray(genus,species,genusSpecies,sex,roiTitle);

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
close("Temp");
selectImage("dbl");
}//Rois



}// is tif
}// tifs
