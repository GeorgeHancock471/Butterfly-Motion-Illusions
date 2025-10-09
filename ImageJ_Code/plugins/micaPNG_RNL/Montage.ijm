t=getTitle();
run("Make Montage...", "columns=4 rows=1 scale=0.50");
run("Abs");
run("Enhance Contrast...", "saturated=0.35 normalize");
rename(t+"_montage");
run("Copy to System");
