function output = phi(r,type)
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
% determines phi-value of distance r between 2 points (depends on chosen RBF
% model
%
% Input:
% r: distance between 2 points
% type: RBF model type
%
% Output: 
% output: phi-value according to RBF model
%--------------------------------------------------------------------------

switch type
case 'linear'
    output = r;
case 'cubic'
    output = r.^3;
case 'thinplate'
    if (r >= 0)
        output = (r.^2).*log(r+realmin);
    else
        output = zeros(size(r));
    end
otherwise
    disp('Error: Unknown type.');
    return;
end

end  % function