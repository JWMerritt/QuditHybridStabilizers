# Creating Jobs for QuditHybridStabilizers

Each Job has a number of quantities associated with it which must be set before the program runs.

## Structure of QuditStateEvol

Fundamentally, `QuditStateEvol` takes trivial quantum states (e.g., $Z=+1$ on all sites) and evolves them into a final *realization* which we extract quantities such as subsystem entropy from. Schematically, the code looks like this:

```
load CKPT file for the Job

load DATA file for the Job

for N in (system sizes):
    for circuit_idx in range(number of circuits):
        for p_idx in (p values):
            for q_idx in (q values):
                -parfor: evolve the states for T time steps
                -Save the unfinished state to the CKPT file
                -If state is finished, use the final realization to calculate quantities,
                then save those quantities to the DATA file.

```

To describe this in more detail, each system has a size (call it `N`) and two parameters (call them `p` and `q`) which determine the time step evolution. Each CKPT file is a *Job*, which genrally contains multiple values of `N`, `p`, and `q` which are to be calculated. The CKPT file also holds information such as which unitary operations will be applied and how many time steps to apply to each system. 

`QuditStateEvol` cycles through all parameters `N`, `p`, and `q` of the Job and calculates final states for each. It splits this calculation into *circuits*. A circuit is when the code performs a calculation for each `p` and `q` value for a fixed `N`. Since the code executes the parfor loop during each circuit, it will calculate a number of realizations per parameter value per circuit, equal to the number of parallel cores that the program is running on.

