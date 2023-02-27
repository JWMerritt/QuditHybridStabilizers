function Make_sh(JobPath,JobName,CKPT_Name_Fullpath,NodeTime,NodeMemory,Number_ParallelRealizations)
%	sets up things for hyak. Is 'Parafermion' specific.
%	>> Edit this code directly on hyak.

RC = false;

if exist(cat(2,JobPath,'/ckpt_',JobName),'file')==2
    fprintf('\n            Job already exists!')
	return
end

shNameFull = cat(2,JobPath,'/',JobName,'.sh')
doneNameFull = cat(2,JobPath,'/ExitFiles/',JobName,'.done')
fprintf(shNameFull)
fprintf('\n')
fprintf(doneNameFull)

FileID_sh = fopen(shNameFull,'w');

%maybe don't put comments or blank lines in the middle of code that's
%  supposed to act as a single line, yeah?
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
%	'\n#SBATCH --mail-type=BEGIN,END','\n#SBATCH --mail-user=jm117@uw.edu'));

fprintf(FileID_sh,'\ndate\n');
fprintf(FileID_sh,'while true; do\n');
fprintf(FileID_sh,'cd /mmfs1/home/jm117/MATLAB/Parafermions\n');
fprintf(FileID_sh,'  module load matlab/r2021a\n');
fprintf(FileID_sh,cat(2,'  matlab -nosplash -nodisplay -r "cd /mmfs1/home/jm117/MATLAB/Parafermions; addpath(genpath(''/mmfs1/home/jm117/MATLAB/Parafermions''));'));
if RC
	fprintf(FileID_sh,' RCrun_code_gen');
else
	fprintf(FileID_sh,' run_code');
end
fprintf(FileID_sh,cat(2,'(''',CKPT_Name_Fullpath,''');DoneFile(''',JobPath,''',''',JobName,''',''',CKPT_Name_Fullpath,''');exit;"\n'));
fprintf(FileID_sh,cat(2,'  FILE=',doneNameFull,'\n'));
fprintf(FileID_sh,cat(2,'  if test -f "$FILE"; then\n    echo "Job completed";\n    break\n  fi\ndone\n\nexit 0'));
%fprintf(FileID_sh,cat(2,'  \nmatlab -nosplash -nodisplay -r "cd /gscratch/home/jm117/MATLAB/Free_Fermions; addpath(genpath(''/gscratch/home/jm117/MATLAB'')); DoneFile(''',JobPath,''',''',JobName,''');exit;"\n\nexit 0'));

fclose(FileID_sh);

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