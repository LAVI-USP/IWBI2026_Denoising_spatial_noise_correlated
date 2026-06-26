function Ycluster = insertCluster( ...
    Y,...
    clusterMask,...
    insertionInfo)

% ==========================================================
% Insert microcalcification clusters into the synthetic image.
%
% Author: Renann F. Brandao
% ==========================================================

Ycluster = Y;

for k = 1:length(insertionInfo)

    center = insertionInfo{k}.Center;

    rows = center(1)-ceil(size(clusterMask,1)/2): ...
           center(1)+floor(size(clusterMask,1)/2)-1;

    cols = center(2)-ceil(size(clusterMask,2)/2): ...
           center(2)+floor(size(clusterMask,2)/2)-1;

    Ycluster(rows,cols)= ...
        Ycluster(rows,cols).*clusterMask;

end