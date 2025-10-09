//Create epic butterfly gid
close("*");

cH=1920*0.65;
cW=1080*0.65;


D=getDirectory("Populations");
F=getFileList(D);

Fl = newArray();

for(i=0;i<F.length;i++){
if(endsWith(F[i],"/"))Fl = Array.concat(Fl,F[i]);
}

Array.show(Fl);

Nrep = 50;


newImage("Animation", "RGB black", cW, cH, Nrep);
setBatchMode(true);
GenArr = newArray("GenPat_0","GenPat_20");


for(i=0;i<Nrep;i++){

d = D+Fl[random()*Fl.length-1]+GenArr[parseInt(random())]+"/";
d = D+Fl[random()*Fl.length-1]+GenArr[1]+"/";

F2 = getFileList(d);

d2 = d + F2[random()*5];

open(d2);
run("Mirror GA Butterfly");
run("RGB Color");
run("Colour GA Butterfly");
run("Copy");
close();
close();

selectImage("Animation");
setSlice(i+1);
run("Paste");

}

setBatchMode("show");

run("Animation Options...", "speed="+3);
doCommand("Start Animation [\\]");
