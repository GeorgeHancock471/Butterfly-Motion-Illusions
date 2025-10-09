D1 = "D:/Organised_Butterfly_Dazzle_George/EMD_Data/CamoEvo_Analyses/Populations/";
D2 = "D:/Organised_Butterfly_Dazzle_George/EMD_Data/CamoEvo_Analyses/Wing_PNGs/";

setBatchMode(true);

F= getFileList(D1);

Array.show(F);

for(f=0;f<F.length;f++){

if(endsWith(F[f],"/")){

genA = newArray("gen_0_genes.txt", "gen_20_genes.txt");

for(g=0;g<genA.length;g++){
dg = D1+F[f]+genA[g];

if(File.exists(dg)){
str = File.openAsString(dg);


gTable = split(str,"\n");

Array.show(gTable);

for(i=0;i<gTable.length-1;i++){
data = split(gTable[i+1], "\t");
ID = data [0];
t = split(ID,"_");
t = t[0];
t = replace(t,"Gen","");

close("*");

print( D1+F[f]+"/GenPat_"+t+"/"+ID+".tif");
open( D1+F[f]+"/GenPat_"+t+"/"+ID+".tif");

run("Select None");
run("Flip Horizontally");

run("RGB Stack");

setSlice(nSlices);
run("Add Slice");

setSlice(nSlices-1);
setThreshold(1,255);
run("Create Selection");
setSlice(nSlices);
run("Set...","value=255");
run("Set Label...", "label=Alpha");

run("Make Inverse");
setSlice(1); run("Set...","value=87");
setSlice(2); run("Set...","value=87");
setSlice(3); run("Set...","value=87");
run("Make Inverse");

setSlice(1);run("Gaussian Blur...", "sigma=8");
setSlice(2);run("Gaussian Blur...", "sigma=8");
setSlice(3);run("Gaussian Blur...", "sigma=8");


File.makeDirectory(D2+"/GA/");
File.makeDirectory(D2+"/GA/"+F[f]);

saveAs("PNG",D2+"/GA/"+F[f]+"/"+g*20+"_"+ID+"_high_res.png");

run("Size...", "width=50 height=76 depth=4 constrain average interpolation=Bilinear");

saveAs("PNG",D2+"/GA/"+F[f]+"/"+g*20+"_"+ID+".png");

print(g*20+"_"+ID+".png");

}
}




}


}//if
}//loop
