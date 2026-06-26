function insertedROIs = extractInsertedROIs( ...
    Y,...
    insertionInfo,...
    roiSize)

% ==========================================================
% Extract ROIs centered at each inserted cluster.
% ==========================================================

halfROI = roiSize/2;

for k=1:length(insertionInfo)

    center = insertionInfo{k}.Center;

    insertedROIs(:,:,k)= ...
        Y( ...
        center(1)-halfROI+1:center(1)+halfROI,...
        center(2)-halfROI+1:center(2)+halfROI);

end