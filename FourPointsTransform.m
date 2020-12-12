function Hs2i = FourPointsTransform(Ps,Pi)
%FOURPOINTSTRANSFORM create 2D homogeneous matrix which transform coordinate wrt scene (calibration box) to image
% Syntax
%       Hs2i = FourPointsTransform(Ps,Pi);
%       Hi2s = FourPointsTransform(Pi,Ps);
%
% Description
%   Formula
%       k*[Pi 1] = [Ps 1] * Hs2i;  k is a scaling factor (not equal to zero)
%
%   Input
%       Ps - four points' coordinate wrt scene coordinate system    << numeric >>   [4*2] or [n*2]
%       Pi - four points' coordinate wrt image coordinate system    << numeric >>   [4*2] or [n*2]
%   Output
%       Hs2i - homogeneous matrix                                   << numeric >>   [3*3]
%
% See Also
%       http://franklinta.com/2014/09/08/computing-css-matrix3d-transforms/
%       tform = fitgeotrans(Ps,Pi,'projective');
%
% Jia-Da Li, Institute of information science, Academia Sinica, 12 Dec, 2020
n = size(Ps,1);
if n==4
    A = zeros(8,8);
    A(1:4,1:2) = Ps;
    A(1:4,3) = 1;
    A(1:4,7:8) = -Pi(:,1)*[1 1].*Ps;
    A(5:8,4:5) = Ps;
    A(5:8,6) = 1;
    A(5:8,7:8) = -Pi(:,2)*[1 1].*Ps;
    Hs2i = ones(3); % [3*3]
    Hs2i(1:8) = A\Pi(:);
else
    % coordinate normalization
    ts = sum(Ps,1)/n;
    ti = sum(Pi,1)/n;
    rs = range(Ps,1)/2;
    ri = range(Pi,1)/2;
    Ps = (Ps - ts)./rs; % offset centroid and normalization
    Pi = (Pi - ti)./ri; % offset centroid and normalization
    
    A = zeros(n*2,8);
    ix = 1:n;
    A(ix,1:2) = Ps;
    A(ix,3) = 1;
    A(ix,7:8) = -Pi(:,1)*[1 1].*Ps;
    
    ix = n+1:n*2;
    A(ix,4:5) = Ps;
    A(ix,6) = 1;
    A(ix,7:8) = -Pi(:,2)*[1 1].*Ps;
    
    Hs2i = ones(3); % [3*3]
    Hs2i(1:8) = A\Pi(:);
    Ts = [1/rs(1) 0 0; 0 1/rs(2) 0; -ts./rs 1];
    iTi = [ri(1) 0 0; 0 ri(2) 0; ti 1];
    Hs2i = Ts*Hs2i*iTi; % restore H
    Hs2i = Hs2i/Hs2i(9);
end
end