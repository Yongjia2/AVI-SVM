function Data = datainput_Branin

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

%Branin function
%3 global minima, no local  minima

Data.dim = 2; %problem dimension
Data.xlow=zeros(1,2);%[-5,0]; %variable lower bounds
Data.xup=ones(1,2); %[10,15]; %variable upper bounds
%objective function
Data.objfunction= @(x)myfun(x);
end

function y=myfun(x)
xlow=[-5,0]; %variable lower bounds
xup=[10,15]; %variable upper bounds
x=xlow + (xup-xlow).*x;
y=(x(:,2)-5.1*x(:,1).^2./(4*pi^2)+5*x(:,1)./pi-6).^2 + 10*(1-1/(8*pi))*cos(x(:,1))+10;

end %function