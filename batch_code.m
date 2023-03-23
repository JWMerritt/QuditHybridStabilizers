function batch_code(CKPT_Name_Fullpath,JobName,Diary_Name_Fullpath)
%   sets up the cluster, then batches run_code.

%fprintf('\nEntered batch_code\n')

Verbose = false;
RC = false;

c = clock;

fprintf('\n B: Starting batch_code.')
fprintf('\n Date: %.4d/%.2d/%.2d, %.2d:%.2d',c(1),c(2),c(3),c(4),c(5))
fprintf('\nStarting cluster with ''%s'' profile.\n\n........\n',JobName)

feature('numcores')

MyCluster = parcluster(JobName)

fprintf('\n B: Deleting old jobs...')

delete(MyCluster.Jobs)

fprintf('\n B: Batching run_code...')

RunJob = batch(MyCluster,'run_code',0,{CKPT_Name_Fullpath,'klone_hyak',RC,Verbose})

fprintf('\n B: Printing diary...')

Diary_Fullname_Fullpath = cat(2,Diary_Name_Fullpath,'.diary')

while ~isequal(RunJob.Tasks(1).State,'finished')
    pause(30) % we only want the diary to update every 30 seconds or so.
    if isfile(Diary_Fullname_Fullpath)
        delete(Diary_Fullname_Fullpath);
    end
    diary(RunJob,Diary_Fullname_Fullpath);
end

fprintf('\n B: batch_code ended. Task State = finished...')

end
