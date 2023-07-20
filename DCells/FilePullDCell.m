function [DCOut,successes,failures] = FilePullDCell(FilesFile,RelDir)
%FILEPULLDCELL  Pull the struct data from a list of .mat files, convert them
% to DCells, and combine them in to one.
%
%   [DCellOut,SuccessfulLoads,FailedLoads] = FILEPULLDCELL(FILE) opens
%   FILE, reads the file names in FILE, loads the file names as .mat files,
%   converts the data inside into DCells, and outputs the combined DCell as
%   DCellOut.
%
%   -- FILE is expected to be a plain text document with a list of file
%   names which are to be loaded. Each entry is a file name "X" (without
%   .mat extension), entries are separated by a newline character, and the
%   list contains no other whitespace. An entry can be ignored by starting
%   the line with the "#" character. The entry "X" loads the file
%   "./DATA/X.mat". If the file cannot be loaded, the backup file
%   "./DATA/X__BKUP_A.mat" is automatically attempted instead. (Note there
%   are two underscores after the file name.) The file is searched for the
%   variable "Out", which is expected to be a struct containing data. This
%   struct is converted a DCell, and combined with the DCells from the
%   other files into DCellOut.
%   
%   -- SuccessfulLoads is a cell array containing the names of the files
%   which were successfully loaded and converted to DCell.
%   
%   -- FailedLoads is a cell array containing the names of the files which
%   were not successfully loaded and converted to DCell, either due to a
%   failure to load, or because the file contained no data.
%   
%   [DCellOut,SuccessfulLoads,FailedLoads] = FILEPULLDCELL(FILE,RELDIR)
%   uses the relative directory RELDIR to load files from "RELDIR/X.mat"
%   instead of defaulting to "./DATA".


if nargin<2
    RelDir = './DATA/';
else
    RelDir = cat(2,RelDir,'/');
end

fprintf('\nFiles Directory: %s',RelDir)

try
    FileID = fopen(FilesFile);
	if FileID~=-1
		fprintf('\nFile %s opened...\n',FilesFile)
    else
        DCOut = {};
		ErMsg = sprintf('File %s could not be opened. Maybe the name is wrong?',FilesFile);
        ErSrct = struct('message',ErMsg,'identifier','FilePullDCell:UnableToOpenFile');
        error(ErSrct)
	end
catch OpenError
    DCOut = {};
    error(OpenError)
end

C = textscan(FileID,'%s');
Names = C{1};
fprintf('\nNames collected...')

DCOut = {};
failures = {};
successes = {};
BKUP = {};

for ii=1:numel(Names)
	if Names{ii}(1)~='#' %this allows us to `comment' out a name by putting a `#' in front of it in the Files-file.
        if exist(cat(2,RelDir,Names{ii},'.mat'),'file')~=2
            fprintf('\n >> %s.mat Does not exist.',Names{ii})
                % If the file doesn't exist, the code that tries to find the filesize will throw an error, so we stop here.
        else
            loadTries = 0;
            dcellTries = 0;
            bts = dir(cat(2,RelDir,Names{ii},'.mat')).bytes; % 'dir' is more persnickety, and needs the folder directory
            fprintf('\n  %s  [ %.1f Kb ] ... ',Names{ii},bts/1000)
            while loadTries<4
                try
                    CurrentLoad = load(cat(2,RelDir,Names{ii}),'Out');   % As long as we're in the Job folder, we don't need the folder name or path
                    fprintf('loaded...')
                    loadTries = 10; 		% we successfully loaded the file!
                    for Out_entry_idx = 1:numel(CurrentLoad.Out)	% one point per Out is so common, I forgot that this could happen!
                        dcellTries = 0;
                        if (numel(CurrentLoad.Out(Out_entry_idx).PurificationEntropy)==0)...
                                ||(numel(CurrentLoad.Out(Out_entry_idx).LengthDistribution)==0)...
                                ||(numel(CurrentLoad.Out(Out_entry_idx).SubsystemEntanglement)==0)
                            fprintf('Data empty.')
                            failures{end+1} = Names{ii};
                        else
                            while dcellTries<4  % let's pull the DCell
                                try
                                    DCOut = DCellAppend(DCOut,CurrentLoad.Out(Out_entry_idx));
                                    if Out_entry_idx==1
                                        fprintf("Converted.")
                                    else
                                        fprintf(',(%d)',Out_entry_idx)
                                    end
                                    dcellTries = 10; 	% we successfully pulled the data!
                                    if Out_entry_idx==1
                                        successes{end+1} = Names{ii};
                                    end
                                catch DCellFail
                                    fprintf('\nfailed to convert...')
                                    fprintf('\n  ~~  %s',DCellFail.identifier)
                                    fprintf('\n  ~~  "%s"',DCellFail.message)
                                    fprintf('\n 	Trying again...')
                                    dcellTries = dcellTries + 1;
                                    pause(0.5)
                                    if dcellTries>=4	% we failed to pull the data... try the first backup, later
                                        BKUP{end+1}=Names{ii};
                                    end
                                end
                            end
                        end
                    end
                catch LoadEr
                    if loadTries<10
                        fprintf('load failed...')
                        loadTries = loadTries + 1;
                    else 	% else the file was loaded successfully, bu an error was thrown while trying to convert to DCell.
                        fprintf('\n >>: error thrown while trying to converting to DCell...')
                        fprintf('\n ~~ %s',LoadEr.identifier)
                        fprintf('\n ~~ %s',LoadEr.message)
                    end
                    pause(1)	% give the system some time to compose itself...
                    if loadTries>=4		% we've failed to load the file... try the first backup, later
                        BKUP{end+1}=Names{ii};
                    end
                end
            end
        end    
    end
