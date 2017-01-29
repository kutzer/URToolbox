function URToolboxUpdate
% URTOOLBOXUPDATE download and update the UR Toolbox. 
%
%   M. Kutzer 27Feb2016, USNA

% TODO - Find a location for "URToolbox Example SCRIPTS"
% TODO - update function for general operation

% Install UR Toolbox
ToolboxUpdate('UR');

updateModule = py.importlib.import_module('URModulesUpdate');

fprintf('Updating Python modules...');
try
    updateModule.updateURModules();
    fprintf('[Complete]\n');
catch
    % TODO - add appropriate update "run" info
    fprintf('[Failed]\n')
    fprintf(2,'Failed to update necessary Python modules. To install manually:\n')
    fprintf(2,'\t - Open the Command Prompt,\n');
    fprintf(2,'\t - Switch to the Python 3.4 Scripts directory\n');
    fprintf(2,'\t\t run "cd C:\\Python34\\Scripts"\n');
    fprintf(2,'\t - Install the math3D module\n');
    fprintf(2,'\t\t run "pip install math3d"\n');
    fprintf(2,'\t - Install the numpy module\n');
    fprintf(2,'\t\t run "pip install numpy"\n');
    fprintf(2,'\t - Install the urx module\n');
    fprintf(2,'\t\t run "pip install urx"\n');
end

end

function ToolboxUpdate(toolboxName)

%% Setup functions
ToolboxVer = str2func( sprintf('%sToolboxVer',toolboxName) );
installToolbox = str2func( sprintf('install%sToolbox',toolboxName) );

%% Check current version
A = ToolboxVer;

%% Setup temporary file directory
fprintf('Downloading the %s Toolbox...',toolboxName);
tmpFolder = sprintf('%sToolbox',toolboxName);
pname = fullfile(tempdir,tmpFolder);

%% Download and unzip toolbox (GitHub)
url = sprintf('https://github.com/kutzer/%sToolbox/archive/master.zip',toolboxName);
try
    fnames = unzip(url,pname);
    fprintf('SUCCESS\n');
    confirm = true;
catch
    confirm = false;
end

%% Check for successful download
if ~confirm
    error('InstallToolbox:FailedDownload','Failed to download updated version of %s Toolbox.',toolboxName);
end

%% Find base directory
install_pos = strfind(fnames, sprintf('install%sToolbox.m',toolboxName) );
sIdx = cell2mat( install_pos );
cIdx = ~cell2mat( cellfun(@isempty,install_pos,'UniformOutput',0) );

pname_star = fnames{cIdx}(1:sIdx-1);

%% Get current directory and temporarily change path
cpath = cd;
cd(pname_star);

%% Install ScorBot Toolbox
installToolbox(true);

%% Move back to current directory and remove temp file
cd(cpath);
[ok,msg] = rmdir(pname,'s');
if ~ok
    warning('Unable to remove temporary download folder. %s',msg);
end

%% Complete installation
fprintf('Installation complete.\n');

end
