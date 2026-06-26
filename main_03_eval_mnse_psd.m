%% =========================================================================
% IWBI 2026
%
% Spectral Analysis and MNSE Evaluation
%
% This script:
%   (1) Loads the reference data
%   (2) Reads noisy and restored images
%   (3) Computes the power spectrum density
%   (4) Computes the MNSE maps
%   (5) Generates the comparison figures
%
% =========================================================================

close all
clear
clc
addpath("Functions")

%% =========================================================================
% Parameters
% =========================================================================

RedFac = [0.50 0.75 1.00];
nRls   = 10;

ROI.rows = 800:1800;
ROI.cols = 150:500;

%% =========================================================================
% Paths
% =========================================================================

root = 'D:\OneDrive\Paper X\Ge\';

path.NoisePar = fullfile(root,'NoiseParameters Ge','NoiseParameters_GE_DM.mat');
path.Mask     = fullfile(root,'VCT','mask_VCT.mat');
path.Reference= fullfile(root,'y_VCT_100prct.mat');

path.Noisy    = fullfile(root,'MNSE tests','DataBase','Images (Noise High Correlation)');
path.GAT      = fullfile(root,'MNSE tests','DataBase','Images Denoised HighCorr (GAT)');
path.GATCorr  = fullfile(root,'MNSE tests','DataBase','Images Denoised HighCorr (GAT Ke)');

%% =========================================================================
% Load reference data
% =========================================================================

load(path.NoisePar)
load(path.Mask)
Y_VCT = double(dicomread('D:\OneDrive\Paper X\Ge\GitHub\VCT (Noise free image)\y_noisefree.dcm'));

mask(:,1:199) = 0;

Y = Y_VCT - tau;

%% =========================================================================
% Main loop
% =========================================================================

for d = 1:length(RedFac)

    fprintf('\n====================================================\n');
    fprintf('Dose level: %.0f%% AEC\n',100*RedFac(d));
    fprintf('====================================================\n');

    doseFolder = sprintf('%dprct',round(RedFac(d)*100));

    %% =====================================================================
    % Compute reference PSD (only once)
    % ======================================================================

    ReferenceROI = RedFac(d).*Y(ROI.rows,ROI.cols);

    [~,PSD.Reference(:,:,d),f1DR] = ...
        NPS_FAB(ReferenceROI,128,0.1,0,0);

    %% =====================================================================
    % Read images and compute PSD
    % ======================================================================

    for r = 1:nRls

        realizationFolder = sprintf('rls_%d',r);

        %---------------------------------------------------------------
        % Read images
        %---------------------------------------------------------------

        Noisy(:,:,r,d) = double(dicomread( ...
            fullfile(path.Noisy,doseFolder,realizationFolder,'VCT_noisy.dcm')));

        Restored(:,:,r,d) = double(dicomread( ...
            fullfile(path.GAT,doseFolder,realizationFolder,'VCT_Denoised.dcm')));

        RestoredCorr(:,:,r,d) = double(dicomread( ...
            fullfile(path.GATCorr,doseFolder,realizationFolder,'VCT_Denoised.dcm')));

        %---------------------------------------------------------------
        % Select ROI
        %---------------------------------------------------------------

        ROI_Noisy = Noisy(ROI.rows,ROI.cols,r,d)-tau;

        ROI_Restored = Restored(ROI.rows,ROI.cols,r,d);

        ROI_RestoredCorr = RestoredCorr(ROI.rows,ROI.cols,r,d);

        %---------------------------------------------------------------
        % Compute PSD
        %---------------------------------------------------------------

        [~,PSD.Noisy(:,:,r,d)] = ...
            NPS_FAB(ROI_Noisy,128,0.1,0,0);

        [~,PSD.Restored(:,:,r,d)] = ...
            NPS_FAB(ROI_Restored,128,0.1,0,0);

        [~,PSD.RestoredCorr(:,:,r,d)] = ...
            NPS_FAB(ROI_RestoredCorr,128,0.1,0,0);

    end

    %% =====================================================================
    % Compute MNSE
    % ======================================================================

    disp('Noisy image')

    [MNSE.Noisy(d),~,RV(:,:,d),RVt.Noisy(:,:,d),Bias2.Noisy(d)] = ...
        calcMNSE(Y,mask,Noisy(:,:,:,d)-tau);

    disp('-----------------------------------------------')

    disp('Restored image')

    [MNSE.Restored(d),~,RV(:,:,d),RVt.Restored(:,:,d),Bias2.Restored(d)] = ...
        calcMNSE(Y,mask,Restored(:,:,:,d));

    disp('-----------------------------------------------')

    disp('Correlation-aware restored image')

    [MNSE.RestoredCorr(d),~,RV(:,:,d),RVt.RestoredCorr(:,:,d),Bias2.RestoredCorr(d)] = ...
        calcMNSE(Y,mask,RestoredCorr(:,:,:,d));

    %% =====================================================================
    % Mean PSD
    % ======================================================================

    PSDmean.Reference = PSD.Reference(:,:,d);

    PSDmean.Noisy = mean(squeeze(PSD.Noisy(:,:,:,d)),2);

    PSDmean.Restored = mean(squeeze(PSD.Restored(:,:,:,d)),2);

    PSDmean.RestoredCorr = mean(squeeze(PSD.RestoredCorr(:,:,:,d)),2);

    %% =====================================================================
    % Plot
    % ======================================================================

    figure

    %subplot(1,3,d)
    %hold on

    semilogy(f1DR,...
        PSDmean.Reference,...
        'k',...
        'LineWidth',1.5);,hold on

    semilogy(f1DR,...
        PSDmean.Noisy,...
        '--',...
        'Color',[0.64 0.08 0.18],...
        'LineWidth',1.5);

    semilogy(f1DR(1:2:end),...
        PSDmean.Restored(1:2:end),...
        'o',...
        'Color',[0.47 0.67 0.19],...
        'LineWidth',1.5);

    semilogy(f1DR(1:2:end),...
        PSDmean.RestoredCorr(1:2:end),...
        '^',...
        'Color',[0.09 0.57 0.90],...
        'LineWidth',1.5);

    grid on

    xlabel('Frequency (mm$^{-1}$)','Interpreter','latex')
    ylabel('Spectral Density (mm$^{2}$)','Interpreter','latex')

    axis([0 5 1e-3 2e4])

    lgd = legend(...
        '$Y$',...
        '$Z$',...
        '$\hat{Y}$',...
        '$\hat{Y}_{\kappa_n}$',...
        'Interpreter','latex',...
        'Orientation','Horizontal',...
        'FontSize',14);

    title(lgd,sprintf('%.0f%% of AEC',100*RedFac(d)),...
        'Interpreter','latex');

    ax = gca;
    ax.FontSize = 12;

end
