function [height,width,ratio] = usual_paper_size(name,vertical)
%USUAL_PAPER_SIZE Output usual paper size
% Syntax
%       [height,width] = usual_paper_size(name)
%       [height,width,ratio] = usual_paper_size(name,true)
%
% Description
%   Input
%       name - paper name, A0-A10, B0-B10, C0-C10               << char >>      '1*2' or '1*3'
%       vertical - If true, output height greater than width.   << logical >>   [1*1]
%   Output
%       height - paper height (unit: millimeter)                << double >>    [1*1]
%       width - paper width (unit: millimeter)                  << double >>    [1*1]
%       ratio - ratio of height and width (height/width)        << double >>    [1*1]
%
% Jia-Da Li, Institute of information science, Academia Sinica, 7 Sep, 2020
height = [];  width = [];  ratio = [];
if ~isempty(name)
    switch upper(name(1))
        case 'A' % Dimensions Of A Series Paper Sizes
            dim = [841, 1189; % A0
                594, 841; % A1
                420, 594; % A2
                297, 420; % A3
                210, 297; % A4
                148, 210; % A5
                105, 148; % A6
                74, 105;  % A7
                52, 74;   % A8
                37, 52;   % A9
                26, 37];  % A10
        case 'B' % Dimensions Of B Series Paper Sizes
            dim = [1000, 1414; % B0
                707, 1000; % B1
                500, 707;  % B2
                353, 500;  % B3
                250, 353;  % B4
                176, 250;  % B5
                125, 176;  % B6
                88, 125;   % B7
                62, 88;    % B8
                44, 62;    % B9
                31, 44];   % B10
        case 'C' % Dimensions Of C Series Envelope Sizes
            dim = [917, 1297; % C0
                648, 917; % C1
                458, 648; % C2
                324, 458; % C3
                229, 324; % C4
                162, 229; % C5
                114, 162; % C6
                81, 114;  % C7
                57, 81;   % C8
                40, 57;   % C9
                28, 40];  % C10
        otherwise
            warning('Unexpect series of paper, output empty value')
            return
    end
    
    siz = eval(name(2:end)) + 1;
    dim = dim(siz,:);
    if vertical
        height = dim(2);
        width = dim(1);
    else % paper orientation: horizontal
        height = dim(1);
        width = dim(2);
    end
    ratio = height/width;
end
end

