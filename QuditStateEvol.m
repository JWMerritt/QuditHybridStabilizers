function QuditStateEvol(CKPT_Name_Fullpath,CodeLocation,Verbose)
%QUDITSTATEEVOL  Evolve a stabilizer state and save the results.
%
%   QUDITSTATEEVOL(CKPT_NAME_FULLPATH, CODELOCATION) loads the CKPT file
%   from the location specified in CKPT_NAME_FULLPATH. In addition, add to
%   the MATLAB path all of the directories and sub-directories of
%   CODELOCATION, although this should have already been done.
%   
%   -- CKPT_NAME_FULLPATH is the full path name of the CKPT file. Do not
%   add '.mat' to the end of this entry. This file should contain
%   information about what is being calculated and the partial data from
%   the current realization if the code was halted in the middle of a
%   calculation. It also points to the DATA file where the results will be
%   saved.
%
%   -- CODELOCATION is the directory which includes the QUDITSTATEEVOL
%   function and all of its dependencies, such as the Unitary functions,
%   TimeStep functions, etc. The code executes
%   addpath(genpath(CODELOCATION)).
%
%   QUDITSTATEEVOL(CKPT_NAME_FULLPATH, CODELOCATION, VERBOSE) if
%   VERBOSE=true, this will output more debug information to the terminal
%   output.
%
%   See also MAKE_CKPT, RUNBATCH

RunVersion = 'RELEASE_0.9';
SelfName = 'QuditStateEvol'; % Here to have the correct documentation for errors.

if nargin<3
    Verbose=false;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DATA_UsedVariables = {
    'Out'
    'JobName'
    'JobInformation'
    'JobSpecifications'
    'Hdim'
    'IsPure'
    'Job_RunLog'
    };
%	These are the saved DATA variables that we need to run the code	


CKPT_UsedVariables = {
    'JobName'
    'DATA_Name_Fullpath'
    'UnitaryFunc'
    'EvolFunc'
    'C_Numbers_Int'
    'TotalTimeSteps'                % should be a matrix of the same size as SystemSizeValues
    'SystemSizeValues'
    'Number_SystemSizes'
    'SystemSize_Index'
    'MeasurementProbabilityValues'
    'Number_MeasurementProbabilities'
    'MeasurementProbability_Index'
    'InteractingProbabilityValues'
    'Number_InteractingProbabilities'
    'InteractingProbability_Index'
    'RunOptions'
    'CircuitsPerSystemSize'     % should be a matrix of the same size as SystemSizeValues
    'TimeStepsBeforeSaving'     % should be a matrix of the same size as SystemSizeValues
    'Number_ParallelStates'     % should be a single number!
    'Number_TimesLoaded'
    'Number_TimesCalculationsSaved'
    'CircuitsPerSystemSize_Counter'
    'TimeSteps_CurrentState'
    'TimeBeforeMakingBKUP'
    'TimeBeforeMakingBKUP_Counter'
    'CurrentNumber_TimesBackedUp'
    'InitializeState'
    'StateArray_Coded'
    };
%	These are the CKPT variables that we need to run the code


DATA_BKUPVariables = cat(1,DATA_UsedVariables,{
	'BKUP_InfoString'
	'SystemSize_Index'
	'MeasurementProbability_Index'
	'InteractingProbability_Index'
	'CircuitsPerSystemSize_Counter'
	});
%	These are the extra variables we include with the DATA_BKUP files, so that we can resume calculations from this point.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Load helper functions
%	The MATLAB compiler throws a fit if it doesn't explicitly see the variables being loaded from the files.
%	The following functions put these variable lists into a nice format you can copy and paste in the 8 load calls below
%	Copy all the code from this first part of the function and run it separately to get a printout of the lines you need,
%		and then paste them below.

%{
CKPT_LoadString = '''';
% This is the list of all the variables that we load the CKPT file.
for ii=1:numel(CKPT_UsedVariables)
	CKPT_LoadString = cat(2,CKPT_LoadString,CKPT_UsedVariables{ii});
	if ii~=numel(CKPT_UsedVariables)
		CKPT_LoadString = cat(2,CKPT_LoadString,''',''');
	else
		CKPT_LoadString = cat(2,CKPT_LoadString,'''');
	end
end

DATA_LoadString = '''';
% This is the list of all the variables that we save to the DATA file.
for ii=1:numel(DATA_UsedVariables)
	DATA_LoadString = cat(2,DATA_LoadString,DATA_UsedVariables{ii});
	if ii~=numel(DATA_UsedVariables)
		DATA_LoadString = cat(2,DATA_LoadString,''',''');
	else
		DATA_LoadString = cat(2,DATA_LoadString,'''');
	end
end

fprintf('\n%s\n',CKPT_LoadString)
fprintf('\n%s\n',DATA_LoadString)
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







addpath(genpath(CodeLocation))

CKPT_SaveString = '''-v7.3';
    % This is the list of all the variables that we save to the CKPT file.
for ii=1:numel(CKPT_UsedVariables)
	CKPT_SaveString = cat(2,CKPT_SaveString,''',''',CKPT_UsedVariables{ii});
end
CKPT_SaveString = cat(2,CKPT_SaveString,'''');

DATA_SaveString = '''';
    % This is the list of all the variables that we save to the DATA file.
for ii=1:numel(DATA_UsedVariables)
	DATA_SaveString = cat(2,DATA_SaveString,DATA_UsedVariables{ii});
	if ii~=numel(DATA_UsedVariables)
		DATA_SaveString = cat(2,DATA_SaveString,''',''');
	else
		DATA_SaveString = cat(2,DATA_SaveString,'''');
	end
end

DATA_BKUP_SaveString = '''';
    % This is the list of all the variables that we save to the DATA BKUP file.
for ii=1:numel(DATA_BKUPVariables)
	DATA_BKUP_SaveString = cat(2,DATA_BKUP_SaveString,DATA_BKUPVariables{ii});
	if ii~=numel(DATA_BKUPVariables)
		DATA_BKUP_SaveString = cat(2,DATA_BKUP_SaveString,''',''');
	else
		DATA_BKUP_SaveString = cat(2,DATA_BKUP_SaveString,'''');
	end
end

fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n ')
fprintf('\n\n   %s ver. %s\n',SelfName,RunVersion)

fprintf(cat(2,'\n QSE: Starting CKPT load code.\n QSE: CKPT file:\n   ',CKPT_Name_Fullpath,'\n'))
if Verbose; whos; pause(10); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	Load Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
	Pseudocode:
		We try to load the CKPT file 2 times.
		We then try to load the BKUP CKPT file 2 times.
			If it succeeds, we overwrite the CKPT file with the loaded variables, and try again from the top.
			If they both fail, then the program ends
		
		Variables:
			LoadAttempts: how many attempts we've made at loading any of the variables. @=-1 means we've succeeded
			CKPT_LoadedFromBKUP: true if we've had to load the variables from BKUP and overwrite the CKPT file; false if not.
			LoadFail: the error we get when a load() fails
			LoadErrorStruct: the error struct that gets thrown when none of the load() functions succeed.

		Functions:
			QSE_CheckCKPTVarFailure(): explicitly checks the existence of the variables we want to load.
%}

LoadAttempts = 0;
CKPT_WasLoadedFromBKUP = false;
CKPT_Name_Fullpath_BKUP = cat(2,CKPT_Name_Fullpath,'__BKUP');

