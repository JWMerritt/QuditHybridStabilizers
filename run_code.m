function run_code(CKPT_Name_Fullpath,RunLocation,RC,Verbose)
%	Do not add '.mat' to the end of ckptNameFull entry.
%	This should be the full path name, starting from /mmfs1/gscratch/...
%	>> Edit this locally (using git), then upload to hyak.

RunVersion = 'PARA_0.9'
SelfName = 'run_code'; % mostly for errors





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
    'RealizationsPerSystemSize'     % should be a matrix of the same size as SystemSizeValues
    'RealizationsBeforeSaving'      % should be a matrix of the same size as SystemSizeValues
    'Number_ParallelRealizations'   % should be a single number!
    'Number_TimesLoaded'
    'Number_TimesCalculationsSaved'
    'RealizationsPerSystemSize_Counter'
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
	'RealizationsPerSystemSize_Counter'
	});
%	These are the extra variables we include with the DATA_BKUP files, so that we can resume calculations from this point.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	Load helper functions
%	The MATLAB compiler throws a fit if it doesn't explicitly see the variables being loaded from the files.
%	The following functions put these variable lists into a nice format you can copy and paste in the 8 load calls below
%	Copy all the code from this first part of the function and run it separately to get a printout of the lines you need,
%		and then paste them below.


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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
























%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   No longer directory dependent!
if nargin<4
	RunLocation = "Lenovo_Yoga"
	RC = false;
	Verbose = true;
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch RunLocation
	case "klone_hyak"
		addpath(genpath('/mmsf1/home/jm117/MATLAB/Parafermions'));
	case "Lenovo_Yoga"
		addpath(genpath('C:\Users\jmerr\Documents\MATLAB\ParafermionComponents'));
	otherwise
		fprintf("Invalid RunLocation. Update run_code() parameters.\n")
		return
end


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

fprintf(DATA_BKUP_SaveString)

fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')

if RC
	fprintf('RCrun_code\n')
else
	fprintf('%s ver. %s\n',SelfName,RunVersion)
end

fprintf(cat(2,'\n X: Starting CKPT load code.\n XX: CKPT file:\n    ',CKPT_Name_Fullpath,'\n\n'))
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
			CheckCKPTVarFailure(): explicitly checks the existence of the variables we want to load.
%}

LoadAttempts = 0;
CKPT_LoadedFromBKUP = false;
CKPT_Name_Fullpath_BKUP = cat(2,CKPT_Name_Fullpath,'__BKUP');

while LoadAttempts==0

	try

		fprintf('\n XX: Loading CKPT variables...')
		%{
		for ii=1:numel(CKPT_UsedVariables)
			load(CKPT_Name_Fullpath,CKPT_UsedVariables{ii});
		end
		%}
		load(CKPT_Name_Fullpath,'JobName','DATA_Name_Fullpath','UnitaryFunc','EvolFunc','C_Numbers_Int','TotalTimeSteps','SystemSizeValues','Number_SystemSizes','SystemSize_Index','MeasurementProbabilityValues','Number_MeasurementProbabilities','MeasurementProbability_Index','InteractingProbabilityValues','Number_InteractingProbabilities','InteractingProbability_Index','RunOptions','RealizationsPerSystemSize','RealizationsBeforeSaving','Number_ParallelRealizations','Number_TimesLoaded','Number_TimesCalculationsSaved','RealizationsPerSystemSize_Counter','TimeSteps_CurrentState','TimeBeforeMakingBKUP','TimeBeforeMakingBKUP_Counter','CurrentNumber_TimesBackedUp','InitializeState','StateArray_Coded')
