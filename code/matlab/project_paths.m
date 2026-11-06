function P = project_paths()
%PROJECT_PATHS  Return absolute paths of the project directories.
%   Paths are derived from the location of this file, so the project can be
%   cloned anywhere without editing any script.
%
%   P.root      project root
%   P.dataRaw   raw EEGLAB datasets (S1.set/.fdt, S2.set/.fdt) - not in git
%   P.dataProc  datasets produced by the pipeline - not in git
%   P.figures   exported ERP figures
%   P.results   ERP numeric results (CSV / MAT)
%   P.eeglab    EEGLAB root folder (set the EEGLAB_PATH environment variable
%               to override the default)

here = fileparts(mfilename('fullpath'));          % <root>/code/matlab
P.root     = fileparts(fileparts(here));

P.dataRaw  = fullfile(P.root, 'data', 'raw');
P.dataProc = fullfile(P.root, 'data', 'processed');
P.figures  = fullfile(P.root, 'figures');
P.results  = fullfile(P.root, 'results');

P.eeglab = getenv('EEGLAB_PATH');
if isempty(P.eeglab)
    P.eeglab = 'D:\eeglab\eeglab2024.2';          % default on the author's PC
end

if ~exist(P.dataProc, 'dir'), mkdir(P.dataProc); end
if ~exist(P.figures,  'dir'), mkdir(P.figures);  end
if ~exist(P.results,  'dir'), mkdir(P.results);  end
end
