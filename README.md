# QuditHybridStabilizers
Stabilizer code for simulation of qudits of prime order $d$ under hybrid dynamics, including random Clifford unitary gates and projective measurements.
This code was used to produce results used chapter 3 of my dissertation, [Measurement-Induced Phase Transitions](https://www.proquest.com/docview/2838107649). 
Also includes ability to simulate Majorana fermions and parafermions with a modified stabilizer formalism.

This repo includes all the files necessary to set up and run a job on the [HYAK](https://hyak.uw.edu) cluster at the University of Washington.

## Background

The *stabilizer formalism* is a way of representing a class of quantum states called *stabilizer states* in a way that is effecient for classical computers to work with. A stabilizer state of $N$ qubits is implicitly defined as the mutual $+1$ eigenstate of a set of operators called the *stabilizer group*, $\mathcal{S}$. Each element of the stabilizer group is a *Pauli string*, which is an operator that consistes of the tensor product of Pauli operators (and the identity) at each site. A group $\mathcal{S}$ of $2^N$ commuting Pauli strings will uniquely define such a stabilizer state, up to an overall factor. $\mathcal{S}$ can be uniquely defined through a *generating set* of $N$ independent operators such that any element of $\mathcal{S}$ is equal to the product of some number of generators in the generating set.

This can be efficiently represented on a classical computer. By writing the Pauli matrix ${Y = -iZX}$ as a product of the Pauli $x$ and $z$ operators, a Pauli string on $N$ sites can be represented as a string of $2N$ digits of 0 and 1, plus an overall multiplicative factor. The digits refer to the exponent of the Pauli $Z$ and $X$; e.g. ${X = Z^0 X^1 \sim [0,1]}$, ${Y = i Z^1 X^1\sim i[1,1]}$. Therefore, the generating set can be represented as $2N^2$ integers (and $N$ constants), which defines the state using far fewer than the generally required $2^N$ real numbers.

If the evolution of our quantum state is such that the state can always be represented as a stabilizer state, then we can calculate that evolution efficiently on classical computers. Unitary operations which map stabilizer states to stabilizer states are called *Clifford unitaries*. When the Pauli strings are represented as a vector of exponents as described above, then a Clifford unitary operation takes the form of a *symplectic matrix* acting on the vector. In addition, taking the projective measurement of a Pauli operator (or generally, any Pauli string) will also map stabilizer states to stabilizer states.

This formalism can be generalized to qudits. Qudits are like qubits, but have more internal states. Instead of having a 2-dimensional local Hilbert space, they have a $d$-dimensional local Hilbert space. This code only focuses on the case when $d$ is a prime number.

We can also generalize this formalism to fermions using *Majorana operators*. Majorana operators $\gamma_i$ act like the Pauili $X$ and $Y$ operators, except that they anticommute with Majorana operators at different sites. Effectively, this changes the symplectic metric which is used to define symplectic matrices, but the rest of the math works out to be roughly the same.

Lastly, we can combine the two generalizations into a *parafermion* Majorana stabilizer representation, where the Majorana operators have order $d$ i.e., $\gamma^d = 1$.

## The simulated experiment

This code simulates the setup defined in [this paper by Li, Chen, and Fisher (2019)](https://doi.org/10.1103/PhysRevB.100.134306). Each time step is defined by four operations:

 - A layer of Clifford unitary gates on odd pairs of sites i.e., sites $(1,2)$, $(3,4)$, ...
 - A set of projective measurements onto the Pauli Z basis. Every site has a probability $p$ of being measured at this step.
 - A layer of Clifford unitary gates on even pairs of sites with periodic boundary conditions i.e., sites $(2,3)$, $(4,5)$, ..., $(N,1)$
 - A final set of projective measurements, where each site again has a probability $p$ of being measured.

After a certain amount of time steps, the subsystem entanglement entropy is measured for contiguous regions of the system. It is found that this entropy undergoes a phase transition as the value of $p$ is increased from $0$.

# How the code works

Details on creating and running jobs can be found in the file [CreatingJobs.md](https://github.com/JWMerritt/QuditHybridStabilizers/blob/main/CreatingJobs.md)

The basic action of the code is to:
- create an initial trivial state
- apply unitary and projective measurements to the state for a certain number of time steps
- extract quantites such as the subsystem entropy from the final state.

The user can define their own unitary operations and time steps, but the basic ones implement a Clifford unitary on pairs of sites (which are really symplectic matrices in the calculation) and perform projective measurements.

This code was designed to work on the [HYAK](https://hyak.uw.edu) supercomputer at the Unviersity of Washington. In particular, it was designed to work on the Checkpoint (CKPT) queue, in which the job runs on resources that are not being used by any other jobs. While this means that one can theroetically load many jobs at once wihtout guilt, since any other job will take priority, it also means that the program could be killed at any time. Thus, the state of the calculation is regularly saved to a file (called the `CKPT` file of the Job) from which it can be loaded. 

The code is parallelized to make use of multiple cores using MATLAB `parfor` loops. The expected number of cores can be set when the Job is set up.

## Details

Each Job has the following files associated with it:
 - A `CKPT` file, which holds the information pertaining to the calculation, any partially completed systems, and the locations of all the other relevant files.
 - A `DATA` file, where the final data is saved.
 - A `diary` file, where the output of the running code is saved.
 - A `Cluster` folder, which holds the information of a MATLAB parcluster associated with the job.

Because HYAK uses Slurm to queue jobs, and the job could be killed at any time, this code resorts to setting up an independent parallel cluster profile for each job.

The calculation is run by running the function `QuditStateEvol(CKPT_FILE, CODE_PATH)`, where `CKPT_FILE` is the full path/file name (without .mat extension) of the Job's `CKPT` file, and `CODE_PATH` is the location of the folder for this repo containing QuditStateEvol and its dependencies.

A couple of helper functions have been included for this. `Create_Jobs` is a function that formalizes creating all of the necessary variables and creating the Jobs. `RunBatch` is a function that initializes the `parcluster` and then batches `QuditStateEvol`. Using these helper functions, the Job also has:

 - A `JobName.sh` shell script which can be batched using slurm's `squeue` command.
 - An `Output` folder which will contain the output logs from slurm.
 - An `ExitFiles` folder, which will contain a `JobName.done` file when the code has completed all of its realizations. Otherwise, the code would stay on the `CKPT` queue and do nothing except make very long output files.