fprintf('\n XX: CKPT Load attempt successful...')
		LoadAttempts = -1;

		if CheckCKPTVarFailure(CKPT_UsedVariables)
			%	If true, then something hasn't loaded correctly.
			LoadAttempts = 1;
			pause(10)
		end

	catch LoadFail
		fprintf('\n >>: ERROR loading ckpt save file.')
		fprintf('\n  ~~  %s',LoadFail.identifier)
		fprintf('\n  ~~  "%s"',LoadFail.message)
		fprintf('\n >>: Trying agian...\n')
		LoadAttempts = 1;
		pause(30)
	end

	if LoadAttempts==1

		try

			fprintf('\n XX: Loading CKPT variables...')
			load(CKPT_Name_Fullpath,'JobName','DATA_Name_Fullpath','UnitaryFunc','EvolFunc','C_Numbers_Int','TotalTimeSteps','SystemSizeValues','Number_SystemSizes','SystemSize_Index','MeasurementProbabilityValues','Number_MeasurementProbabilities','MeasurementProbability_Index','InteractingProbabilityValues','Number_InteractingProbabilities','InteractingProbability_Index','RunOptions','RealizationsPerSystemSize','RealizationsBeforeSaving','Number_ParallelRealizations','Number_TimesLoaded','Number_TimesCalculationsSaved','RealizationsPerSystemSize_Counter','TimeSteps_CurrentState','TimeBeforeMakingBKUP','TimeBeforeMakingBKUP_Counter','CurrentNumber_TimesBackedUp','InitializeState','StateArray_Coded')
			fprintf('\n XX: CKPT Load attempt successful...')
			LoadAttempts = -1;

			if CheckCKPTVarFailure(CKPT_UsedVariables)
				LoadAttempts = 2;
				pause(10)
			end

		catch LoadFail
			fprintf('\n >>:ERROR loading CKPT Save file.')
			fprintf('\n  ~~  %s',LoadFail.identifier)
			fprintf('\n  ~~  "%s"',LoadFail.message)
			fprintf('\n >>: Attempting to load from backup...')
			LoadAttempts = 2;
			pause(30)
		end

	end

	if LoadAttempts==2

		try

			fprintf('\n XX: Loading CKPT_BKUP variables...')
			load(CKPT_Name_Fullpath_BKUP,'JobName','DATA_Name_Fullpath','UnitaryFunc','EvolFunc','C_Numbers_Int','TotalTimeSteps','SystemSizeValues','Number_SystemSizes','SystemSize_Index','MeasurementProbabilityValues','Number_MeasurementProbabilities','MeasurementProbability_Index','InteractingProbabilityValues','Number_InteractingProbabilities','InteractingProbability_Index','RunOptions','RealizationsPerSystemSize','RealizationsBeforeSaving','Number_ParallelRealizations','Number_TimesLoaded','Number_TimesCalculationsSaved','RealizationsPerSystemSize_Counter','TimeSteps_CurrentState','TimeBeforeMakingBKUP','TimeBeforeMakingBKUP_Counter','CurrentNumber_TimesBackedUp','InitializeState','StateArray_Coded')

			if CheckCKPTVarFailure(CKPT_UsedVariables)
				LoadAttempts = 3;
				pause(10)
			else
				fprintf('\n XX: Successful BKUP load. Recreating ckpt save...')
				%%%%%%%%%%%%%%%%%%%%%%
				%save(ckptNameFull,'-v7.3','filename','DATA_Name_Full','NumCores','UnitaryFunc','EvolFunc','t','PVals','NVals','QVals','Pnum','Nnum','Qnum','Qintervalnum','subRealizations','RunLimits','subPeriod','tags','N_i','p_i','q_i','initializeState','stateArray','circuits','runLevel','matTime','BkupLimit','bkupTime','currentBkupNum');
				%%%%%%%%%%%%%%%%%%%%%%
				SaveData(CKPT_Name_Fullpath,{CKPT_UsedVariables{:},'-v7.3'},true,'CKPT');
				fprintf('Save successful, apparently. Starting from the top...\n\n')
				LoadAttempts = 0;
				CKPT_LoadedFromBKUP = true;
			end

		catch LoadFail
			fprintf('\n >>: ERROR loading BKUP_CKPT Save file.')
			fprintf('\n  ~~  %s',LoadFail.identifier)
			fprintf('\n  ~~  "%s"',LoadFail.message)
			fprintf('\n >>: Trying one last time...')
			LoadAttempts = 3;
			pause(30)
		end

	end

	if LoadAttempts==3

		try

			fprintf('\n XX: Loading CKPT_BKUP variables, second try...')
			load(CKPT_Name_Fullpath_BKUP,'JobName','DATA_Name_Fullpath','UnitaryFunc','EvolFunc','C_Numbers_Int','TotalTimeSteps','SystemSizeValues','Number_SystemSizes','SystemSize_Index','MeasurementProbabilityValues','Number_MeasurementProbabilities','MeasurementProbability_Index','InteractingProbabilityValues','Number_InteractingProbabilities','InteractingProbability_Index','RunOptions','RealizationsPerSystemSize','RealizationsBeforeSaving','Number_ParallelRealizations','Number_TimesLoaded','Number_TimesCalculationsSaved','RealizationsPerSystemSize_Counter','TimeSteps_CurrentState','TimeBeforeMakingBKUP','TimeBeforeMakingBKUP_Counter','CurrentNumber_TimesBackedUp','InitializeState','StateArray_Coded')

			if CheckCKPTVarFailure(CKPT_UsedVariables)
				LoadErrorStruct = struct('message','Not all variables loaded correctly','identifier',sprintf('%s:VarNotFound',SelfName))
				error(LoadErrorStruct)
			else
				fprintf('\n XX: Successful BKUP load. Recreating CKPT save...')
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				%save(ckptNameFull,'-v7.3','filename','DATA_Name_Full','NumCores','UnitaryFunc','EvolFunc','t','PVals','NVals','QVals','Pnum','Nnum','Qnum','Qintervalnum','subRealizations','RunLimits','subPeriod','tags','N_i','p_i','q_i','initializeState','stateArray','circuits','runLevel','matTime','BkupLimit','bkupTime','currentBkupNum');
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				SaveData(CKPT_Name_Fullpath,{CKPT_UsedVariables{:},'-v7.3'},true,'CKPT');
				fprintf('Save successful, apparently. Starting from the top...\n\n')
				LoadAttempts = 0;
				CKPT_LoadedFromBKUP = true;
			end

		catch LoadFail
			fprintf('\n >>: ERROR loading BKUP_CKPT Save file.')
			fprintf('\n  ~~  %s',LoadFail.identifier)
			fprintf('\n  ~~  "%s"',LoadFail.message)
			fprintf('\n >>: PROGRAM FAILURE...\n')
			LoadErrorStruct = struct('message','Could not load CKPT nor CKPT_BKUP files successfully.','identifier',sprintf('%s:NoSuccessfulLoad',SelfName))
			error(LoadErrorStruct)
			return
		end
	end
end

fprintf('\n X: Current Run Info - current successful run: %d (current successful load: %d)\n',Number_TimesCalculationsSaved+1,Number_TimesLoaded+1)


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
			CheckDATAVarFailure(): explicitly checks the existence of the variables we want to load.
%}
		

if Verbose; whos; pause(10); end

fprintf('\n X: Starting Data load code.\n X: Data file: %s\n\n',DATA_Name_Fullpath)

LoadAttempts = 0;
DATA_LoadedFromBKUP = false;
DATA_Name_BKUP_A = cat(2,DATA_Name_Fullpath,'__BKUP_A');
DATA_Name_BKUP_B = cat(2,DATA_Name_Fullpath,'__BKUP_B');

