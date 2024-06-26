function Data = DYCORS_opt(Data,maxeval,NumberNewSamples)
%----------------********************************--------------------------
% Copyright (C) 2014 Cornell University
% This file is part of the program DYCORS.m
%
%    DYCORS.m is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    DYCORS.m is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with DYCORS.m.  If not, see <http://www.gnu.org/licenses/>.
%----------------********************************--------------------------
%
%
%
%----------------*****  Contact Information *****--------------------------
%   Primary Contact (Implementation Questions, Bug Reports, etc.):
%   Juliane Mueller: juliane.mueller2901@gmail.com
%       
%   Secondary Contact:
%       Christine A. Shoemaker: cas12@cornell.edu
%
%----------------********************************--------------------------
%--------------------------------------------------------------------------
% DYCORS_opt is the local optimization routine. It iterates at most
% until totally maxeval points have been evaluated, or, if a local minimum
% has been found, the routine terminates in less than maxeval evaluations,
% but will restart from scratch to use up all remaining function evaluation
% points.
%
% Input: 
% Data: struct-variable with problem information (variable bounds,
%       objective/simulation function handle, etc.)
% maxeval: maximum number of function evaluations for each trial
% NumberNewSamples: number of points where objective/simulation function
%                   is evaluated in every iteration of the algorithm; if
%                   NumberNewSamples > 1, evaluations are in parallel, in
%                   which case Matlab Parallel Computing Toolbox is
%                   required.
%
% Output:
% Data: updated struct-variable containing the results of the current run
%       until stop at local minimum, or stop after maxeval evaluations
%--------------------------------------------------------------------------

xrange = Data.xup - Data.xlow;  % variable range in every dimension
minxrange = min(xrange);  % smallest variable range
m = size(Data.S,1);  % number of points already sampled

% scale design points to actual dimensions (初始是实在[0,1]区间产生的，这里把初始点放缩为实际大小)
Data.S = repmat(Data.xup-Data.xlow,m,1).*Data.S + repmat(Data.xlow,m,1);

% initialize arrays
% evaluate experimental design points
Data.m = min(m,maxeval);  % in case number of point in initial experimental design exceed max. number of allowed evaluations
Data.fevaltime = zeros(maxeval,1);  % initialize vector with time for function evaluations
Data.Y = zeros(maxeval,1);  % initialize array with function values
Data.S = Data.S(1:Data.m,:);  % in case Data.m > maxeval, throw additional points away
Data.S(Data.m+1:maxeval,:) = 0;  % initialize array with sample points (first Data.m points are from initial experimental design)

% for serial evaluation of points in initial starting design:
%------------------------ SERIAL ------------------------------------------
for ii = 1:Data.m  % go through all Data.m points
    time1 = tic;  % start timer for recording function evaluation time
    Data.Y(ii,1) = feval(Data.objfunction,Data.S(ii,:));  % expensive simulation
    Data.fevaltime(ii) = toc(time1);  % record time for expensive evaluation
    
    if ii == 1  % initialize best point found so far = first evaluated point
        Data.xbest=Data.S(ii,:);  % best point
        Data.Fbest=Data.Y(ii);  % best objective function value
    elseif Data.Y(ii) < Data.Fbest  % update best point found so far if necessary
        Data.Fbest=Data.Y(ii);  % best objective function value
        Data.xbest=Data.S(ii,:);  % best point
    end
    
end
%-------------------- END SERIAL ------------------------------------------

% for parallel evaluation of points in initial starting design delete
% comments in the following and comment out the serial code above
%------------------------ PARALLEL ----------------------------------------
% m=Data.m;
% Y=Data.Y;
% S=Data.S;
% ObjFunction=Data.objfunction;
% Time=Data.fevaltime;
% 
% parfor ii = 1:m %go through all Data.m points
%     time1 = tic; %start timer for recording function evaluation time
%     Y(ii,1) = feval(ObjFunction,S(ii,:)); %expensive simulation
%     Time(ii) = toc(time1); %record time for expensive evaluation
% end
% 
% [Data.Fbest, IDfbest]=min(Y(1:m));
% Data.xbest=S(IDfbest,:); %best point
%         
% Data.Y=Y;
% Data.fevaltime=Time;
%---------------------- END PARALLEL --------------------------------------
    
% determine pairwise distance between points
PairwiseDistance=pdist2(Data.S(1:Data.m,:),Data.S(1:Data.m,:));  % 计算采样点之间的（欧氏）距离，返回距离矩阵
 