while LoadAttempts==0

	try

		fprintf('\n QSE: Loading CKPT variables...')
		load(CKPT_Name_Fullpath,'JobName','DATA_Name_Fullpath','UnitaryFunc','EvolFunc','C_Numbers_Int','TotalTimeSteps','SystemSizeValues','Number_SystemSizes','SystemSize_Index','MeasurementProbabilityValues','Number_MeasurementProbabilities','MeasurementProbability_Index','InteractingProbabilityValues','Number_InteractingProbabilities','InteractingProbability_Index','RunOptions','CircuitsPerSystemSize','TimeStepsBeforeSaving','Number_ParallelStates','Number_TimesLoaded','Number_TimesCalculationsSaved','CircuitsPerSystemSize_Counter','TimeSteps_CurrentState','TimeBeforeMakingBKUP','TimeBeforeMakingBKUP_Counter','CurrentNumber_TimesBackedUp','InitializeState','StateArray_Coded')
        fprintf('\n QSE: CKPT Load attempt successful...')
		LoadAttempts = -1;

		if QSE_CheckCKPTVarFailure(CKPT_UsedVariables)
			%	If true, then something hasn't loaded correctly.
			LoadAttempts = 1;
			pause(10)
		end

	catch LoadFailErr
		fprintf('\n >>: ERROR loading ckpt save file.')
		fprintf('\n  ~~  %s',LoadFailErr.identifier)
		fprintf('\n  ~~  "%s"',LoadFailErr.message)
		fprintf('\n >>: Trying agian...\n')
		LoadAttempts = 1;
		pause(30)
	end

	if LoadAttempts==1

		try

			fprintf('\n QSE: Loading CKPT variables...')
			load(CKPT_Name_Fullpath,'JobName','DATA_Name_Fullpath','UnitaryFunc','EvolFunc','C_Numbers_Int','TotalTimeSteps','SystemSizeValues','Number_SystemSizes','SystemSize_Index','MeasurementProbabilityValues','Number_MeasurementProbabilities','MeasurementProbability_Index','InteractingProbabilityValues','Number_InteractingProbabilities','InteractingProbability_Index','RunOptions','CircuitsPerSystemSize','TimeStepsBeforeSaving','Number_ParallelStates','Number_TimesLoaded','Number_TimesCalculationsSaved','CircuitsPerSystemSize_Counter','TimeSteps_CurrentState','TimeBeforeMakingBKUP','TimeBeforeMakingBKUP_Counter','CurrentNumber_TimesBackedUp','InitializeState','StateArray_Coded')
			fprintf('\n QSE: CKPT Load attempt successful...')
			LoadAttempts = -1;

			if QSE_CheckCKPTVarFailure(CKPT_UsedVariables)
				LoadAttempts = 2;
				pause(10)
			end

		catch LoadFailErr
			fprintf('\n >>:ERROR loading CKPT Save file.')
			fprintf('\n  ~~  %s',LoadFailErr.identifier)
			fprintf('\n  ~~  "%s"',LoadFailErr.message)
			fprintf('\n >>: Attempting to load from backup...\n')
			LoadAttempts = 2;
			pause(30)
		end

	end

	if LoadAttempts==2

		try

			fprintf('\n QSE: Loading CKPT_BKUP variables...')
			load(CKPT_Name_Fullpath_BKUP,'JobName','DATA_Name_Fullpath','UnitaryFunc','EvolFunc','C_Numbers_Int','TotalTimeSteps','SystemSizeValues','Number_SystemSizes','SystemSize_Index','MeasurementProbabilityValues','Number_MeasurementProbabilities','MeasurementProbability_Index','InteractingProbabilityValues','Number_InteractingProbabilities','InteractingProbability_Index','RunOptions','CircuitsPerSystemSize','TimeStepsBeforeSaving','Number_ParallelStates','Number_TimesLoaded','Number_TimesCalculationsSaved','CircuitsPerSystemSize_Counter','TimeSteps_CurrentState','TimeBeforeMakingBKUP','TimeBeforeMakingBKUP_Counter','CurrentNumber_TimesBackedUp','InitializeState','StateArray_Coded')

			if QSE_CheckCKPTVarFailure(CKPT_UsedVariables)
				LoadAttempts = 3;
				pause(10)
			else
				fprintf('\n QSE: Successful BKUP load. Recreating ckpt save...')
				QSE_SaveData(CKPT_Name_Fullpath, [CKPT_UsedVariables;'-v7.3'], true, 'CKPT');
				fprintf('\N QSE: Save successful, apparently. Starting from the top...\n')
				LoadAttempts = 0;
				CKPT_WasLoadedFromBKUP = true;
			end

		catch LoadFailErr
			fprintf('\n >>: ERROR loading BKUP_CKPT Save file.')
			fprintf('\n  ~~  %s',LoadFailErr.identifier)
			fprintf('\n  ~~  "%s"',LoadFailErr.message)
			fprintf('\n >>: Trying one last time...\n')
			LoadAttempts = 3;
			pause(30)
		end

	end

	if LoadAttempts==3

		try

			fprintf('\n QSE: Loading CKPT_BKUP variables, second try...')
			load(CKPT_Name_Fullpath_BKUP,'JobName','DATA_Name_Fullpath','UnitaryFunc','EvolFunc','C_Numbers_Int','TotalTimeSteps','SystemSizeValues','Number_SystemSizes','SystemSize_Index','MeasurementProbabilityValues','Number_MeasurementProbabilities','MeasurementProbability_Index','InteractingProbabilityValues','Number_InteractingProbabilities','InteractingProbability_Index','RunOptions','CircuitsPerSystemSize','TimeStepsBeforeSaving','Number_ParallelStates','Number_TimesLoaded','Number_TimesCalculationsSaved','CircuitsPerSystemSize_Counter','TimeSteps_CurrentState','TimeBeforeMakingBKUP','TimeBeforeMakingBKUP_Counter','CurrentNumber_TimesBackedUp','InitializeState','StateArray_Coded')

			if QSE_CheckCKPTVarFailure(CKPT_UsedVariables)
				LoadErrorStruct = struct('message','Not all variables loaded correctly','identifier',sprintf('%s:VarNotFound',SelfName))
				error(LoadErrorStruct)
			else
				fprintf('\n QSE: Successful BKUP load. Recreating CKPT save...')
				QSE_SaveData(CKPT_Name_Fullpath, [CKPT_UsedVariables;'-v7.3'], true, 'CKPT');
				fprintf('Save successful, apparently. Starting from the top...\n\n')
				LoadAttempts = 0;
				CKPT_WasLoadedFromBKUP = true;
			end

		catch LoadFailErr
			fprintf('\n >>: ERROR loading BKUP_CKPT Save file.')
			fprintf('\n  ~~  %s',LoadFailErr.identifier)
			fprintf('\n  ~~  "%s"',LoadFailErr.message)
			fprintf('\n >>: PROGRAM FAILURE...\n')
			LoadErrorStruct = struct('message','Could not load CKPT nor CKPT_BKUP files successfully.','identifier',sprintf('%s:NoSuccessfulLoad',SelfName));
			error(LoadErrorStruct)
		end
	end
end

fprintf('\n QSE: Current Run Info - current successful run: %d (current successful load: %d)\n',Number_TimesCalculationsSaved+1,Number_TimesLoaded+1)


		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
	Pseudocode:
		We try to load the DATA file 2 times.
		We then try to load the BKUP_A DATA file 2 times.
		We then try to load the BKUP_B DATA file 2 times.
			If either succeeds, we overwrite the DATA file with the loaded variables, and try again from the top.
			If they all fail, then the program ends
		
		Variables:
			LoadAttempts: how many attempts we've made at loading any of the variables. @=-1 means we've succeeded
			DATA_LoadedFromBKUP: true if we've had to load the variables from BKUP and overwrite the CKPT file; false if not.
			LoadFail: the error we get when a load() fails
			LoadErrorStruct: the error struct that gets thrown when none of the load() functions succeed.

		Functions:
			QSE_CheckDATAVarFailure(): explicitly checks the existence of the variables we want to load.
%}
		

if Verbose; whos; pause(10); end

fprintf('\n QSE: Starting Data load code.\n QSE: DATA file:\n   %s\n',DATA_Name_Fullpath)

LoadAttempts = 0;
DATA_WasLoadedFromBKUP = false;
DATA_Name_BKUP_A = cat(2,DATA_Name_Fullpath,'__BKUP_A');
DATA_Name_BKUP_B = cat(2,DATA_Name_Fullpath,'__BKUP_B');