while LoadAttempts == 0

	try

		fprintf('\n XX: Loading DATA viariables...')
		load(DATA_Name_Fullpath,'Out','JobName','JobInformation','JobSpecifications','Hdim','IsPure','Job_RunLog')
		fprintf('\n XX: DATA load complete...')
		LoadAttempts = -1;

		if CheckDATAVarFailure(DATA_UsedVariables)
			fprintf(' >>: Problem: Not all DATA variables loaded correctly.\n >>:   Trying again...')
			LoadAttempts = 1;
			pause(10)
		end

	catch LoadFail
		fprintf('\nERROR loading data.')
		fprintf('\n  ~~  %s',LoadFail.identifier)
		fprintf('\n  ~~  "%s"',LoadFail.message)
		fprintf('\n 	Trying again...\n')
		LoadAttempts = 1;
		pause(30)
	end

	if LoadAttempts==1

		try

			fprintf('\n XX: Loading DATA viariables...')
			load(DATA_Name_Fullpath,'Out','JobName','JobInformation','JobSpecifications','Hdim','IsPure','Job_RunLog')
			fprintf('\n XX: DATA load complete...')
			LoadAttempts = -1;

			if CheckDATAVarFailure(DATA_UsedVariables)
				fprintf(' >>: Problem: Not all DATA variables loaded correctly.\n >>:   Trying from BKUP_A...')
				LoadAttempts = 2;
				pause(10)
			end

		catch LoadFail
			fprintf('\nERROR loading data.')
			fprintf('\n  ~~  %s',LoadFail.identifier)
			fprintf('\n  ~~  "%s"',LoadFail.message)
			fprintf('\n 	Attempting to load from backup A...\n')
			LoadAttempts = 2;
			pause(30)
		end

	end

	if LoadAttempts==2

		try

			fprintf('\n XX: Loading DATA BKUP_A viariables...')
			load(DATA_Name_BKUP_A,'Out','JobName','JobInformation','JobSpecifications','Hdim','IsPure','Job_RunLog');
			fprintf('\n XX: DATA load complete...')

			if CheckDATAVarFailure(DATA_UsedVariables)
				fprintf('\n >>: Problem: Not all BKUP_A variables loaded correctly.\n >>:   Trying again...')
				LoadAttempts = 3;
				pause(10)
			else
				fprintf('\n XXX: Successful BKUP load. Recreating DATA Save and restarting...\n\n')
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

				%save(DATA_Name_Fullpath,'Out','JobInformation','CKPT_RunLog','specs');

				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				SaveData(DATA_Name_Fullpath,DATA_UsedVariables,true,'DATA')
				LoadAttempts = 0;
				DATA_LoadedFromBKUP = true;
			end

		catch LoadFail
			fprintf('\n >>: ERROR with BKUP data.')
			fprintf('\n  ~~  %s',LoadFail.identifier)
			fprintf('\n  ~~  "%s"',LoadFail.message)
			fprintf('\n >>: Trying again...\n')
			LoadAttempts = 3;
			pause(30)
		end

	end

	if LoadAttempts==3

		try

			fprintf('\n XX: Loading DATA BKUP_A viariables...')
			load(DATA_Name_BKUP_A,'Out','JobName','JobInformation','JobSpecifications','Hdim','IsPure','Job_RunLog');
			fprintf('\n XX: DATA load complete...')

			if CheckDATAVarFailure(DATA_UsedVariables)
				fprintf('\n >>: Problem: Not all BKUP_A variables loaded correctly.\n >>:   Attempting to load from BKUP_B...')
				LoadAttempts = 4;
				pause(10)
			else
				fprintf('\n XXX: Successful BKUP load. Recreating DATA Save and restarting...\n\n')
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

				%save(DATA_Name_Fullpath,'Out','JobInformation','CKPT_RunLog','specs');
				
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				SaveData(DATA_Name_Fullpath,DATA_UsedVariables,true,'DATA');
				LoadAttempts = 0;
				DATA_LoadedFromBKUP = true;
			end

		catch LoadFail
			fprintf('\n >>: ERROR with BKUP data.')
			fprintf('\n  ~~  %s',LoadFail.identifier)
			fprintf('\n  ~~  "%s"',LoadFail.message)
			fprintf('\n >>: Trying backup B...\n')
			LoadAttempts = 4;
			pause(30)
		end

	end

	if LoadAttempts==4

		try

			fprintf('\n XX: Loading DATA BKUP_B viariables...')
			load(DATA_Name_BKUP_B,'Out','JobName','JobInformation','JobSpecifications','Hdim','IsPure','Job_RunLog');
			fprintf('\n XX: DATA load complete...')

			if CheckDATAVarFailure(DATA_UsedVariables)
				fprintf('\n >>: Problem: Not all BKUP_B variables loaded correctly.\n >>:   Trying one final time...')
				LoadAttempts = 5;
				pause(10)
			else
				fprintf('\n XXX: Successful BKUP load. Recreating DATA Save and restarting...\n\n')
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

				%save(DATA_Name_Fullpath,'Out','JobInformation','CKPT_RunLog','specs');

				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				SaveData(DATA_Name_Fullpath,DATA_UsedVariables,true,'DATA');
				LoadAttempts = 0;
				DATA_LoadedFromBKUP = true;
			end

		catch LoadFail
			fprintf('\n >>: ERROR with BKUP data.')
			fprintf('\n  ~~  %s',LoadFail.identifier)
			fprintf('\n  ~~  "%s"',LoadFail.message)
			fprintf('\n >>: Trying one final time...\n')
			LoadAttempts = 5;
			pause(30)
		end

	end

	if LoadAttempts==5

		try

			fprintf('\n XX: Loading DATA BKUP_B viariables...')
			load(DATA_Name_BKUP_B,'Out','JobName','JobInformation','JobSpecifications','Hdim','IsPure','Job_RunLog');
			fprintf('\n XX: DATA load complete...')

			if CheckDATAVarFailure(DATA_UsedVariables)
				fprintf('\n >>: Problem: Not all BKUP_B variables loaded correctly.')
				LoadErrorStruct = struct('message','Not all variables loaded correctly','identifier',sprintf('%s:VarNotFound',SelfName))
				error(LoadErrorStruct)
			else
				fprintf('\n XXX: Successful BKUP load. Recreating DATA Save and restarting...\n\n')
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

				%save(DATA_Name_Fullpath,'Out','JobInformation','CKPT_RunLog','specs');

				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				SaveData(DATA_Name_Fullpath,DATA_UsedVariables,true,'DATA');
				LoadAttempts = 0;
				DATA_LoadedFromBKUP = true;
			end

		catch LoadFail
			fprintf('\n >>: ERROR with BKUP data.')
			fprintf('\n  ~~  %s',LoadFail.identifier)
			fprintf('\n  ~~  "%s"',LoadFail.message)
			fprintf('\n >>: PROGRAM FAILURE...\n')
			LoadErrorStruct = struct('message','Could not load DATA nor DATA_BKUP files successfully.','identifier',sprintf('%s:NoSuccessfulLoad',SelfName))
			error(LoadErrorStruct)
			%	If the code ever gets here, there's probably an issue with Hyak, not the backups.
			%	At least, that's what I'd hope; and so we're better off restarting the whole
			%	program rather loading backup C, and losing 10+ hours of work.
			return
		end

	end

end

if CKPT_LoadedFromBKUP || DATA_LoadedFromBKUP
	%	We don't want a half-remembered run to get into our data, so reset the current realization.
	InitializeState = true;
	TimeSteps_CurrentState = 0;
	SaveData(DATA_Name_Fullpath,DATA_UsedVariables,true,'DATA');
	SaveData(CKPT_Name_Fullpath,{CKPT_UsedVariables{:},'-v7.3'},true,'CKPT');
	%	if DATA loaded from backup, resave CKPT to save new _Index values corresponding to restored DATA.
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	parpool code
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
		RunPool = parpool(RunCluster,Number_ParallelRealizations)
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


c = clock;
fprintf('\n Date: %.4d/%.2d/%.2d, %.2d:%.2d\n',c(1),c(2),c(3),c(4),c(5))



CurrentNumberOfRealizations = -1;
try         %   this is for when the corresponding entry of Out hasn't been initialized yet...
	CurrentNumberOfRealizations = numel(Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).Realizations);
catch
	CurrentNumberOfRealizations = 0;
end


Job_RunLog_Current = sprintf('Beginning level %d (%d) attempt at %.4d/%.2d/%.2d, %.2d:%.2d, with version %s. Starting at System Size = %d, with %d realizations.',Number_TimesCalculationsSaved+1,Number_TimesLoaded+1,c(1),c(2),c(3),c(4),c(5),RunVersion,SystemSizeValues(SystemSize_Index),CurrentNumberOfRealizations);
if CKPT_LoadedFromBKUP == true
	Job_RunLog_Current = cat(2,Job_RunLog_Current,' -- BKUP CKPT load required');
	if Verbose; fprintf(' 	VV: CKPT BKUP required. Info added to Job_RunLog for this run.\n'); end
end
if DATA_LoadedFromBKUP == true
	Job_RunLog_Current = cat(2,Job_RunLog_Current,' -- BKUP DATA load required');
	if Verbose; fprintf(' VV: DATA BKUP required. Info added to Job_RunLog for run.\n'); end
end


Job_RunLog = cat(1,Job_RunLog,{Job_RunLog_Current});
	% Job_RunLog comes from the CKPT file, and is a column cell of strings with the run data
SaveData(DATA_Name_Fullpath,{'Job_RunLog','-append'},false,'DATA -append');


SystemSizeValues
MeasurementProbabilityValues
InteractingProbabilityValues
RealizationsPerSystemSize


