D=getDirectory("Butterfly Directory");
F=getFileList(D);
Array.show(F);


Titles=newArray("genus","species","genusSpecies","sex");

Titles=Array.concat(Titles,"fw_length","fw_breadth","fw_fan","fw_stretch","fw_area","fw_ar","fw_circ","fw_rough");

Titles=Array.concat(Titles,"hw_length","hw_breadth","hw_fan","hw_stretch","hw_area","hw_ar","hw_circ","hw_rough");





TitlesS = String.join(Titles,",");

SaveD=File.getParent(D)+"/Wing_Measures.csv";
if(File.exists(SaveD)) File.delete(SaveD);
File.append(TitlesS,SaveD);


for(j=0;j<F.length;j++){
close("*");
if(endsWith(F[j],".png")){
open(D+F[j]);
T=getTitle();
T=replace(T,".png","");
sT=split(T,"_");

genus=sT[0];
species=sT[1];
genusSpecies=sT[0]+"_"+sT[1];
sex =sT[2];

print(genus);
print(species);
print(genusSpecies);
print(sex);




if(isOpen("Temp")) close("Temp");
run("32-bit");
setBatchMode(false);
setThreshold(0,244);
run("Create Selection");
run("Create Mask");
run("Close-");
run("Select None");
rename("Temp");
run("Butterfly Stat Measures Scaled");




exit

setBatchMode(true);

t=getTitle();

run("To ROI Manager");

// Measure Body
//--------------------------------------------------------------------------
roiManager("select",2);
bl=getValue("Area");


// Measure Forewing
//---------------------------------------------------------------------------
rn=0;

run("Select None");
if(isOpen("mask")) close("mask");
run("Duplicate...", "title=mask"); run("32-bit");
run("Set...","value=0");

roiManager("select",rn);
run("Set...","value=1");

// Get centroid from results table
x = getValue("XM");
y = getValue("YM");

run("Select None");
run("Enhance Contrast...", "saturated=0.35");

roiManager("select",rn);
run("Convex Hull");
run("Interpolate", "interval=1");
Roi.getCoordinates(xp,yp);

xh = newArray();
yh = newArray();
Array.getStatistics(xp,min,max,mean);

for(i=0; i<xp.length; i++) {
if(xp[i]<min+15){
xh=Array.concat(xh,xp[i]);
yh=Array.concat(yh,yp[i]);
}
}
Array.getStatistics(yh,ymin,ymax,ymean);
ymid=(ymax+ymin)/2;
Array.getStatistics(xp,xmin,xmax,xmean);
makePoint(min,ymid);



Array.show(xp,yp);

// Brute force max distance

pAx = 0;
pAy = 0;
pBx = 0;
pBy = 0;
distance=0;


for(i=0; i<xp.length; i++) {
		if(xp[i]>xmean){
		d =pow(pow(xmin-xp[i],2)+pow(ymid-yp[i],2),0.5);
		if(d > distance) {
			distance = d;
			pAx = xmin;
			pAy = ymid;
			pBx = xp[i];
			pBy = yp[i];
		print(d);
		}
		}
}
run("Select None");
run("Minimum...", "radius=3");
makeLine(pAx,pAy, pBx,pBy);
length=getValue("Area");
roiManager("Add");


// roughness
run("Select None");
setThreshold(1,1);
run("Create Selection");
a=getValue("Area");
run("Convex Hull");
r= getValue("Area") / bl;
roiManager("Add");



roiManager("select",roiManager("count")-2);
run("Rotate...", "  angle=90");
run("Scale... ", "x=1.5 y=1.5 centered");
run("Line to Area");
run("Make Inverse");
run("Multiply...", "value=0");
setThreshold(1,1); run("Create Selection");
roiManager("Add");
width=getValue("Area");
close("mask");


roiManager("select",rn);
fw_length=length/bl;
fw_breadth=width/bl;
fw_fan=getValue("Height")/bl;
fw_stretch=getValue("Width")/bl;

fw_area=getValue("Area")/bl;
fw_ar = fw_length/fw_breadth;
fw_circ=getValue("Circ.");
fw_rough = r/fw_area;



// Measure Hindwing
//---------------------------------------------------------------------------
rn=1;

run("Select None");
if(isOpen("mask")) close("mask");
run("Duplicate...", "title=mask"); run("32-bit");
run("Set...","value=0");

roiManager("select",rn);
run("Set...","value=1");

// Get centroid from results table
x = getValue("XM");
y = getValue("YM");

run("Select None");
run("Enhance Contrast...", "saturated=0.35");

roiManager("select",rn);
run("Convex Hull");
run("Interpolate", "interval=1");
Roi.getCoordinates(xp,yp);

xh = newArray();
yh = newArray();
Array.getStatistics(xp,min,max,mean);

for(i=0; i<xp.length; i++) {
if(xp[i]<min+15){
xh=Array.concat(xh,xp[i]);
yh=Array.concat(yh,yp[i]);
}
}
Array.getStatistics(yh,ymin,ymax,ymean);
ymid=ymin+(ymax-ymin)/6;
Array.getStatistics(xp,xmin,xmax,xmean);
makePoint(min,ymid);



Array.show(xp,yp);

// Brute force max distance

pAx = 0;
pAy = 0;
pBx = 0;
pBy = 0;
distance=0;


for(i=0; i<xp.length; i++) {
		if(xp[i]>xmean){
		d =pow(pow(xmin-xp[i],2)+pow(ymid-yp[i],2),0.5);
		if(d > distance) {
			distance = d;
			pAx = xmin;
			pAy = ymid;
			pBx = xp[i];
			pBy = yp[i];
		print(d);
		}
		}
}
run("Select None");
run("Minimum...", "radius=3");
makeLine(pAx,pAy, pBx,pBy);
length=getValue("Area");


roiManager("Add");
// roughness
run("Select None");
setThreshold(1,1);
run("Create Selection");
a=getValue("Area");
run("Convex Hull");
r= getValue("Area")/bl;

roiManager("Add");

roiManager("select",roiManager("count")-2);

run("Rotate...", "  angle=90");
run("Scale... ", "x=1.5 y=1.5 centered");
run("Line to Area");
run("Make Inverse");
run("Multiply...", "value=0");
setThreshold(1,1); run("Create Selection");
roiManager("Add");
width=getValue("Area");



close("mask");


roiManager("select",rn);
hw_length=length/bl;
hw_breadth=width/bl;
hw_fan=getValue("Height")/bl;
hw_stretch=getValue("Width")/bl;

hw_area=getValue("Area")/bl;
hw_ar = hw_length/hw_breadth;
hw_circ=getValue("Circ.");

hw_rough = r/hw_area;





Results=newArray(genus,species,genusSpecies,sex);
Results=Array.concat(Results,fw_length,fw_breadth,fw_fan,fw_stretch,fw_area,fw_ar,fw_circ,fw_rough);
Results=Array.concat(Results,hw_length,hw_breadth,hw_fan,hw_stretch,hw_area,hw_ar,hw_circ,hw_rough);


ResultsS = String.join(Results,",");

File.append(ResultsS,SaveD);

roiManager("select",roiManager("count")-1);
roiManager("delete");
close("Temp");


}// is tif
}// tifs

waitForUser("DONE");
