function D = denoising_pipeline( ...
    Z,...
    xi_q,...
    xi_e,...
    tau,...
    kappa_n,...
    useSpatialCorrelation,...
    filterStrength)

% ==========================================================
% Model-based denoising pipeline for digital mammography.
%
% The pipeline consists of:
%
%   1. Generalized Anscombe Transform (GAT)
%   2. BM3D denoising
%   3. Exact unbiased inverse GAT
%
% Two denoising strategies are available:
%
%   useSpatialCorrelation = false
%       BM3D assuming additive white Gaussian noise (AWGN).
%
%   useSpatialCorrelation = true
%       BM3D accounting for spatially correlated noise through
%       the measured noise Power Spectral Density (PSD).
%
% The BM3D profile parameters were tuned such that both
% denoising strategies produce comparable residual noise levels.
% This allows the comparison to focus primarily on signal
% preservation (bias) rather than differences in noise magnitude.
%
% ==========================================================

addpath(fullfile('BM3D_New','bm3d'));

%% ==========================================================
% BM3D profile
%% ==========================================================

profile = BM3DProfile('refilter');

%% ==========================================================
% Variance Stabilizing Transform (Generalized Anscombe)
%% ==========================================================

V = 2 ./ xi_q .* sqrt( ...
    max(0,...
    xi_q .* (Z - tau) + ...
    (3/8) .* xi_q.^2 + ...
    xi_e^2));

%% ==========================================================
% BM3D denoising
%% ==========================================================

if useSpatialCorrelation

    %--------------------------------------------------------
    % Noise PSD estimated from the correlation kernel
    %--------------------------------------------------------

    PSD = abs(fft2( ...
        kappa_n,...
        size(Z,1),...
        size(Z,2))).^2 * numel(Z);

    %--------------------------------------------------------
    % Profile adjustment
    %
    % Parameters were empirically tuned to produce residual
    % noise levels comparable to the AWGN-based denoising,
    % allowing the comparison to focus on signal loss.
    %--------------------------------------------------------

    profile.filter_strength = filterStrength;

    profile.lambda_thr3D    = 2.6;
    profile.lambda_thr3D_re = 2.8;

    profile.mu2             = 0.9;
    profile.mu2_re          = 1.0;

    D_VST = BM3D(V,PSD,profile);

else

    %--------------------------------------------------------
    % Conventional BM3D assuming AWGN
    %--------------------------------------------------------

    D_VST = BM3D(V,1,'np');

end

%% ==========================================================
% Numerical stability
%% ==========================================================

D_VST = max(D_VST,10);

%% ==========================================================
% Exact inverse Generalized Anscombe Transform
%% ==========================================================

D = GenAnscombe_inverse_closed_form( ...
    D_VST,...
    xi_e,...
    xi_q,...
    0);

end