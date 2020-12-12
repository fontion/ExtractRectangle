function lg = isnumletter(s)
%ISNUMLETTER check if input string is a numeric letter of each element
% Jia-Da Li, Institute of information science, Academia Sinica, 12 Dec, 2020
siz = size(s);
n = prod(siz);
s = double(s(:))*ones(1,10);
p = ones(n,1)*(48:57);
lg = any(s==p,2);
lg = reshape(lg,siz);
end