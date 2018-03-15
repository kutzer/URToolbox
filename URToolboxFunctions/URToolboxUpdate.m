function URToolboxUpdate
% URTOOLBOXUPDATE download and update the UR Toolbox. 
%
%   M. Kutzer 27Feb2016, USNA

% Updates
%   15Mar2018 - Updated to include try/catch for required toolbox
%               installations and include msgbox warning when download 
%               fails.

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
try
    A = ToolboxVer;
catch ME
    A = [];
    fprintf('No previous version of %s detected.\n',toolboxName);
end

%% Setup temporary file directory
fprintf('Downloading the %s Toolbox...',toolboxName);
tmpFolder = sprintf('%sToolbox',toolboxName);
pname = fullfile(tempdir,tmpFolder);

%% Download and unzip toolbox (GitHub)
url = sprintf('https://github.com/kutzer/%sToolbox/archive/master.zip',toolboxName);
try
    % Original download/unzip method using "unzip"
    fnames = unzip(url,pname);
    
    fprintf('SUCCESS\n');
    confirm = true;
catch
    try
        % Alternative download method using "urlwrite"
        % - This method is flagged as not recommended in the MATLAB
        % documentation.
        % TODO - Consider an alternative to urlwrite.
        tmpFname = sprintf('%sToolbox-master.zip',toolboxName);
        urlwrite(url,fullfile(pname,tmpFname));
        fnames = unzip(fullfile(pname,tmpFname),pname);
        delete(fullfile(pname,tmpFname));
        
        fprintf('SUCCESS\n');
        confirm = true;
    catch
        fprintf('FAILED\n');
        confirm = false;
    end
end

%% Check for successful download
alternativeInstallMsg = [...
    sprintf('Manually download the %s Toolbox using the following link:\n',toolboxName),...
    sprintf('\n'),...
    sprintf('%s\n',url),...
    sprintf('\n'),...
    sprintf('Once the file is downloaded:\n'),...
    sprintf('\t(1) Unzip your download of the "%sToolbox"\n',toolboxName),...
    sprintf('\t(2) Change your "working directory" to the location of "install%sToolbox.m"\n',toolboxName),...
    sprintf('\t(3) Enter "install%sToolbox" (without quotes) into the command window\n',toolboxName),...
    sprintf('\t(4) Press Enter.')];
        
if ~confirm
    warning('InstallToolbox:FailedDownload','Failed to download updated version of %s Toolbox.',toolboxName);
    fprintf(2,'\n%s\n',alternativeInstallMsg);
    
    msgbox(alternativeInstallMsg, sprintf('Failed to download %s Toolbox',toolboxName),'warn');
    return
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