D=getDirectory("Butterfly Directory");
F=getFileList(D);
Array.show(F);


Titles=newArray("genus","species","genusSpecies","sex","wing","periodicity","energy","VH","OA","SpotStripe");
TitlesS = String.join(Titles,",");

SaveD=D+"GAB_Measures.csv";
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

selectImage("P");
roiManager("select",roiManager("count")-1);
P=getValue("Mean");

selectImage("E");
roiManager("select",roiManager("count")-1);
E=getValue("Mean");

selectImage("VH");
roiManager("select",roiManager("count")-1);
VH=getValue("Mean");

selectImage("OA");
roiManager("select",roiManager("count")-1);
OA=getValue("Mean");

selectImage("DR");
roiManager("select",roiManager("count")-1);
DR=getValue("Mean");

Results=newArray(genus,species,genusSpecies,sex,roiTitle,P,E,VH,OA,DR);
ResultsS = String.join(Results,",");

File.append(ResultsS,SaveD);


roiManager("select",roiManager("count")-1);
roiManager("delete");
close("Temp");
selectImage("dbl");
}//Rois

}// is tif
}// tifs
