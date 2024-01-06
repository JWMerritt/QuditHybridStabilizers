#!/bin/bash
#SBATCH --job-name=TEST_d5
#SBATCH --account=stf-ckpt
#SBATCH --partition=ckpt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=3
#SBATCH --mem=20G
#SBATCH --time=32:00:00
#SBATCH --chdir=C:/Users/jmerr/Documents/MATLAB/ParafermionComponents/UnitTests/TestJob
#SBATCH --output=C:/Users/jmerr/Documents/MATLAB/ParafermionComponents/UnitTests/TestJob/Output/TEST_d5.log
date
while true; do
cd PRIMARY_DIRECTORY
  module load matlab/r2021a
  matlab -nosplash -nodisplay -r "cd PRIMARY_DIRECTORY; addpath(genpath('PRIMARY_DIRECTORY')); RunBatch('C:/Users/jmerr/Documents/MATLAB/ParafermionComponents/UnitTests/TestJob/CKPT/TEST_d5_CKPT','TEST_d5','C:/Users/jmerr/Documents/MATLAB/ParafermionComponents/UnitTests/TestJob/DIARY/TEST_d5'); DoneFile('C:/Users/jmerr/Documents/MATLAB/ParafermionComponents/UnitTests/TestJob','TEST_d5','C:/Users/jmerr/Documents/MATLAB/ParafermionComponents/UnitTests/TestJob/CKPT/TEST_d5_CKPT'); exit;"
  FILE=C:/Users/jmerr/Documents/MATLAB/ParafermionComponents/UnitTests/TestJob/ExitFiles/TEST_d5.done
  if test -f "$FILE"; then
    echo "Job completed";
    break
  fi
done

exit 0