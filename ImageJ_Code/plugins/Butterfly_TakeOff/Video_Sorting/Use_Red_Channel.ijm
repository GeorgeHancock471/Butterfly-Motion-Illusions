//R channel only
setBatchMode(true);
run("Duplicate...", "duplicate");



for(i=0;i<nSlices;i++){
setSlice(i+1);
run("Duplicate...", " ");
run("RGB Stack");
run("Copy");
setSlice(2); run("Divide...","value=6");
run("Copy"); setPasteMode("Subtract");
setSlice(1);
run("Paste");
run("Copy"); setPasteMode("Copy");
close;
run("Paste");
}
run("32-bit");
setBatchMode("show");

rename("R_only");
