function Make_CKPT(JobName,JobInformation,JobSpecifications,Hdim,IsPure,...
    UnitaryFunc,EvolFunc,C_Numbers_Int,TotalTimeSteps,...
    SystemSizeValues,MeasurementProbabilityValues,InteractingProbabilityValues,...
    RunOptions,CircuitsPerSystemSize,TimeStepsBeforeSaving,Number_ParallelStates,...
    TimeBeforeMakingBKUP,SaveLocation,ClusterLocation,CKPT_Name_Fullpath)

%MAKE_CKPT  Make a CKPT (Checkpoint) file which is used to run qudit
% calculations.
%
%   MAKE_CKPT(...) makes all of the files which will be necessary for
%   QuditStateEvol to run the calculations for the qudit stabilizer states.
%   
%   -- First, creates a CKPT file using the data specified. Initializes the
%   internal StateArray to trivial states which depend on the details of
%   the data.
%
%   -- Second, creates an empty DATA file that QuditStateEvol will save the
%   results to.
%
%   -- Third, creates a new parallel cluster profile with the same name as
%   the job (which is specified in the inputs). This is the cluster profile
%   that will be used any time that this job is run.
%
%   A unique cluster profile is used because of the nature of the CKPT
%   queue on the Klone cluster of the Hyak supercomputer at the University
%   of Washington. A job in the CKPT queue would run whenever there were
%   free nodes to run on, but could be stopped at any time if another user
%   needed the node. Since MATLAB's batch queue had to be subordinate to
%   Hyak's slurm scheduler and ran as just another program on the nodes,
%   this sudden termination would leave inaccurate information in the
%   cluster's profile about the number of jobs currently running. If all
%   jobs used the same 'local' cluster profile, this would lead to a
%   cluster that had many dead jobs which were still considered active. The
%   easiest solution to this was to create a unique profile for each job,
%   and have the code remove any jobs that the cluster was running before
%   executing its own parallel code.

%Creates the initial file that QuditStateEvol will use to save its state
%
%  Data saved as SaveLocation/JobName.mat = DATA_Name_Fullpath.mat
%  ckpt saved as CKPT_Name_Fullpath.mat
%  cluster saved as "JobName", with JobStorageLocation = ClusterLocation/JobName/

%   >> For use with git on hyak

%{
    Inputs:
    DATA:
        JobName
        JobInformation
        JobSpecifications
        Hdim
        IsPure
    CKPT:
        UnitaryFunc
        EvolFunc
        C_Numbers_Int
        TotalTimeSteps
        SystemSizeValues
        MeasurementProbabilityValues
        InteractingProbabilityValues
        RunOptions
        CircuitsPerSystemSize
        TimeStepsBeforeSaving
        Number_ParallelStates
        TimeBeforeMakingBKUP
    Other:
        SaveLocation
        ClusterLocation
        CKPT_Name_Fullpath

%}


    % These variable lists should be exactly the same as the ones which appear
    % in the QuditStateEvol function!

DATA_UsedVariables = {
    'Out'
    'JobName'
    'JobInformation'
    'JobSpecifications'
    'Hdim'
    'IsPure'
    'Job_RunLog'
    };

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

%   List of variable names, for saving.
%   Needs to be a cell of chars, *not* strings.


PrintOut = cat(2,' MC: Making CKPT Save for: ',JobName,sprintf('\n%s\n',datetime("now")));
% '\n%.4d/%.2d/%.2d, %.2d:%.2d\n'
fprintf(PrintOut


pause(3)


Number_SystemSizes = numel(SystemSizeValues)
Number_MeasurementProbabilities = numel(MeasurementProbabilityValues)
Number_InteractingProbabilities = numel(InteractingProbabilityValues)

pause(3)

if (max(size(CircuitsPerSystemSize))~=Number_SystemSizes)
    error('CircuitsPerSystemSize array must match size of SystemSizeValues array.')
end
if ~isa(JobName,'char')
    error('The file name needs to be a "char" data type.')
end

CircuitsPerSystemSize

SystemSize_Index = 1;
MeasurementProbability_Index = 1;
InteractingProbability_Index = 1;
    % These will become current Size/Measurment/Interacting index

CircuitsPerSystemSize_Counter = 1;
    % Number of calculation loops done at one phase point (i.e., for a certain
    % value of the independent variables)

Number_TimesLoaded = 0;
Number_TimesCalculationsSaved = 0;
    % Counts the number of times the code has run

TimeSteps_CurrentState = 0;
    % The current number of time steps applied to the state

Job_RunLog = cell(0,0);

TimeBeforeMakingBKUP

TimeBeforeMakingBKUP_Counter = 0;

CurrentNumber_TimesBackedUp = 1;

InitializeState = false;
    % The states will be saved in a trivial state.

if TimeStepsBeforeSaving(1)>0
        % Initialize the trivial states.
    %{
        N = SystemSizeValues(1); % The size of the first system we'll be working with.

	if IsPure
        StartState_Coded = StateEncode(mod(TrivState(N),Hdim),Hdim);
        %   StateEncode expects no negative numbers, so mod() is required.
        Number_Generators = N;
    else
        StartState_Coded = StateEncode(zeros(N,2*N),Hdim);
        Number_Generators = 0;
	end
	StateArray_Coded = cell(Number_ParallelStates,1);
	for ii=1:Number_ParallelStates
		StateArray_Coded{ii} = struct('State',StartState_Coded,'Number_Generators',Number_Generators);
	end
    %}

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

    if IsPure
        if System_Is_Bosonic
            StartState_Coded = StateEncode(mod(TrivStateBoson(N),Hdim), Hdim);
                % StateEncode expects no negative numbers, so mod() is required.
            Number_Generators = N;
        else
            StartState_Coded = StateEncode(mod(TrivStateMajorana(N),Hdim), Hdim);
                % StateEncode expects no negative numbers, so mod() is required.
            Number_Generators = N;
        end
    else
        StartState_Coded = StateEncode(zeros(N,2*N),Hdim);
        Number_Generators = 0;
    end
    
	StateArray_Coded = cell(Number_ParallelStates,1);
	for ii=1:Number_ParallelStates
		StateArray_Coded{ii} = struct('State',StartState_Coded,'Number_Generators',Number_Generators);
	end

else

	StateArray_Coded = {};
	% for TimeStepsBeforeSaving<0, stateArray is explicitly assigned {} by QuditStateEvol

end

DATA_Name_Fullpath = cat(2,SaveLocation,'/',JobName)

CKPT_Name_Fullpath


fprintf('\n  Saving checkpoint... \n')

save(CKPT_Name_Fullpath,'-v7.3',CKPT_UsedVariables{:})

Out = struct();
%   the saves happen infrequently, so we're not worried about preallocating array space
Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).LengthDistribution = cell(0,0);
Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).SubsystemEntropy = cell(0,0);
Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).PurificationEntropy = cell(0,0);
Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).Realizations = cell(0,0);

