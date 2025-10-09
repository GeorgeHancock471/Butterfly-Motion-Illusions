D=getDirectory("Butterfly Directory");
F=getFileList(D);
Array.show(F);

pxmm = 23.583; // measured using the same scanner as the butterfly book


Titles=newArray("genus","species","genusSpecies","sex");

Titles=Array.concat(Titles,"Body_Length","Wing_Area","Wing_WBF");



TitlesS = String.join(Titles,",");

SaveD=File.getParent(D)+"/Size_WBF.csv";
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

// Measure Body
//--------------------------------------------------------------------------
roiManager("select",2);
BL=getValue("Area");
BL= BL/pxmm;


roiManager("Select", newArray(0,1));
roiManager("Combine");
getStatistics(wingArea, mean);

print("__________________________");
wingArea = (wingArea*2) / pow(pxmm, 2); // times two for both wings!
print("Wing area (mm^2) = " + wingArea);
freq = pow( 10, (-0.134346*((log(wingArea)/log(10))*1.23952-7.843389 )+0.53418));




Results=newArray(genus,species,genusSpecies,sex);
Results=Array.concat(Results,BL,wingArea,freq);



ResultsS = String.join(Results,",");

File.append(ResultsS,SaveD);

roiManager("select",roiManager("count")-1);
roiManager("delete");
close("Temp");


}// is tif
}// tifs

waitForUser("DONE");
