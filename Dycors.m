function [solution,value,data]=Dycors(testFunction)
addpath('DYCORS_m')
[Solution,data] = DYCORS(testFunction,200, 1,1,1);
solution = Solution.BestPoints;
value = Solution.BestValues;
data.Value = Solution.FuncVal;
data.Point = Solution.DMatrix;