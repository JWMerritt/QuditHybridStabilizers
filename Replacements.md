The renaming conventions I'm using:

**Stages:**
 - Make the code more readable.
    - Rename certain functions and variables
    - Add documentation and clarifying comments
 - Move C_Numbers_Int into RunOptions to place more emphasis on the bosonic features.

## New Names 

 Old name | New name
---|---
Measure | MeasureMajorana
Smetric | SymplecticMetricMajorana
SmetricBoson | SymplecticMetricBoson
SProd | SProdB / SProdM
Scell* | DCell*
Scellerize | DCellConvert
TimeStepBasic | TimeStepMajoranaBasic
TimeStepBosonic | TimeStepBosonBasic
SystemSymplecticBoson / BosonSymplectic | PairSymplecticBoson
SystemSymplecticMajorana | SymplecticMajorana
batch_code | RunBatch
run_code(<br>CKPT_Name_Fullpath,<br>RunLocation='klone_hyak'<br>\*RC=false, \*Verbose=false) | QuditStateEvol(<br>CKPT_Name_Fullpath,<br>RunLocation='mmfs1/home/...',<br>\*Verbose=false)
RealizationsPerSystemSize | CircuitsPerSystemSize
RealizationsBeforeSaving | TimeStepsBeforeSaving
Number_ParallelRealizations | Number_ParallelStates
C_Numbers_Int | C_Numbers_Hdim
make_batch_ckpts.m | Create_Jobs.m
CliffordSymplecticMajorana.m | CNumToMajSymplectic.m

To test:
subPeriod<0 for fermions and bosons.