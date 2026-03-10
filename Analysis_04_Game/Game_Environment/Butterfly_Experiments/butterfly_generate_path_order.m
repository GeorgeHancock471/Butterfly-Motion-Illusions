clear
clc
rng(1)                     % fixed seed for reproducibility
nPlayers = 100;

% -------------------------
% PARAMETERS
% -------------------------
nBlocks  = 3;
nPaths   = 10;
nBflies  = 5;

butterflyIDs = { ...
    'Brintesia_circe__Male', ...
    'Lycaena_tityrus__Female', ...
    'Gonepteryx_cleobule__Male', ...
    'Papilio_alexanor__Female', ...
    'Pyrgus_sidae__Male'};

flightPaths = arrayfun(@(x) sprintf('%02d',x),1:nPaths,'UniformOutput',false);

% Global path × butterfly usage
C = zeros(nPaths,nBflies);

schedule = struct();

% For CSV export
csvData = {};
row = 1;

% -------------------------
% MAIN GENERATION LOOP
% -------------------------
for p = 1:nPlayers

    for b = 1:nBlocks

        % Randomize flight paths for this block
        pathOrder = randperm(nPaths);

        % Each butterfly twice per block
        bfPool = repelem(1:nBflies,2);
        bfPool = bfPool(randperm(nPaths));

        % Improve assignment to minimize global imbalance
        assign = improveAssignment(bfPool, pathOrder, C);

        % Save + update global counts
        for t = 1:nPaths
            path = pathOrder(t);
            bf   = assign(t);

            schedule(p,b,t).path      = flightPaths{path};
            schedule(p,b,t).butterfly = butterflyIDs{bf};

            C(path,bf) = C(path,bf) + 1;

            % CSV row
            csvData{row,1} = p;                     % Player
            csvData{row,2} = b;                     % Block
            csvData{row,3} = t;                     % Trial in block
            csvData{row,4} = flightPaths{path};     % Path
            csvData{row,5} = butterflyIDs{bf};      % Butterfly
            row = row + 1;
        end
    end
end

% -------------------------
% SAVE FILES
% -------------------------
save('experimentSchedule.mat','schedule','C','flightPaths','butterflyIDs');

T = cell2table(csvData, ...
    'VariableNames',{'Player','Block','Trial','Path','Butterfly'});
writetable(T,'experimentSchedule.csv');

disp('Schedule saved as experimentSchedule.mat and experimentSchedule.csv');

% ==========================================================
% LOCAL FUNCTION
% ==========================================================
function assign = improveAssignment(assign, pathOrder, C)

n = numel(assign);
improved = true;

while improved
    improved = false;

    for i = 1:n
        for j = i+1:n

            b1 = assign(i);
            b2 = assign(j);
            if b1 == b2
                continue
            end

            p1 = pathOrder(i);
            p2 = pathOrder(j);

            oldCost = C(p1,b1) + C(p2,b2);
            newCost = C(p1,b2) + C(p2,b1);

            if newCost < oldCost
                assign(i) = b2;
                assign(j) = b1;
                improved = true;
            end
        end
    end
end
end
