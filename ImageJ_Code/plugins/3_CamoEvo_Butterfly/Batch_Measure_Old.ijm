
//Directory
D=getDirectory("Populations");
F=getFileList(D);

for(i=0;i<F.length;i++){

if(endsWith(F[i],"/")){

run("GA Hancock Measures", "butterfly="+D+F[i]);
}
}


