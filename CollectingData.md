# Collecting data for QuditHybridStabilizers

After a calculation has been run, the final results will be contained in a `DATA` file, which will be named after the Job's name, `JobName.mat`. It contains some strings which carry information about the Job, and one struct named `Out`. Each entry in `Out` corresponds to one coice of the parameters which define the systems which are run by the Job. By default, each entry of `Out` contains the following fields:

 - `SystemSize` - the size of the system
 - `MeasurementProbability` - the probability per-site of a projective measurement
 - `InteractingProbability` - usually equal to 0; see [CreatingJobs/Parameters](https://github.com/JWMerritt/QuditHybridStabilizers/main/CreatingJobs.md#Parameters) for more information
 - `TotalTimeSteps` - the total number of time steps applied to the system
 - `SubsystemEntropy` - a cell array, containing column vectors which correspond to the subsystem entropy of the realizations calculated by `QuditStateEvol`. `Out(i).SubsystemEntropy{j}(k)` gives the average entropy of all subsystems of length `k` in the realization numbered `j` defined by the parameters given in `Out(i)`.
 - `LengthDistribution` - a cell array containing column vectors which correspond to the length distribution of the realizations. `Out(i).LengthDistribution{j}(k)` gives the total number of generators of length `k` in the realization numbered `j` defined by the parameters given in `Out(i)`. For more information, see [this paper by Li, Chen, and Fisher (2019)](https://doi.org/10.1103/PhysRevB.100.134306). Note that the Length Distribution given in this code is 1 larger than that defined in the paper, and is not normalized by system size.
 - `PurificationEntropy` - a cell containing doubles which correspond to the purification entropy of the realizations. It equals the number of zero generators in the check matrix which defines the state.
 - `Realizations` - a cell array counting the number of realizations. `Out(i).Realizations{j}` counts the number of realizations which were averaged over to give the entry `j` of the previous quantities. By default, `QuditStateEvol` records every individual realization (so that the standard deviation can be calculated), and so every entry of the cell array should equal `1`.

## Organizing the outputs

The tools provided for organizing the information from the `DATA` files are given in the `DCells` folder. 

The data is pulled from one or more `DATA` files and extracted into a cell array (called a `DCell` or `DATA Cell`) using the function `DCellConvert`. Each cell entry corresponds to one value of the parameters `SystemSize`, `MeasurementProbability`, and `InteractingProbability`. This data can then be put into vector arrays using `DCellPullData` so that they can be plotted. It also calculates the standard deviation of the data for each point.