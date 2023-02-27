function Make_CKPT(JobName,JobInformation,JobSpecifications,Hdim,IsPure,UnitaryFunc,EvolFunc,C_Numbers_Int,TotalTimeSteps,SystemSizeValues,MeasurementProbabilityValues,InteractingProbabilityValues,RunOptions,RealizationsPerSystemSize,RealizationsBeforeSaving,Number_ParallelRealizations,TimeBeforeMakingBKUP,SaveLocation,ClusterLocation,CKPT_Name_Fullpath)
%Creates the initial file that run_code will use to save its state
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
        RealizationsPerSystemSize
        RealizationsBeforeSaving
        Number_ParallelRealizations
        TimeBeforeMakingBKUP
    Other:
        SaveLocation
        ClusterLocation
        CKPT_Name_Fullpath

%}




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

%   List of variable names, for saving.
%   Needs to be a cell of chars, *not* strings.



RC = false
Hyak = false

%{
if RC
	TimeBeforeMakingBKUP = 60;
else
	TimeBeforeMakingBKUP = 1800;
end
%}

c=clock;
PrintOut = cat(2,'X: Making CKPT Save for: ',JobName,'\n%.4d/%.2d/%.2d, %.2d:%.2d\n');
fprintf(PrintOut,c(1),c(2),c(3),c(4),c(5))


pause(3)


Number_SystemSizes = numel(SystemSizeValues)
Number_MeasurementProbabilities = numel(MeasurementProbabilityValues)
%Qintervalnum = numel(MeasurementProbabilityValues)
%   For right now, we won't have a bunch of different intervals;
%   we'll just run different jobs.
Number_InteractingProbabilities = numel(InteractingProbabilityValues)

pause(3)

if (max(size(RealizationsPerSystemSize))~=Number_SystemSizes)%&&(RealizationsPerSystemSize~=false)
    error('RealizationsPerSystemSize array must match size of SystemSizeValues array.')
end
if ~isa(JobName,'char')
    error('The file name needs to be a "char" data type.')
end

%mkdir(ParStorageLocation)

RealizationsPerSystemSize

%{
if RealizationsPerSystemSize==false
    RealizationsPerSystemSize = zeros(1,Number_SystemSizes)+pool.NumWorkers;
end
%}

SystemSize_Index = 1;
MeasurementProbability_Index = 1;
InteractingProbability_Index = 1;
%   These will become current Size/Measurment/Interacting index

RealizationsPerSystemSize_Counter = 1;
%   number of realizations done at one phase point

Number_TimesLoaded = 0;
Number_TimesCalculationsSaved = 0;
%   number of times the code has run

TimeSteps_CurrentState = 0;
%   current number of time steps applied to the state

Job_RunLog = cell(0,0);

TimeBeforeMakingBKUP

TimeBeforeMakingBKUP_Counter = 0;

CurrentNumber_TimesBackedUp = 1;

InitializeState = false;

if RealizationsBeforeSaving(1)>0
    L = SystemSizeValues(1);
    %   The size of the first system we'll be working with.
	if IsPure
        %StartState = TrivState(L);
        StartState_Coded = StateEncode(mod(TrivState(L),Hdim),Hdim)
        %   StateEncode expects no negative numbers, so mod() is required.
        Number_Generators = L;
    else
        %StartState = zeros(L,2*L);
        StartState_Coded = 0
        Number_Generators = 0;
	end
	StateArray_Coded = {}
	for ii=1:Number_ParallelRealizations
		StateArray_Coded = cat(1,StateArray_Coded,struct('State',StartState_Coded,'Number_Generators',Number_Generators))
	end

else

	StateArray_Coded = {};
	% for sP<0, stateArray is explicitly assigned {} by run_code_ckpt

end

DATA_Name_Fullpath = cat(2,SaveLocation,'/',JobName)

CKPT_Name_Fullpath %= cat(2,ckptBaseLoc,ckptpath,'/ckpt_save_',JobName);



fprintf('\n  Saving checkpoint... \n')

%{
CKPT_SaveString = '';
for ii=1:numel(CKPT_UsedVariables)
    CKPT_SaveString = cat(2,CKPT_SaveString,''',''',CKPT_UsedVariables{ii});
end
%   quotes and commas are placed before all entries, so account for this in the next line:
EvalString = cat(2,'save(CKPT_Name_Fullpath,''-v7.3',CKPT_SaveString,''');');
fprintf(EvalString)
eval(EvalString);
%}
save(CKPT_Name_Fullpath,'-v7.3',CKPT_UsedVariables{:})

Out = struct();
%   the saves happen infrequently, so we're not worried about preallocating array space
Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).LengthDistribution = cell(0,0);
Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).SubsystemEntropy = cell(0,0);
Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).PurificationEntropy = cell(0,0);
Out(SystemSize_Index,MeasurementProbability_Index,InteractingProbability_Index).Realizations = cell(0,0);



fprintf('\n  Saving DATA file... \n')

%{
DATA_SaveString = '''';
for ii=1:numel(DATA_UsedVariables)
	DATA_SaveString = cat(2,DATA_SaveString,DATA_UsedVariables{ii});
	if ii~=numel(DATA_UsedVariables)
		DATA_SaveString = cat(2,DATA_SaveString,''',''');
	else
		DATA_SaveString = cat(2,DATA_SaveString,'''');
	end
end
EvalString = cat(2,'save(DATA_Name_Fullpath,',DATA_SaveString,');');
fprintf(EvalString)
eval(EvalString);
%}
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

if ~RC  %if RC, then run_code will use 'RunContainer' profile

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
	
	if MyCluster.NumWorkers~=Number_ParallelRealizations
		error('\nError! Cluster cores not equal to Number_ParallelRealizations. Server probably doesn''t have enough cores alloted to MATLAB...\n')
	end

    mkdir(ClusPathFull)
    MyCluster.JobStorageLocation = ClusPathFull

    pause(1)

    clusterSuccess = false;
    while ~clusterSuccess
        try
            ProfileNameAvailable = true;
            profileList = parallel.clusterProfiles;
            for ii=1:numel(profileList)
                if isequal(profileList{ii},JobName)
                    ProfileNameAvailable = false;
                    fprintf('\nCluster Profile already exists...')
                end
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
    
end

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
%16/Feb/2021 - stateArray now stays {} if RealizationsPerSystemSize<=0
%14/Apr/2021 - Edited to klone form, has 'EvolFunc', 'tags', and 'specs' as inputs.
%   Now has CKPT_Name_Full as input, too.
%28/Jul/2021 - Added code to double check that the number of workers in the parcluster is the NumCores we would like.