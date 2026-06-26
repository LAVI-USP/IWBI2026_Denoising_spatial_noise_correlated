%% =========================================================
% Insert Microcalcification Clusters into Synthetic Mammograms
%
% This script inserts simulated microcalcification clusters into
% noise-free VCT mammograms. The insertion coordinates are selected
% automatically inside homogeneous breast regions and are preserved
% across all simulated radiation dose levels.
%
% ==========================================================

close all;
clear;
clc;
addpath('Functions')

%% =========================================================
% Simulation parameters
%% =========================================================

gamma = [0.50 0.75 1.00];

clusterContrast = 0.08;
nClusters = 10;

%% =========================================================
% Input folders
%% =========================================================

rootFolder = fileparts(mfilename('fullpath'));

inputFolder = fullfile(rootFolder);
outputFolder = fullfile(rootFolder,'Results');

%% =========================================================
% Load synthetic mammogram
%% =========================================================

Y_VCT = double(dicomread(fullfile( ...
    inputFolder,...
    'VCT (Noise free image)',...
    'y_noisefree.dcm')));

info = dicominfo(fullfile( ...
    inputFolder,...
    'VCT (Noise free image)',...
    'y_noisefree.dcm'));

%% =========================================================
% Load estimated noise parameters
%% =========================================================

load(fullfile(inputFolder,...
    'NoiseParameters',...
    'NoiseParameters_GE_DM.mat'));

Y = Y_VCT - tau;

%% =========================================================
% Load breast mask
%% =========================================================

load(fullfile(inputFolder,...
    'VCT (Noise free image)',...
    'mask_VCT.mat'));
mask = mask_beast;

mask(:,1:199)=0;

candidateLocations = logical(mask);

%% =========================================================
% Load microcalcification cluster template
%% =========================================================

load(fullfile(inputFolder,...
    'MC cropped (Ge)',...
    'MaskMC_330um_NEW.mat'));

clusterMask = MaskMC;

clusterMask(clusterMask~=0) = ...
    clusterMask(clusterMask~=0)*clusterContrast;

clusterMask = abs(clusterMask-1);

%% =========================================================
% Simulate all radiation dose levels
%% =========================================================

for dose = 1:length(gamma)

    fprintf('\n');
    fprintf('Dose level = %.0f %% AEC\n',100*gamma(dose));

    Ydose = gamma(dose)*Y;

    %% -----------------------------------------------------
    % First dose:
    % automatically determine insertion locations
    %% -----------------------------------------------------

    if dose==1

        insertionInfo = selectInsertionLocations(...
            Ydose,...
            candidateLocations,...
            clusterMask,...
            nClusters);

    end

    %% -----------------------------------------------------
    % Insert cluster
    %% -----------------------------------------------------

    Ycluster = insertCluster(...
        Ydose,...
        clusterMask,...
        insertionInfo);

    %% -----------------------------------------------------
    % Save image
    %% -----------------------------------------------------

    outputImage = Ycluster + tau;

    folderOUT = fullfile( ...
        outputFolder,...
        'ImagesWithMC',...
        sprintf('%dprct',round(100*gamma(dose))),...
        'rls_1');

    if ~exist(folderOUT,'dir')
        mkdir(folderOUT)
    end

    dicomwrite(uint16(outputImage),...
        fullfile(folderOUT,'VCT_wMC_NoiseFree.dcm'),...
        info,...
        'CreateMode','Copy');

end