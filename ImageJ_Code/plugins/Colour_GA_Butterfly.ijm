if(isOpen("Lab")) close("Lab");
if(isOpen("Output")) close("Output");

//run("Duplicate...", " ");
rename("Lab");
run("Lab Stack");


setSlice(1);
run("Copy");


setSlice(2);
run("Paste");
run("Divide...","value=100");
m=-40+random()*80;
m2=0.5+random()*2;
p=0.5+random();
run("Macro...", "code=v=sin(pow(v,"+p+")*PI*"+m2+")*"+m);

setSlice(3);
run("Paste");
run("Divide...","value=100");
m=-40+random()*80;
m2=0.5+random()*2;
p=0.5+random();
run("Macro...", "code=v=sin(pow(v,"+p+")*PI*"+m2+")*"+m);





run("CIELAB 32Bit to RGB24 smooth");
