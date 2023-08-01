# Creating Jobs for QuditHybridStabilizers

Each Job has a number of quantities associated with it which must be set before the program runs.

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

## Parameters

The file [Create_Job.m](https://github.com/JWMerritt/QuditHybridStabilizers/main/Create_Job.m) gives an example of how to set up a Job. There are descriptions there for each of the necessary parameters which need to be set, but a couple of highlights are:

 - 

