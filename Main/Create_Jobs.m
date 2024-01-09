function Failures = Create_Jobs(password, C_Numbers_Hdim)
%CREATE_JOBS  Create multiple Jobs to run with the QuditHybridStabilizers
% framework. The user will primarily work with functions/scripts such as
% this one. The function CREATE_JOBS should be changed to reflect the Jobs
% that will be created.
%
%   FAILURES = CREATE_JOBS(PASSWORD) will make a set of Jobs based on the
%   details entered into the function CREATE_JOBS.
%
%   -- PASSWORD is a value that must match the password defined by the user
%   inside the CREATE_JOBS function. This is so that if multiple
%   CREATE_JOBS functions are in the MATLAB path, the correct one is
%   called.
%
%   It is expected that multiple directories of jobs--each with a different
%   focus--will be in the user's MATLAB path, each with a CREATE_JOBS
%   function specific for that focus. Each of these should have a different
%   Password to ensure the correct CREATE_JOBS function is called.
%
%   FAILURES = CREATE_JOBS(PASSWORD, CLIFF_NUMS) is required for Majorana
%   parafermion jobs, with CLIFF_JOBS being the relevant integer list,
%   corresponding to parafermion order, which generate the symplectic
%   matrices that correspond to unitary operations on the system.
%
%   See also MAKE_CKPT, QUDITSTATEEVOL, MAKE_SH
	
	if nargin==0
		password=0+1i;
	end
	
	Failures = {};
	
		

	%%%%%%%%%%%%%%%%%%%%%
	% Step one: change the password
    %
	% We assume that each job folder on your MATLAB path has a copy of this
	%   function, so we ask for a password to make sure you're using the copy
	%   of Make_Jobs that you intend to use. Make this password different
	%   for each job.


	PASSWORD = 'test job';
    

	if ~isequal(password,PASSWORD)
		fprintf('Oops, wrong password. Make sure you''re using the right Create_Jobs code.\n')
		Failures = {'n/a'};
		return
    end

   
    %%%%%%%%%%%%%%%%%%%%
	% Step two: make sure the input values are exactly what you want.
	% 	They form the backbone of the jobs to follow.


    % The directory which includes all of the code for QuditHybridStabilizers
    QHS_CODE_PATH = '/path/to/QHS/repo';
    

    % The statistics of the system being simulated. Should either be "Boson" or
    % "Fermion"
    StatisticsType = 'Boson'
	

    % `MeasurementProbability` and `InteractingProbability` get assigned a
    % per-circuit value inside QuditStateEvol. The fields must be initialized
    % though, and we must also include "StatisticsType" in this struct.


    % The on-site Hilbert space dimension of the qudits
	Hdim = 5
    

    % If the Job is meant to simulate parafermions, then the Clifford numbers
    % must be loaded. These represent all of the valid symplectic matrices
    % which can act on parafermion states and implement valid "Clifford"
    % unitary operations, which map a Majorana paraferion stabilizer state to a
    % stabilizer state.
    %   This can sometimes cause issues where MATLAB throws an error for trying
    %   to load a file into a static workspace; if this occurs, then load the
    %   file before calling Create_Jobs and then pass it in as an arguement.
    %C_Numbers_Hdim = load('C_Numbers_All.mat').C_Numbers_3;
    C_Numbers_Hdim = []


    % Is this a pure state? Determines what a trivial state looks like.
    IsPure = true
    

    % The function which determines each time step. Includes calls to the
    % Measure function.
    EvolFunc = @TimeStepBosonBasic


    % The function which determines unitary evolution. This is passed as an
    % argument to EvolFunc.
    UnitaryFunc = @UnitaryBosonBasic
    

    % Number of parallel states i.e., the number of cores that the program
    % will be running on.
    Number_ParallelStates = 3


    % Time in seconds before making backups of the CKPT and DATA files.
    TimeBeforeMakingBKUP = 1*60
    

    %%%%%%%%%%%%%%
    % The following two parameters are used by Make_sh, which is a
    % script-making code specific to the klone cluster of HYAK.

    % Do we make the .sh file?
    MakeSH = true

    % The time that the script will be requesting to use the node for. Note
    % that if you are using the CKPT queue, it seems that this time resets when
    % the code is interrupted and restarted on another CKPT node.
    NodeTime = '32:00:00'


    % The amount of memory that the script will be requesting for the node.
    NodeMemory = '20G'


    %%%%%%%%%%%%%%
    % File locations
    
    % The location of the Job folder. If using Make_sh, this should include an
    % Output folder for the output of the Slurm log files, and an ExitFiles
    % folder for the ".done" files.
    JobPath = '/home/username/QHS/Jobs/Jobname'


    % The location of the final DATA file and its backups
    % Defaults to JobPath/DATA
    SaveLocation = cat(2, JobPath, '/DATA')


    % The location of the parcluster. Will contain the data for the parcluster
    % jobs. Defaults to JobPath/Cluster
    ClusterLocation = cat(2, JobPath, '/Cluster')


    % The location of the CKPT file and its backup
    % Should be placed on a high-frequency, large-volume drive
    CKPT_Folder = '/high_frequency_storage/QHS_CKPT/Jobname'


    % The location of the diary files.
    % Defaults to JobPath/Diary
    % Diary folder created by `makeFiles` below will have the name
    % 'JobName.diary'.
    Diary_Folder = cat(2, JobPath, '/Diary')


    % If using Make_sh, the location of the Slurm scripts
    % Defaults to JobPath
    sh_Folder = JobPath
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Step three: setup the jobs
    % `SystemSizeValues`, `MeasurementProbabilityValues`, and
    % `InteractingProbabilityValues` should be row vectors of any size, and a
    % calculation will be done foe each of their combinations.
    %
    %`CircuitsPerSystemSize`, `TotalTimeSteps`, and `TimeStepsBeforeSaving` all
    % correspond to specific system sizes, and should be row vectors of the
    % same length as `SystemSizeValues`.
	
    % The sizes of the systems that are to be simulated
    SystemSizeValues = [100, 250, 500]


    % The probability per site to be measured
    MeasurementProbabilityValues = [0.1, 0.2, 0.3, 0.4]


    % For @Free_Interactin_Unitary, this is the probability of choosing an interacting
    % gate rather than a free gate. For any other unitary, this is not used and
    % can be set to 0. This can be modified to a user-defined action, depending
    % on the unitary function used.
    InteractingProbabilityValues = [0, 1]


    % Total number of circuits per system size. Must be the same size as
    % SystemSizeValues, and the entries correspond.
    % ( System sizes of [250,500] with Circuits of [200,100] means that the
    % 250-site system will run 200 times, and the 500-site system will
    % run 100 times, before the Job is completed.)
    CircuitsPerSystemSize = [100, 100, 100]


    % Total number of time steps per system. Must be the same size as
    % SystemSizeValues, and the entries correspond.
    TotalTimeSteps = [50, 100, 200]


    % Number of time steps applied to each system before the code saves a CKPT.
    % Must be the same size as SystemSizeValues, and the entries correspond.
    % Negative values mean that a system of size N will run for N time steps,
    % and the magnitude indicates how many times this is done before saving.
    % (A system of 250 sites with a TimeStepsBeforeSaving value of -5 will run
    % apply 250 timesteps to a trivial state, calculate the results, and do
    % this 5 times before saving the results in the DATA file.)
    TimeStepsBeforeSaving = [-2, 250, 100]


    % This is a string that can be used to add notes to the DATA file, for
    % categorizing it in the future.
    JobInformation = 'Put a description of the Job''s purpose here.'


    % This string is for more technical information about the job. Details such
    % as Hdim and Number_ParallelStates are appended to the end of it in the
    % function makeFiles().
    JobSpecifications_Root = 'Enter some technical information here, such as the name of the UnitaryFunction used.'


    % The name of the job. DATA, CKPT, and parallel clusters are saved using
    % this name.
    JobName = 'Job_Name'

    
    % Set this parameter to true if you would like to overwrite any preexisting
    % jobs that have the same name.
    overwriteExistingJob = false;
    

    % `makefiles` creates the full CKPT and diary file names, includes some
    % details in the JobSpecifications string, and executes Make_CKPT and
    % Make_sh.
    

    makeFiles
	
	
	
	
	
	
	
	
	
	
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function checkParameters
        % Helper function that runs some tests on the parameters to make sure that
        % there aren't simple errors.
		if (~ischar(JobPath)) && (~isstring(JobPath))
			ErrMsg = 'Error: `JobPath` must be a string or char array.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidValueType');
			error(ErrStruct);
		end
		if (~ischar(SaveLocation)) && (~isstring(SaveLocation))
			ErrMsg = 'Error: `SaveLocation` must be a string or char array.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidValueType');
			error(ErrStruct);
		end        
		if (~ischar(ClusterLocation)) && (~isstring(ClusterLocation))
			ErrMsg = 'Error: `ClusterLocation` must be a string or char array.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidValueType');
			error(ErrStruct);
		end
		if (~ischar(CKPT_Folder)) && (~isstring(CKPT_Folder))
			ErrMsg = 'Error: `CKPT_Folder` must be a string or char array.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidValueType');
			error(ErrStruct);
		end
		if (~ischar(JobSpecifications_Root)) && (~isstring(JobSpecifications_Root))
			ErrMsg = 'Error: `JobSpecification_Root` must be a string or char array.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidValueType');
			error(ErrStruct);
		end
		if (~ischar(JobName)) && (~isstring(JobName))
			ErrMsg = 'Error: `JobName` must be a string or char array.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidValueType');
			error(ErrStruct);
		end
		if (~ischar(JobInformation)) && (~isstring(JobInformation))
			ErrMsg = 'Error: `JobInformation` must be a string or char array.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidValueType');
			error(ErrStruct);
		end
		if MakeSH
			if (~ischar(sh_Folder)) && (~isstring(sh_Folder))
				ErrMsg = 'Error: `JobPath` must be a string or char array.';
				ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidValueType');
				error(ErrStruct);
			end
		end
		SystemSizeSize = size(SystemSizeValues);
		if SystemSizeSize(1)~=1
			ErrMsg = 'Error: `SystemSizeValues` must be a roe vector.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidArraySize');
			error(ErrStruct);
		end
		MeasurementProbSize = size(MeasurementProbabilityValues);
		if MeasurementProbSize(1)~=1
			ErrMsg = 'Error: `MeasurementProbabilityValues` must be a roe vector.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidArraySize');
			error(ErrStruct);
		end
		InteractingProbSize = size(InteractingProbabilityValues);
		if InteractingProbSize(1)~=1
			ErrMsg = 'Error: `InteractingSizeValues` must be a roe vector.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidArraySize');
			error(ErrStruct);
		end
		if size(CircuitsPerSystemSize)~=SystemSizeSize
			ErrMsg = 'Error: `CircuitsPerSystemSize` must have the same number of elements as `SystemSizeValues`.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidArraySize');
			error(ErrStruct);
		end
		if size(TotalTimeSteps)~=SystemSizeSize
			ErrMsg = 'Error: `TotalTimeSteps` must have the same number of elements as `SystemSizeValues`.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidArraySize');
			error(ErrStruct);
		end
		if size(TimeStepsBeforeSaving)~=SystemSizeSize
			ErrMsg = 'Error: `TimeStepsBeforeSaving` must have the same number of elements as `SystemSizeValues`.';
			ErrStruct = struct('message', ErrMsg, 'identifier', 'CreateJob:InvalidArraySize');
			error(ErrStruct);
		end
    end

    function out = check_preexisting_job
        out = true;
        if exist([SaveLocation, '/', JobName, '.mat'], 'file')==2
			fprintf('\n            Job already exists! Delete DATA/JobName.mat file if you''re sure you want to re-make this job.')
			Failures = cat(1,Failures,JobName);
            out = false;
			return
        end
        if exist([CKPT_Folder ,'/', JobName, '_CKPT.mat'], 'file')==2
			fprintf('\n            Job already exists! Delete JobName_CKPT.mat file if you''re sure you want to re-make this job.')
			Failures = cat(1,Failures,JobName);
			out = false;
            return
        end
        if MakeSH
		    if exist([sh_Folder,'/',JobName,'.sh'],'file')==2
			    fprintf('\n            Job already exists! Delete JobName.sh file if you''re sure you want to re-make this job.')
			    Failures = cat(1,Failures,JobName);
			    out = false;
                return
            end
        end
    end
		
	function makeFiles
            % If the bash script already exists, we may have a Job with this name
            % already created, and running this code would risk overwriting the CKPT
            % and DATA files of that Job, erasing the data. If this is something you
            % would like to do, then remove the .sh file associated with the job.
        
        checkParameters;
        if ~overwriteExistingJob
            no_job_exists = check_preexisting_job;
            if ~no_job_exists
                return
            end
        end

        RunOptions = struct('MeasurementProbability',0,'InteractingProbability',0,'StatisticsType',StatisticsType);
		CKPT_Name_FullPath = [CKPT_Folder,'/',JobName,'_CKPT'];
        Diary_FullName_FullPath = [Diary_Folder,'/',JobName,'.diary'];
		JobSpecifications = [JobSpecifications_Root, sprintf('Hdim = %d, IsPure = %d, Number_ParallelStates = %d',Hdim,IsPure,Number_ParallelStates)];

        Make_CKPT(JobName,JobInformation,JobSpecifications,Hdim,IsPure,...
            UnitaryFunc,EvolFunc,C_Numbers_Hdim,TotalTimeSteps,...
            SystemSizeValues,MeasurementProbabilityValues,InteractingProbabilityValues,...
            RunOptions,CircuitsPerSystemSize,TimeStepsBeforeSaving,Number_ParallelStates,...
            TimeBeforeMakingBKUP,SaveLocation,ClusterLocation,CKPT_Name_FullPath)

        if MakeSH
            Make_sh(sh_Folder,QHS_CODE_PATH,JobPath,JobName,CKPT_Name_FullPath,...
            Diary_FullName_FullPath,NodeTime,NodeMemory,Number_ParallelStates)
        end

    end
end
