function H = pTransform2mMatrix(ttrans)

ndArray = ttrans.matrix.A;
nList = ndArray.tolist;

nCell = cell(nList); 

% TODO - preallocate memory etc
for i = 1:numel(nCell)
    iList = nCell{i};
    iCell = cell(iList);
    H(i,:) = cell2mat(iCell);
end