while LoadAttempts == 0

	try

		fprintf('\n QSE: Loading DATA viariables...')
		load(DATA_Name_Fullpath,'Out','JobName','JobInformation','JobSpecifications','Hdim','IsPure','Job_RunLog')
		fprintf('\n QSE: DATA load complete...')
		LoadAttempts = -1;

		if QSE_CheckDATAVarFailure(DATA_UsedVariables)
			fprintf(' >>: Problem: Not all DATA variables loaded correctly.\n >>:   Trying again...\n')
			LoadAttempts = 1;
			pause(10)
		end

	catch LoadFailErr
		fprintf('\nERROR loading data.')
		fprintf('\n  ~~  %s',LoadFailErr.identifier)
		fprintf('\n  ~~  "%s"',LoadFailErr.message)
		fprintf('\n 	Trying again...\n')
		LoadAttempts = 1;
		pause(30)
	end

	if LoadAttempts==1

		try

			fprintf('\n QSE: Loading DATA viariables...')
			load(DATA_Name_Fullpath,'Out','JobName','JobInformation','JobSpecifications','Hdim','IsPure','Job_RunLog')
			fprintf('\n QSE: DATA load complete...')
			LoadAttempts = -1;

			if QSE_CheckDATAVarFailure(DATA_UsedVariables)
				fprintf(' >>: Problem: Not all DATA variables loaded correctly.\n >>:   Trying from BKUP_A...\n')
				LoadAttempts = 2;
				pause(10)
			end

		catch LoadFailErr
			fprintf('\nERROR loading data.')
			fprintf('\n  ~~  %s',LoadFailErr.identifier)
			fprintf('\n  ~~  "%s"',LoadFailErr.message)
			fprintf('\n 	Attempting to load from backup A...\n')
			LoadAttempts = 2;
			pause(30)
		end

	end

	if LoadAttempts==2

		try

			fprintf('\n QSE: Loading DATA BKUP_A viariables...')
			load(DATA_Name_BKUP_A,'Out','JobName','JobInformation','JobSpecifications','Hdim','IsPure','Job_RunLog');
			fprintf('\n QSE: DATA load complete...')

			if QSE_CheckDATAVarFailure(DATA_UsedVariables)
				fprintf('\n >>: Problem: Not all BKUP_A variables loaded correctly.\n >>:   Trying again...\n')
				LoadAttempts = 3;
				pause(10)
			else
				fprintf('\n QSE: Successful BKUP load. Recreating DATA Save and restarting...\n\n')
				QSE_SaveData(DATA_Name_Fullpath, DATA_UsedVariables, true, 'DATA')
				LoadAttempts = 0;
				DATA_WasLoadedFromBKUP = true;
			end

		catch LoadFailErr
			fprintf('\n >>: ERROR with BKUP data.')
			fprintf('\n  ~~  %s',LoadFailErr.identifier)
			fprintf('\n  ~~  "%s"',LoadFailErr.message)
			fprintf('\n >>: Trying again...\n')
			LoadAttempts = 3;
			pause(30)
		end

	end

	if LoadAttempts==3

		try

			fprintf('\n QSE: Loading DATA BKUP_A viariables...')
			load(DATA_Name_BKUP_A,'Out','JobName','JobInformation','JobSpecifications','Hdim','IsPure','Job_RunLog');
			fprintf('\n QSE: DATA load complete...')

			if QSE_CheckDATAVarFailure(DATA_UsedVariables)
				fprintf('\n >>: Problem: Not all BKUP_A variables loaded correctly.\n >>:   Attempting to load from BKUP_B...\n')
				LoadAttempts = 4;
				pause(10)
			else
				fprintf('\n QSE: Successful BKUP load. Recreating DATA Save and restarting...\n\n')
				QSE_SaveData(DATA_Name_Fullpath,DATA_UsedVariables,true,'DATA');
				LoadAttempts = 0;
				DATA_WasLoadedFromBKUP = true;
			end

		catch LoadFailErr
			fprintf('\n >>: ERROR with BKUP data.')
			fprintf('\n  ~~  %s',LoadFailErr.identifier)
			fprintf('\n  ~~  "%s"',LoadFailErr.message)
			fprintf('\n >>: Trying backup B...\n')
			LoadAttempts = 4;
			pause(30)
		end

	end

	if LoadAttempts==4

		try

			fprintf('\n QSE: Loading DATA BKUP_B viariables...')
			load(DATA_Name_BKUP_B,'Out','JobName','JobInformation','JobSpecifications','Hdim','IsPure','Job_RunLog');
			fprintf('\n QSE: DATA load complete...')

			if QSE_CheckDATAVarFailure(DATA_UsedVariables)
				fprintf('\n >>: Problem: Not all BKUP_B variables loaded correctly.\n >>:   Trying one final time...\n')
				LoadAttempts = 5;
				pause(10)
			else
				fprintf('\n QSE: Successful BKUP load. Recreating DATA Save and restarting...\n\n')
				QSE_SaveData(DATA_Name_Fullpath, DATA_UsedVariables, true, 'DATA');
				LoadAttempts = 0;
				DATA_WasLoadedFromBKUP = true;
			end

		catch LoadFailErr
			fprintf('\n >>: ERROR with BKUP data.')
			fprintf('\n  ~~  %s',LoadFailErr.identifier)
			fprintf('\n  ~~  "%s"',LoadFailErr.message)
			fprintf('\n >>: Trying one final time...\n')
			LoadAttempts = 5;
			pause(30)
		end

	end

	if LoadAttempts==5

		try

			fprintf('\n QSE: Loading DATA BKUP_B viariables...')
			load(DATA_Name_BKUP_B,'Out','JobName','JobInformation','JobSpecifications','Hdim','IsPure','Job_RunLog');
			fprintf('\n QSE: DATA load complete...')

			if QSE_CheckDATAVarFailure(DATA_UsedVariables)
				fprintf('\n >>: Problem: Not all BKUP_B variables loaded correctly.')
				LoadErrorStruct = struct('message','Not all variables loaded correctly','identifier',sprintf('%s:VarNotFound',SelfName));
				error(LoadErrorStruct)
			else
				fprintf('\n QSE: Successful BKUP load. Recreating DATA Save and restarting...\n\n')
				QSE_SaveData(DATA_Name_Fullpath, DATA_UsedVariables, true, 'DATA');
				LoadAttempts = 0;
				DATA_WasLoadedFromBKUP = true;
			end

		catch LoadFailErr
			fprintf('\n >>: ERROR with BKUP data.')
			fprintf('\n  ~~  %s',LoadFailErr.identifier)
			fprintf('\n  ~~  "%s"',LoadFailErr.message)
			fprintf('\n >>: PROGRAM FAILURE...\n')
			LoadErrorStruct = struct('message','Could not load DATA nor DATA_BKUP files successfully.','identifier',sprintf('%s:NoSuccessfulLoad',SelfName));
			error(LoadErrorStruct)
			%	If the code ever gets here, there's probably an issue with Hyak, not the backups.
			%	At least, that's what I'd hope; and so we're better off restarting the whole
			%	program rather loading backup C, and losing 10+ hours of work.
			return
		end

	end

end

if CKPT_WasLoadedFromBKUP || DATA_WasLoadedFromBKUP
	%	We don't want a half-remembered run to get into our data, so reset the current realization.
	InitializeState = true;
	TimeSteps_CurrentState = 0;
	QSE_SaveData(DATA_Name_Fullpath, DATA_UsedVariables, true, 'DATA');
    QSE_SaveData(CKPT_Name_Fullpath, [CKPT_UsedVariables;'-v7.3'], true, 'CKPT');
	%	if DATA loaded from backup, resave CKPT to save new _Index values corresponding to restored DATA.
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	parpool code
    %   The following code may be necessary for running QuditStateEvol directly
    %   on a node; however, it should not be necessary when batching the code
    %   through RunBatch().
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
if Verbose; whos; pause(10); end
fprintf('\n X: Starting Cluster and Parpool.\n')

ClusterSuccess = false;
ParpoolSuccess = false;

InheritedPool=gcp('nocreate');
if max(size(InheritedPool))~=0	%	There's already a pool present!
	if RC && isequal(InheritedPool.Cluster.Profile,'RunContainer')
		fprintf('\n XX: RunContainer pool already present, so we''ll just go with this.')
		RunPool = gcp('nocreate');
		ParpoolSuccess = true;
		ClusterSuccess = true;
	else
		fprintf('\n XX: Pool already created... Not really gonna deal with this...')
		delete(InheritedPool)
		fprintf('\n XX: Pool deleted...')
	end
end

while ~ClusterSuccess

	fprintf('\n XX: Starting Cluster...\n')
	try
		
		if RC
			RunCluster = parcluster('RunContainer');
		else
			RunCluster = parcluster(JobName);
		end

		ClusterSuccess = true;

		if Verbose
			RunCluster
		end

		fprintf('\n XX: Deleting old cluster jobs...\n')
		delete(RunCluster.Jobs)
		fprintf('\n XX: ...Done. Hopefully...')

	catch ClusterFail
		fprintf('\n >>: Cluster failed to start!')
		fprintf('\n ~~ %s',ClusterFail.identifier)
		fprintf('\n ~~ "%s"',ClusterFail.message)
		fprintf('\n >>: Retrying...\n')
	end

end

while ~ParpoolSuccess
	try
		RunPool = parpool(RunCluster,Number_ParallelStates)
		ParpoolSuccess = true;
	catch PoolFail
		fprintf('\n >>: Parpool failed to start!')
		fprintf('\n ~~ %s',PoolFail.identifier)
		fprintf('\n ~~ "%s"',PoolFail.message)
		fprintf('\n >>: Retrying...')
	end
end



if Verbose
	pwd
	RunCluster
	RunPool
	whos
	pause(10)
end
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fprintf('\n Date: %s',datetime("now"))


CurrentNumberOfRealizations = -1;
try         %   this is for when the corresponding entry of Out hasn't been initialized yet...
	CurrentNumberOfRealizations = numel(Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).Realizations);
catch
	CurrentNumberOfRealizations = 0;
end


