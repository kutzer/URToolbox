%{

Convert Python dictionary to MATLAB structure
This will stay as Python types within the structure if they
are also lists, tuples, dictionaries, etc

ENS Kevin Strotz
22 September 2016

%}

function mStruct = pDict2mStruct(pDict)

    mStruct = struct(pDict);
    
end