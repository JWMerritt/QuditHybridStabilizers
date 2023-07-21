function RunBatch(CKPT_Name_Fullpath,JobName,Diary_Name_Fullpath)
%   sets up the cluster, then batches run_code.

%fprintf('\nEntered batch_code\n')

Verbose = false;

fprintf('\n B: Starting RunBatch.')
fprintf('\n Date: %s', datetime("now"))
fprintf('\n Parallel information:')
feature('numcores');
fprintf('\n ========\n Starting cluster with ''%s'' profile.', JobName)

MyCluster = parcluster(JobName)

fprintf('\n B: Deleting all old jobs on this cluster...')

delete(MyCluster.Jobs)

fprintf('\n B: Batching run_code...')

RunJob = batch(MyCluster,'run_code',0,{CKPT_Name_Fullpath,'klone_hyak',RC,Verbose})

fprintf('\n B: Printing diary...')

Diary_Fullname_Fullpath = cat(2,Diary_Name_Fullpath,'.diary')

for ii=1:10
    % update quickly for the first 5-10 minutes
    pause(30)
    if isfile(Diary_Fullname_Fullpath)
        delete(Diary_Fullname_Fullpath);
    end
    diary(RunJob,Diary_Fullname_Fullpath);
end

while ~isequal(RunJob.Tasks(1).State,'finished')
    pause(5*60) % we only want the diary to update every so often.
    if isfile(Diary_Fullname_Fullpath)
        delete(Diary_Fullname_Fullpath);
    end
    diary(RunJob,Diary_Fullname_Fullpath);
end

fprintf('\n B: batch_code ended. Task State = finished...')

end
