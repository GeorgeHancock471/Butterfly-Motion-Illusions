
//Directory
D=getDirectory("Populations");
F=getFileList(D);

for(i=0;i<F.length;i++){

if(endsWith(F[i],"/")){

if(indexOf(F[i],"Pyrgus_andromedae_FE_6") !=-1) run("GA Hancock Measures 3 G20", "butterfly="+D+F[i]);
if(indexOf(F[i],"Pyrgus_andromedae_FE_7") !=-1) run("GA Hancock Measures 3 G20", "butterfly="+D+F[i]);
if(indexOf(F[i],"Pyrgus_andromedae_FE_8")!=-1) run("GA Hancock Measures 3 G20", "butterfly="+D+F[i]);
if(indexOf(F[i],"Pyrgus_andromedae_FE_9")!=-1) run("GA Hancock Measures 3 G20", "butterfly="+D+F[i]);
if(indexOf(F[i],"Pyrgus_andromedae_FE_10")!=-1) run("GA Hancock Measures 3 G20", "butterfly="+D+F[i]);



}
}


