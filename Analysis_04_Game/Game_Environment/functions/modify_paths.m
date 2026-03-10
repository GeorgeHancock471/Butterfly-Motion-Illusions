function modify_paths()

    % Step 1: Get the directory of the current script
    modelLocation = fileparts(mfilename('fullpath'));  % This gets the folder where the current .m file is located

    % Step 2: Create the full paths for the other files
    batchPath = fullfile(modelLocation, "Batch.bat");
    pythonPath = fullfile(modelLocation, "Python.py");
    rigPath = fullfile(modelLocation, "Rig.blend");

    % Step 3: Display the full paths
    disp('Batch Path:');
    disp(batchPath);  % This will print the full path to Batch.bat

    disp('Python Path:');
    disp(pythonPath);  % This will print the full path to Python.py

    disp('Rig Path:');
    disp(rigPath);     % This will print the full path to Rig.blend

end