% initial RBF matrices
[PHI,phi0,P,pdim] = InitialRBFMatrices(maxeval,Data,PairwiseDistance);

% tolerance parameters
Data.tolerance= 0.001*minxrange*norm(ones(1,Data.dim));    % tolerance for deciding when two points coincide

% algorithm parameters
sigma_stdev_default = 0.2*minxrange;  % page537  0.2 * L(D)
sigma_stdev = sigma_stdev_default;  % current mutation rate 
maxshrinkparam = 6;  % maximal number of shrinkage of standard deviation for normal distribution when generating the candidate points
failtolerance = max(5,Data.dim);
succtolerance = 3;

% initializations
iterctr = 0;  % number of iterations 迭代次数
shrinkctr = 0;  % number of times sigma_stdev was shrunk 扰动标准差收缩次数
failctr = 0;  % number of consecutive unsuccessful iterations 连续失败次数
localminflag = 0;  % indicates whether or not xbest is at a local minimum 指出xbest是否是局部最优值
succctr = 0;  % number of consecutive successful iterations 连续成功次数
weightpattern = [0.3,0.5,0.8,0.95];  % weight for the response surface criterion
% do until max number of f-evals reached or local min found
while Data.m < maxeval && localminflag == 0
    iterctr = iterctr + 1;  % increment iteration counter
    mw = mod(iterctr,length(weightpattern));
    if mw==0
        w_r=weightpattern(end);  % weight for the response surface criterion 响应面准则权重
    else
        w_r=weightpattern(mw);  % weight for the response surface criterion
    end
    fprintf('\n Iteration: %d \n\n',iterctr);
    fprintf('\n Best function value in this restart: %d \n', Data.Fbest);
    % number of new samples in an iteration
    NumberNewSamples=min(NumberNewSamples,maxeval-Data.m);  % 新采样点个数不能超出估值次数
    
    % replace large function values by the median of all available function values
    Ftransform = Data.Y(1:Data.m);
    medianF = median(Data.Y(1:Data.m));  % 返回中位数
    Ftransform(Ftransform>medianF) = medianF;  % 为什么将大于中位数的函数值换成中位数
    
    % fit the response surface
    % Compute RBF parameters
    a = [PHI(1:Data.m,1:Data.m),P(1:Data.m,:);P(1:Data.m,:)',zeros(pdim)];
    eta = sqrt((10^-16) * norm(a, 1) * norm(a, inf));
    coeff = (a + eta * eye(Data.m + pdim)) \[Ftransform;zeros(pdim,1)];
    Data.lambda = coeff(1:Data.m);
    Data.ctail = coeff(Data.m+1:Data.m+pdim);
              
    
    % select the next function evaluation point by DYCORS perturbation:
    % Perturbation probability
    DDSprob = min(20/Data.dim,1)*(1-(log(Data.m-2*(Data.dim+1)+1)/log(maxeval-2*(Data.dim+1))));  % page535 倒数第二段  其中 n0=2*（Data.dim+1）
    % create candidate points
    CandPoint = repmat(Data.xbest,Data.Ncand,1); 
    for ii =1:Data.Ncand
        r=rand(1,Data.dim);  
        ar = r < DDSprob;  % 随机扰动坐标
        if ~(any(ar))  % 至少选择一个坐标进行扰动
            r = randperm(Data.dim);
            ar(r(1))=1;
        end
        for jj =1:Data.dim
            if ar(jj)==1
                CandPoint(ii,jj) = CandPoint(ii,jj) + sigma_stdev*randn(1) ;
                if CandPoint(ii,jj) < Data.xlow(jj)  % 候选点越过下界
                    CandPoint(ii,jj) = Data.xlow(jj)+ (Data.xlow(jj)-CandPoint(ii,jj));  % 若低于下界，则以下界为轴将函数值对称回来
                    if CandPoint(ii,jj) >Data.xup(jj)  % 若对称回来后又超出上界，则设置该点坐标为下界
                        CandPoint(ii,jj) = Data.xlow(jj);
                    end
                elseif CandPoint(ii,jj) > Data.xup(jj)  % 候选点越过上界
                    CandPoint(ii,jj) = Data.xup(jj)- (CandPoint(ii,jj)-Data.xup(jj));
                    if CandPoint(ii,jj) <Data.xlow(jj)
                        CandPoint(ii,jj) = Data.xup(jj);
                    end
                end
            end
        end
    end
    
    

    % Select the best candidate point(s)
    [xselected,normval] = Minimize_Merit_Function(Data,CandPoint,...
        NumberNewSamples,w_r);
     
    % clear unnecessary variables
    clear CandPoint;
    
    % perform function evaluation at the remaining selected point
    
    if size(xselected,1)>1  % more than one new point, do parallel evaluation
        Fselected=zeros(size(xselected,1) ,1);  % initialize arrays
        Time=zeros(size(xselected,1) ,1);
        ObjFunc=Data.objfunction;  % parfor does not work with struct-variable
        parfor ii =1:size(xselected,1)  % parallel for loop
            time1 = tic;  % record time for every function evaluation
            Fselected(ii,1) = feval(ObjFunc,xselected(ii,:));
            Time(ii,1)=toc(time1);
        end
        % update data arrays
        Data.fevaltime(Data.m+1:Data.m+size(xselected,1),1) = Time;
        Data.S(Data.m+1:Data.m+size(xselected,1),:)=xselected;
        Data.Y(Data.m+1:Data.m+size(xselected,1),1)=Fselected;
        Data.m=Data.m+size(xselected,1);  % update the number of function evaluations  
    else  % only one new point
        time1 = tic;  % record time for every function evaluation
        Fselected = feval(Data.objfunction,xselected);
        Data.m=Data.m+1;  % update the number of function evaluations
        Data.fevaltime(Data.m,1) = toc(time1);
        Data.S(Data.m,:)=xselected;
        Data.Y(Data.m,1)=Fselected;
    end
        
    
    % determine best one of newly sampled points
    [minSelected,IDminSelected]=min(Fselected);  
    xMinSelected=xselected(IDminSelected,:);
    if minSelected < Data.Fbest  % update best point found so far if necessary
        if (Data.Fbest - minSelected) > (1e-3)*abs(Data.Fbest)  % 目标函数具有千分之一的改进
            % "significant" improvement
            failctr = 0;  % 设置失败次数为0
            succctr=succctr+1;  % 成功次数+1
        else
            % no "significant" improvement
            failctr = failctr + 1;
            succctr=0;
        end  
        Data.xbest = xMinSelected;  % best point found so far
        Data.Fbest = minSelected;  % best objective function value found so far
    else
        failctr = failctr + 1;
        succctr=0;
    end

    
    % check if algorithm is in a local minimum
    shrinkflag = 1;  % shrinkflag 是扰动标准差是否收缩的标志（开关）：1 代表没有陷入局部最优，0 代表陷入局部最优
    if failctr >= failtolerance  % check how many consecutive failed improvement trials
        if shrinkctr >= maxshrinkparam
            shrinkflag = 0;
            disp('Stopped reducing sigma because the maximum reduction has been reached.');
        end
        failctr = 0;
        
        if shrinkflag == 1
            shrinkctr = shrinkctr + 1;
            sigma_stdev = sigma_stdev / 2;
            disp('Reducing sigma by half!');
        else  
            localminflag = 1;
            disp('Algorithm is probably in a local minimum! Restarting the algorithm from scratch.');  % from scratch：从头开始
        end
    end

    if succctr >= succtolerance  % check if number of consecutive improvements is large enough
        sigma_stdev = min(2*sigma_stdev,sigma_stdev_default);  % increase search radius
        succctr=0;
    end
    
    % update PHI matrix only if planning to do another iteration
    if Data.m < maxeval && localminflag == 0
        n_old = Data.m - size(xselected,1);
        for kk =1:size(xselected,1)
            new_phi = phi(normval{kk},Data.phifunction);
            PHI(n_old+kk,1:n_old+kk-1) = new_phi;
            PHI(1:n_old+kk-1,n_old+kk) = new_phi';
            PHI(n_old+kk,n_old+kk) = phi0;
            P(n_old+kk,2:Data.dim+1) = xselected(kk,:);
            clear new_phi;
        end
    end
    
end
  
% collect only the data for actual function evaluations that have been done
% (Data.m may be lower than maxeval, in which case the algorithm restarts)
Data.S=Data.S(1:Data.m,:);
Data.Y=Data.Y(1:Data.m,:);
Data.fevaltime=Data.fevaltime(1:Data.m,:);
Data.NumberFevals=Data.m;


end  % function