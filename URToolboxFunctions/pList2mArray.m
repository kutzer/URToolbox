%{

Convert Python lists into MATLAB arrays

ENS Kevin Strotz, USN
22 September 2016

%}

function mArray = pList2mArray(pList)

    mCell = cell(pList);
    mArray = cell2mat(mCell);
    
end