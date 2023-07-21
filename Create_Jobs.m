function Failures = Create_Jobs(password,C_Numbers_Int)
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
%   See also MAKE_CKPT, QUDITSTATEEVOL
	
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

	PASSWORD = 'main';
	
	if ~isequal(password,PASSWORD)
		fprintf('oops, wrong password. Make sure you''re using the right Create_Jobs code.\n')
		Failures = {'n/a'};
		return
	end
	
	%%%%%%%%%%%%%%%%%%%%
	% Step two: make sure the input values are exactly what you want.
	% 	They form the backbone of the jobs to follow.
    
	
	JobNickname = 'Main'
	JobInformation = 'klone run. QuditStateEvol.m with @TimeStepBosonic and @BosonUnitary.'
	JobSpecifications_Root = ''


	Hdim = 3

	IsPure = true

	UnitaryFunc = @BosonUnitary
	EvolFunc = @TimeStepBosonic

	StatisticsType = 'Boson'
	
	RunOptions = struct('MeasurementProbability',0,'InteractingProbability',0,'StatisticsType',StatisticsType)
	%	'MeasurementProbability' and 'InteractingProbability' usually get assigned inside QuditStateEvol.
	
	RunLimits = 2000
	NodeTime = '32:00:00'
	NodeMemory = '20G'
	
	Number_ParallelStates = 20
	TimeBeforeMakingBKUP = 10*60
		% = time in seconds
	
	% Expected: /Output/ folder for Slurm .log files; /ExitFiles/ folder for .done files
	
	JobFolderName = 'Main'
	JobFolderLocation = '/mmfs1/gscratch/stf/jm117/data/Parafermions/'
	DiaryFolderLocation = '/mmfs1/gscratch/stf/jm117/diaries/Parafermions/'
	CKPTFolderLocation = '/mmfs1/gscratch/stf/jm117/ckpts/Parafermions/'
	% 	DON'T FORGET to make the CKPT directory!
	
	JobPath = cat(2,JobFolderLocation,JobFolderName)
		%	Location of the following folders
	SaveLocation = cat(2,JobFolderLocation,JobFolderName,'/DATA')
		%	Location of 'FILENAME.mat' data files
	ClusterLocation = cat(2,JobFolderLocation,JobFolderName,'/Cluster')
		%   Location of 'Jobs' cluster folders
	CKPT_Folder = cat(2,CKPTFolderLocation,JobNickname)  
		%	Location of '$FILENAME_CKPT.mat' files.
	Diary_Folder = cat(2,DiaryFolderLocation,JobNickname)
        %   Location of the diaries, which are the outputs from the batch() jobs.
	sh_Folder = cat(2,'/mmfs1/home/jm117/MATLAB/Parafermions/Jobs/',JobFolderName)
		%	Location of the 'FILENAME.sh' files
	
	
	%JobName,JobInformation,JobSpecifications,Hdim,IsPure,UnitaryFunc,EvolFunc,C_Numbers_Int,TotalTimeSteps,SystemSizeValues,MeasurementProbabilityValues,InteractingProbabilityValues,RunOptions,RealizationsPerSystemSize,RealizationsBeforeSaving,Number_ParallelStates,TimeBeforeMakingBKUP,SaveLocation,ClusterLocation,CKPT_Name_Fullpath)

	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Step three: setup the jobs
    % This can be done in whatever way you would like. Below is a sample, along
    % with the local functions 'bmakeName' and 'makeFiles' to execute the
    % functions that actually make the files.
	

	N__ALL_SystemSizes = 100
	N__ALL_TotalTimeSteps = 100
	N__ALL_CircuitsPerN = 30
	N__ALL_TimePerSave = 25
	%}

	N__NumberOfSystemSizes = 1;
	MProbs = [0.15,0.16,0.17]
	MString = 'n016'
	IProbs = [0,0.5]
	
	if all( [numel(N__ALL_SystemSizes)==N__NumberOfSystemSizes,...
            numel(N__ALL_TotalTimeSteps)==N__NumberOfSystemSizes,...
            numel(N__ALL_CircuitsPerN)==N__NumberOfSystemSizes,...
            numel(N__ALL_TimePerSave)==N__NumberOfSystemSizes] )
        % It's easy to mess up and not make these matrices to be the same size, so
        % this just does a quick check.

		for jj=1:numel(N__ALL_SystemSizes)
			
			SystemSizeValues = N__ALL_SystemSizes(jj)
			CircuitsPerSystemSize = N__ALL_CircuitsPerN(jj)
			TotalTimeSteps = N__ALL_TotalTimeSteps(jj)
			TimeStepsBeforeSaving = N__ALL_TimePerSave(jj)

			MeasurementProbabilityValues = MProbs
			InteractingProbabilityValues = IProbs 

            % Jobs will be named [JOBNICKNAME]_d[HDIM]_N[SYSTEMSIZE]_m[MVAL]_[#]

			JobName = bmakeNames(JobNickname,num2str(Hdim),num2str(SystemSizeValues),MString,'1');
			makeFiles
			
			JobName = bmakeNames(JobNickname,num2str(Hdim),num2str(SystemSizeValues),MString,'2');
			makeFiles
			
		end
	else
		fprintf(' >> Error: Triple-check your numbers!!! \n')
	end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	
	
	function Fname = makeNames(DESIG,SSize,MProb,IProb,num)	%  ALL ENTRIES ARE STRINGS
		Fname = cat(2,DESIG,'_N',SSize,'_m',MProb,'_i',IProb,'_',num);
		fprintf('\n    filename: %s\n',Fname)
	end

	function Fname = bmakeNames(DESIG,HDIM,SSize,MProb,num)	%  ALL ENTRIES ARE STRINGS
		Fname = cat(2,DESIG,'_d',HDIM,'_N',SSize,'_m',MProb,'_',num);
		fprintf('\n    filename: %s\n',Fname)
	end
	
	
	
	function makeFiles
		if exist(cat(2,sh_Folder,'/',JobName,'.sh'),'file')==2
			fprintf('\n            Job already exists! Delete JobName.sh file if you''re sure you want to re-make this job.')
			Failures = cat(1,Failures,JobName)
			return
		else
			CKPT_Name_Fullpath = cat(2,CKPT_Folder,'/',JobName,'_CKPT');
            Diary_Name_Fullpath = cat(2,Diary_Folder,'/',JobName)
			JobSpecifications = cat(2, JobSpecifications_Root, sprintf('Hdim = %d, IsPure = %d, Number_ParallelStates = %d',Hdim,IsPure,Number_ParallelStates));
			Make_CKPT(JobName,JobInformation,JobSpecifications,Hdim,IsPure,UnitaryFunc,EvolFunc,C_Numbers_Int,TotalTimeSteps,SystemSizeValues,MeasurementProbabilityValues,InteractingProbabilityValues,RunOptions,CircuitsPerSystemSize,TimeStepsBeforeSaving,Number_ParallelStates,TimeBeforeMakingBKUP,SaveLocation,ClusterLocation,CKPT_Name_Fullpath)
			Make_batch_sh(sh_Folder,JobPath,JobName,CKPT_Name_Fullpath,Diary_Name_Fullpath,NodeTime,NodeMemory,Number_ParallelStates)
		end
    end
end
