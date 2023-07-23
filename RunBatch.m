function RunBatch(CKPT_Name_Fullpath,JobName,Diary_Name_Fullpath)
%   sets up the cluster, then batches run_code.

%fprintf('\nEntered batch_code\n')

Verbose = false;

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
%fprintf('\n   Cluster Profile: %s', MyCluster.Profile)
%fprintf('\n   Host: %s', MyCluster.Host)
%fprintf('\n   NumWorkers: %.0f', MyCluster.NumWorkers)
%fprintf('\n   Current Jobs: ')
%MyCluster.Jobs
fprintf('\n===========')
fprintf('\n RB: Batching QuditSateEvol...');
RunJob = batch(MyCluster,'QuditStateEvol',0,{CKPT_Name_Fullpath,'C:\Users\jmerr\Documents\MATLAB\ParafermionComponents'});
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
