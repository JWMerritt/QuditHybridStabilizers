function RunBatch(CKPT_Name_FullPath, JobName, CodePath, Diary_FullName_FullPath, deleteAllJobsOnExit)
%RUNBATCH Execute QuditStateEvol and continuously update an output diary
% file.
%   PLEASE NOTE that if the function RUNBATCH is executed in the MATLAB
%   terminal and then cancelled, QuditStateEvol will still be running on
%   the parcluster--only the continuous recording of the diary will
%   stop--unless deleteAllJobsOnExit is true. If not, the jobs can be
%   removed using `MyCluster = parcluster(JobName);
%   delete(MyCluster.Jobs);`.
%
%   RUNBATCH(CKPT_NAME_FULLPATH, JOBNAME, CODE_PATH, DIARY_NAME_FULLPATH)
%   loads the CKPT file, creates a parcluster under the JOBNAME profile,
%   adds CODE_PATH and children to the MATLAB path, batches QuditStateEvol
%   onto the JOBNAME parcluster, and records the diary output.
%
%   CKPT_NAME_FULLPATH is the full path of the Job's CKPT file, without the
%   .mat extension.
%
%   JOBNAME is the name of the Job, and should be the name of the cluster
%   profile associated with the job.
%
%   CODE_PATH is the path to the folder containing QuditStateEvol
%   and its dependencies (i.e., the main directory of the GitHub repo).
%   These folders will be added to the MATLAB path by QuditStateEvol.m.
%
%   DIARY_FULLNAME_FULLPATH is the full path of the diary file, including
%   the file extension.
%
%   DELETE_ALL_JOBS_ON_EXIT is an optional parameter (defaults to true)
%   which if true, will delete all of the jobs on the cluster named
%   `<JobName>`.
%
%   See also MAKE_CKPT, QUDITSTATEEVOL

if nargin<5
    deleteAllJobsOnExit = true;
end

% Remove .mat extension, if present
if numel(CKPT_Name_FullPath)>4
    CKPT_Name_FullPath = RemoveMatExt(CKPT_Name_FullPath);
end

if exist([CKPT_Name_FullPath, '.mat'], 'file')~=2
    fprintf('\nRB: File not found: %s.mat\n    Returning...', CKPT_Name_FullPath)
    return
end
if exist(CodePath, 'dir')~=7
    fprintf('\nRB: Code directory not found: %s.\n    Returning...', CodePath)
    return
end

% Check for valid Diary name / directory
if ~isfile(Diary_FullName_FullPath)
    diaryID = fopen(Diary_FullName_FullPath,'w');
    fclose(diaryID);
    if diaryID == -1
        errMsg = sprintf("Diary file, %s, cannot be accessed. Possibly incorrect parent directory path.", Diary_FullName_FullPath);
        errStruct = struct('message', errMsg, 'identifier', 'RunBatch::InvalidDiaryFile');
        error(errStruct)
    end
end

fprintf('\n RB: Starting RunBatch.')
fprintf('\n   Date: %s', datetime("now"))

% Print info to terminal
fprintf('\n RB: Parallel information:\n\n===========\n')
feature('numcores');

fprintf('\n===========\n\n RB: Starting cluster with ''%s'' profile....', JobName)
MyCluster = parcluster(JobName);
disp(MyCluster)
fprintf('\n RB: Done.')

fprintf('\n===========')

fprintf('\n RB: Diary file:')
fprintf('\n   %s',Diary_FullName_FullPath)

fprintf('\n===========')

fprintf('\n RB: Deleting all old jobs on this cluster...')
delete(MyCluster.Jobs)
fprintf('\n RB: Done. MyCluster.Jobs = ')
MyCluster.Jobs

fprintf('\n===========')

fprintf('\n RB: Batching QuditSateEvol...');
RunJob = batch(MyCluster,'QuditStateEvol',0,{CKPT_Name_FullPath,CodePath});
if deleteAllJobsOnExit
    cleanupObj = onCleanup(@()DeleteClusterJobs(JobName));
    % when cleanupObj is destroyed (by ending the program, error, or ctrl+C),
    % the function DeleteClusterJobs(JobName) is called, deleting the batch job
    % from the cluster.
end
fprintf('\n RB: Done.')
fprintf('\n RB: Running code and updating diary...\n')

for ii=1:10
    pause(30) % update quickly for the first 5-10 minutes
    if isfile(Diary_FullName_FullPath)
        delete(Diary_FullName_FullPath);
    end
    diary(RunJob,Diary_FullName_FullPath);
    fprintf('...Diary updated.\n')
end

while ~isequal(RunJob.Tasks(1).State,'finished')
    pause(5*60) % we only want the diary to update every so often.
    if isfile(Diary_FullName_FullPath)
        delete(Diary_FullName_FullPath);
    end
    diary(RunJob,Diary_FullName_FullPath);
end

fprintf('\n RB: RunBatch ended. Task State = finished...')

end
