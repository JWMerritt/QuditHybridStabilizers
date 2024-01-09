    
	%%%%%%%%%%%%%%%%%%%%%
	% Step one: change the password
    %
	% We assume that each job folder on your MATLAB path has a copy of this
	%   function, so we ask for a password to make sure you're using the copy
	%   of Make_Jobs that you intend to use. Make this password different
	%   for each job.


	PASSWORD = 'test job';

   
    %%%%%%%%%%%%%%%%%%%%
	% Step two: make sure the input values are exactly what you want.
	% 	They form the backbone of the jobs to follow.
    

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
    JobPath = 'C:/Users/jmerr/Documents/MATLAB/ParafermionComponents/UnitTests/TestJob'


    % The location of the final DATA file and its backups
    SaveLocation = cat(2, JobPath, '/DATA')


    % The location of the parcluster. Will contain the data for the parcluster
    % jobs.
    ClusterLocation = cat(2, JobPath, '/CLUSTER')


    % The location of the CKPT file and its backup
    CKPT_Folder = cat(2, JobPath, '/CKPT')


    % The location of the diary files.
    Diary_Folder = cat(2, JobPath, '/DIARY')


    % If using Make_sh, the location of the Slurm scripts
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
    SystemSizeValues = [1000]


    % The probability per site to be measured
    MeasurementProbabilityValues = [0.2,0.3,0.4]


    % For @Free_Interactin_Unitary, this is the probability of choosing an interacting
    % gate rather than a free gate. For any other unitary, this is not used and
    % can be set to 0. This can be modified to a user-defined action, depending
    % on the unitary function used.
    InteractingProbabilityValues = [0,1]


    % Total number of circuits per system size. Must be the same size as
    % SystemSizeValues, and the entries correspond.
    % ( System sizes of [250,500] with Circuits of [200,100] means that the
    % 250-site system will run 200 times, and the 500-site system will
    % run 100 times, before the Job is completed.)
    CircuitsPerSystemSize = [100]


    % Total number of time steps per system. Must be the same size as
    % SystemSizeValues, and the entries correspond.
    TotalTimeSteps = [400]


    % Number of time steps applied to each system before the code saves a CKPT.
    % Must be the same size as SystemSizeValues, and the entries correspond.
    % Negative values mean that a system of size N will run for N time steps,
    % and the magnitude indicates how many times this is done before saving.
    % (A system of 250 sites with a TimeStepsBeforeSaving value of -5 will run
    % apply 250 timesteps to a trivial state, calculate the results, and do
    % this 5 times before saving the results in the DATA file.)
    TimeStepsBeforeSaving = [50]


    % This is a string that can be used to add notes to the DATA file, for
    % categorizing it in the future.
    JobInformation = 'Simple Job to create some example data to test on.'


    % This string is for more technical information about the job. Details such
    % as Hdim and Number_ParallelStates are appended to the end of it in the
    % function makeFiles().
    JobSpecifications_Root = 'Enter some technical information here.'


    JobName = 'TEST_d5_N1000'
    

