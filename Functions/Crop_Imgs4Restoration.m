function [Crop,indX_Sup,indX_Inf,indY_Inf,indY_Sup] = Crop_Imgs4Restoration(img,info,BreastMask)

if strcmp(info.ImageLaterality,'R')
    img = flip(img,2);
    BreastMask = flip(BreastMask,2);
end

maskCrop = mean(BreastMask,1)>0;
indx = find(maskCrop>0);
indX_Sup = indx(end)+200;
indX_Inf = 1;

maskCrop = mean(BreastMask,2)>0;
indy = find(maskCrop>0);
indY_Inf = max(indy(1)-100,1)-200;
indY_Sup = min(indy(end)+100,size(img,1))+200;

Crop = img(indY_Inf:indY_Sup,indX_Inf:indX_Sup);

maskCrop = mean(BreastMask,1)>0;
indx = find(maskCrop>0);


if strcmp(info.ImageLaterality,'R')
    Crop = flip(Crop,2);
    
    indX(1) = size(img,2) - indX_Sup +1;
    indX(2) = size(img,2);
    indX  =sort(indX);
    indX_Inf = indX(1);
    indX_Sup = indX(2);
end

end