fprintf('\n\n.....\n Running Level %d (%d)\n....\n\n',Number_TimesCalculationsSaved+1,Number_TimesLoaded+1)
Number_TimesLoaded = Number_TimesLoaded+1; 	%Update now that the program has launched successfully.
if Verbose; fprintf('\n VV: Number_TimesLoaded (# of startups) updated; program launched successfully.\n'); end
SaveData(CKPT_Name_Fullpath,{'Number_TimesLoaded','-append'},false,'CKPT -append');
%save(CKPT_Name_Fullpath,'Number_TimesLoaded','-append')


StateArray = cell(Number_ParallelRealizations,1);
if RealizationsBeforeSaving(SystemSize_Index)>0
	DecodeStateArray();
end



runFresh = true; 	% This will let us know when the program has successfully contributed data.

Complete = false;

StateArrayEmptyGlobalCounter = 0;
SaveFailGlobalCounter = 0;
BKUP_InfoString = '';
%	If BKUP_InfoString is first defined inside MainCod(), then it won't be a global variable,
%	and other functions (specifically SaveData()) won't recognize it.

while ~Complete

	try
		Complete = MainCode;
	catch MainFail
		fprintf('\n >>: Error in executing Main Code:')
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
			PrintStack(MainFail)
		end

		fprintf('\n >>: Retrying...\n')
		pause(60)

	end

end

fprintf('\n\n\n      All done!!\n\n')
















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%	Local Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





