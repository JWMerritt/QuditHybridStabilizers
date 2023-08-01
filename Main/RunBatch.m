function RunBatch(CKPT_Name_Fullpath,JobName,Code_Path,Diary_Name_Fullpath)
%RUNBATCH  Execute QuditStateEvol and continuously update an output diary
% file.
%   PLEASE NOTE that if the function RUNBATCH is executed in the MATLAB
%   terminal and then cancelled, QuditStateEvol will still be running on
%   the parcluster. It can be removed using `MyCluster =
%   parcluster(JobName); delete(MyCluster.Jobs);`.
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
%   and its dependencies.
%
%   DIARY_NAME_FULLPATH is the full path of the diary file, without any
%   extension. By default, RUNBATCH gives this file a ".diary" extension.
%
%   See also MAKE_CKPT, QUDITSTATEEVOL

fprintf('\n RB: Starting RunBatch.')
fprintf('\n   Date: %s', datetime("now"))
fprintf('\n RB: Parallel information:\n\n===========\n')
feature('numcores');

fprintf('\n===========\n\n RB: Starting cluster with ''%s'' profile....', JobName)
MyCluster = parcluster(JobName)
fprintf('\n RB: Done.')
fprintf('\n===========')
fprintf('\n RB: Deleting all old jobs on this cluster...')
delete(MyCluster.Jobs)
fprintf('\n RB: Done. MyCluster.Jobs = ')
MyCluster.Jobs
fprintf('\n===========')
fprintf('\n RB: Batching QuditSateEvol...');
RunJob = batch(MyCluster,'QuditStateEvol',0,{CKPT_Name_Fullpath,Code_Path});
fprintf('\n RB: Done.')
fprintf('\n===========')
fprintf('\n RB: Diary file:')
Diary_Fullname_Fullpath = cat(2,Diary_Name_Fullpath,'.diary');
fprintf('\n   %s',Diary_Fullname_Fullpath)
fprintf('\n RB: Running code and updating diary...\n')

for ii=1:10
    pause(30) % update quickly for the first 5-10 minutes
    if isfile(Diary_Fullname_Fullpath)
        delete(Diary_Fullname_Fullpath);
    end
    diary(RunJob,Diary_Fullname_Fullpath);
    fprintf('...Diary updated.\n')
end

while ~isequal(RunJob.Tasks(1).State,'finished')
    pause(5*60) % we only want the diary to update every so often.
    if isfile(Diary_Fullname_Fullpath)
        delete(Diary_Fullname_Fullpath);
    end
    diary(RunJob,Diary_Fullname_Fullpath);
end

fprintf('\n RB: RunBatch ended. Task State = finished...')

end
