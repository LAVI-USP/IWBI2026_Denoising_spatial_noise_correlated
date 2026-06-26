%% =========================================================
% Model-Based Denoising of Digital Mammography
%
% This script applies two model-based denoising strategies to
% simulated mammography images:
%
%   (1) AWGN assumption
%   (2) Spatially correlated noise assumption
%
% The denoising pipeline consists of:
%   - Generalized Anscombe Transform (GAT)
%   - BM3D denoising
%   - Exact inverse GAT
%
% ==========================================================

close all;
clear;
clc;

%% =========================================================
% Simulation parameters
%% =========================================================

gamma = [0.50 0.75 1.00];

nRealizations = 10;

filterStrength = [0.82 0.85 0.87];

%% =========================================================
% Load required functions
%% =========================================================

addpath('Functions');

%% =========================================================
% Load estimated noise parameters
%% =========================================================

load(fullfile('NoiseParameters',...
    'NoiseParameters_GE_DM.mat'));

%% =========================================================
% Load breast mask
%% =========================================================

load(fullfile('VCT (Noise free image)','mask_VCT.mat'));
mask(:,1:199)=0;

%% =========================================================
% Load reference image
%% =========================================================

info = dicominfo(fullfile('VCT (Noise free image)','y_noisefree.dcm'));

Y_VCT = double(dicomread(fullfile('VCT (Noise free image)','y_noisefree.dcm')));

Y = Y_VCT - tau;

%% =========================================================
% Loop over all simulated dose levels
%% =========================================================

for dose = 1:length(gamma)

    fprintf('\n');
    fprintf('=============================================\n');
    fprintf('Dose level: %.0f %% AEC\n',100*gamma(dose));
    fprintf('=============================================\n');

    for realization = 1:nRealizations

        fprintf('Realization %02d / %02d\n',...
            realization,nRealizations);

        %% =================================================
        % Load noisy image
        %% =================================================

        folderIN = fullfile(...
            'Results',...
            'Images (Noise Correlation)',...
            sprintf('%dprct',round(gamma(dose)*100)),...
            sprintf('rls_%d',realization));

        Z = double(dicomread(...
            fullfile(folderIN,'VCT_noisy.dcm')));

        %% =================================================
        % Crop breast region
        %% =================================================

        [cropImg,...
         indX_sup,...
         indX_inf,...
         indY_inf,...
         indY_sup] = Crop_Imgs4Restoration(...
            Z,...
            info,...
            mask);

        xi_q_crop = xi_qi(...
            indY_inf:indY_sup,...
            indX_inf:indX_sup);

        %% =================================================
        % Correlation-aware denoising
        %% =================================================

        cropRestored = denoising_pipeline(...
            cropImg,...
            xi_q_crop,...
            xi_e,...
            tau,...
            K_N,...
            true,...
            filterStrength(dose));

        Yhat_kn = Z - tau;

        Yhat_kn(...
            indY_inf:indY_sup,...
            indX_inf:indX_sup) = cropRestored;

        %% =================================================
        % Save correlation-aware image
        %% =================================================

        folderOUT = fullfile(...
            'Results',...
            'Images Denoised (Correlated)',...
            sprintf('%dprct',round(gamma(dose)*100)),...
            sprintf('rls_%d',realization));

        if ~exist(folderOUT,'dir')
            mkdir(folderOUT)
        end

        dicomwrite(...
            uint16(Yhat_kn),...
            fullfile(folderOUT,'VCT_Denoised.dcm'),...
            info,...
            'CreateMode','Copy');

        %% =================================================
        % AWGN denoising
        %% =================================================

        cropRestored = denoising_pipeline(...
            cropImg,...
            xi_q_crop,...
            xi_e,...
            tau,...
            K_N,...
            false,...
            filterStrength(dose));

        Yhat = Z - tau;

        Yhat(...
            indY_inf:indY_sup,...
            indX_inf:indX_sup) = cropRestored;

        %% =================================================
        % Save AWGN image
        %% =================================================

        folderOUT = fullfile(...
            'Results',...
            'Images Denoised (AWGN)',...
            sprintf('%dprct',round(gamma(dose)*100)),...
            sprintf('rls_%d',realization));

        if ~exist(folderOUT,'dir')
            mkdir(folderOUT)
        end

        dicomwrite(...
            uint16(Yhat),...
            fullfile(folderOUT,'VCT_Denoised.dcm'),...
            info,...
            'CreateMode','Copy');

    end

end

fprintf('\n');
fprintf('=============================================\n');
fprintf('Model-based denoising completed successfully.\n');
fprintf('=============================================\n');