fprintf('\n  Saving DATA file... \n')

save(DATA_Name_Fullpath,DATA_UsedVariables{:})



%%%%%%%%%%%%%%%%%%%%%%%
%		Cluster bit.
%       list profile names: [allProf,defaultProf] = parallel.clusterProfiles
%       remove profile: parallel.internal.ui.MatlabProfileManager.removeProfile('MyProFileName');
%%%%%%%%%%%%%%%%%%%%%%%
%	We want each parallel pool to run in a folder which is dedicated to that job.
%	This helps with some problems we were having earlier, with parallel jobs just being given numbers.
%	For each job, we make a pool, change the directory to a job-specific one,
%	 then save the cluster profile with that directory specified.

ClusPathFull = cat(2,ClusterLocation,'/',JobName)

clusterSuccess = false;
while ~clusterSuccess
    try
        MyCluster = parcluster('local')
        clusterSuccess = true;
    catch
        fprintf('\nCluster failed to initialize. Retrying...\n')
    end
end

if MyCluster.NumWorkers<Number_ParallelStates
	error('\nError! Cluster cores less than Number_ParallelStates. Server probably doesn''t have enough cores alloted to MATLAB...\n')
elseif MyCluster.NumWorkers>Number_ParallelStates
    fprintf('\nCluster has more cores than Number_ParallelStates. Decreasing...')
    MyCluster.NumWorkers = Number_ParallelStates;
end

mkdir(ClusPathFull)
MyCluster.JobStorageLocation = ClusPathFull

pause(1)

clusterSuccess = false;
while ~clusterSuccess
    try
        ProfileNameAvailable = true;
        if any(ismember(parallel.clusterProfiles, JobName))
            ProfileNameAvailable = false;
            fprintf('\nCluster Profile already exists...')
        end
        if ~ProfileNameAvailable
            try
                fprintf('deleting...\n')
                parallel.internal.ui.MatlabProfileManager.removeProfile(JobName);
            catch DeleteFail
                fprintf('  Failed to delete cluster profile.')
				fprintf('\n  ~~  %s',DeleteFail.identifier)
				fprintf('\n  ~~  "%s',DeleteFail.message)
				fprintf('\n 	Retrying...\n')
            end
        else
            clusterSuccess = true;
        end
    catch
        fprintf('\nLooks like we couldn''t get the cluster profile list? Retrying...\n')
    end
end

MyCluster
saveAsProfile(MyCluster,JobName)

fprintf('\nCluster Profile Saved...\n')

pause(1)
end

%10/Dec/2020 - Finished version 1.0 of the code.
%14/Dec/2020 - Uploaded to hyak. Edited variables from (qi,Ni,pi) -> (q_i,N_i,p_i) to avoid conflating the index p_i with the circular constant Pi.
%13/Jan/2021 - Modified the ckpt save folder from /gscratch/home/jm117 to /gscratch/stf/jm117. Also added 'ckptinfo' var.
%17/Jam/2021 - made the function generic by taking in all the parameters as input variables.
%    meant to be used with make_files.m to automate jobs more.
%15/Feb/2021 - Added code to make the FileName into a cluster profile to try and cut down
%   on the local_cluster_jobs nonsense of having over 700 jobs apparently running.
%   Also made TrivState a sparse matrix when t==0.
%16/Feb/2021 - stateArray now stays {} if CircuitsPerSystemSize<=0
%14/Apr/2021 - Edited to klone form, has 'EvolFunc', 'tags', and 'specs' as inputs.
%   Now has CKPT_Name_Full as input, too.
%28/Jul/2021 - Added code to double check that the number of workers in the parcluster is the NumCores we would like.

%28/Feb/2023 - Finished updating it to use the Parafermion parameters.

