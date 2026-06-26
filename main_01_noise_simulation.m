%% =========================================================
% Code Version: Matlab2025b
% Noise Simulation for Digital Mammography
%
% This script generates correlated noisy mammography images
% according to the noise model described in:
%
% Brandao RF et al.
% Model-Based Denoising of Digital Mammography
% Incorporating Spatial Noise Correlation
%
% ==========================================================

close all;
clear;
clc;

%% =========================================================
% Simulation parameters
%% =========================================================

gamma = [0.50 0.75 1.00];      % Dose scaling factors
nRealizations = 10;            % Number of noise realizations

%% =========================================================
% Input folders
%% =========================================================

rootFolder = fileparts(mfilename('fullpath'));

inputFolder  = fullfile(rootFolder);
outputFolder = fullfile(rootFolder,'Results');

%% =========================================================
% Load noise-free image
%% =========================================================

Y_VCT = double(dicomread(fullfile(inputFolder,...
    'VCT (Noise free image)',...
    'y_noisefree.dcm')));

info = dicominfo(fullfile(inputFolder,...
    'VCT (Noise free image)',...
    'y_noisefree.dcm'));

%% =========================================================
% Load estimated noise parameters
%% =========================================================

load(fullfile(inputFolder,...
    'NoiseParameters',...
    'NoiseParameters_GE_DM.mat'));

kappa_n = K_N;

%% =========================================================
% Load breast mask (optional)
%% =========================================================

load(fullfile(inputFolder,...
    'VCT (Noise free image)',...
    'mask_VCT.mat'));

mask(:,1:199)=0;

%% =========================================================
% Remove image offset
%% =========================================================

Y = Y_VCT - tau;

%% =========================================================
% Loop over dose levels
%% =========================================================

for dose = 1:length(gamma)

    fprintf('\n');
    fprintf('=========================================\n');
    fprintf('Dose level = %.0f %% AEC\n',100*gamma(dose));
    fprintf('=========================================\n');

    %% -----------------------------------------------------
    % Scale image according to radiation dose
    %% -----------------------------------------------------

    Y_gamma = gamma(dose)*Y;

    %% -----------------------------------------------------
    % Generate independent noise realizations
    %% -----------------------------------------------------

    for realization = 1:nRealizations

        fprintf('Realization %02d\n',realization);

        %% ---------------------------------------------
        % Pad image for convolution
        %% ---------------------------------------------

        padSize = floor(size(kappa_n)/2);

        Y_pad = padarray(Y_gamma,...
                         padSize,...
                         'replicate',...
                         'both');

        xi_q_pad = padarray(xi_qi,...
                            padSize,...
                            'replicate',...
                            'both');

        %% ---------------------------------------------
        % Signal-dependent standard deviation
        %% ---------------------------------------------

        sigma = sqrt( ...
            xi_s^2 .* Y_pad.^2 + ...
            xi_q_pad .* Y_pad + ...
            xi_e^2 );

        %% ---------------------------------------------
        % Generate correlated Gaussian noise
        %% ---------------------------------------------

        whiteNoise = randn(size(Y_pad));

        correlatedNoise = conv2( ...
            sigma .* whiteNoise,...
            kappa_n,...
            'valid');

        %% ---------------------------------------------
        % Simulated noisy image
        %% ---------------------------------------------

        Z = Y_gamma + correlatedNoise;

        %% ---------------------------------------------
        % Restore DICOM offset
        %% ---------------------------------------------

        Y_save = Y_gamma + tau;
        Z_save = Z + tau;

        %% ---------------------------------------------
        % Save noise-free image
        %% ---------------------------------------------

        folderNoiseFree = fullfile( ...
            outputFolder,...
            'Images (NoiseFree)',...
            sprintf('%dprct',round(100*gamma(dose))),...
            sprintf('rls_%d',realization));

        if ~exist(folderNoiseFree,'dir')
            mkdir(folderNoiseFree)
        end

        dicomwrite(uint16(Y_save),...
            fullfile(folderNoiseFree,'VCT_NoiseFree.dcm'),...
            info,...
            'CreateMode','Copy');

        %% ---------------------------------------------
        % Save noisy image
        %% ---------------------------------------------

        folderNoise = fullfile( ...
            outputFolder,...
            'Images (Noise Correlation)',...
            sprintf('%dprct',round(100*gamma(dose))),...
            sprintf('rls_%d',realization));

        if ~exist(folderNoise,'dir')
            mkdir(folderNoise)
        end

        dicomwrite(uint16(Z_save),...
            fullfile(folderNoise,'VCT_noisy.dcm'),...
            info,...
            'CreateMode','Copy');

    end

end

disp(' ');
disp('Noise simulation completed successfully.');