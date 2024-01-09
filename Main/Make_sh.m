function Make_sh(sh_Folder,CodePath,JobPath,JobName,CKPT_Name_Fullpath,Diary_FullName_Fullpath,NodeTime,NodeMemory,Number_ParallelRealizations)
%MAKE_SH  Create a .sh file to put into the queue on HYAK.
%
%   MAKE_SH(SH_FOLDER, JOBPATH, JOBNAME, CKPT_NAME_FULLPATH,
%   DIARY_FULLNAME_FULLPATH, NODETIME, NODEMEM, NUM_PARSTATES) creates a shell
%   script which can be added to the slurm queue of HYAK's klone cluster
%   using `squeue`. It is set up to add a job to the CKPT queue of the STF
%   account.
%
%   -- SH_FOLDER is the folder where the final shell script will be saved.
%
%   -- JOBPATH is the path to the folder with the Job folder in it.
%
%   -- JOBNAME is the name of the Job.
%
%   -- CKPT_NAME_FULLPATH is the name of the CKPT file, along with the
%   absolute path to get there, but *not* including the .mat file
%   extension. E.g., '/mmfs1/gscratch/username/CKPTS/JOBNAME_CKPT'.
%
%   -- DIARY_FULLNAME_FULLPATH absolute path of the diary file, including
%   name and file extension. E.g.,
%   '/mmfs1/gscratch/username/DIARY/DIARYNAME.diary'.
%
%   -- NODETIME is a string of the form 'HH:MM:SS', and tells slurm how
%   long to run the Job for.
%
%   -- NODEMEMORY is the amound of memory allocated to the Job, e.g. '10G'.
%
%   -- NUM_PARSTATES is the number of cores that the Job will have
%   dedicated to it. Note that on the interactive nodes, you might need to
%   use --ntasks-per-node=1 --cpus-per-task=NUM_PARSTATES instead of the
%   format used below. I don't know why there is a difference.
%
%   See also CREATE_JOBS, DONEFILE


fprintf(' MSH: Path to QHS code: %s\n', CodePath)

if exist(cat(2,JobPath,'/ckpt_',JobName),'file')==2
    fprintf('\n            Job already exists!')
    return
end

shNameFull = cat(2,sh_Folder,'/',JobName,'.sh');
doneNameFull = cat(2,JobPath,'/ExitFiles/',JobName,'.done');
fprintf(' MSH: Full .sh file: %s\n   This is the file which Slurm will batch.\n', shNameFull)
fprintf(' MSH: Full .done file: %s\n   This file will be created when the Job is completed.\n   Its existence signals the code to stop running.\n', doneNameFull)


FileID_sh = fopen(shNameFull,'w');
% this eventually closes the file, even if there is an error while
% executing this file
cleanupObj = onCleanup(@() fclose(FileID_sh)); 

fprintf(FileID_sh,...
cat(2,'#!/bin/bash',...
'\n#SBATCH --job-name=',JobName,...
'\n#SBATCH --account=stf-ckpt',...
'\n#SBATCH --partition=ckpt',...
'\n#SBATCH --nodes=1',...
'\n#SBATCH --ntasks-per-node=',num2str(Number_ParallelRealizations),...
'\n#SBATCH --mem=',NodeMemory,...
'\n#SBATCH --time=',NodeTime,...
'\n#SBATCH --chdir=',JobPath,...
'\n#SBATCH --output=',JobPath,'/Output/',JobName,'.log'));


fprintf(FileID_sh,['\ndate\n']);
fprintf(FileID_sh,['while true; do\n']);
fprintf(FileID_sh,['cd ',CodePath,'\n']);
fprintf(FileID_sh,['  module load matlab/r2021a\n']);
fprintf(FileID_sh,['  matlab -nosplash -nodisplay -r "cd ',CodePath,'; addpath(genpath(''',CodePath,'''));',...
    ' RunBatch(''',CKPT_Name_Fullpath,''',''',JobName,''',''',Diary_FullName_Fullpath,''');',...
    ' DoneFile(''',JobPath,''',''',JobName,''',''',CKPT_Name_Fullpath,'''); exit;"\n']);
fprintf(FileID_sh,['  FILE=',doneNameFull,'\n']);
fprintf(FileID_sh,['  if test -f "$FILE"; then\n    echo "Job completed";\n    break\n  fi\ndone\n\nexit 0']);


end


%17/Jan/2021 - made this thing. Hope it helps.
%12/Feb/2021 - updated this thing because I found out you can block commands inside double quotes
%   to get multiple Matlab commands to run in one instance of the 'matlab -nosplash -nodisplay -r' thing.
%02/Mar/2021 - put in a for-loop to run the run_code_ckpt multiple times, so it just restarts when it crashes.
%14/Apr/2021 - Updated for use with run_code_gen on klone. Changed the 10-time repeat of the execution
%   command into a bona fide bash loop. Changed to fit run_code_gen convention of taking CKPT_Name_Fullpath as argument.
%28/Jul/2021 - Removed the convention that the .sh file should start with "ckpt_". They're all ckpt at this point...
%20/Sep/2021 - Added the 'CKPT_Name_Fullpath' input to the DoneFile code, which applies a consistency check to the Job.
%26/Feb/2023 - modified it to work with Parafermions. Updated variable names.
%28/Feb/2023 - Turned into batch_ version.