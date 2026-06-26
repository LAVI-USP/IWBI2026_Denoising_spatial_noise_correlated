%% =========================================================================
% IWBI 2026
%
% Channelized Hotelling Observer (CHO)
%
% This script:
%   (1) Loads the ROI database
%   (2) Splits training and testing datasets
%   (3) Computes CHO detectability
%   (4) Compares all restoration methods
%
% =========================================================================

close all
clear
clc

addpath('Functions')

%% =========================================================================
% Parameters
% =========================================================================

DoseLevels = [0.50 0.75 1.00];

ImageTypes = { ...
    'NoiseFree',...
    'Noise',...
    'Denoised',...
    'Denoised_Ke'};

nCases    = 200;
nTrain    = 100;
nChannels = 5;
ch_width  = 2.5;

TrainIdx = 1:nTrain;
TestIdx  = nTrain+1:nCases;

%% =========================================================================
% Paths
% =========================================================================

root = 'D:\OneDrive\Paper X\Ge\GitHub\ModelObserver (Dataset)';

%% =========================================================================
% Main loop
% =========================================================================

for d = 1:length(DoseLevels)

    doseFolder = sprintf('%dprct',DoseLevels(d)*100);

    fprintf('\n=====================================================\n');
    fprintf('Dose Level : %.0f%% AEC\n',100*DoseLevels(d));
    fprintf('=====================================================\n');

    %% =====================================================================
    % Load images
    % ======================================================================

    Dataset = struct();

    for t = 1:length(ImageTypes)

        fprintf('Loading %-15s ... ',ImageTypes{t});

        for i = 1:nCases

            Dataset(t).Name = ImageTypes{t};

            Dataset(t).Present(:,:,i) = ...
                double(dicomread(...
                fullfile(root,...
                doseFolder,...
                ImageTypes{t},...
                'present',...
                sprintf('ROI_%d.dcm',i))));

            Dataset(t).Absent(:,:,i) = ...
                double(dicomread(...
                fullfile(root,...
                doseFolder,...
                ImageTypes{t},...
                'absent',...
                sprintf('ROI_%d.dcm',i))));

        end

        fprintf('Done\n');

    end

    %% =====================================================================
    % Channelized Hotelling Observer
    % ======================================================================

    fprintf('\nRunning CHO...\n');

    for t = 1:length(ImageTypes)

        fprintf('\n%s\n',Dataset(t).Name);

        [Results(d).Method(t).SNR,...
         Results(d).Method(t).t_sp,...
         Results(d).Method(t).t_sa,...
         Results(d).Method(t).ChannelImage,...
         Results(d).Method(t).Template,...
         Results(d).Method(t).MeanSP,...
         Results(d).Method(t).MeanSA,...
         Results(d).Method(t).MeanSignal,...
         Results(d).Method(t).CHO] = ...
            conv_LG_CHO_2d(...
            Dataset(t).Absent(:,:,TrainIdx),...
            Dataset(t).Present(:,:,TrainIdx),...
            Dataset(t).Absent(:,:,TestIdx),...
            Dataset(t).Present(:,:,TestIdx),...
            ch_width,...
            nChannels,...
            1);

        fprintf('SNR = %.4f\n',Results(d).Method(t).SNR);

    end

end

%% =========================================================================
% Summary
% =========================================================================

fprintf('\n\n===============================================\n');
fprintf('CHO Summary\n');
fprintf('===============================================\n');

for d = 1:length(DoseLevels)

    fprintf('\nDose %.0f%% AEC\n',100*DoseLevels(d));

    for t = 1:length(ImageTypes)

        fprintf('%-15s : %.4f\n',...
            ImageTypes{t},...
            Results(d).Method(t).SNR);

    end

end