Job_RunLog_Current = sprintf('Beginning code execution number %d attempt (with %d successful runs) at %s, with code version %s. Starting at System Size = %d, with %d realizations.',Number_TimesLoaded+1,Number_TimesCalculationsSaved+1,datetime("now"),RunVersion,SystemSizeValues(SystemSize_Index),CurrentNumberOfRealizations);
if CKPT_WasLoadedFromBKUP == true
	Job_RunLog_Current = cat(2,Job_RunLog_Current,' -- BKUP CKPT load required');
	if Verbose; fprintf(' 	VV: CKPT BKUP required. Info added to Job_RunLog for this run.\n'); end
end
if DATA_WasLoadedFromBKUP == true
	Job_RunLog_Current = cat(2,Job_RunLog_Current,' -- BKUP DATA load required');
	if Verbose; fprintf(' VV: DATA BKUP required. Info added to Job_RunLog for run.\n'); end
end


Job_RunLog = cat(1,Job_RunLog,{Job_RunLog_Current});
	% Job_RunLog comes from the CKPT file, and is a column cell of strings with the run data
QSE_SaveData(DATA_Name_Fullpath,{'Job_RunLog','-append'},false,'DATA -append');


fprintf('\n QSE: System info:')
SystemSizeValues
MeasurementProbabilityValues
InteractingProbabilityValues
CircuitsPerSystemSize


%	These are here for readability.
%	We allow a fermionic system to be identified by 'Fermionic', 'Fermion', or the number 1. Similar for bosons.
Boson_Keywords = {'Bosonic','Boson','0'};
Parafermion_Keywords = {'Fermionic','Fermion','1','Parafermion','Parafermionic','Majorana'};
System_Is_Fermionic = false; System_Is_Bosonic = false;
if isfield(RunOptions,'StatisticsType')
    if any(ismember(Parafermion_Keywords, RunOptions.StatisticsType))
	    System_Is_Fermionic = true;
    elseif any(ismember(Boson_Keywords, RunOptions.StatisticsType))
	    System_Is_Bosonic = true;
    else
	    error('Invalid StatisticsType. RunOptions.StatisticsType should be either ''Boson'' or ''Fermion''.')
    end
end



fprintf('\n\n.....\n Running Execution %d (%d successful saves)\n....\n\n',Number_TimesLoaded+1,Number_TimesCalculationsSaved+1)
Number_TimesLoaded = Number_TimesLoaded + 1; 	%Update now that the program has launched successfully.
if Verbose; fprintf('\n VV: Number_TimesLoaded (# of startups) updated; program launched successfully.\n'); end
QSE_SaveData(CKPT_Name_Fullpath,{'Number_TimesLoaded','-append'},false,'CKPT -append');

StateArray = cell(Number_ParallelStates,1);
if TimeStepsBeforeSaving(SystemSize_Index)>0
	QSE_DecodeStateArray();
end



runFresh = true; 	% This will let us know when the program has successfully contributed data.

Complete = false;

StateArrayEmptyGlobalCounter = 0;
SaveFailGlobalCounter = 0;
BKUP_InfoString = '';

