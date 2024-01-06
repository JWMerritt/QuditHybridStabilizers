function DeleteClusterJobs(ClusterName)
%REMOVEJOB delete all jobs from the cluster under the profile name
% <ClusterName>.
%   Instantiates a cluster using the cluster profile ClusterName, then runs
%   `delete(Cluster.Jobs)`.

MyCluster = parcluster(ClusterName);
delete(MyCluster.Jobs);

end

