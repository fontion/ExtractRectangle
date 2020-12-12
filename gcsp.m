function sp = gcsp(idx)
%GCSP get current screen position
% Jia-Da Li, Institute of information science, Academia Sinica, 12 Dec, 2020
sp = get(0,'MonitorPosition');
if ~isvector(sp)
	pl = get(0,'PointerLocation');
    xmin = sp(:,1);
    xmax = sp(:,1) + sp(:,3);
    ymin = sp(:,2);
    ymax = sp(:,2) + sp(:,4);
    lg = pl(1) >= xmin & pl(1) < xmax & pl(2) >= ymin & pl(2) < ymax;
    sp = sp(lg,:);
end
if nargin > 0
    sp = sp(idx);
end
end