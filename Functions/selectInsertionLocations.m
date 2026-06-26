function insertionInfo = selectInsertionLocations( ...
    Y,...
    candidateLocations,...
    clusterMask,...
    nClusters)

% ==========================================================
% Automatically select insertion locations inside homogeneous
% breast tissue.
%
% Author: Renann F. Brandao
% ==========================================================

maxLocalStd = 30;

insertionInfo = cell(nClusters,1);

allCenters = [0 0];

for k = 1:nClusters

    searching = true;

    while searching

        [row,col] = find(candidateLocations);

        possible = [row col];

        idx = datasample(1:size(possible,1),1,'Replace',false);

        center = possible(idx,:);

        ROI = Y( ...
            center(1)-ceil(size(clusterMask,1)/2): ...
            center(1)+floor(size(clusterMask,1)/2)-1,...
            center(2)-ceil(size(clusterMask,2)/2): ...
            center(2)+floor(size(clusterMask,2)/2)-1);

        localStd = std2(ROI);

        if localStd < maxLocalStd && ...
                sum(ismember(center,allCenters,'rows'))==0

            searching = false;

        end

    end

    candidateLocations( ...
        center(1)-125:center(1)+124,...
        center(2)-125:center(2)+124)=0;

    insertionInfo{k}.Center = center;

    allCenters = [allCenters; center];

end