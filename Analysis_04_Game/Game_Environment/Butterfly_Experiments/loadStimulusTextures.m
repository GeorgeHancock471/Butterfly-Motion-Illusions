function textures = loadStimulusTextures(window, backgroundDir, flipX, flipY)
% LOADSTIMULUSTEXTURES
% Loads all PNG images from a directory as Psychtoolbox textures.
%
% INPUTS:
%   window        - Psychtoolbox window pointer
%   backgroundDir - path to directory containing PNG images
%   flipX         - logical, flip image left-right if true
%   flipY         - logical, flip image up-down if true
%
% OUTPUT:
%   textures      - 1xN cell array of texture handles

    if nargin < 3, flipX = false; end
    if nargin < 4, flipY = false; end

    % Get all PNG files
    imageFiles = dir(fullfile(backgroundDir, '*.png'));

    if isempty(imageFiles)
        error('No PNG files found in directory: %s', backgroundDir);
    end

    % Sort by filename (important for frame order)
    imageNames = sort({imageFiles.name});

    % Preallocate
    textures = cell(1, numel(imageNames));

    for i = 1:numel(imageNames)

        imgPath = fullfile(backgroundDir, imageNames{i});
        [img, ~, alpha] = imread(imgPath);

        % Apply flips
        if flipX
            img = flip(img, 2); % flip left-right
            if ~isempty(alpha)
                alpha = flip(alpha, 2);
            end
        end
        if flipY
            img = flip(img, 1); % flip up-down
            if ~isempty(alpha)
                alpha = flip(alpha, 1);
            end
        end

        % Create texture (with alpha if present)
        if isempty(alpha)
            textures{i} = Screen('MakeTexture', window, img);
        else
            textures{i} = Screen('MakeTexture', window, cat(3, img, alpha));
        end
    end
end
