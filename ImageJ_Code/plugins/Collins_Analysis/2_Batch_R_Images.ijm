D=getDirectory("Butterfly Directory");
F=getFileList(D);
Array.show(F);

D2=File.getParent(D)+"/R_PNGs/";
File.makeDirectory(D2);


for(j=0;j<F.length;j++){
setBatchMode(true);
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

morphoType=genusSpecies+"_"+sex;

print(genus);
print(species);
print(genusSpecies);
print(sex);


run("To ROI Manager");


run("RGB Stack");
setSlice(3);
run("Add Slice");
run("Set...","value=0");

roiManager("select",2);
bl=getValue("Area");
roiManager("select",newArray(0,1));
roiManager("Combine");
run("Set...","value=255");
run("Set Label...", "label=Alpha");
run("Crop");
w=getWidth()/bl*50;
h=getHeight()/bl*50;
run("Size...", "width=&w height=&h depth=4 interpolation=Bilinear");
run("Canvas Size...", "width=60 height=80 position=Center-Left zero");
saveAs("PNG", D2+morphoType+".png");

//setBatchMode("show");
close("*");



}// is tif
}// tifs

waitForUser("DONE");