function Completed = MainCode
	%{	
	pseudocode:
		While we still have some N values to do:

			Run circuits until we hit the limit for that N value (RealizationsPerSystemSize(N_i)).
			Each circuit includes one (or more) realizations for each value of p and q for that N value.
				The number of realizations per circuit is (RealizationsBeforeSaving).

			While we have circuits / realizations left to complete:
				Get our current state for a realization.
				While we still have operations to do on the state (matTime<NVal):
					Run the parallelized time evol code for RealizationsBeforeSaving steps,
					or a number of full realzations if subPeriod<0.
					Then, save our progress to the CKPT file.
			When we have some completed realizations, calculate the entropies, and save it to the Data file.

			When we hit the RunLimit of circuits for that N value, move to the next N value
		
		When we run out of N values, exit the program successfully.
		
		donefile.m should put a flag up to stop queueing the job.
	
	
	local variables for this function: (outdated)
		Completed
		currentReals
		N
		parP
		parQ
		sP
		bkuptic
		tempArray
		localTemp
		Has_Not_Been_Enough_Time
		c2
		saveSuccess
		trialCounter
		StateArrayEmptyCounter
		StateArrayEmpty
		S
		ns
		sR
		RNum

	%}
	Completed = false;
	

	while SystemSize_Index<=Number_SystemSizes
	%	We complete a System Size before moving on to the next.

		fprintf('\nSystem Size = %d',SystemSizeValues(SystemSize_Index));
		if Verbose; fprintf('\n VV: System Size Index = %d',SystemSize_Index); end
		
		S_Metric = SMetric(2*SystemSizeValues(SystemSize_Index));

		StateArrayEmptyCounter = 0; 	% we will also reset this to zero after each full circuit

		while RealizationsPerSystemSize_Counter <= RealizationsPerSystemSize(SystemSize_Index)
			%	The point-loop. We'll iterate over this loop after every successful realization save.
			%	$circuits will only increase after we've gone over all (p,q) values, but we'll come back here after each realization.
			%   circuits will come from the save data
			if Verbose; fprintf('\n VV: Top of the ''circuits'' loop. Beginning realization code.'); end
			
			
			if RealizationsBeforeSaving(SystemSize_Index)<0
					%	if so, then we'll be doing multiple realizations per run, so
					%	we don't worry about saving or overwriting states here, and
					%	we'll reset the stateArray every time.

				if Verbose; fprintf('\n VV: Initializing stateArray as empty.'); end
				
				InitializeState = false;
				% 	note this doesn't really matter, as we'll never make it to
				%	the other case as long as subPeriod<0
				
				
				StateArray = cell(Number_ParallelRealizations,1);
				StateArray_Coded = {};
				SaveData(CKPT_Name_Fullpath,{CKPT_UsedVariables{:},'-v7.3'},true,'CKPT');

			elseif InitializeState

				if Verbose; fprintf('\n VV: Initializing TrivState'); end

				if IsPure
					if Verbose; fprintf(' for IsPure == true ( TrivState() ).'); end
					StartState = TrivState(SystemSizeValues(SystemSize_Index));
					Number_Generators = SystemSizeValues(SystemSize_Index);
				else
					if Verbose; fprintf(' for IsPure == false ( Zeros state ).'); end
					StartState = zeros(SystemSizeValues(SystemSize_Index),2*SystemSizeValues(SystemSize_Index));
					Number_Generators = 0;
				end
				
				StateArray = cell(Number_ParallelRealizations,1);
				if Verbose; fprintf('.. Initializing StateArray'); end
				for ii=1:Number_ParallelRealizations
					StateArray{ii} = struct('State',StartState,'Number_Generators',Number_Generators);
				end
				
				EncodeStateArray();
				SaveData(CKPT_Name_Fullpath,{CKPT_UsedVariables{:},'-v7.3'},true,'CKPT');
				InitializeState = false;

			end
			
			c = clock;
			try         %   this is for when the corresponding entry of Out hasn't been initialized yet...
				currentReals = numel(Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).Realizations);
			catch
				currentReals = 0;
			end
			
			
					%%%%%%%%%%%%%%%%%%%%%%%%		%%%%%%%%%%%%%
			fprintf('\n  Running circuit %d / %d, (%d Realization entries),\n    MeasurementProbability = %.3f,\n    InteractingProbability = %.3f,\n  current time: %.2d:%.2d...\n',RealizationsPerSystemSize_Counter,RealizationsPerSystemSize(SystemSize_Index),currentReals,MeasurementProbabilityValues(MeasurementProbability_Index),InteractingProbabilityValues(InteractingProbability_Index),c(4),c(5));
			if Verbose; fprintf(' VV: (MeasurementProbability_Index,InteractingProbability_Index) = (%d,%d) VV ',MeasurementProbability_Index,InteractingProbability_Index); end 	%keep the trailing VV in this one.
					%%%%%%%%%%%%%%%%%%%%%%%%		%%%%%%%%%%%%%
			
			
			%                       Here's the meat:
			
			
			while TimeSteps_CurrentState < TotalTimeSteps(SystemSize_Index) 	% This is the loop that calculates the realization(s). We'll usually get killed in the middle of this while loop.                       
				%shoud be "less than" here, since it should jump to the N in intervals of 100 or so, based on subPeriod
				%  when matTime equals NVals, then we have done a number of time steps equal to the system size,
				%  and should not do any more time steps; correspondingly, this loop will not run, since matTime ~< NVals.

				
				%       All the below self-declarations and stuff are necessary to get  
				%       the parfor loop to use these variables. Something weird with ckpt, idk.

				%{

				subPeriod = subPeriod;
				NVals = NVals; PVals = PVals; QVals = QVals; t=t;
				parP = PVals(p_i); parQ = QVals{p_i}(q_i);
				N_i = N_i; p_i = p_i; q_i = q_i;
				UnitaryFunc = UnitaryFunc; EvolFunc = EvolFunc;
				matTime = matTime;
				stateArray = stateArray;
				tempArray = stateArray;
				N = NVals(N_i);
				sP = subPeriod(N_i);
				updateAttachedFiles(RunPool);
				bkuptic = tic;

				%}

				RealizationsBeforeSaving = RealizationsBeforeSaving;

				SystemSizeValues = SystemSizeValues;
				MeasurementProbabilityValues = MeasurementProbabilityValues;
				InteractingProbabilityValues = InteractingProbabilityValues;

				par_MeasurementProbability = MeasurementProbabilityValues(MeasurementProbability_Index);
				par_InteractingProbability = InteractingProbabilityValues(InteractingProbability_Index);
				par_SystemSize = SystemSizeValues(SystemSize_Index);
				par_TotalTimeSteps = TotalTimeSteps(SystemSize_Index);
				par_RealizationsBeforeSaving = RealizationsBeforeSaving(SystemSize_Index);

				UnitaryFunc = UnitaryFunc;
				EvolFunc = EvolFunc;
				S_Metric = S_Metric;

				RunOptions.MeasurementProbability = par_MeasurementProbability;
				RunOptions.InteractingProbability = par_InteractingProbability;

				TimeSteps_CurrentState = TimeSteps_CurrentState;
				StateArray = StateArray;
				TempArray = StateArray;

				BKUP_tic = tic;

				%{
				updateAttachedFiles(RunPool)
				listAutoAttachedFiles(RunPool)

				RunPool.AttachedFiles

				FILES = dir('/mmfs1/home/jm117/MATLAB/Parafermions/ParafermionComponents/**/*.m');
				for ii=1:numel(FILES)
					FILES_FULL{ii} = cat(2,FILES(ii).folder,'/',FILES(ii).name);
				end
				addAttachedFiles(RunPool,FILES_FULL)
				updateAttachedFiles(RunPool)
				RunPool.AttachedFiles
				%}
				
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%	The Parallel Loop
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				
				Has_Not_Been_Enough_Time = true; 	% Used whenever we complete a realization, but there's too much time left
				if Verbose; fprintf('\n VV: starting Has_Not_Been_Enough_Time loop...'); end

				while Has_Not_Been_Enough_Time

					%if Verbose; fprintf('parfor loop...'); end

					try
						parfor par_Core_Index=1:Number_ParallelRealizations	%split the load among the cores

							%if Verbose; fprintf('\n	VV:	PP>> [%d] Entered parfor loop',par_Core_Index); end;
							%	it's *too* verbose! Clogs up the log files...
							k = clock;
							seed = par_Core_Index+k(6)*10000;
							rng(seed);

							if par_RealizationsBeforeSaving>0
								%if Verbose; fprintf('\n	VV:	PP>> [%d] par_Reals > 0',par_Core_Index); end

								localTemp = StateArray{par_Core_Index};	% the parfor loop never modifies stateArray directly
								for jj=1:min(par_RealizationsBeforeSaving, par_TotalTimeSteps-TimeSteps_CurrentState)	% for if subPeriod does't evenly divide the total time step number
									% apply time step subPeriod number of times:
									[localTemp.State,localTemp.Number_Generators] = EvolFunc(localTemp.State,localTemp.Number_Generators,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric);
									%	Psi,NumGenerators,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric
								end

							else % sP<0
								% run multiple times
								%if Verbose; fprintf('\n	VV:	PP>> [%d] par_Reals < 0',par_Core_Index); end

								localTemp = {}
								for kk = 1:abs(par_RealizationsBeforeSaving)

									if IsPure
										Current_State = TrivState(par_SystemSize);
										par_NumGenerators = par_SystemSize;
									else
										Current_State = zeros(par_SystemSize,2*par_SystemSize);
										par_NumGenerators = 0;
									end

									for jj=1:par_TotalTimeSteps
										[Current_State,par_NumGenerators] = EvolFunc(Current_State,par_NumGenerators,C_Numbers_Int,Hdim,UnitaryFunc,RunOptions,S_Metric);
										%fprintf('\nCore: %d, timestep: %d',par_Core_Index,jj)
									end

									currentsize = size(Current_State);
									%fprintf('\nsumsum of current state: %d, size: [%d, %d], generators: %d', sum(sum(abs(Current_State))),currentsize(1),currentsize(2),par_NumGenerators)

									par_Bigram = Bigrams(Current_State,par_NumGenerators)
									currentsize = size(par_Bigram)
									%fprintf(', bigram size: [%d, %d]',currentsize(1),currentsize(2))

									%fprintf('\n [%d, ] \n',par_Bigram(1,1))
									localTemp{kk,1} = LengthDistribution(par_Bigram,par_SystemSize);		% Length Distributions
									localTemp{kk,2} = EntropyOfAllRegionSizes(par_Bigram,par_SystemSize);	% Subsystem entropy
									localTemp{kk,3} = par_SystemSize - par_NumGenerators;					% Purification entropy

								end

							end

							%                   End calculation.
							TempArray{par_Core_Index} = localTemp;

						end		% end parfor loop

					catch ParforError
						fprintf('\n >>: %s: ERROR in parfor loop.',SelfName)
						fprintf('\n  ~~  %s',ParforError.identifier)
						fprintf('\n  ~~  "%s"',ParforError.message)
						fprintf('\n >>: Full error stack:\n')
						PrintStack(ParforError)
						error(ParforError)
					end
					
					StateArray = TempArray;
					if RealizationsBeforeSaving(SystemSize_Index)>0
						TimeSteps_CurrentState = TimeSteps_CurrentState + RealizationsBeforeSaving(SystemSize_Index);
							%if we did less than subPeriod, that's okay, since this 
							%will still put matTime over N and not restart the loop
					else
						TimeSteps_CurrentState = SystemSizeValues(SystemSize_Index);
					end
					
					%{
					if it's been less than 5 min, run again. Add more time steps to the realization.
					That is, unless there's no time steps remaining to calculate, and we need to save.
					Then just wait a minute to prevent over-saving issues, then proceed.
					While it would be nice to put the time check inside the parfor loop to reduce overhead,
					  it allows the possibility for the realizations to get out of sync, time-wise, which we
					  can't deal with.
					We could also write this better, and have the `subPeriod<0' jobs run more realizations,
					  But it's more complicated that it seems. This is only a just-in-case thing; set up the times better!
					%}
					
					BKUP_tic_Limit = 10;
					%	Number in seconds before going on to make a backup

					if toc(BKUP_tic)<BKUP_tic_Limit
						fprintf(' -@ %d/%d @- ',toc(BKUP_tic),BKUP_tic_Limit)
						Has_Not_Been_Enough_Time = true;
						if TimeSteps_CurrentState >= TotalTimeSteps(SystemSize_Index)
							Has_Not_Been_Enough_Time = false;
							pause(60)
						end
					else
						Has_Not_Been_Enough_Time = false;
					end
					TimeBeforeMakingBKUP_Counter = TimeBeforeMakingBKUP_Counter + toc(BKUP_tic);
					
				end	% end of <while Has_Not_Been_Enough_Time>

				EncodeStateArray()
				%	Outside of initializing the states, the parfor loop is the only time that StateArray is changed.
				
				if Verbose; fprintf('\n VV: Has_Not_Been_Enough_Time/parfor loop(s) completed.'); end
				
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%	Saving Code
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				
				StateArrayEmpty = false;

				%{
				for ii=1:numel(stateArray)
					if numel(stateArray{ii})==0
						fprintf('\n >>: ERROR. stateArray entry empty after parfor loop.\n >>: Restarting the realization (restarting MainCode)...')
						initializeState = true;
						matTime = 0; 	%	(these two variabels are global, so this is relevant.)
						ErStr = struct('message','stateArray empty following parfor loop.','identifier','run_code_gen:stateArrayEmpty')
						error(ErStr)
					end
				end
				%}
				%	I'm not sure yet if there's a corresponding problem in the parafermion code...
				
				c = clock;
				fprintf('\n     Completed %d timesteps.... %.2d/%.2d, %.2d:%.2d  ',TimeSteps_CurrentState,c(2),c(3),c(4),c(5))
					%    We'll just save all the data again and overwrite the old file. This helps us plug whatever leak
					%    Matlab has when using '-append' like we do. Besides, the whole file's datasize is in the array
					%    anyways, so it's not like it will take much more time than just saving the array...

				saveSuccess = false;
				trialCounter = 0;

				%SaveData(ckptNameFull,cat(2,'''-v7.3'',',ckptDataString),true,'CKPT');
				%	StateArray already Encoded after parfor loop.
				SaveData(CKPT_Name_Fullpath,{CKPT_UsedVariables{:},'-v7.3'},true,'CKPT');

				if TimeBeforeMakingBKUP_Counter >= TimeBeforeMakingBKUP 	%cycle the backup saves

					if Verbose; fprintf('\n VV: Backup counter met. Backup saves:'); end

					c2 = clock;

					BKUP_InfoString = sprintf('Backup %.2d, made %.4d/%.2d/%.2d, %.2d:%.2d',CurrentNumber_TimesBackedUp+1,c2(1),c2(2),c2(3),c2(4),c2(5));
					saveSuccess = false;
					trialCounter = 0;
					
					%	This whole set of loops is for cycling the DATA_BKUP_# files

					while (~saveSuccess) && (trialCounter<20) && isequal(exist(cat(2,DATA_Name_Fullpath,'__BKUP_B.mat'),'file'),2)

						if Verbose; fprintf('\n   vv: B->C...'); end

						try
							saveSuccess = copyfile(cat(2,DATA_Name_Fullpath,'__BKUP_B.mat'),cat(2,DATA_Name_Fullpath,'__BKUP_C.mat'));
							%	Note that the DATA_Name_BKUP_B name is already saved... but whatever
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

					while (~saveSuccess) && (trialCounter<20) && isequal(exist(cat(2,DATA_Name_Fullpath,'__BKUP_A.mat'),'file'),2)

						if Verbose; fprintf('\n   vv: A->B...'); end

						try

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

						try
							%save(cat(2,DATA_Name_Full,'__BKUP_A'),'Out','JobInformation','CKPT_RunLog','specs','bkupinfo','N_i','p_i','q_i','circuits')
							%	if Verbose; fprintf('\n   vv: Saved...'); end
							%testOpen = load(cat(2,DATA_Name_Full,'__BK_A'));
							%	if Verbose; fprintf(' testOpen success...'); end
							fprintf('\nBKUP_InfoString = "%s"\n',BKUP_InfoString)
							saveSuccess = SaveData(cat(2,DATA_Name_Fullpath,'__BKUP_A'),DATA_BKUPVariables,true,'DATA_BKUP_A');
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

					saveSuccess = false;
					trialCounter = 0;

					%	StateArray Encoded before start of BKUP code.
					SaveData(CKPT_Name_Fullpath_BKUP,{CKPT_UsedVariables{:},'-v7.3'},true,'CKPT_BKUP');

					CurrentNumber_TimesBackedUp = CurrentNumber_TimesBackedUp + 1;
					TimeBeforeMakingBKUP_Counter = 0;

					if Verbose; fprintf('\n VV: Current nubmer of times backed up = %d  VV',CurrentNumber_TimesBackedUp); end


				end
				
				if runFresh
					Number_TimesCalculationsSaved = Number_TimesCalculationsSaved + 1;	%Update now that the program has successfully contributed data
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

			if RealizationsPerSystemSize(SystemSize_Index) > 0			%calculate the entropies

				if Verbose; fprintf('\n VV: Doing entropy calculation...'); end 
				
				%	The relevant Out().Argument is a column cell that the following will be appended to:
				TempS = cell(Number_ParallelRealizations,1);
				TempLengthDist = TempS;
				TempMixedS = TempS;
				TempRealizationCount = TempS;

				StateArrayEmpty = false;

				for Realizations_Index=1:Number_ParallelRealizations      %couldn't think of a more clever way to do this...
					TempRealizationCount{Realizations_Index}=1;
				end

				for Realizations_Index=1:Number_ParallelRealizations

					if numel(StateArray{Realizations_Index})~=0

						%if Verbose; fprintf('\n 	VV: StateArray{%d}.Number_Generators = %d',Realizations_Index,StateArray{Realizations_Index}.Number_Generators); end
							
						TempBigrams = Bigrams(StateArray{Realizations_Index}.State,StateArray{Realizations_Index}.Number_Generators);
						TempLengthDist{Realizations_Index} = LengthDistribution(TempBigrams,SystemSizeValues(SystemSize_Index));
						TempS{Realizations_Index} = EntropyOfAllRegionSizes(TempBigrams,SystemSizeValues(SystemSize_Index));
						TempMixedS{Realizations_Index} = SystemSizeValues(SystemSize_Index) - StateArray{Realizations_Index}.Number_Generators;
					
					else

						fprintf('\nBad read on data. StateArray{ii} = {}. Skipping this circuit entry...\n\n')
						TempS = {};
						TempLengthDist = {};
						TempMixedS = {};
						TempRealizationCount = {};
						StateArrayEmpty = true;
						StateArrayEmptyCounter = StateArrayEmptyCounter + 1;
						break 	%we don't need to reapeat this code $subRealizations times. Just the once will work.

					end

				end

			else % RealizationsPerSystemSize(SystemSize_Index) < )

				if Verbose; fprintf('\n VV: Doing entropy tallies...'); end
				TempLengthDist = {};
				TempS = {};
				TempMixedS = {};
				RNum = Number_ParallelRealizations*abs(RealizationsPerSystemSize(SystemSize_Index)) %subRealizations(N_i)*abs(subPeriod(N_i));
				TempRealizationCount = mat2cell(ones(RNum,1),ones(1,RNum));
				%	this says to make an RNum x 1 matrix of ones, and split them into a 20 row cell, with one entry per row.
				%	it gives us an RNum x 1 cell with 1 in each entry, like in the subPeriod>0 case.
				for Realizations_Index=1:Number_ParallelRealizations

					if numel(StateArray{Realizations_Index})~=0
						%	StateArray{ii} will be a (Number_ParallelRealizations)-by-3 cell.
						%	The three entries will be: 
						%		{kk,1} = Length Distribution
						%		{kk,2} = Subsystem Entropy
						%		{kk,3} = Purification Entropy
						TempLengthDist = cat(1,TempLengthDist,StateArray{Realizations_Index}{:,1});
						TempS = cat(1,TempS,StateArray{Realizations_Index}{:,2});
						TempMixedS = cat(1,TempMixedS,StateArray{Realizations_Index}{:,3});
						StateArrayEmpty = false;
					else
						% there are no entries in stateArray. Don't know why this happens sometimes...
						% It may happen when /home/jm117 doesn't have enough free space to do what's needed...
						% nonetheless, we cap it at 20 times/circuit, to avoid 8GB Output files, again...
						
						fprintf('\nBad read on data. StateArray{ii} = {}. Skipping this circuit entry...\n\n')
						TempLengthDist = {};
						TempS = {};
						TempMixedS = {};
						TempRealizationCount = {};
						StateArrayEmpty = true;
						StateArrayEmptyCounter = StateArrayEmptyCounter + 1;
						break 	%we don't need to reapeat this code $subRealizations times. Just the once will work.

					end

				end

			end		%We've now tabulated the properties of this realization
			

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%	Now that we've calculated the quantities, let's collect the data:
				

			if ~StateArrayEmpty
				%{
				Out(q_i,N_i,p_i).p = PVals(p_i);
				Out(q_i,N_i,p_i).N = NVals(N_i);
				Out(q_i,N_i,p_i).q = QVals{p_i}(q_i);
				Out(q_i,N_i,p_i).t = t;
				Out(q_i,N_i,p_i).S = cat(1,Out(q_i,N_i,p_i).S,S);
				Out(q_i,N_i,p_i).ns = cat(1,Out(q_i,N_i,p_i).ns,ns);
				Out(q_i,N_i,p_i).reals = cat(1,Out(q_i,N_i,p_i).reals,sR);
				SaveData(DATA_Name_Full,'''Out'',''JobInformation'',''CKPT_RunLog'',''specs''',true,'Data');
				fprintf('  Completed (N,p,q) = (%d,%.2f,%.2f), circuit %d\n',NVals(N_i),PVals(p_i),QVals{p_i}(q_i),circuits)
				%}

				Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).SystemSize = SystemSizeValues(SystemSize_Index);
				Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).MeasurementProbability = MeasurementProbabilityValues(MeasurementProbability_Index);
				Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).InteractingProbability = InteractingProbabilityValues(InteractingProbability_Index);
				Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).TotalTimeSteps = TotalTimeSteps(SystemSize_Index);
				Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).LengthDistribution = cat(1,Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).LengthDistribution,TempLengthDist);
				Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).SubsystemEntropy = cat(1,Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).SubsystemEntropy,TempS);
				Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).PurificationEntropy = cat(1,Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).PurificationEntropy,TempMixedS);
				Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).Realizations = cat(1,Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).Realizations,TempRealizationCount);
				
				

					%   Below code replaces the "while p_i" and "while q_i" loops
					%   so that every point each (p,q) gets one realization per circuit

				InteractingProbability_Index = InteractingProbability_Index + 1;

				if InteractingProbability_Index > Number_InteractingProbabilities

					InteractingProbability_Index = 1;
					MeasurementProbability_Index = MeasurementProbability_Index + 1;

					if MeasurementProbability_Index > Number_MeasurementProbabilities

						MeasurementProbability_Index = 1;
						RealizationsPerSystemSize_Counter = RealizationsPerSystemSize_Counter + 1;
						StateArrayEmptyCounter = 0;

					end

				end
					%    We'll just save all the data again and overwrite the old file. This helps us plug whatever leak
					%    Matlab has when using '-append' like we do.
					%	 -- I'd like to switch this one back to "-append", since we save the entire CKPT data after initializing
					%		each the stateArray, after each parfor loop, and whenever we do a BKUP save... but I don't know
					%	 	exactly what variables I should save... -- 27/Nov/2021

					%	Hypothesis: we save the _Index variables here, using -append, so that on the next run, the system knows to do the next point.
					%	If StateArray is empty, we skip this, and the _Index variables stay the same. 
					%	The following reset code still goes through, and we just re-run this point.
				%SaveData(CKPT_Name_Full,CKPT_SaveString,true,'CKPT');

			elseif StateArrayEmptyCounter>=20
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
			SaveData(DATA_Name_Fullpath,DATA_UsedVariables,true,'DATA');
			SaveData(CKPT_Name_Fullpath,{CKPT_UsedVariables{:},'-v7.3'},true,'CKPT');
			
			if Verbose; fprintf(' VV: circuit run complete. SystemSize_Index = %d, MeasurementProbability_Index = %d, InteractingProbability_Index = %d, RealizationsPerSystemSize_Counter = %d',SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index,RealizationsPerSystemSize_Counter); end
			
		end 	


		%   We've finished this N value. On to the next one.
		if Verbose; fprintf('\n VV: ''circuits'' loop completed.'); end

		RealizationsPerSystemSize_Counter = 1;
		MeasurementProbability_Index = 1;
		InteractingProbability_Index = 1;
		SystemSize_Index = SystemSize_Index + 1;

		InitializeState = true;
		TimeSteps_CurrentState = 0;

		SaveData(CKPT_Name_Fullpath,{CKPT_UsedVariables{:},'-v7.3'},true,'CKPT')
		%SaveData(ckptNameFull,'''N_i'',''p_i'',''q_i'',''circuits'',''initializeState'',''matTime'',''-append''',false,'CKPT -append')
		
		if Verbose; fprintf(' VV: N value complete. SystemSize_Index = %d, MeasurementProbability_Index = %d, InteractingProbability_Index = %d, RealizationsPerSystemSize_Counter = %d',SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index,RealizationsPerSystemSize_Counter); end
	end

	if Verbose; fprintf('\n VV: N_i loop completed.'); end
	
	%	If this code is running, then we've gone through all of the NVals, as N_i > Nnum
	fprintf('\n\n\n      All done??\n\n')
	Completed = true;
	
end





function sS = SaveDataOld(file,items,loadTest,ref)
%	attempts to save some variables to a file, and handles errors if it fails
%	local variables: sS (saveSuccess), tC (trialCounter), tO (for testing file loads), SaveFail (the possible error),
%		SaveErrorStruct (error thrown when we can't save), ErrorMessage (the message associated with SaveErrorStruct)
	sS = false;
	tC = 0;
	while (~sS)&&(tC<=20)
		try
			if Verbose; fprintf('\n VV: run_code_gen.SaveData: Saving ''%s'' file...',ref); end
			eval(cat(2,'save(''',file,''',',items,');'));
            if loadTest
                tO = load(file);
				clear t0
            end
			sS = true;
			tC = 0;
		catch SaveFail
			fprintf('\n >>: run_code_gen.SaveData: ERROR with ''%s'' save.',ref)
			fprintf('\n  ~~  %s',SaveFail.identifier)
			fprintf('\n  ~~  "%s"',SaveFail.message)
			fprintf('\n >>: Retrying...\n')
			tC = tC + 1;
			pause(30)
		end
	end
	if tC>=20
		fprintf('\n\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        fprintf('\n            MAJOR ERROR SAVING %s FILE. RETURNING...',ref)
        fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')

		if loadTest
			ErrorMessage = sprintf('SaveData(): Could not save and load a %s file successfully.',ref);
		else
			ErrorMessage = sprintf('SaveData(): Could not save a %s file successfully.',ref);
		end
		ErrorMessage = cat(2,ErrorMessage,sprintf('  ~~  %s',SaveFail.identifier),sprintf('  ~~  "%s"',SaveFail.message))

		SaveErrorStruct = struct('message',ErrorMessage,'identifier','run_code_gen:NoSuccessfulSave');
		error(SaveErrorStruct)

	end

end




function SaveSuccesses__ = SaveData(File,ItemsList,LoadTest,ref)
	%	attempts to save some variables to a file, and handles errors if it fails
	%	local variables: sS (saveSuccess), tC (trialCounter), tO (for testing file loads), SaveFail (the possible error),
	%		SaveErrorStruct (error thrown when we can't save), ErrorMessage (the message associated with SaveErrorStruct)
		SaveSuccesses__ = false;
		Trial_Counter__ = 0;
		while (~SaveSuccesses__)&&(Trial_Counter__<=20)
			try
				if Verbose; fprintf('\n VV: %s.SaveData: Saving ''%s'' file...',SelfName,ref); end
				%eval(cat(2,'save(''',file,''',',items,');'));
				save(File,ItemsList{:});
				if LoadTest
					tO__ = load(File);
					fprintf(tO__.JobName)
					clear tO__;
				end
				SaveSuccesses__ = true;
				Trial_Counter__ = 0;
			catch SaveFail
				fprintf('\n >>: %s.SaveData: ERROR with ''%s'' save.',SelfName,ref)
				fprintf('\n  ~~  %s',SaveFail.identifier)
				fprintf('\n  ~~  "%s"',SaveFail.message)
				fprintf('\n >>: Retrying...\n')
				Trial_Counter__ = Trial_Counter__ + 1;
				pause(30)
			end
		end
		if Trial_Counter__>=20
			fprintf('\n\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
			fprintf('\n            MAJOR ERROR SAVING %s FILE. RETURNING...',ref)
			fprintf('\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n')
	
			if LoadTest
				ErrorMessage__ = sprintf('SaveData(): Could not save and load a %s file successfully.',ref);
			else
				ErrorMessage__ = sprintf('SaveData(): Could not save a %s file successfully.',ref);
			end
			ErrorMessage__ = cat(2,ErrorMessage__,sprintf('  ~~  %s',SaveFail.identifier),sprintf('  ~~  "%s"',SaveFail.message))
	
			SaveErrorStruct__ = struct('message',ErrorMessage__,'identifier',sprintf('%s:NoSuccessfulSave',SelfName));
			error(SaveErrorStruct__)
	
		end
	
	end






function varsFailed = CheckCKPTVarFailure(Vars)
%	checks if all of the expected variables were loaded from the CKPT file
%	local variables: Vars, failVars, VarExist, varsFailed

	%Vars = {'filename','DATA_Name_Full','NumCores','UnitaryFunc','EvolFunc','t','PVals','NVals','QVals','Pnum','Nnum','Qnum','Qintervalnum','subRealizations','RunLimits','subPeriod','tags','N_i','p_i','q_i','initializeState','stateArray','circuits','runLevel','matTime','BkupLimit','bkupTime','currentBkupNum'};
	failVars = {};
	%lastwarn
	for jj=1:numel(Vars)
		VarExist = exist(Vars{jj});
		if VarExist~=1
			failVars{numel(failVars)+1} = Vars{jj};
			if Verbose; fprintf('\n VV: run_code_gen.checkCKPTVarFailure: Variable not found: %s',Vars{jj}); end
		end
	end
	if numel(failVars)>0
		fprintf('\n >>: Problem: not all CKPT variables loaded correctly.\n')
		failVars;
		varsFailed = true;
	else
		fprintf('\n XX: All CKPT variables loaded.\n')
		varsFailed = false;
	end		
end





function varsFailed = CheckDATAVarFailure(Vars)
%	checks if all of the expected variables were loaded from the Data file
%	local variables: Vars, failVars, VarExist, varsFailed

	%Vars = {'Out','JobInformation','CKPT_RunLog','specs'};
	failVars = {};
	%lastwarn
	for jj=1:numel(Vars)
		VarExist = exist(Vars{jj});
		if VarExist~=1
			failVars{numel(failVars)+1} = Vars{jj};
			if Verbose; fprintf('\n VV: run_code_gen.CheckDATAVarFailure: Variable not found: %s',Vars{jj}); end
		end
	end
	if numel(failVars)>0
		fprintf('\n >>: Problem: not all Data variables loaded correctly.\n')
		failVars;
		varsFailed = true;
	else
		fprintf('\n XX: All Data variables loaded.\n')
		varsFailed = false;
	end		
end





function EncodeStateArray()
%	Encodes all entries of StateArray, in place.

	if RealizationsBeforeSaving(SystemSize_Index)>0
		for ii=1:Number_ParallelRealizations
			StateArray_Coded{ii}.State = StateEncode(StateArray{ii}.State,Hdim);
			StateArray_Coded{ii}.Number_Generators = StateArray{ii}.Number_Generators;
		end
	else
		StateArray_Coded = {};
	end

end

function DecodeStateArray()
%	Decodes all entries of StateArray_Coded

	CurrentN = SystemSizeValues(SystemSize_Index);

	for ii=1:Number_ParallelRealizations
		%	NOT StateArray, which will be initialized to {} before this.
		StateArray{ii} = struct('State',zeros(CurrentN,2*CurrentN),'Number_Generators',0);

		StateArray{ii}.State = StateDecode(StateArray_Coded{ii}.State,Hdim,2*CurrentN);

		sz = size(StateArray{ii}.State);
		fprintf('\n DecodeStateArray(): StateArray size = [%d, %d]. sumsum = %d',sz(1),sz(2),sum(sum(abs(StateArray{ii}.State))))

		StateArray{ii}.Number_Generators = StateArray_Coded{ii}.Number_Generators;

	end

end





function PrintStack(ErrorIn)
%	takes the ErrorIn error structure and prints the stack as would a usual error

	for ii=1:numel(ErrorIn.stack)
		fprintf('\n >>:::   in %s, line %d', ErrorIn.stack(ii).name, ErrorIn.stack(ii).line)
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

%{

24/Feb/2023 - Updated the code to work with my 'Parafermion' project. I don't know 
	how much parafermion action it'll actually get, though, but I like the format
	better. Requires less of me remembering what each variable is.
25/Feb/2023 - It seems to be working well enough. Gonna dump this onto klone and
	hope for the best!
	
%}