end

if numel(BKUP)>0
	fprintf('\nTime to try BKUPs...')
end

BKUPsucc = {};

for ii=1:numel(BKUP)
    try
		BKname = cat(2,BKUP{ii},'__BKUP_A');
		bts = dir(cat(2,RelDir,BKname,'.mat')).bytes;
		fprintf('\n  %s  [ %.1f Kb ] ... ',BKname,bts/1000)
        CurrentLoad = load(BKname,'Out');
		fprintf('loaded...')
		for Out_entry_idx=1:numel(CurrentLoad.Out)
			if (numel(CurrentLoad.Out(Out_entry_idx).PurificationEntropy)==0)...
                    ||(numel(CurrentLoad.Out(Out_entry_idx).LengthDistribution)==0)...
                    ||(numel(CurrentLoad.Out(Out_entry_idx).SubsystemEntanglement)==0)
				fprintf('Data empty.')
			else
				try
					DCOut = DCellAppend(DCOut,CurrentLoad.Out);
					if Out_entry_idx==1
						fprintf("Converted.")
					else
						fprintf(',(%d)',Out_entry_idx)
					end
					successes{end+1} = BKname;
					BKUPsucc{end+1} = BKname;
				catch DCellFail
                    fprintf('\n  %s failed to convert.',cat(2,BKUP{ii},'__BKUP_A'))
                    fprintf('\n  ~~  %s',DCellFail.identifier)
                    fprintf('\n  ~~  "%s"',DCellFail.message)
                    fprintf('\n 	Trying again...')
					failures{end+1}=BKUP{ii};
				end
			end
		end
    catch
        failures{end+1}=BKUP{ii};
		fprintf('\n    %s failed to load.',cat(2,BKUP{ii},'__BKUP_A'))
    end
end


fprintf('\n  Backups loaded:')
if numel(BKUPsucc)==0
	fprintf('\n    none.')
else
	for ii=1:numel(BKUPsucc)
		fprintf('\n    %s',BKUPsucc{ii})
	end
end

fprintf('\n  Failures:')
if numel(failures)==0
	fprintf('\n    none!')
else
	for ii=1:numel(failures)
		fprintf('\n    %s',failures{ii})
	end
end

end

%22/Feb/2021 - Created to decrease workload for collecting data across a
%   bunch of files.
%08/Oct/2021 - Added notifications for the size of the file, and code for
%	when there hasn't been any data saved to the file yet.
%19/Oct/2021 - Added code to handle the apparently as yet unaccounted for
%	case where Out has more than one structure entry (i.e. Out(1).S, Out(2).S,...).
%{
01/Mar/2023 - Updated the code to work with Parafermion notation.

%}