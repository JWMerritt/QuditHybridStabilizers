function [RDOut,successes,failures] = RDataFromList(FileList,DataDir)
%RDATAFROMLIST  Pull the `Out` struct data from a list of .mat files,
%convert them to RData objects, and combine them in to one.
%
%   [RDataOut, SuccessfulLoads, FailedLoads] = RDATAFROMLIST(FILE) opens
%   FILE, reads the file names in FILE, loads the file names as .mat files,
%   converts the data inside into RData objects, and outputs the combined
%   RData object as RDataOut.
%
%   -- FILE is expected to be a plain text document with a list of file
%   names which are to be loaded. Each entry is a file named NAME (without
%   .mat extension), entries are separated by a newline character, **and
%   the list contains no other whitespace**. An entry can be ignored by
%   starting the line with the "#" character. The entry NAME loads the file
%   "./DATA/NAME.mat". If the file cannot be loaded, the backup file
%   "./DATA/NAME__BKUP_A.mat" is automatically attempted instead. The file
%   is searched for the variable "Out", which is expected to be a struct
%   containing data. This struct is converted an RData object, and combined
%   with the other RData objects from the other files into RDataOut.
%   
%   -- SuccessfulLoads is a cell array containing the names of the files
%   which were successfully loaded and converted into the RData object.
%   
%   -- FailedLoads is a cell array containing the names of the files which
%   were not successfully loaded and converted into the RData object,
%   either due to a failure to load, or because the file contained no data.
%   
%   [RDataOut, SuccessfulLoads, FailedLoads] = RDATAFROMLIST(FILE, DATADIR)
%   uses the (possibly relative) directory DATADIR to load files from
%   "DATADIR/NAME.mat" instead of defaulting to "./DATA".
%
%   See also RDATA
    
    % both the following values need to be less than 10000.
    MAX_LOAD_ATTEMPTS = 4;  % maximum number of times we'll try to load a file
    MAX_OUTSTRUCT_ATTEMPTS = 4;  % maximum number of times we'll try to convert 'Out' into a DCell


    if nargin<2
        DataDir = './DATA/';
    else
        DataDir = cat(2,DataDir,'/');
    end

    fprintf('\nFiles Directory: %s',DataDir)
    RDOut = RData();
    failures = {};
    successes = {};

    try
        FileID = fopen(FileList);
        if FileID~=-1
            fprintf('\nFile %s opened...\n',FileList)
        else
            ErrMsg = sprintf('File %s could not be opened. Maybe the name is wrong?',FileList);
            ErrStruct = struct('message',ErrMsg,'identifier','RDataFromList:UnableToOpenFile');
            error(ErrStruct)
        end
    catch OpenError
        error(OpenError)
    end

    C = textscan(FileID,'%s');
    Names = C{1};
    fprintf('\nNames collected...')

    BKUP_loads = {};  % holds the names of failed loads, where we need to try loading backup files

    for ii=1:numel(Names)
        if Names{ii}(1)~='#' %this allows us to "comment" out a name by putting a "#" in front of it in the file list.
            FullName = cat(2,DataDir,Names{ii},'.mat');
            if exist(FullName,'file')~=2
                fprintf('\n  %s Does not exist. ( %s )',Names{ii}, FullName)
                    % If the file doesn't exist, the code that tries to find the filesize will throw an error, so we stop here.
                failures{end+1} = Names{ii};
            else
                [SuccessResult, NextRData] = local_RData_From_File(Names{ii}, DataDir, '', MAX_LOAD_ATTEMPTS, MAX_OUTSTRUCT_ATTEMPTS);
                if SuccessResult
                    successes{end+1} = Names{ii};
                    RDOut.append(NextRData);
                else
                    BKUP_loads{end+1} = Names{ii};  % we'll try to load these failures from their BKUP files
                end
            end    
        end
    end

    if numel(BKUP_loads)>0
        fprintf('\nTime to try BKUPs...')
    end

    BKUP_successes = {};

    for ii=1:numel(BKUP_loads)
        [SuccessResult, NextRData] = local_RData_From_File(BKUP_loads{ii}, DataDir, '__BKUP_A', MAX_LOAD_ATTEMPTS, MAX_OUTSTRUCT_ATTEMPTS);
        if SuccessResult
            BKUP_successes{end+1} = BKUP_loads{ii};
            RDOut.append(NextRData);
        else
            failures{end+1} = BKUP_loads{ii};
        end
    end


    fprintf('\n\nComplete.\n  Backups loaded:')
    if numel(BKUP_successes)==0
        fprintf('\n    none.')
    else
        for ii=1:numel(BKUP_successes)
            fprintf('\n    %s',BKUP_successes{ii})
        end
    end

    fprintf('\n  Failures:')
    if numel(failures)==0
        fprintf('\n    none!')
    else
        for ii=1:numel(failures)
            fprintf('\n    %s',failures{ii})
        end
        fprintf('\n')
    end

