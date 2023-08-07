# Creating Jobs for QuditHybridStabilizers

Each Job has a number of quantities associated with it which must be set before the program runs. For more information extracting the data out of the final `DATA` file, see [CollectingData.md](https://github.com/JWMerritt/QuditHybridStabilizers/blob/main/CollectingData.md)

## Structure of QuditStateEvol

Fundamentally, `QuditStateEvol` takes trivial quantum states (e.g., $Z=+1$ on all sites) and evolves them into a final *Realization* from which we extract quantities such as subsystem entropy from. Schematically, the code looks like this:

```
load CKPT file for the Job

load DATA file for the Job from address in CKPT file

for N in (system sizes):
    for circuit_idx in range(number of circuits):
        for p_idx in (p values):
            for q_idx in (q values):
                -parfor: evolve the States for T time steps
                -Save the unfinished State to the CKPT file
                -If State is finished, calculate quantities using the final Realization
                then save those quantities to the DATA file.

```

To describe this in more detail, each system has a size (call it `N`) and two parameters (call them `p` and `q`) which determine the time step evolution. Each `CKPT` file describes a *Job*, which genrally contains multiple values of `N`, `p`, and `q` which are to be used for calculations. The `CKPT` file also holds information such as which unitary operations will be applied and how many time steps to apply to each system. 

`QuditStateEvol` cycles through all parameters `N`, `p`, and `q` of the Job and calculates final states for each. It splits this calculation into *circuits*. A circuit is when the code performs a calculation for each `p` and `q` value for a fixed `N`. The code executes the parfor loop during each circuit; if there are `K` cores being used, then there will be `K` Realizations per circuit.

Once a circuit has been completed and we have a nubmer of realizations, the relevant quantities (such as subsystem entanglement entropy) are extracted, and saved to the Job's `DATA` file. This file will contain the final results of the Job's calculations.

## Parameters

The file [Create_Jobs.m](https://github.com/JWMerritt/QuditHybridStabilizers/blob/main/Create_Jobs.m) gives an example of how to set up a Job. It includes a list of necessary parameters and a description of each. The most important system parameters are:

 - `Hdim` - the on-site local Hilbert space dimension (i.e., the number of states per qudit). Should always be a prime integer.
 - `SystemSizeValues` - a double array of system sizes.
 - `MeasurementProbabilityValues` - a double array of values between 0 and 1. This sets the probabilty of each site to be measured, as described in the README file
 - `InteractingProbabilityValues` - a double array of values between 0 and 1. This is only used by the unitary function `Free_Interacting_Unitary` for $d=2$ Majorana fermions, where the Clifford unitary gates are separated into free and interacting gates. However, this can be modified by a user-defined unitary function to be whatever extra parameter is needed.
 - `StatisticsType` - a char array equal to either 'Boson' or 'Fermion', depending on the type of system which is to be simulated.
 - `TotalTimeSteps` - a double array of the same size as `SystemSizeValues`. It is total number of time steps to apply to each system, and each entry corresonds to the same entry in `SystemSizeValues`.
 - `TimeStepsPerSave` - a double array of the same size as `SystemSizeValues`. It is number of time steps to apply to each system before saving the current state in the `CKPT` file, and each entry corresonds to the same entry in `SystemSizeValues`. 

    - Note that `TimeStepsPerSave` can be negative. If it has a value of `-T` for a system of size `N`, then the system is run for `N` time steps, and this is done `T` times before saving the results in the `DATA` file. This is helpful on smaller systems, since it reduces the overhead of entering and exiting the `parfor` loop when the realizations take a short amount of time to compute.
