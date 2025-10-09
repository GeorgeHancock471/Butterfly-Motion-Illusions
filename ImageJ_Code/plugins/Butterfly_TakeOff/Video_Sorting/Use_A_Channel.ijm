//R channel only
setBatchMode(true);
run("Duplicate...", "duplicate");
rename("T");

run("Duplicate...", "duplicate");
rename("R_only");
run("32-bit");
setPasteMode("Copy");

for(i=0;i<nSlices;i++){
selectImage("T");
setSlice(i+1);
run("Duplicate...", " ");
run("Lab Stack");
setSlice(2);
run("Copy");
close;
selectImage("R_only");
setSlice(i+1);
run("Paste");
}
run("32-bit");
setBatchMode("show");

