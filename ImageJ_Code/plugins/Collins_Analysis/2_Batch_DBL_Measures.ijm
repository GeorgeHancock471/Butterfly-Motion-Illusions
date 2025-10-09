D=getDirectory("Butterfly Directory");
F=getFileList(D);
Array.show(F);


Titles=newArray("genus","species","genusSpecies","sex","wing");

Channels = newArray("DBL");
Measures = newArray("mean","stdev");

// Add additional Titles
for(i=0;i<Channels.length;i++){
for(j=0;j<Measures.length;j++){
Titles=Array.concat(Titles,Channels[i]+"_"+Measures[j]);
}
}


TitlesS = String.join(Titles,",");

SaveD=File.getParent(D)+"/DBL_Measures.csv";
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




setBatchMode(true);

t=getTitle();

run("To ROI Manager");

run("Convert to DBL");


roiManager("Select", newArray(0,1));
roiManager("Combine");
roiManager("Add");


wingArray=newArray("forewing","hindwing","both");
roiIndexes = newArray(0,1,2);


for(i=0;i<3;i++){
roiTitle = wingArray[i];
Results=newArray(genus,species,genusSpecies,sex,roiTitle);

for(c=0;c<Channels.length;c++){
roiManager("select",roiIndexes[i]);
setSlice(c+1);
m=getValue("Mean");
d=getValue("StdDev");
Results=Array.concat(Results,m,d);
}//channels

ResultsS = String.join(Results,",");

File.append(ResultsS,SaveD);

roiManager("select",roiManager("count")-1);


}//Rois


}// is tif
}// tifs

waitForUser("Done!");