end




function [SuccessResult, localOutRData] = local_RData_From_File(Filename, local_RelDir, appendum, MAX_LOAD_ATTEMPTS, MAX_OUTSTRUCT_ATTEMPTS)
    % local function to hold code relating to repeatedly attempting to load a
    % file and convert the contents to an RData object.
    
    localOutRData = RData();
    loadTriesCounter = 0;
    FullName = cat(2, Filename, appendum);
    bts = dir(cat(2, local_RelDir, FullName, '.mat')).bytes; % 'dir' is more persnickety, and needs the folder directory
    fprintf('\n  %s  [ %.1f Kb ] ... ', FullName, bts/1000)
    SUCCESSFUL_LOAD = 10000;  % used to flag a successful load
    while loadTriesCounter <= MAX_LOAD_ATTEMPTS
        try
            CurrentLoad = load(cat(2, local_RelDir, FullName), 'Out');   % As long as we're in the Job folder, we don't need the folder name or path
            fprintf('loaded...')
            loadTriesCounter = SUCCESSFUL_LOAD; 		% we successfully loaded the file!
        catch LoadEr
            if loadTriesCounter < SUCCESSFUL_LOAD
                fprintf('load failed...')
                loadTriesCounter = loadTriesCounter + 1;
            else 	% else the file was loaded successfully, bu an error was thrown while trying to convert to RData object.
                fprintf('\n >>: error thrown while trying to load %s ...', FullName)
                fprintf('\n ~~ %s',LoadEr.identifier)
                fprintf('\n ~~ %s',LoadEr.message)
            end
            pause(0.5)	% give the system some time to compose itself...
            if loadTriesCounter > MAX_LOAD_ATTEMPTS		% we've failed to load the file... try the first backup, later
                SuccessResult = false;
                return
            end
        end
    end
    % We've successfully loaded the file into CurrentLoad
    [SuccessResult, localOutRData] = local_Pull_OutStruct_To_RData(CurrentLoad.Out, MAX_OUTSTRUCT_ATTEMPTS);
end



function [SuccessResult, localOutRData] = local_Pull_OutStruct_To_RData(OutStruct, MAX_OUTSTRUCT_ATTEMPTS)
    SuccessResult = true;  % did the operation succeed?
    SUCCESSFUL_LOAD = 10000;
    localOutRData = DCell();
    for Out_entry_idx = 1:numel(OutStruct)
        if (numel(OutStruct(Out_entry_idx).PurificationEntropy)==0)...
                ||(numel(OutStruct(Out_entry_idx).LengthDistribution)==0)...
                ||(numel(OutStruct(Out_entry_idx).SubsystemEntropy)==0)
            fprintf('Data empty.')
        else
            rdataTriesCounter = 0;
            while rdataTriesCounter <= MAX_OUTSTRUCT_ATTEMPTS
                try
                    NextRData = RData(OutStruct(Out_entry_idx));
                    localOutRData.append(NextRData);
                    if Out_entry_idx==1
                        fprintf("Converted")
                    else
                        fprintf(',(%d)',Out_entry_idx)
                    end
                    rdataTriesCounter = SUCCESSFUL_LOAD; 	% we successfully pulled the data!
                catch RDataFail
                    fprintf('\nfailed to convert...')
                    fprintf('\n  ~~  %s',RDataFail.identifier)
                    fprintf('\n  ~~  "%s"',RDataFail.message)
                    fprintf('\n 	Trying again...')
                    rdataTriesCounter = rdataTriesCounter + 1;
                    pause(0.1)
                    if rdataTriesCounter > MAX_OUTSTRUCT_ATTEMPTS	% we failed to pull the data... try the first backup, later
                        SuccessResult = false;
                        return
                    end
                end
            end
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
09/Jan/2024 - Refactored the code into multiple smaller chuncks, and
renamed all references to 'DCell' into 'RData'.

%}