# Collecting data for QuditHybridStabilizers

After a calculation has been run, the final results will be contained in a `DATA` file, which will be named after the Job's name, `JobName.mat`. It contains some strings that carry information about the Job, and one struct named `Out`. Each entry in `Out` corresponds to one coice of the parameters which define the systems which are run by the Job. By default, each entry of `Out` contains the following fields:

 - `SystemSize` - the size of the system
 - `MeasurementProbability` - the probability per-site of a projective measurement
 - `InteractingProbability` - usually equal to 0; see [CreatingJobs/Parameters](https://github.com/JWMerritt/QuditHybridStabilizers/blob/main/CreatingJobs.md#Parameters) for more information
 - `TotalTimeSteps` - the total number of time steps applied to the system
 - `SubsystemEntropy` - a cell array, containing column vectors which correspond to the subsystem entropy of the realizations calculated by `QuditStateEvol`. `Out(i).SubsystemEntropy{j}(k)` gives the average entropy of all subsystems of length `k` in the realization numbered `j` defined by the parameters given in `Out(i)`.
 - `LengthDistribution` - a cell array containing column vectors which correspond to the length distribution of the realizations. `Out(i).LengthDistribution{j}(k)` gives the total number of generators of length `k` in the realization numbered `j` defined by the parameters given in `Out(i)`. For more information, see [this paper by Li, Chen, and Fisher (2019)](https://doi.org/10.1103/PhysRevB.100.134306). Note that the Length Distribution given in this code is 1 larger than that defined in the paper, **and is not normalized by system size.**
 - `PurificationEntropy` - a cell containing doubles which correspond to the purification entropy of the realizations. It equals the number of zero generators in the check matrix which defines the state.
 - `Realizations` - a cell array counting the number of realizations. `Out(i).Realizations{j}` counts the number of realizations which were averaged over to give the entry `j` of the previous quantities. By default, `QuditStateEvol` records every individual realization (so that the standard deviation can be calculated), and so every entry of the cell array should equal `1`.

## Organizing the outputs

The tools provided for organizing the information from the `DATA` files are given in the `RData` folder. An `RData` object contains useful data and methods pertaining to data extraction. Generally, the flow goes like this:

 - In the job folder, write a .txt file containing the names of all `DATA` files that are going to be extracted.

     - These files should all be in the same location. 
     - Lines can be commented out by starting with a '#' character.
     - The names should not include the `.mat` file extension. 
     - There should be no whitespace other than newline characters, even in comments, and the file should terminate with a newline character. 

 - Run `[ROut, SuccessList, FailureList] = RDataFromList(FileList, DataDir)`, where `FileList` is the path to the `.txt` file containing the names of the `DATA` files, and `DataDir` is the path to the directory containing the `DATA` files. `ROut` will be an `RData` object with the data collected from the files.

 - Use `[N, M, I, T, Out, Reals, Sig] = ROut.pull(ARG)` to pull the data into matrices that can be plotted. `ARG` is the name of the variable to be extracted, and by default must be one of `'SubsystemEntropy'`, `'PurificationEntropy'`, or `'LengthDistribution'`. Each entry `i` of these resulting arrays represents the average results of systems with one set of parameters:

    - `N(i)` is the size of the systems
    - `M(i)` is the measurement probability value
    - `I(i)` is the interacting probability value
    - `T(i)` is the total number of time steps
    - `Out{i}` is the averaged value for the property `ARG` of the system. `Out` is a cell. For `ARG = SubsystemEntanglement, LengthDistribution`, `Out{i}(L)` describes the property at length `L`, and for `PurificationEntropy`, `Out{i}` has one element.
    - `Reals(i)` is the total number of realizations which were averaged over
    - `Sig{i}` is the standard deviation of each point, $\sqrt{\sum_i^{n} (\mu - x_i)^2/(n-1)}$. `Sig` is a cell array, and `Sig{i}(L)` is the standard deviation of `Out{i}(L)`.