while ~Complete

	try

				%{	
		pseudocode:
        (SS=SystemSize, MP=MeasurementProbability, IP=InteractingProbability)

			While we still have some  values to do:

				Run circuits until we hit the limit for that SS value ( CircuitsPerSystemSize(SystemSize_Index) ).
				Each circuit includes one (or more) realizations for each value of MP and IP for that SS value.
					The number of realizations per loop is (TimeStepsBeforeSaving).

				While we have circuits / realizations left to complete:
					Get our current state for a realization.
					While we still have operations to do on the state (matTime<SS):
						Run the parallelized time evol code for TimeStepsBeforeSaving steps,
                          and save our progress to the CKPT file.
						Or run a number of full realzations if CircuitsPerSystemSize value < 0.
						
				When we have some completed realizations, calculate the entropies, and save it to the DATA file.

				When we hit the CircuitsPerSystemSize limit of circuits for that SS value, move to the next SS value
			
			When we run out of SS values, exit the program successfully.
			
			donefile.m should put a flag up to stop queueing the job.
		

		%}
		Completed = false;
		
		while SystemSize_Index<=Number_SystemSizes
		%	We complete a System Size before moving on to the next.

		
			fprintf('\nSystem Size = %d',SystemSizeValues(SystemSize_Index));
			if Verbose; fprintf('\n VV: System Size Index = %d',SystemSize_Index); end
			

			%   S_Metric calculation, based on StatisticsType
			if System_Is_Fermionic
				S_Metric = SymplecticMetricMajorana(SystemSizeValues(SystemSize_Index));
			elseif System_Is_Bosonic
				S_Metric = SymplecticMetricBoson(SystemSizeValues(SystemSize_Index));
			else    % Defaults to fermions.
				S_Metric = SymplecticMetricMajorana(SystemSizeValues(SystemSize_Index));
			end

			StateArrayIsEmptyCounter = 0; 	% we will also reset this to zero after each full circuit


			while CircuitsPerSystemSize_Counter <= CircuitsPerSystemSize(SystemSize_Index)
				%	We'll iterate over this loop after every successful realization save.
				%	Circuits counter will only increase after we've gone over all (MP,IP) values, but we'll come back here after each realization.
				%   Circuits counter will come from the CKPT data
				if Verbose; fprintf('\n VV: Top of the ''circuits'' loop. Beginning realization code.'); end
				
				
				if TimeStepsBeforeSaving(SystemSize_Index)<0
						% If so, then we'll be doing multiple realizations per run, so
						% we don't worry about saving or overwriting states here, and
						% we'll reset the StateArray every time.
					    if Verbose; fprintf('\n VV: Initializing stateArray as empty.'); end

					InitializeState = false;
					% 	Note this doesn't really matter, as we'll never make it to
					%	the other case as long as CircuitsPerSystemSize(SystemSize_Index)<0
					StateArray = cell(Number_ParallelStates,1);
					StateArray_Coded = {};
					QSE_SaveData(CKPT_Name_Fullpath, [CKPT_UsedVariables;'-v7.3'], true, 'CKPT');

				elseif InitializeState
					    if Verbose; fprintf('\n VV: Initializing TrivState'); end

					if IsPure
                            if Verbose; fprintf(' for IsPure == true ( TrivState() ).'); end
						if System_Is_Bosonic
							StartState = TrivStateBoson(SystemSizeValues(SystemSize_Index));
                        else
                            StartState = TrivStateMajorana(SystemSizeValues(SystemSize_Index));
                        end
						Number_Generators = SystemSizeValues(SystemSize_Index);
					else
                            if Verbose; fprintf(' for IsPure == false ( Zeros state ).'); end
						StartState = zeros(SystemSizeValues(SystemSize_Index),2*SystemSizeValues(SystemSize_Index));
						Number_Generators = 0;
					end
					
					StateArray = cell(Number_ParallelStates,1);
					if Verbose; fprintf('.. Initializing StateArray'); end
					for ii=1:Number_ParallelStates
						StateArray{ii} = struct('State',StartState,'Number_Generators',Number_Generators);
					end
					
					QSE_EncodeStateArray();
					QSE_SaveData(CKPT_Name_Fullpath, [CKPT_UsedVariables;'-v7.3'], true, 'CKPT');
					InitializeState = false;

				end
				
				c = clock;
				try         %   this is for when the corresponding entry of Out hasn't been initialized yet...
					currentReals = numel(Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).Realizations);
				catch
					currentReals = 0;
				end
				
				
						%%%%%%%%%%%%%%%%%%%%%%%%		%%%%%%%%%%%%%
				fprintf(['\n\n  Running circuit %d / %d',...
                    '\n    MeasurementProbability = %.3f   (%d/%d),',...
                    '\n    InteractingProbability = %.3f   (%d/%d),',...
                    '\n    Realizations completed for these parameters: %.0f',...
                    '\n  Current time: %s'],...
                    CircuitsPerSystemSize_Counter,CircuitsPerSystemSize(SystemSize_Index),MeasurementProbabilityValues(MeasurementProbability_Index),MeasurementProbability_Index,Number_MeasurementProbabilities,InteractingProbabilityValues(InteractingProbability_Index),InteractingProbability_Index,Number_InteractingProbabilities,currentReals,datetime("now"));
						%%%%%%%%%%%%%%%%%%%%%%%%		%%%%%%%%%%%%%
				
				
				%                       Here's the meat:
				
				
				while TimeSteps_CurrentState < TotalTimeSteps(SystemSize_Index) 	% This is the loop that calculates the realization(s). We'll usually get killed in the middle of this while loop.                       
					% Shoud be "less than" here, since it should jump to the SS in intervals of
					% 100 or so, based on CircuitsPerSystemSize
					%
                    % (When matTime equals NVals, then we have done a number of time steps equal
                    % to the system size, and should not do any more time steps;
                    % correspondingly, this loop will not run, since matTime ~< NVals.)

					
					% All the below self-declarations and stuff are necessary to get the parfor
					% loop to use these variables. Something weird with Hyak's CKPT queue, idk.

					TimeStepsBeforeSaving = TimeStepsBeforeSaving;

					SystemSizeValues = SystemSizeValues;
					MeasurementProbabilityValues = MeasurementProbabilityValues;
					InteractingProbabilityValues = InteractingProbabilityValues;

					par_MeasurementProbability = MeasurementProbabilityValues(MeasurementProbability_Index);
					par_InteractingProbability = InteractingProbabilityValues(InteractingProbability_Index);
					par_SystemSize = SystemSizeValues(SystemSize_Index);
					par_TotalTimeSteps = TotalTimeSteps(SystemSize_Index);
					par_TimeStepsBeforeSaving = TimeStepsBeforeSaving(SystemSize_Index);

					UnitaryFunc = UnitaryFunc;
					EvolFunc = EvolFunc;
					S_Metric = S_Metric;

					RunOptions.MeasurementProbability = par_MeasurementProbability;
					RunOptions.InteractingProbability = par_InteractingProbability;
                        % Remember that RunOptions defines the evolution, and in general will
                        % change for every realization.

					TimeSteps_CurrentState = TimeSteps_CurrentState;
					StateArray = StateArray;
					TempArray = StateArray;

					BKUP_tic = tic;

                        % Sometimes, parallel problems can be solved by trying to directly attach
                        % files with updateAttachedFiles(Pool).
					
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%	The Parallel Loop
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					
					Has_Not_Been_Enough_Time = true; 	% Used for whenever we complete a realization, but there's too much time left
					    if Verbose; fprintf('\n VV: starting Has_Not_Been_Enough_Time loop...'); end
                    ParloopTooFast_Counter = false;

					while Has_Not_Been_Enough_Time
                        
						try
							parfor par_Core_Index=1:Number_ParallelStates	% Split the load among the cores

								c = datevec(datetime("now"));
								seed = par_Core_Index + floor(c(6)*10000);
								rng(seed);

								if par_TimeStepsBeforeSaving>0

									localTemp = StateArray{par_Core_Index};	% the parfor loop never modifies stateArray directly
									for jj=1:min(par_TimeStepsBeforeSaving, par_TotalTimeSteps-TimeSteps_CurrentState)	% for if the realization subperiod does't evenly divide the total time step number
										% apply time step TimeStepsBeforeSaving number of times:
										[localTemp.State,localTemp.Number_Generators] = EvolFunc(localTemp.State,localTemp.Number_Generators,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric);
										%	Psi,NumGenerators,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric
									end

                                else % TimeStepsBeforeSaving is negative, so we run multiple realizations.

									localTemp = {}
									for kk = 1:abs(par_TimeStepsBeforeSaving)

										if IsPure
											if System_Is_Bosonic
												Current_State = TrivStateBoson(par_SystemSize);
                                            else
                                                Current_State = TrivStateMajorana(par_SystemSize);
                                            end
											par_NumGenerators = par_SystemSize;
										else
											Current_State = zeros(par_SystemSize,2*par_SystemSize);
											par_NumGenerators = 0;
										end

										for jj=1:par_TotalTimeSteps
											[Current_State,par_NumGenerators] = EvolFunc(Current_State,par_NumGenerators,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric);
                                        end
						                
										par_Bigram = Bigrams(Clip(Current_State,Hdim,IsPure),par_NumGenerators);

										localTemp{kk,1} = LengthDistribution(par_Bigram,par_SystemSize);		% Length Distributions
										localTemp{kk,2} = EntropyOfAllRegionSizes(par_Bigram,par_SystemSize);	% Subsystem entropy
										localTemp{kk,3} = par_SystemSize - par_NumGenerators;					% Purification entropy

									end

								end

								%                   End calculation.
								TempArray{par_Core_Index} = localTemp;

                            end % END OF PARFOR LOOP %%%%%%%%%%%%%%%%%%%%%%%%

						catch ParforError
							fprintf('\n >>: %s: ERROR in parfor loop.',SelfName)
							fprintf('\n  ~~  %s',ParforError.identifier)
							fprintf('\n  ~~  "%s"',ParforError.message)
							fprintf('\n >>: Full error stack:\n')
							QSE_PrintStack(ParforError)
							error(ParforError)
						end
						
						StateArray = TempArray;
						if TimeStepsBeforeSaving(SystemSize_Index)>0
							TimeSteps_CurrentState = min(TimeSteps_CurrentState+TimeStepsBeforeSaving(SystemSize_Index), TotalTimeSteps(SystemSize_Index));
								%if we did less than subPeriod, that's okay, since this 
								%will still put matTime over N and not restart the loop
						else
							TimeSteps_CurrentState = SystemSizeValues(SystemSize_Index);
						end
						
						%{
						If it's been less than 5 min, run again. Add more time steps to the realization.
						That is, unless there are no time steps remaining to calculate, and thus we need to save.
						Then just wait a minute to prevent issues with saving too often, then proceed.
						While it would be nice to put the time check inside the parfor loop to reduce overhead,
						it allows the possibility for the realizations to get out of sync, time-wise, which we
						can't deal with.
						We could also write this better, and have the `TimeStepsPerSystemSize<0' jobs run more realizations,
						But it's more complicated that it seems. This is only a just-in-case thing; set up the times better!
						%}
						
						BKUP_tic_Limit = 600;
						%	Number in seconds before going on to make a backup

						if toc(BKUP_tic)<BKUP_tic_Limit
                            if ~ParloopTooFast_Counter
                                fprintf('\n       Quick parloop: completed in')
                            end
                            ParloopTooFast_Counter = true;
							fprintf(' %.0fsec/%.0fsec...',toc(BKUP_tic),BKUP_tic_Limit)
							Has_Not_Been_Enough_Time = true;
							if TimeSteps_CurrentState >= TotalTimeSteps(SystemSize_Index)
								Has_Not_Been_Enough_Time = false;
                                fprintf(' Realization completed.')
								pause(60)
							end
						else
							Has_Not_Been_Enough_Time = false;
						end
						TimeBeforeMakingBKUP_Counter = TimeBeforeMakingBKUP_Counter + toc(BKUP_tic);
						
					end	% end of <while Has_Not_Been_Enough_Time>

					QSE_EncodeStateArray()
					%	Outside of initializing the states, the parfor loop is the only time that StateArray is changed.
					
					if Verbose; fprintf('\n VV: Has_Not_Been_Enough_Time/parfor loop(s) completed.'); end
					
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%	Saving Code
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					
					StateArrayIsEmpty = false;
					
					c = datevec(datetime("now"));
					fprintf('\n     Completed %d timesteps.... %.2d/%.2d, %.2d:%.2d  ',TimeSteps_CurrentState,c(2),c(3),c(4),c(5))
						%    We'll just save all the data again and overwrite the old file. This helps us plug whatever leak
						%    Matlab has when using '-append' like we do. Besides, the whole file's datasize is in the array
						%    anyways, so it's not like it will take much more time than just saving the array...

					saveSuccess = false;
					trialCounter = 0;

					%	StateArray already Encoded after parfor loop.
					QSE_SaveData(CKPT_Name_Fullpath, [CKPT_UsedVariables;'-v7.3'], true, 'CKPT');

					if TimeBeforeMakingBKUP_Counter >= TimeBeforeMakingBKUP 	% Cycle the backup saves
						    if Verbose; fprintf('\n VV: Backup counter met. Backup saves:'); end

						BKUP_InfoString = sprintf('Backup %.2d, made %s',CurrentNumber_TimesBackedUp+1,datetime("now"));
						saveSuccess = false;
						trialCounter = 0;
						
						%	This whole set of loops is for cycling the DATA_BKUP_# files
                        %   If there are a cumulative total of 20 failures, the program exits.
                        
                        BKUP_B_Exists = isequal(exist(cat(2,DATA_Name_Fullpath,'__BKUP_B.mat'),'file'),2);
						while (~saveSuccess) && (trialCounter<20) && BKUP_B_Exists

							    if Verbose; fprintf('\n   vv: B->C...'); end

							try
								saveSuccess = copyfile(cat(2,DATA_Name_Fullpath,'__BKUP_B.mat'),cat(2,DATA_Name_Fullpath,'__BKUP_C.mat'));
								%	Note that the DATA_Name_BKUP_B name is already saved as a variable... but whatever
								trialCounter = 0;
								if Verbose; fprintf(' C Done.'); end
							catch BCError
								fprintf('\nERROR with backup B->C.')
								fprintf('\n  ~~  %s',BCError.identifier)
								fprintf('\n  ~~  "%s"',BCError.message)
								fprintf('\n    Retrying...\n')
								trialCounter = trialCounter + 1;
								if Verbose; fprintf('   VV:  trialCounter = %d\n',trialCounter); end
								pause(10)
							end

						end

						saveSuccess = false;
                        BKUP_A_Exists = isequal(exist(cat(2,DATA_Name_Fullpath,'__BKUP_A.mat'),'file'),2);
						while (~saveSuccess) && (trialCounter<20) && BKUP_A_Exists

							if Verbose; fprintf('\n   vv: A->B...'); end

							try % Copy BKUP_A to BKUP_B. We load both files to test if they saved correctly.
								testOpen = load(cat(2,DATA_Name_Fullpath,'__BKUP_A'));
									if Verbose; fprintf(' BKUP_A loaded successfully...'); end
								saveSuccess = copyfile(cat(2,DATA_Name_Fullpath,'__BKUP_A.mat'),cat(2,DATA_Name_Fullpath,'__BKUP_B.mat'));
									if Verbose; fprintf('\n   vv: BKUP_A saved to BKUP_B...'); end
								testOpen = load(cat(2,DATA_Name_Fullpath,'__BKUP_B'));
									if Verbose; fprintf(' (New) BKUP_B loaded successfully...'); end
								trialCounter = 0;
									if Verbose; fprintf(' B Done.'); end
							catch ABError
								fprintf('\n\nERROR with backup A->B.')
								fprintf('\n  ~~  %s',ABError.identifier)
								fprintf('\n  ~~  "%s"',ABError.message)
								fprintf('\n    Retrying...\n')
								trialCounter = trialCounter + 1;
									if Verbose; fprintf('   VV:  trialCounter = %d\n',trialCounter); end
								pause(30)
							end

						end

						saveSuccess = false;

						while (~saveSuccess) && (trialCounter<20)

							if Verbose; fprintf('\n   vv: Data->A...'); end

							try % Rather than copying DATA to BKUP_A, just save the current data as BKUP_A, and test to see if the file loads.
								%fprintf('\nBKUP_InfoString = "%s"',BKUP_InfoString)
                                fprintf('\n   -- BKUP %.0f performed successfully.', CurrentNumber_TimesBackedUp+1)
								saveSuccess = QSE_SaveData(cat(2,DATA_Name_Fullpath,'__BKUP_A'),DATA_BKUPVariables,true,'DATA_BKUP_A');
									if Verbose; fprintf('\n   vv: DATA backed up successfully...'); end
								trialCounter = 0;
									if Verbose; fprintf(' A Done.'); end
							catch AError
								fprintf('\n\nERROR with backup save A.')
								fprintf('\n  ~~  %s',AError.identifier)
								fprintf('\n  ~~  "%s"',AError.message)
								fprintf('\n    Retrying...\n')
								trialCounter = trialCounter + 1;
								if Verbose; fprintf('   VV:  trialCounter = %d\n',trialCounter); end
								pause(30)
							end

						end

						if trialCounter>=20
							fprintf('\n\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
							fprintf('\n            MAJOR ERROR SAVING BKUP FILE. RETURNING...')
							fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
							ErStr = struct('message','Major error saving DATA_BKUP file.','identifier',sprintf('%s:DataBkupFailure',SelfName));
							error(ErStr)
						end

						%	This is the code for CKPT_BKUP
						%	StateArray was Encoded before start of BKUP code.
						QSE_SaveData(CKPT_Name_Fullpath_BKUP, [CKPT_UsedVariables;'-v7.3'], true, 'CKPT_BKUP');

						CurrentNumber_TimesBackedUp = CurrentNumber_TimesBackedUp + 1;
						TimeBeforeMakingBKUP_Counter = 0;

						    if Verbose; fprintf('\n VV: Current nubmer of times backed up = %d  VV',CurrentNumber_TimesBackedUp); end


					end
					
					if runFresh
						Number_TimesCalculationsSaved = Number_TimesCalculationsSaved + 1;	% Update, now that the program has successfully contributed data
						    if Verbose; fprintf('\n 	VV: Number_TimesCalculationsSaved (# of successes) updated; program has contributed data.\n'); end
						runFresh = false;
					end
					
				end		%We've now completed this particular realization
				
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%	We now have a completed realization!
				% 	Now that we have the realization(s), we get the data from it.

				
				    if Verbose; fprintf('\n VV: matTime loop completed.'); end
				
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%	Calculate the quantities of this realization:

				if TimeStepsBeforeSaving(SystemSize_Index) > 0			% Calculate the entropies

					    if Verbose; fprintf('\n VV: Doing entropy calculation...'); end 
					
					%	The relevant Out().Argument is a column cell that the following will be
                    %	appended to.
					TempS = cell(Number_ParallelStates,1);
					TempLengthDist = cell(Number_ParallelStates,1);
					TempMixedS = cell(Number_ParallelStates,1);
					TempRealizationCount = cell(Number_ParallelStates,1);

					StateArrayIsEmpty = false;

					for results_idx=1:Number_ParallelStates
                            % In times past, each entry could have been the average of many
                            % realizations. However, that makes it difficult to find the standard
                            % deviation of the final average, and so now we just have an entry {1} for
                            % each final state.
						TempRealizationCount{results_idx}=1;
                    end

					for results_idx=1:Number_ParallelStates

						if numel(StateArray{results_idx})~=0

							%if Verbose; fprintf('\n 	VV: StateArray{%d}.Number_Generators = %d',Realizations_Index,StateArray{Realizations_Index}.Number_Generators); end
								
							TempBigrams = Bigrams(Clip(StateArray{results_idx}.State,Hdim,IsPure), StateArray{results_idx}.Number_Generators);
							TempLengthDist{results_idx} = LengthDistribution(TempBigrams, SystemSizeValues(SystemSize_Index));
							TempS{results_idx} = EntropyOfAllRegionSizes(TempBigrams, SystemSizeValues(SystemSize_Index));
							TempMixedS{results_idx} = SystemSizeValues(SystemSize_Index) - StateArray{results_idx}.Number_Generators;
						
						else

							fprintf('\nBad read on data. StateArray{ii} = {}. Skipping this circuit entry...\n\n')
							TempS = {};
							TempLengthDist = {};
							TempMixedS = {};
							TempRealizationCount = {};
							StateArrayIsEmpty = true;
							StateArrayIsEmptyCounter = StateArrayIsEmptyCounter + 1;
							break 	% We don't need to reapeat this code for each parallel state. Just the once will work.

						end

					end

                else % TimeStepsBeforeSaving(SystemSize_Index) < 0

					if Verbose; fprintf('\n VV: Doing entropy tallies...'); end
					TempLengthDist = {};
					TempS = {};
					TempMixedS = {};
					RNum = Number_ParallelStates*abs(TimeStepsBeforeSaving(SystemSize_Index));	 % Total number of final states calculated
					TempRealizationCount = mat2cell(ones(RNum,1),ones(1,RNum)); % Returns an RNum-by-1 cell array where every entry is 1.

					for results_idx=1:Number_ParallelStates

						if numel(StateArray{results_idx})~=0
							%	StateArray{ii} will be a Number_ParallelStates-by-3 cell array.
							%	The three entries will be: 
							%		{kk,1} = Length Distribution
							%		{kk,2} = Subsystem Entropy
							%		{kk,3} = Purification Entropy
							TempLengthDist = cat(1,TempLengthDist,StateArray{results_idx}{:,1});
							TempS = cat(1,TempS,StateArray{results_idx}{:,2});
							TempMixedS = cat(1,TempMixedS,StateArray{results_idx}{:,3});
							StateArrayIsEmpty = false;
						else
							% There are no entries in stateArray. Don't know why this happens sometimes...
							% It may happen when the home directory doesn't have enough free space to do what's needed...
							% Nonetheless, we cap it at 20 times/circuit, to avoid 8GB Output files. Again...
							
							fprintf('\nBad read on data. StateArray{ii} = {}. Skipping this circuit entry...\n\n')
							TempLengthDist = {};
							TempS = {};
							TempMixedS = {};
							TempRealizationCount = {};
							StateArrayIsEmpty = true;
							StateArrayIsEmptyCounter = StateArrayIsEmptyCounter + 1;
							break 	% We don't need to reapeat this code for each parallel state. Just the once will work.

						end

					end

				end		% We've now tabulated the properties of this realization
				

				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%	Now that we've calculated the quantities, let's collect the data:
					

				if ~StateArrayIsEmpty

					Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).SystemSize = SystemSizeValues(SystemSize_Index);
					Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).MeasurementProbability = MeasurementProbabilityValues(MeasurementProbability_Index);
					Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).InteractingProbability = InteractingProbabilityValues(InteractingProbability_Index);
					Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).TotalTimeSteps = TotalTimeSteps(SystemSize_Index);
					Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).LengthDistribution = cat(1,Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).LengthDistribution,TempLengthDist);
					Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).SubsystemEntropy = cat(1,Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).SubsystemEntropy,TempS);
					Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).PurificationEntropy = cat(1,Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).PurificationEntropy,TempMixedS);
					Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).Realizations = cat(1,Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).Realizations,TempRealizationCount);

					InteractingProbability_Index = InteractingProbability_Index + 1;
					if InteractingProbability_Index > Number_InteractingProbabilities
						InteractingProbability_Index = 1;
						MeasurementProbability_Index = MeasurementProbability_Index + 1;
						if MeasurementProbability_Index > Number_MeasurementProbabilities
							MeasurementProbability_Index = 1;
							CircuitsPerSystemSize_Counter = CircuitsPerSystemSize_Counter + 1;
							StateArrayIsEmptyCounter = 0;
                        end
                    end

						%    We'll just save all the data again and overwrite the old file. This helps us plug whatever leak
						%    Matlab had when using '-append' like we used to.
						%	 -- I'd like to switch this one back to "-append", since we save the entire CKPT data after initializing
						%		each the stateArray, after each parfor loop, and whenever we do a BKUP save... but I don't know
						%	 	exactly what variables I should save... -- 27/Nov/2021

						%	Hypothesis: we save the _Index variables here, using -append, so that on the next run, the system knows to do the next point.
						%	If StateArray is empty, we skip this, and the _Index variables stay the same. 
						%	The following reset code still goes through, and we just re-run this point.
					%QSE_SaveData(CKPT_Name_Full,CKPT_SaveString,true,'CKPT');

				elseif StateArrayIsEmptyCounter>=20
					fprintf('\n\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
					fprintf('\n            MAJOR ERROR: stateArray consistently empty. Returning...')
					fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
					ErStr = struct('message','stateArray consistently empty...','identifier',sprintf('%s:stateArrayEempty',SelfName));
					error(ErStr)
				end % End of Data collecting if-end statement
				

				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%	Now that we've collected the data (or not if StateArray was empty),
				%	Let's save our progress:

				InitializeState = true;
				TimeSteps_CurrentState = 0;
				QSE_SaveData(DATA_Name_Fullpath, DATA_UsedVariables, true, 'DATA');
				QSE_SaveData(CKPT_Name_Fullpath, [CKPT_UsedVariables;'-v7.3'], true, 'CKPT');
				
				    if Verbose; fprintf(' VV: circuit run complete. SystemSize_Index = %d, MeasurementProbability_Index = %d, InteractingProbability_Index = %d, CircuitsPerSystemSize_Counter = %d',SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index,CircuitsPerSystemSize_Counter); end
				
			end 	


			%   We've finished this N value. On to the next one.
			if Verbose; fprintf('\n VV: ''circuits'' loop completed.'); end

			CircuitsPerSystemSize_Counter = 1;
			MeasurementProbability_Index = 1;
			InteractingProbability_Index = 1;
			SystemSize_Index = SystemSize_Index + 1;

			InitializeState = true;
			TimeSteps_CurrentState = 0;

			QSE_SaveData(CKPT_Name_Fullpath, [CKPT_UsedVariables; '-v7.3'], true, 'CKPT')
			%QSE_SaveData(ckptNameFull,'''N_i'',''p_i'',''q_i'',''circuits'',''initializeState'',''matTime'',''-append''',false,'CKPT -append')
			
			if Verbose; fprintf(' VV: SystemSize value complete. SystemSize_Index = %d, MeasurementProbability_Index = %d, InteractingProbability_Index = %d, CircuitsPerSystemSize_Counter = %d',SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index,CircuitsPerSystemSize_Counter); end
		end

		if Verbose; fprintf('\n VV: SystemSize_Index loop completed.'); end
		
		%	If this code is running, then we've gone through all of the
        %	SystemSizeValues, and SystemSize_Index > Number_SystemSizes
		fprintf('\n\n\n      All done??\n\n')
		
		Completed = true;




	catch MainFail
		fprintf('\n >>: Error in executing main code of QuditStateEvol:')
		fprintf('\n ~~ %s',MainFail.identifier)
		fprintf('\n ~~ "%s"',MainFail.message)

		if isequal(MainFail.identifier,sprintf('%s:CkptBkupFailure',SelfName))
			SaveFailGlobalCounter = SaveFailGlobalCounter + 1;
			if SaveFailGlobalCounter>=5
				fprintf('\n >>: Save consistently failing. I''m not really sure what would cause this. Ending Program...\n')
				return
			end
		elseif isequal(MainFail.identifier,sprintf('%s:stateArrayEmpty',SelfName))
			StateArrayEmptyGlobalCounter = StateArrayEmptyGlobalCounter + 1;
			if StateArrayEmptyGlobalCounter>=5
				fprintf('\n >>: stateArray *consistently* consistently empty. Ending Program...\n')
				return
			end
		else
			QSE_PrintStack(MainFail)
		end

		fprintf('\n >>: Retrying...\n')
		pause(60)

	end

end

fprintf('\n\n\n      All done!!\n\n')
















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





function SaveSuccesses__ = QSE_SaveData(File,ItemsList,LoadTest,RefName)
% Attempts to save some variables to a file, and handles errors if it fails
	SaveSuccesses__ = false;
	Trial_Counter__ = 0;
    Times_to_Try__ = 20;
	while (~SaveSuccesses__)&&(Trial_Counter__<=Times_to_Try__)
		try
			if Verbose; fprintf('\n VV: %s.SaveData: Saving ''%s'' file...',SelfName,RefName); end
			save(File,ItemsList{:});
			if LoadTest
				tO__ = load(File);
				%fprintf(tO__.JobName)
				clear tO__;
			end
			SaveSuccesses__ = true;
			Trial_Counter__ = 0;
		catch SaveFail
			fprintf('\n >>: %s.SaveData: ERROR with ''%s'' save.',SelfName,RefName)
			fprintf('\n  ~~  %s',SaveFail.identifier)
			fprintf('\n  ~~  "%s"',SaveFail.message)
			fprintf('\n >>: Retrying...\n')
			Trial_Counter__ = Trial_Counter__ + 1;
			pause(30)
		end
	end
	if Trial_Counter__>=Times_to_Try__
		fprintf('\n\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
		fprintf('\n            MAJOR ERROR SAVING %s FILE. RETURNING...',RefName)
		fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')

		if LoadTest
			ErrorMessage__ = sprintf('SaveData(): Could not save and then load a %s file successfully.',RefName);
		else
			ErrorMessage__ = sprintf('SaveData(): Could not save a %s file successfully.',RefName);
		end
		ErrorMessage__ = cat(2,ErrorMessage__,sprintf('  ~~  %s',SaveFail.identifier),sprintf('  ~~  "%s"',SaveFail.message));

		SaveErrorStruct__ = struct('message',ErrorMessage__,'identifier',sprintf('%s:NoSuccessfulSave',SelfName));
		error(SaveErrorStruct__)
    end
end






function varsFailed = QSE_CheckCKPTVarFailure(Vars)
%	checks if all of the expected variables were loaded from the CKPT file
%	local variables: Vars, failVars, VarExist, varsFailed

	failVars = {};
	%lastwarn
	for zz=1:numel(Vars)
		VarExist = exist(Vars{zz});
		if VarExist~=1
			failVars{numel(failVars)+1} = Vars{zz};
			if Verbose; fprintf('\n VV: QSE_checkCKPTVarFailure: Variable not found: %s',Vars{zz}); end
		end
	end
	if numel(failVars)>0
		fprintf('\n >>: Problem: not all CKPT variables loaded correctly.\n')
		failVars;
		varsFailed = true;
	else
		fprintf('\n QSE: All CKPT variables loaded.\n')
		varsFailed = false;
	end		
end





function varsFailed = QSE_CheckDATAVarFailure(Vars)
%	checks if all of the expected variables were loaded from the Data file
%	local variables: Vars, failVars, VarExist, varsFailed

	%Vars = {'Out','JobInformation','CKPT_RunLog','specs'};
	failVars = {};
	%lastwarn
	for zz=1:numel(Vars)
		VarExist = exist(Vars{zz});
		if VarExist~=1
			failVars{numel(failVars)+1} = Vars{zz};
			if Verbose; fprintf('\n VV: QSE_CheckDATAVarFailure: Variable not found: %s',Vars{zz}); end
		end
	end
	if numel(failVars)>0
		fprintf('\n >>: Problem: not all Data variables loaded correctly.\n')
		failVars;
		varsFailed = true;
	else
		fprintf('\n QSE: All Data variables loaded.\n')
		varsFailed = false;
	end		
end





function QSE_EncodeStateArray()
%	Encodes all entries of StateArray, in place.
%   StateArray_Coded is loaded directly from the CKPT file.
	if TimeStepsBeforeSaving(SystemSize_Index)>0
		for zz=1:Number_ParallelStates
			StateArray_Coded{zz}.State = StateEncode(StateArray{zz}.State,Hdim);
			StateArray_Coded{zz}.Number_Generators = StateArray{zz}.Number_Generators;
		end
    else
        % If the number of timesteps before saving is negative, then we never save
        % a partially-realized state into the CKPT file.
		StateArray_Coded = {};
	end

end


function QSE_DecodeStateArray()
%	Decodes all entries of StateArray_Coded

	CurrentN = SystemSizeValues(SystemSize_Index);

	for zz=1:Number_ParallelStates
		%	NOT StateArray, which will be initialized to {} before this.
		StateArray{zz} = struct('State',zeros(CurrentN,2*CurrentN),'Number_Generators',0);

		StateArray{zz}.State = StateDecode(StateArray_Coded{zz}.State,Hdim,2*CurrentN);

		if zz==1
			sz = size(StateArray{zz}.State);
			fprintf('\n QSE: QSE_DecodeStateArray(): StateArray size = [%d, %d]. sumsum = %d',sz(1),sz(2),sum(sum(abs(StateArray{zz}.State))))
			%	We're gonna keep this line in, since it should only activate once at the start of the code.
            %   The point is that if there's something funny with the state (e.g. being
            %   all zeros instead of a trivial initial state), it will show up in
            %   sumsum ( sum(sum(state)) = 0 in that case ).
		end

		StateArray{zz}.Number_Generators = StateArray_Coded{zz}.Number_Generators;

	end

end





function QSE_PrintStack(ErrorIn)
%	takes the ErrorIn error structure and prints the stack as would a usual error

	for zz=1:numel(ErrorIn.stack)
		fprintf('\n >>:::   in %s, line %d', ErrorIn.stack(zz).name, ErrorIn.stack(zz).line)
	end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

%3/Sep/20 - Added forceVal and UnitaryFunc functionality, and modified to
%   work on hyak
%8/Sep/20 - Added the time-based method, for letting hyak just run as
%   many realizations as possible in six hours
%26/Sep/20 - Changed to work with the new version of mat_PSA
%10/Dec/20 - Finished version 1.0 of _ckpt code.
%14/Dec/20 - Edited variables from (qi,Ni,pi) -> (q_i,N_i,p_i) to avoid 
%   conflating the index p_i with the circular constant Pi.
%   Also fiddled around with things to get the parfor loop to work.
%22/Dec/20 - re-ordered some of the for-loops so that the code prioritizes 
%   completing entire p-lines of the phase diagram, like run_code_phase does.
%13/Jan/21 - Changed the save directory from /gscratch/home/jm117 to
%   /gscratch/stf/jm117, which is where the data should have been all along.
%13/Jan/21 - Also added the 'ckptinfo' var so that I know when the different
%   ckpt runs were.
%28/Jan/21 - changed the save command so that after parfor is run, it overwrites
%    the ckpt_save_ instead of appending to it. Was already done after realization
%    completion, but now done after every parfor run, to plug an apparent memory leak
%01/Feb/20 - Added try/catch around saving the ckpt_saves, and loading
%   them. Added a system for making auromatic backups of the ckpt_save
%   files as well as the data files. Added the ability to use negative
%   subPeriod values to cause multiple realizations for parfor loop. Also added
%	rng-seed code inside of the parfor loop.
%15/Feb/21 - Added code to make the filename into a cluster profile to try and cut down
%    on the local_cluster_jobs nonsense of having over 700 jobs apparently running.
%    Also completely removed "ParStorageLocation" from the files, since it'll be in the
%    cluster location now.
%23/Feb/21 - Updated the BKUP code to attempt to restore data from previous
%   two backupts instead of one.
%   - Fixed the unfortunate error for negative subPeriods that resulted in
%   such realizations only going through one time step before extracting
%   the entropy.
%02/Mar/21 - Revamped BKUP, so that instead of 50 BKUP data files, there will
%   only ever be three - BK_A, BK_B, BK_C. Also backwards-compatible with
%   jobs already running. Also took the save [try...catch] loop and made
%   it it's own local function, called SaveData().
%04/Apr/2021 - Revamped function to add variability to the time step
%   evolution. Added 'tags' option to ckpt data, 'specs' data to output
%   Data, and the input Run_Func to specify evolution. Removed 'forceVal'
%   in favor of implementing it through 'tags'.
%14/Apr/2021 - Moving everything to klone has given me some leeway to rewrite
%   how some of this works. Removed Run_Func input in favor of saving an
%   EvolFunc as part of the ckpt file. Now uses ckptNameFull to find ckpt file,
%   allowing for jobs to each have their own ckpt folder.
%16/Apr/2021 - Added 'gated' code to just rerun the parfor loop if it completes
%   in less than five minutes. Still prints '@' to output file.
%03/Sep/2021 - Added a limit to how many times the code is allowed to throw a 
%	'subArray empty' error before exiting. Hopefully, this will prevent a
%	4 gigabyte Output file from happening again...
%13/Sep/2021 - Spruced up the 'Load Code' to check for variables better,
%	added some code for a 'Verbose' option to more explicitly output what's happening,
%	and added more comments, including pseudocode for the primary loop of the code.
%28/Sep/2021 - Tried putting code into local functions. The 'Load Code' has issues,
%	since it seems like the variabless loaded are considered local to that function
%	if it's loaded there, and not picked up by the rest of the code... and MATLAB
%	won't compile because it doesn't recognize them as being defined elsewhere...
%01/Oct/2021 - Added version number. Put version at 1.99, and I expect to update it
%	to version 2.0 when I finalize some stuff about the error-catching code
%	around the MainCode execution.
%01/Oct/2021 - I think I'm happy with the error catching code, at least for the two
%	main errors: save failing, and stateArray empty error. I may make it more
%	refined in the future, but until then, this will be version 2.0.
%** Updated to ver. 2.00.
%07/Oct/2021 - I think I finally pinned down the repeating 'stateArray empty' problem.
%	The code that set initializeState=true was behind some code that didn't run when
%	we caught the stateArray problem, so it would never get resolved... I also added
%	some code to catch the problem earlier, and added more Verbose messages.
%** Updated to ver. 2.01.
%28/Oct/2021 - Trying to fix the problem where, apparently, matrices will come out of
%	the parfor loop as zero matrices, giving the highest possible entropy. But I
%	modified the ckinstr code to include the current N value, number of realizations,
%	and run_code_gen version. 
%** Updated to ver. 2.02.
%27/Nov/2021 - Throwing stuff at the wall, but nothing major. Changed the 
%	SaveData that shows up when we initialize the stateArray to do a full 
%	save of all CKPT variables; added a SaveData after resetting 'initializeState'
%	and 'matTime' at the end of the	circuits loop; added 'matTime = 0' to list of 
%	reset variables when we finish a N_i loop.
%30/Nov/2021 - Apparently, adding the save code for 'initializeState' and 'matTime'
%	fixed the "all-zero matrices getting passed" issue... 
%** Updated to ver. 2.03.


%24/Feb/2023 - Updated the code to work with my 'Parafermion' project. I don't know
%	how much parafermion action it'll actually get, though, but I like the format
%	better. Requires less of me remembering what each variable is.
%25/Feb/2023 - It seems to be working well enough. Gonna dump this onto klone and
%	hope for the best!
%03/Mar/2023 - Fixed a major error in the code, in which I never clipped the state
%	before finding the bigrams...
%14/Mar/2023 - The Free-versus-Interacting project for March Meeting failed, but
%	I updated the code to be able to run bosons now, which can be flagged
%	in RunOpitons by 'StatisticsType' = 'Fermionic' or 'Bosonic'. Defaults to 
%	Fermionic whenever 'StatisticsType' is not defined in RunOptions.
%		I'm also looking towards publishing this code on GitHub, so I took the
%	main() code and put it back into the main part of the function.
%07/May/2023 - Added help code to the front of the function, and changed the 
%   normal output to include the Measurement/Interacting indices.

%21/July/2023 - Began updating the code as part of the project to get it
%  published on GitHub. I've already updated all of the component
%  functions, now I just need to update what are effectively the front-end
%  functions, and this one. It's good to finally sit down and update some
%  of the bad or misleading variable names which were confusing even me.
%  Whoever's reading this right now, I hope you appreciate it!
%
%