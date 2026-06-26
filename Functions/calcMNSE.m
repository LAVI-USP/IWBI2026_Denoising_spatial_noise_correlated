function [MNSEMean,MNSE_map, RV,RVt, Bias2,Bias2_MAP_1] = calcMNSE(z_GT,mask,img_noisy)
%% GT
Factor1 = 0;

GT=mean(z_GT,3);

RV1=(var(z_GT,[],3)./GT);
%Factor1=(mean(RV1(mask))/(size(z_GT,3)));

%% NOISY
rl=size(img_noisy,3);

for k=1:rl
    Img_aux = img_noisy(:,:,k);
    %ImgNoisy_DC_OK(:,:,k)=reshape(polyval(polyfit(Img_aux(mask),GT(mask),1),Img_aux),size(GT));
    ImgNoisy_DC_OK(:,:,k) = Img_aux.*(mean2(GT(mask))/mean2(Img_aux(mask)));

    %mean2(GT(mask))/mean2(Img_aux(mask))

    NQE=((GT-ImgNoisy_DC_OK(:,:,k)).^2)./GT;
    MNSE(k)=mean(-Factor1+NQE(mask));
    MNSE_map(:,:,k)=-Factor1+NQE;

end
MNSE_map = mean(MNSE_map,3);
MNSEMean=mean(MNSE);
STD=std(MNSE);
[~,~,MNSECI] = ttest(MNSE(:));

%% Estimate the normalized residual noise variance
RVt=var(ImgNoisy_DC_OK,[],3)./GT;
RV=mean(RVt(mask));
[~,~,RVCI] = ttest(RVt(mask));

%% Estimate the normalized bias squared
Bias2t=((GT-mean(ImgNoisy_DC_OK,3)).^2)./GT;

%% Again, there is an error associated with the limited number of realizations
% that we used to estimate the bias. This second factor is related to the
% number of realizations used for the bias estimation (N_RLS), while Factor
% 1 is related to the number of realizations used for the GT (N_GT).
Factor2=(RV/rl);

%% The bias must now be adjusted by two factors: one of them due to the 'imperfect'
% GT (Factor1) and the second one due to the limited number of realizations
% used to estimate the bias itself (Factor2)
Bias2_MAP_1=-Factor1-Factor2+Bias2t;
Bias2_MAP=-Factor1-Factor2+Bias2t(mask);
Bias2=mean(Bias2_MAP);
[~,~,Bias2CI] = ttest(Bias2_MAP);

%% Since the bias squared and the residual noise variance are the decompositions
% of the MNSE, the sum of bias^2 + Residual Variance must be equals to
% the MNSE
disp(['Total MNSE: ' num2str(round(100*MNSEMean,2)) ' % [' num2str(round(100*MNSECI(1),2)) '% ' num2str(round(100*MNSECI(2),2)) '%]']);
disp(['Residual Noise: ' num2str(round(100*RV,2)) ' % [' num2str(round(100*RVCI(1),2)) '% ' num2str(round(100*RVCI(2),2)) '%]']);
disp(['Bias Squared: ' num2str(round(100*Bias2,2)) '% [' num2str(round(100*Bias2CI(1),2)) '% ' num2str(round(100*Bias2CI(2),2)) '%]']);
disp(['Proof (must be ~0%): ' num2str(round(100*(MNSEMean-RV-Bias2),2)) '%']);

% Results=[MNSEMean RV Bias2;];

end