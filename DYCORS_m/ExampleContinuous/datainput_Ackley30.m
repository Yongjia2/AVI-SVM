function Data = datainput_Ackley30
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

%30-dim ackley function



Data.xlow=zeros(1,30); %lower variable bounds
Data.xup=ones(1,30); %upper variable bounds
Data.dim=30;    %problem dimension
%objective function
Data.objfunction=@(x)myfun(x);
end %function

function y=myfun(x)
xlow=-15*ones(1,30); %variable lower bounds
xup=30*ones(1,30); %variable upper bounds
n=length(xlow);
x=xlow + (xup-xlow).*x;
y=-20*exp(-0.2*sqrt(sum(x.^2,2)/n)) - exp(sum(cos(2*pi*x),2)/n);

end %function