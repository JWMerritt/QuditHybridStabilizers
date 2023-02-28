function batch_code(CKPT_Name_Fullpath,JobName,Diary_Name_Fullpath)
%   sets up the cluster, then batches run_code.

Verbose = false;
RC = false;

c = clock;

fprintf('\n B: Starting batch_code.')
fprintf('\n Date: %.4d/%.2d/%.2d, %.2d:%.2d',c(1),c(2),c(3),c(4),c(5))
fprintf('Starting cluster with ''%s'' profile.',JobName)

MyCluster = parcluster(JobName)

fprintf('\n B: Deleting old jobs...')

delete(MyCluster.Jobs)

fprintf('\n B: Batching run_code...')

RunJob = batch(MyCluster,'run_code',0,{CKPT_Name_Fullpath,'klone_hyak',RC,Verbose)

fprintf('\n B: Printing diary...')

Diary_Fullname_Fullpath = cat(2,Diary_Name_Fullpath,'.diary')

while ~isequal(RunJob.Jobs(1).Tasks(1).State,'finished')
    pause(30)
    diary(RunJob,Diary_Fullname_Fullpath);
end

fprintf('\n B: batch_code ended. Task State = finished...')

end