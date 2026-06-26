function [nps2D, NNPS1D, f1D] = NPS_FAB(I,W, px, gt, par)
    I = double(I);
    [M, N] = size(I);

    if ~exist('W', 'var'), W = M;
    elseif (W <= 0 || W > M), W = M;
    end;
    if ~exist('gt', 'var'), gt = 0; end;
    if ~exist('par', 'var'), par = 0; end;
    
    % Sub-images Selection (processing each sub-image)
    % Size of each ROI
    S = (M/W)*(N/W); % Number of sub-images
    k = 0;
    
    for i = 1:M/W
        for j = 1:N/W
            k = k+1;
            sub_img(:,:,k) = I((((i-1)*W)+1):i*W,(((j-1)*W)+1):j*W);
            if gt == 0
                las = mean(I(:)); % Large Area Signal
                mean_sub_img(:,:,k) = mean(mean(sub_img(:,:,k)));
                F(:,:,k) = sub_img(:,:,k) - mean_sub_img(:,:,k);
            elseif gt < 0
                las = 1; % Large Area Signal
                mean_sub_img(:,:,k) = mean(mean(sub_img(:,:,k)));
                F(:,:,k) = sub_img(:,:,k) - mean_sub_img(:,:,k);
            else
                las = mean(gt(:)); % Large Area Signal
                F(:,:,k) = sub_img(:,:,k);
            end;
             
        end
    end
    
    % NPS 2D
     %[nps2D, f] = calc_digital_nps(F, 2, px, 1, 0, 1);
     [nps2D, f] = calc_digital_nps(F, 2, px,1,0,1);
     %nnps2D = nps2D./max(I(:)).^2; % Rod
     %nnps2D = nps2D./las.^2;
     nnps2D = nps2D;
    
    
    % NPS 1D - RADIAL - Euclidean Distance
    
    % Distance matrix (u, v) plane;
    aux = repmat(-floor(W/2):ceil(W/2)-1,W,1);
    D = round(sqrt(aux.^2+(aux').^2));
    
    NNPS1D = zeros(1,floor(W/2));
    if par
        parfor k = 1:W/2
            aux = nnps2D(D == k);
            NNPS1D(k) = mean(aux(:));
        end;
    else
        for k = 1:W/2
            aux = nnps2D(D == k);
            NNPS1D(k) = mean(aux(:));
        end;
    end
    
    % Frequency
    delta_f = 1/(W*px);
    f1D = zeros(1,floor(W/2)-1);
    f1D(1) = delta_f;
    for i = 1:((W/2)-1)
        f1D(i+1) = f1D(i)+delta_f;
    end
end