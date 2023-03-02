function [Scell,successes,failures] = FilePullScell(FilesFile,RelDir)
% For Parafermion jobs. Reads a text file with the relevent file names, and tries to pull data from them all. Returns names that it couldn't load.
%%%%%%%%%%%%%%%%%%%%%%%%%%%

		%  Assumes bare filename, without '.mat' extension, for BKUP handling
        %  Expects to be executed from within the Job folder, with the files to be
        %   pulled inside a DATA folder; this is determined by RelDir.
        %   Furthermore, the folders need to be in the MATLAB path.
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    RelDir = './DATA/';	% Remember, Hyak's Linux uses '/', while Windows uses '\' or '/'.
else
    RelDir = cat(2,RelDir,'/');
end

try
    FileID = fopen(FilesFile);
	if FileID~=-1
		fprintf('\nFile %s opened...\n',FilesFile)
	else
		fprintf('\n >> Error: %s could not be opened. Maybe the name is wrong?')
		return
	end
catch
    frpintf('\nCouldn''t open file list.\n')
    return
end

C = textscan(FileID,'%s');
Names = C{1};
fprintf('\nNames collected...')

Scell = {};
failures = {};
successes = {};
BKUP = {};

for ii=1:numel(Names)
	if Names{ii}(1)~='#' %this allows us to `comment' out a name by putting a `#' in front of it in the Files-file.
        if exist(cat(2,RelDir,Names{ii},'.mat'),'file')~=2
            fprintf('\n >> %s Does not exist.',Names{ii})
                % if the file doesn't exist, the code that tries to find
                % the filesize will throw an error
        else
            loadTries = 0;
            scellTries = 0;
            bts = dir(cat(2,RelDir,Names{ii},'.mat')).bytes; % 'dir' is more persinickity, and needs the folder directory
            fprintf('\n  %s  [ %.1f Kb ] ... ',Names{ii},bts/1000)
            while loadTries<4
                try
                    Load = load(cat(2,RelDir,Names{ii}),'Out');   % as long as we're in the Job folder, we don't need the folder name or path
                    fprintf('loaded...')
                    loadTries = 10; 		% we successfully loaded the file!
                    for jj = 1:numel(Load.Out)	% one point per Out is so common, I forgot that this could happen!
                        scellTries = 0;
                        if numel(Load.Out(jj).PurificationEntropy)==0
                            fprintf('Data empty.')
                            failures{numel(failures)+1} = Names{ii};
                        else
                            while scellTries<4  % let's pull the Scell
                                try
                                    Scell = ScellAppend(Scell,Load.Out(jj));
                                    if jj==1
                                        fprintf("Scell'd.")
                                    else
                                        fprintf(',(%d)',jj)
                                    end
                                    scellTries = 10; 	% we successfully pulled the data!
                                    if jj==1
                                        successes{numel(successes)+1} = Names{ii};
                                    end
                                catch
                                    fprintf('failed to Scellerize...')
                                    scellTries = scellTries + 1;
                                    pause(0.5)
                                    if scellTries>=4	% we failed to pull the data... try the first backup, later
                                        BKUP{numel(BKUP)+1}=Names{ii};
                                    end
                                end
                            end
                        end
                    end
                catch LoadEr
                    if loadTries<10
                        fprintf('load failed...')
                        loadTries = loadTries + 1;
                    else 	% else an error was thrown while trying to Scellerize
                        fprintf('\n >>: error thrown while trying to Scellerize...')
                        fprintf('\n ~~ %s',LoadEr.identifier)
                        fprintf('\n ~~ %s',LoadEr.message)
                    end
                    pause(1)	% give the system some time to compose itself...
                    if loadTries>=4		% we've failed to load the file... try the first backup, later
                        BKUP{numel(BKUP)+1}=Names{ii};
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
        Load = load(BKname,'Out');
		fprintf('loaded...')
		for jj=1:numel(Load.Out)
			if numel(Load.Out(jj).PurificationEntropy)==0
				fprintf('Data empty.')
			else
				try
					Scell = ScellAppend(Scell,Load.Out);
					if jj==1
						fprintf("Scell'd.")
					else
						fprintf(',(%d)',jj)
					end
					successes{numel(successes)+1} = BKname;
					BKUPsucc{numel(BKUPsucc)+1} = BKname;
				catch
					failures{numel(failures)+1}=BKUP{ii};
					fprintf('\n    %s failed to Scellerize.',cat(2,BKUP{ii},'__BKUP_A'))
				end
			end
		end
    catch
        failures{numel(failures)+1}=BKUP{ii};
		fprintf('\n    %s failed to load.',cat(2,BKUP{ii},'__BKUP_A'))
    end
end


fprintf('\n  Backups:')
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