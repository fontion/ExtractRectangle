function varargout = ExtractRectangle(varargin)
% EXTRACTRECTANGLE MATLAB code for ExtractRectangle.fig
%      EXTRACTRECTANGLE, by itself, creates a new EXTRACTRECTANGLE or raises the existing
%      singleton*.
%
%      H = EXTRACTRECTANGLE returns the handle to a new EXTRACTRECTANGLE or the handle to
%      the existing singleton*.
%
%      EXTRACTRECTANGLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXTRACTRECTANGLE.M with the given input arguments.
%
%      EXTRACTRECTANGLE('Property','Value',...) creates a new EXTRACTRECTANGLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ExtractRectangle_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ExtractRectangle_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Jia-Da Li, Institute of information science, Academia Sinica, 12 Dec, 2020

% Edit the above text to modify the response to help ExtractRectangle

% Last Modified by GUIDE v2.5 05-Nov-2020 00:00:56

% Begin initialization code - DO NOT EDIT
normalstart = true;
if isappdata(groot,mfilename)
    mainfig = getappdata(groot,mfilename);
    figure(mainfig)
    handles = guidata(mainfig);
    if isfield(handles,'view1')
        figure(handles.view1)
    end
    normalstart = false;
end
if normalstart
    gui_Singleton = 1;
    if strcmp(computer,'GLNXA64')
        gui_Name = [mfilename '_linux'];
    else % windows platform
        gui_Name = mfilename;
    end
    gui_State = struct('gui_Name',       gui_Name, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @ExtractRectangle_OpeningFcn, ...
        'gui_OutputFcn',  @ExtractRectangle_OutputFcn, ...
        'gui_LayoutFcn',  [] , ...
        'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end
    
    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
end
% End initialization code - DO NOT EDIT
end


% --- Executes just before ExtractRectangle is made visible.
function ExtractRectangle_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ExtractRectangle (see VARARGIN)

% Choose default command line output for ExtractRectangle
handles.output = hObject;
handles.mainpath = fileparts(mfilename('fullpath'));
addpath(handles.mainpath)
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ExtractRectangle wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = ExtractRectangle_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% wkpFcn = @(~,eventdata) WindowKeyPressFcn(hObject,eventdata);
figpos = FigurePosition(hObject);
set(hObject,'visible','on','outerposition',figpos); % let main figure on focus after start-up
set_unit_to_normalized(handles)
setCallback_mainfig(handles)
Initial_UI(handles)
% Update handles structure
guidata(hObject, handles);
setappdata(groot,mfilename,hObject)
end

function set_unit_to_normalized(handles)
figpos = get(handles.figure1,'position');
% orientation button group
h = [handles.portrait, handles.landscape];
set(h,'unit','normalized')
% paper dimension button group
h = [handles.default_size, handles.auto_size, handles.custom_size, handles.papersize_menu, handles.btngroup_orientation, ...
    handles.text_height, handles.text_width, handles.height_value, handles.width_value, handles.text_unit, handles.unit_menu];
set(h,'unit','normalized')
% settings panel
h = [handles.text_algorithm, handles.text_filetype, handles.algorithm_menu, handles.filetype_menu];
set(h,'unit','normalized')
% top level items
tags = {'text_impath','text_outputRes','text_percent','impath_value','resolution_value','btngroup_paper','panel_setting',...
    'browse_btn','rotim_btn','rectangle_btn','white_btn','export_btn'};
for i=1:length(tags)
    if ~strcmp(get(handles.(tags{i}),'unit'),'pixels')
        error('Unexpect item units')
    end
    pos = get(handles.(tags{i}),'position');
    pos(1:2) = pos(1:2) - 1;
    pos = pos./figpos([3,4,3,4]);
    set(handles.(tags{i}),'unit','normalized','position',pos)
end
end

function setCallback_mainfig(handles)
% image_path_callback
set(handles.impath_value,'Callback',@impath_value_Callback)
set(handles.browse_btn,'Callback',@browse_btn_Callback)
% let all figure on top
set(handles.btngroup_paper,'ButtonDownFcn',@figOnTop)
% paper size select changed callback
set(handles.btngroup_paper,'SelectionChangedFcn',@papersize_SelectionChangedFcn)
% orientation selection changed callback
set(handles.btngroup_orientation,'SelectionChangedFcn',@orientation_SelectionChangedFcn)
% paper size menu
set(handles.papersize_menu,'Callback',@papersize_menu_Callback)
% edit box
set([handles.height_value, handles.width_value, handles.resolution_value],'Callback',@value_Callback)
% buttons
set(handles.rotim_btn,'Callback',@rotim_btn_Callback)
set(handles.rectangle_btn,'Callback',@rectangle_btn_Callback)
set(handles.white_btn,'Callback',@white_btn_Callback)
set(handles.export_btn,'Callback',@export_btn_Callback)
% figure1_CloseRequestFcn
set(handles.figure1,'WindowKeyPressFcn',@WindowKeyPressFcn,'CloseRequestFcn',@figure1_CloseRequestFcn)
end

function figOnTop(hObject,~)
handles = guidata(hObject);
SelectionType = get(handles.figure1,'SelectionType');
if strcmp(SelectionType,'open') && isfield(handles,'view1')
    figure(handles.view1)
end
end

function Initial_UI(handles)
% initial Unit menu (set "UserData" as "Value")
set(handles.unit_menu,'UserData',get(handles.unit_menu,'Value'))
% initial rotation angle: 0 degree
set(handles.rotim_btn,'UserData',0)
% inital height and width
set([handles.height_value, handles.width_value],'UserData','')
% set paper size menu content
ps = cell(11,3);
for c=1:3
    for n=0:10
        ps{n+1,c} = sprintf([char(64+c) '%d'],n);
    end
end
hObject = handles.papersize_menu;
set(hObject,'string',ps(:),'value',find(strcmp('A4',ps(:)))) % set default value
feval(get(hObject,'Callback'),hObject)
% Assign Paper Dimension
h = [handles.text_height, handles.text_width, handles.height_value, handles.width_value, handles.text_unit, handles.unit_menu];
set(h,'Enable','off')
set(handles.auto_size,'value',1)
eventdata = struct('OldValue',handles.default_size, 'NewValue',handles.auto_size); % select "Auto Detect Paper Size"
papersize_SelectionChangedFcn(handles.figure1,eventdata) % trigger Selection Changed Callback
% Rotate Image
% set(handles.rotim_btn,'String','<html><center>Rotate Image<br>Current 270 degree</center>') % https://www.mathworks.com/matlabcentral/answers/12349-gui-buttons-with-two-rows
end

function figpos = FigurePosition(mainfig)
% compute figure outerposition

% get current screen position
sp = gcsp;
figpos = get(mainfig,'position');
if strcmp(computer,'GLNXA64') % Linux platform (test on ubuntu 20.04)
    taskbar_width = 52;
    topbar_height = 27;
    figpos(1) = sp(1)+taskbar_width;
    figpos(2) = round(sp(2)+(sp(4)-topbar_height)/2-figpos(4)/2);
    figpos(4) = figpos(4) + 37; % WindowTitle(37)
else % windows platform
    osver = system_dependent('getwinsys');
    taskbar_height = 40;
    if strcmp(osver(1:11),'Version 6.1') % Windows 7
        innerborder = 8;
        outerborder = 0;
    else % Windows 8 and later version
        innerborder = 1;
        outerborder = 7; % left bottom and right border of window (top outerborder and innerborder = 0)
        Bo = outerborder*[-1 -1 2 1];
    end
    if isequal(sp,get(0,'ScreenSize')) % has taskbar
        sp([2 4]) = sp([2 4]) + taskbar_height*[1 -1];
    end
    figpos(1) = sp(1);
    figpos(2) = round(sp(2)+sp(4)/2-figpos(4)/2);
    figpos(3) = figpos(3) + 2*innerborder;
    figpos(4) = figpos(4) + 30 + 2*innerborder; % WindowTitle(30)
    
    if outerborder~=0
        figpos = figpos + Bo;
    end
end
end

function view1 = ShowImage(X,mainfig,view1,deg)
[imageH,imageW,~] = size(X);
sp = gcsp;
mainfigpos = get(mainfig,'Position');
if strcmp(computer,'GLNXA64') % Linux platform (test on ubuntu 20.04)
    taskbar_width = 52;
    topbar_height = 27;
    x2 = mainfigpos(1)+mainfigpos(3); % right end of mainfig
    scrW1 = sp(3) - taskbar_width;
    scrW2 = scrW1 - max(0,x2-sp(1)-taskbar_width);
    scrH = sp(4) - (topbar_height+37); % window title (37)
    % scrH = sp(4) - (topbar_height+37+25+30); % window title (37), menubar(25), figure toolbar(30)
    avoid_overlap = mainfigpos(1) <= sp(1)+taskbar_width; % main figure already at most left position to avoid overlapping
    if avoid_overlap
        scrW = scrW2;
    else
        scrW = scrW1;
    end
    if scrH/scrW < imageH/imageW % figure border touch screen top-down boundary
        H = scrH;
        W = ceil(H/imageH*imageW);
        left = sp(1) + taskbar_width + floor((scrW1 - W)/2);
        bottom = sp(2);
        if left < x2 % main figure overlap with image figure
            if avoid_overlap % main figure already at most left position to avoid overlapping
                left = max(x2,sp(1)+taskbar_width);
            end
        end
        scr2pixel = imageH/H;
    else % figure border touch screen left-right boundary
        W = scrW;
        if avoid_overlap % main figure already at most left position to avoid overlapping
            left = max(x2,sp(1)+taskbar_width);
        else
            left = sp(1)+taskbar_width;
        end
        H = ceil(W/imageW*imageH);
        bottom = sp(2) + floor((scrH - H)/2);
        scr2pixel = imageW/W;
    end
else
    if isequal(sp,get(groot,'ScreenSize')) % has taskbar
        taskbar_height = 40;
    else
        taskbar_height = 0;
    end
    osver = system_dependent('getwinsys');
    if strcmp(osver(1:11),'Version 6.1') % Windows 7
        innerborder = 8;
    else % Windows 8 or later version
        innerborder = 1;
    end
    x2 = mainfigpos(1)+mainfigpos(3)+innerborder; % right end of mainfig
    scrW1 = sp(3) - 2*innerborder;
    scrW2 = scrW1 - max(0,x2-sp(1));
    scrH = sp(4) - (30+innerborder+taskbar_height); % window title (30)
    %scrH = sp(4) - (30+28+27+innerborder+taskbar_height); % window title (30), menubar(28), figure toolbar(27)
    avoid_overlap = mainfigpos(1)-innerborder <= sp(1);
    if avoid_overlap
        scrW = scrW2;
    else
        scrW = scrW1;
    end
    if scrH/scrW < imageH/imageW % figure border touch screen top-down boundary
        H = scrH;
        W = ceil(H/imageH*imageW);
        left = sp(1) + floor((scrW1 - W)/2) + innerborder;
        bottom = sp(2) + taskbar_height+innerborder;
        if left-innerborder < x2 % main figure overlap with image figure
            if avoid_overlap % main figure already at most left position to avoid overlapping
                left = max(x2,sp(1)) + innerborder;
            end
        end
        scr2pixel = imageH/H;
    else % figure border touch screen left-right boundary
        W = scrW;
        if avoid_overlap % main figure already at most left position to avoid overlapping
            left = max(x2,sp(1)) + innerborder;
        else
            left = sp(1) + innerborder;
        end
        H = ceil(W/imageW*imageH);
        bottom = sp(2) + taskbar_height + floor((scrH - H)/2) + innerborder;
        scr2pixel = imageW/W;
    end
end
view1pos = [left bottom W H];

if nargin>=3
    set(groot,'CurrentFigure',view1)
    set(view1,'Position',view1pos)
    h_image = findobj(view1,'type','image');
    if nargin>3
        handles = guidata(mainfig);
        deg_pre = get(handles.rotim_btn,'UserData');
        ang = deg - deg_pre;
        X_pre = get(h_image,'CData');
        rot = [cosd(ang) -sind(ang) 0; sind(ang) cosd(ang) 0; 0 0 1];
        ctr_pre = [(1+size(X_pre,2))/2, (1+size(X_pre,1))/2, 1];
        ctr_new = [(1+imageW)/2, (1+imageH)/2, 1]; % rotation center
        h_extract_region = findobj(view1,'tag','extract_region');
        if ~isempty(h_extract_region)
            vtx_extract_region = get(h_extract_region,'vertices');
            vtx_extract_region = (vtx_extract_region-ctr_pre)*rot+ctr_new;
            if atand(tand(ang)) > 45 % ang may appear -270 degree, use atand to make value into [-90 90]
                vtx_extract_region = circshift(vtx_extract_region,-1,1);
            end
            edgecolor = get(h_extract_region,'edgecolor');
            delete(h_extract_region)
        end
        h_white = findobj(view1,'tag','white_region');
        if ~isempty(h_white)
            vtx_white = get(h_white,'vertices');
            vtx_white = (vtx_white-ctr_pre)*rot+ctr_new;
            UserData = get(h_white,'UserData');
            delete(h_white)
        end
    end
    delete(h_image)
else % fig = mainfig
    if strcmp(computer,'GLNXA64')
        view1 = figure('OuterPosition',view1pos+[0,0,0,37],'UserData',mainfig,'WindowKeyPressFcn',@WindowKeyPressFcn,'CloseRequestFcn',@view1CloseRequestFcn,'name',[mfilename '-view1'],'NumberTitle','off','Toolbar','none','menubar','none');
        % 使用Position會有bug，顯示的位置不是設定的位置，改用OuterPosition
    else
        view1 = figure('Position',view1pos,'UserData',mainfig,'WindowKeyPressFcn',@WindowKeyPressFcn,'CloseRequestFcn',@view1CloseRequestFcn,'name',[mfilename '-view1'],'NumberTitle','off','Toolbar','none','menubar','none');
    end
    axes('position',[0 0 1 1])
end
h_image = imshow(X);
setappdata(h_image,'scr2pixel',scr2pixel)
if nargin > 3
    if ~isempty(h_extract_region)
        h_extract_region = patch('vertices',vtx_extract_region,'faces',1:4,'edgecolor',edgecolor,'facecolor','none','tag','extract_region','UserData',handles.export_btn,'DeleteFcn',@patch_DeleteFcn);
        set(handles.view1,'WindowButtonMotionFcn',{@ButtonMotionFcn_detectVTX,h_extract_region,h_image})
        lg = validate_export_status(handles);
        % update height and width
        if lg && logical(get(handles.auto_size,'Value'))
            scale = sscanf(get(handles.resolution_value,'String'),'%f')/100;
            [nx, ny] = decide_dimension(h_extract_region,scale);
            nx = round(nx);  ny = round(ny);
            set(handles.height_value,'String',sprintf('%d',ny))
            set(handles.width_value,'String',sprintf('%d',nx))
            if ny >= nx
                if get(handles.portrait,'Value')==0
                    set(handles.portrait,'Value',1)
                end
            else
                if get(handles.landscape,'Value')==0
                    set(handles.landscape,'Value',1)
                end
            end
        end
    end
    if ~isempty(h_white)
        patch('vertices',vtx_white,'faces',1:4,'edgecolor','w','facecolor','none','tag','white_region','DeleteFcn',@patch_DeleteFcn,'UserData',UserData);
    end
end
end

function view1CloseRequestFcn(hObject,~)
mainfig = get(hObject,'UserData');
% delete figure and other graphic objects
% delete(findobj(hObject,'tag','extract_region')) % delete patch object and enable button
% delete(findobj(hObject,'tag','white_region')) % delete patch object and enable button
% delete view1
delete(hObject)
handles = guidata(mainfig);
handles = rmfield(handles,'view1');
guidata(mainfig,handles)
% Disable buttons
set(handles.rotim_btn,'Enable','off')
set(handles.rectangle_btn,'Enable','off')
set(handles.white_btn,'Enable','off')
if strcmp(get(handles.export_btn,'Enable'),'on')
    set(handles.export_btn,'Enable','off')
end
end

function WindowKeyPressFcn(hObject, eventdata)
if strcmp(get(hObject,'Name'),[mfilename '-view1'])
    handles = guidata(get(hObject,'UserData'));
else
    handles = guidata(hObject);
end
hObject = [];
switch eventdata.Key
    case 'b'
        hObject = handles.browse_btn;
    case 'r'
        if isempty(eventdata.Modifier)
            hObject = handles.rectangle_btn;
        else
            if isequal(eventdata.Modifier,{'shift'})
                hObject = handles.rotim_btn;
            end
        end
    case 'w'
        hObject = handles.white_btn;
    case 'e'
        hObject = handles.export_btn;
end

if ~isempty(hObject) && strcmp(get(hObject,'Enable'),'on')
    feval(get(hObject,'Callback'),hObject)
end
end

function impath_value_Callback(hObject,~)
handles = guidata(hObject);
str = get(hObject,'String');
A = exist(str,'file');
if A==2 % str is a file
    [folder,~,ext] = fileparts(str);
    setpref(mfilename,'lastFolder',folder)
    % update output file type
    ext = lower(ext);
    filetype = get(handles.filetype_menu,'String');
    lg = contains(filetype,ext);
    if any(lg)
        set(handles.filetype_menu,'value',find(lg))
        % Show Image
        X = imread(str);
        if isfield(handles,'view1')
            ShowImage(X,handles.figure1,handles.view1);
        else
            handles.view1 = ShowImage(X,handles.figure1);
            guidata(handles.figure1,handles)
        end
        if isequal(get(hObject,'BackgroundColor'),[1,0,0])
            set(hObject,'BackgroundColor','w','ForegroundColor','k')
        end
        % Enable buttons
        if strcmp(get(handles.rotim_btn,'Enable'),'off')
            set([handles.rotim_btn, handles.rectangle_btn, handles.white_btn],'Enable','on')
        end
        if get(handles.rotim_btn,'UserData')~=0
            set(handles.rotim_btn,'String','Rotate Image','UserData',0)
        end
        % reset white color calibration
        set(handles.white_btn,'UserData',[],'String','Pick White Color')
        % Disable Export Button
        if strcmp(get(handles.export_btn,'Enable'),'on')
            set(handles.export_btn,'Enable','off')
        end
    else
        % Disable buttons
        if strcmp(get(handles.rotim_btn,'Enable'),'on')
            set([handles.rotim_btn, handles.rectangle_btn, handles.white_btn],'Enable','off')
        end
        warndlg('Input file format is not supported','Not support')
    end
elseif A==7 % str is a folder
    if str(end)==filesep,  str(end)=[];  end
    setpref(mfilename,'lastFolder',str)
    if isequal(get(hObject,'BackgroundColor'),[1,0,0])
        set(hObject,'BackgroundColor','w','ForegroundColor','k')
    end
    % Disable buttons
    if strcmp(get(handles.rotim_btn,'Enable'),'on')
        set([handles.rotim_btn, handles.rectangle_btn, handles.white_btn],'Enable','off')
    end
else
    set(hObject,'BackgroundColor','r','ForegroundColor','w')
end
end

function browse_btn_Callback(hObject,~)
if ispref(mfilename,'lastFolder')
    inifolder = getpref(mfilename,'lastFolder');
    while ~exist(inifolder,'dir')
        inifolder = fileparts(inifolder);
    end
else
    inifolder = cd;
end
curfolder = cd;
cd(inifolder)
[filename,pathname] = uigetfile(...
    {'*.bmp;*.png;*.tif;*.tiff;*.jpg;*.jpeg','MATLAB supported images (*.bmp,*.png,*.tif,*.jpg)';...
    '*.bmp','Windows Bitmap file (*.bmp)';'*.png','Portable Network Graphics (*.png)';...
    '*.tif;*.tiff','Tagged Image File Format (*.tif,*.tiff)';...
    '*.jpg;*.jpeg','Joint Photographic Experts Group (*.jpg,*.jpeg)'});
if ischar(filename)
    handles = guidata(hObject);
    if pathname(end)==filesep,  pathname(end)=[];  end
    setpref(mfilename,'lastFolder',pathname)
    set(handles.impath_value,'String',[pathname filesep filename])
    [~,~,ext] = fileparts(filename);
    ext = lower(ext);
    filetype = get(handles.filetype_menu,'String');
    set(handles.filetype_menu,'value',find(contains(filetype,ext)))
    % trigger image_path Callback
    feval(get(handles.impath_value,'Callback'),handles.impath_value)
end
cd(curfolder)
end

function papersize_menu_Callback(hObject,~)
handles = guidata(hObject);
ps = get(hObject,'string');
val = get(hObject,'value');
vertical = get(handles.portrait,'value');
[height,width] = usual_paper_size(ps{val},vertical);
set(handles.height_value,'string',sprintf('%d',height))
set(handles.width_value,'string',sprintf('%d',width))
unit = get(handles.unit_menu,'string');
val = get(handles.unit_menu,'value');
if ~strcmp(unit{val}, 'millimeter')
    set(handles.unit_menu,'value',find(strcmp('Millimeter',unit)))
end
end

function papersize_SelectionChangedFcn(hObject,eventdata)
handles = guidata(hObject);
switch eventdata.OldValue
    case handles.default_size
        h = [handles.papersize_menu, handles.portrait, handles.landscape];
        set(h,'Enable','off')
        set(handles.btngroup_orientation,'ForegroundColor',[.5, .5, .5])
        % backup orientation
        set(handles.btngroup_orientation,'UserData', get(handles.btngroup_orientation,'SelectedObject'))
    case handles.auto_size
        % remove pixel unit
        unit = get(handles.unit_menu,'string');
        unit(strcmp('Pixel',unit)) = [];
        set(handles.unit_menu,'String',unit,'Value',length(unit))
    case handles.custom_size
        h = [handles.text_height, handles.text_width, handles.text_unit, handles.unit_menu, handles.height_value, handles.width_value];
        set(h,'Enable','off')
        % backup custom height and width)
        val = get(handles.height_value,'String');
        set(handles.height_value,'UserData',val)
        val = get(handles.width_value,'String');
        set(handles.width_value,'UserData',val)
        set(handles.unit_menu,'UserData',get(handles.unit_menu,'Value'))
end
switch eventdata.NewValue
    case handles.default_size
        h = [handles.papersize_menu, handles.portrait, handles.landscape];
        set(h,'Enable','on')
        set(handles.btngroup_orientation,'ForegroundColor','k')
        % restore orientation
        if get(handles.btngroup_orientation,'SelectedObject')~=get(handles.btngroup_orientation,'UserData')
            set(handles.btngroup_orientation,'SelectedObject', get(handles.btngroup_orientation,'UserData'))
        end
        hObject = handles.papersize_menu;
        feval(get(hObject,'Callback'),hObject)
    case handles.auto_size
        unit = get(handles.unit_menu,'string');
        lg = strcmp('Pixel',unit);
        if any(lg)
            val = find(lg);
        else
            unit{end+1} = 'Pixel';
            val = length(unit);
        end
        set(handles.unit_menu,'String',unit,'Value',val)
        % update height and width
        if isfield(handles,'view1') && ~isequal(get(handles.resolution_value,'BackgroundColor'),[1,0,0])
            h = findobj(handles.view1,'tag','extract_region');
            if ~isempty(h)
                scale = sscanf(get(handles.resolution_value,'String'),'%f')/100;
                [nx, ny] = decide_dimension(h,scale);
                nx = round(nx);  ny = round(ny);
                set(handles.height_value,'String',sprintf('%d',ny))
                set(handles.width_value,'String',sprintf('%d',nx))
                if ny >= nx
                    if get(handles.portrait,'Value')==0
                        set(handles.portrait,'Value',1)
                    end
                else
                    if get(handles.landscape,'Value')==0
                        set(handles.landscape,'Value',1)
                    end
                end
            end
        end
    case handles.custom_size
        h = [handles.text_height, handles.text_width, handles.text_unit, handles.unit_menu, handles.height_value, handles.width_value];
        set(h,'Enable','on')
        % restore value
        val = get(handles.height_value,'UserData');
        set(handles.height_value,'String',val)
        feval(get(handles.height_value,'Callback'),handles.height_value)
        val = get(handles.width_value,'UserData');
        set(handles.width_value,'String',val)
        feval(get(handles.width_value,'Callback'),handles.width_value)
        set(handles.unit_menu,'Value',get(handles.unit_menu,'UserData'))
end
validate_export_status(handles);
end

function orientation_SelectionChangedFcn(hObject,~)
handles = guidata(hObject);
H = get(handles.height_value,'string');
W = get(handles.width_value,'string');
set(handles.height_value,'string',W)
set(handles.width_value,'string',H)
end

% function CheckBox_Callback(hObject,~)
% if get(hObject,'UserData')
%     set(hObject,'value',1)
% else
%     handles = guidata(hObject);
%     str = lower(get(hObject,'String'));
%     tag = [str '_value'];
%     if get(hObject,'value')
%         % restore value
%         val = get(handles.(tag),'UserData');
%         set(handles.(tag),'Enable','on','String',val)
%         set(hObject,'ForegroundColor','k')
%     else
%         % backup value
%         val = get(handles.(tag),'String');
%         set(handles.(tag),'Enable','off','UserData',val,'String','N/A')
%         set(hObject,'ForegroundColor',[.5, .5, .5])
%     end
% end
% end

function value_Callback(hObject,~)
handles = guidata(hObject);
str = get(hObject,'String');
str = str(isnumletter(str) | str=='.');
set(hObject,'String',str)
tag = get(hObject,'tag');
if isempty(str) || sscanf(str,'%f')==0
    if isequal(get(hObject,'BackgroundColor'),[1,1,1])
        set(hObject,'BackgroundColor','r')
    end
    if strcmp(get(handles.export_btn,'Enable'),'on')
        set(handles.export_btn,'Enable','off')
    end
else
    if isequal(get(hObject,'BackgroundColor'),[1,0,0])
        set(hObject,'BackgroundColor','w')
    end
    lg = strcmp(tag, {'height_value','width_value'});
    if any(lg)
        % compute another value to fix aspect ratio
        if isfield(handles,'view1')
            h_extract_region = findobj(handles.view1,'tag','extract_region');
            if ~isempty(h_extract_region) && isequal(get(h_extract_region,'EdgeColor'),[1 1 0])
                vtx = get(h_extract_region,'vertices');
                ratio = (vtx(3,2)-vtx(1,2))/(vtx(3,1)-vtx(1,1));
                if lg(1) % heigth_value changed and use to calculate width
                    if isequal(get(handles.width_value,'BackgroundColor'),[1,0,0])
                        height = sscanf(str,'%f');
                        width = height/ratio;
                        set(handles.width_value,'String',sprintf('%f',width))
                        set(handles.width_value,'BackgroundColor','w')
                    end
                else % width_value changed and use to calculate height
                    if isequal(get(handles.height_value,'BackgroundColor'),[1,0,0])
                        width = sscanf(str,'%f');
                        height = width*ratio;
                        set(handles.height_value,'String',sprintf('%f',height))
                        set(handles.height_value,'BackgroundColor','w')
                    end
                end
            end
        end
        % update orientation
        height = sscanf(get(handles.height_value,'String'), '%f');
        width = sscanf(get(handles.width_value,'String'), '%f');
        if height >= width
            if get(handles.portrait,'value')==0
                set(handles.portrait,'Value',1)
            end
        else % height < width
            if  get(handles.landscape,'value')==0
                set(handles.landscape,'Value',1)
            end
        end
    else % resolution_value
        if isfield(handles,'view1')
            h = findobj(handles.view1,'tag','extract_region');
            if ~isempty(h) && get(handles.auto_size,'Value')
                scale = sscanf(str,'%f')/100;
                [nx, ny] = decide_dimension(h,scale);
                nx = round(nx);  ny = round(ny);
                set(handles.height_value,'String',sprintf('%d',ny))
                set(handles.width_value,'String',sprintf('%d',nx))
            end
        end
    end
    validate_export_status(handles);
end
end

function rotim_btn_Callback(hObject,~)
handles = guidata(hObject);
deg = get(hObject,'UserData');
deg = 90*floor(deg/90) + 90;
if deg>180, deg = deg-360;  end
image_path = get(handles.impath_value,'String');
do_rotate(image_path,deg,handles.figure1,handles.view1)
if deg==0
    set(hObject,'String','Rotate Image','UserData',deg)
else
    str = sprintf('<html><center>Rotate Image<br>Current %d degree</center>',deg);
    set(hObject,'String',str,'UserData',deg)
end
end

function do_rotate(image_path,deg,mainfig,view1)
if deg==0
    X = imread(image_path);
else
    X = imrotate(imread(image_path),deg,'bicubic');
end
ShowImage(X,mainfig,view1,deg);
end

function rectangle_btn_Callback(hObject,~)
handles = guidata(hObject);
set(groot,'CurrentFigure',handles.view1)
h_axes = get(handles.view1,'Child');
delete(findobj(h_axes,'tag','extract_region'))
[x,y,button] = ginput(1);
if button==1
    vtxfun = @() patch_vertices([x,y],h_axes);
    h = patch('vertices',vtxfun(),'faces',1:4,'edgecolor','y','facecolor','none','tag','extract_region','UserData',handles.export_btn,'DeleteFcn',@patch_DeleteFcn);
    set(handles.view1,'WindowButtonMotionFcn',{@ButtonMotionFcn_vertices,vtxfun,h},'WindowButtonUpFcn',@ButtonUpFcn_rectangleBtn)
end
end

function ButtonUpFcn_rectangleBtn(hObject,~)
h = findobj(hObject,'tag','extract_region');
vtx = get(h,'vertices');
if vtx(1,1)==vtx(3,1) && vtx(1,2)==vtx(3,2)
    delete(h)
    set(hObject,'WindowButtonMotionFcn','','WindowButtonUpFcn','')
else
    if vtx(1,1) > vtx(3,1) || vtx(1,2) > vtx(3,2)
        vtx = circshift(vtx,2,1); % force point order as left-top, right-top, right-bottom, left-bottom
        set(h,'vertices',vtx)
    end
    h_image = findobj(hObject,'type','image');
    set(hObject,'WindowButtonMotionFcn',{@ButtonMotionFcn_detectVTX,h,h_image},'WindowButtonUpFcn','')
    rectangle_btn_Callback_continue(hObject,h)
    update_height_width(hObject)
end
end

function rectangle_btn_Callback_continue(hObject,h)
handles = guidata(get(hObject,'UserData'));
lg = validate_export_status(handles);
if lg && logical(get(handles.auto_size,'Value'))
    scale = sscanf(get(handles.resolution_value,'String'),'%f')/100;
    [nx, ny] = decide_dimension(h,scale);
    nx = round(nx);  ny = round(ny);
    set(handles.height_value,'String',sprintf('%d',ny))
    set(handles.width_value,'String',sprintf('%d',nx))
    if ny >= nx
        if get(handles.portrait,'Value')==0
            set(handles.portrait,'Value',1)
        end
    else
        if get(handles.landscape,'Value')==0
            set(handles.landscape,'Value',1)
        end
    end
end
end

function update_height_width(hObject)
handles = guidata(get(hObject,'UserData'));
if get(handles.custom_size,'Value')
    h = findobj(hObject,'tag','extract_region');
    vtx = get(h,'vertices');
    nx = vtx(3,1)-vtx(1,1);
    ny = vtx(3,2)-vtx(1,2);
    lg_height = isequal(get(handles.height_value,'BackgroundColor'),[1,1,1]);
    lg_width = isequal(get(handles.width_value,'BackgroundColor'),[1,1,1]);
    if lg_height || lg_width
        if lg_height
            height = sscanf(get(handles.height_value,'String'),'%f');
            height_digits = 0;
            while rem(height*10^height_digits,1)~=0
                height_digits = height_digits + 1;
            end
        else
            height_digits = inf;
        end
        if lg_width
            width = sscanf(get(handles.width_value,'String'),'%f');
            width_digits = 0;
            while rem(width*10^width_digits,1)~=0
                width_digits = width_digits + 1;
            end
        else
            width_digits = inf;
        end
        ratio = ny/nx;
        if height_digits < width_digits && width_digits > 3
            width = height/ratio;
            set(handles.width_value,'String',sprintf('%f',width))
            if isequal(get(handles.width_value,'BackgroundColor'),[1,0,0])
                set(handles.width_value,'BackgroundColor','w')
            end
            update_orientation(nx,ny,handles.portrait,handles.landscape)
        elseif height_digits > width_digits && height_digits > 3
            height = width*ratio;
            set(handles.height_value,'String',sprintf('%f',height))
            if isequal(get(handles.height_value,'BackgroundColor'),[1,0,0])
                set(handles.height_value,'BackgroundColor','w')
            end
            update_orientation(nx,ny,handles.portrait,handles.landscape)
        end
    else
        update_orientation(nx,ny,handles.portrait,handles.landscape)
    end
end
    
end

function update_orientation(nx,ny,h_portrait,h_landscape)
if ny >= nx
    if get(h_portrait,'Value')==0
        set(h_portrait,'Value',1)
    end
else
    if get(h_landscape,'Value')==0
        set(h_landscape,'Value',1)
    end
end
end

function ButtonMotionFcn_detectVTX(hObject,~,h,h_image)
vtx = get(h,'vertices');
vtx(:,3) = [];
h_axes = get(hObject,'Child');
cp = get(h_axes,'CurrentPoint');
cp = cp(1,1:2);
ds = sum((cp-vtx).^2,2);
pointer = 'arrow';
scr2pixel = getappdata(h_image,'scr2pixel'); % number of image pixel per screen dot
tol = [3,2]*(96/25.4*scr2pixel); % tolerance for corner and edge detection are 3mm and 2mm, respectively
if any(ds <= tol(1).^2)
    [~,ix] = min(ds);
    if ix==1 || ix==3
        pointer = 'topl';
    else % ix==2 || ix==4
        pointer = 'topr';
    end
    set(hObject,'WindowButtonDownFcn',@ButtonDownFcn_corner)
else
    if isequal(get(h,'edgecolor'),[1 1 0])
        xi = vtx([1,3],1);
        yi = vtx([1,3],2);
        dx = abs(cp(1) - xi);
        dy = abs(cp(2) - yi);
        lg = [dx; dy] <= tol(2);
        if any(lg)
            pointer = {'left','right','top','bottom'};
            pointer = pointer{lg};
            set(hObject,'WindowButtonDownFcn',@ButtonDownFcn_edge)
        end
    end
end
if strcmp(pointer,'arrow') && ~isempty(get(hObject,'WindowButtonDownFcn'))
    set(hObject,'WindowButtonDownFcn','')
end
if ~strcmp(get(hObject,'Pointer'),pointer)
    set(hObject,'Pointer',pointer)
end
end

function ButtonDownFcn_corner(hObject,~)
h_axes = get(hObject,'Child');
h = findobj(h_axes,'tag','extract_region');
h_image = findobj(h_axes,'type','image');
vtx = get(h,'vertices');
vtx(:,3) = [];
cp = get(h_axes,'CurrentPoint');
cp = cp(1,1:2);
ds = sum((cp-vtx).^2,2);
[~,ix] = min(ds);
setappdata(hObject,'initial_position',[cp(1,:);vtx(ix,:)])
setappdata(hObject,'image_size',size(get(h_image,'CData')))
preButtonMotionFcn = get(hObject,'WindowButtonMotionFcn');
set(hObject,'WindowButtonMotionFcn',{@ButtonMotionFcn_corner,h_axes,h,ix},'WindowButtonUpFcn',{@ButtonUpFcn_corner,preButtonMotionFcn})
end

function ButtonMotionFcn_corner(hObject,~,h_axes,h,ix)
vtx = get(h,'vertices');
cp = get(h_axes,'CurrentPoint');
ip = getappdata(hObject,'initial_position');
imsize = getappdata(hObject,'image_size');
newx = ip(2,1) + cp(1,1)-ip(1,1);
newy = ip(2,2) + cp(1,2)-ip(1,2);
newx(newx < 0.5) = 0.5;
newx(newx > imsize(2)+0.5) = imsize(2)+0.5;
newy(newy < 0.5) = 0.5;
newy(newy > imsize(1)+0.5) = imsize(1)+0.5;
vtx(ix,1:2) = [newx, newy];
set(h,'vertices',vtx)
if ~isequal(get(h,'edgecolor'),[0,1,1])
    set(h,'edgecolor','c')
end
end

function ButtonUpFcn_corner(hObject,~,preButtonMotionFcn)
h_axes = get(hObject,'Child');
cp = get(h_axes,'CurrentPoint');
ip = getappdata(hObject,'initial_position');
if ~isequal(cp(1,:),ip(1,:)) % withdraw 
    h = findobj(h_axes,'tag','extract_region');
    rectangle_btn_Callback_continue(hObject,h)
end
set(hObject,'WindowButtonMotionFcn',preButtonMotionFcn,'WindowButtonUpFcn','')
rmappdata(hObject,'initial_position')
rmappdata(hObject,'image_size')
end

function ButtonDownFcn_edge(hObject,~)
h_axes = get(hObject,'Child');
h = findobj(h_axes,'tag','extract_region');
h_image = findobj(h_axes,'type','image');
vtx = get(h,'vertices');
switch get(hObject,'Pointer')
    case 'left'
        ix = [1,4];
    case 'right'
        ix = [2,3];
    case 'top'
        ix = [1,2];
    case 'bottom'
        ix = [3,4];       
end
cp = get(h_axes,'CurrentPoint');
setappdata(hObject,'initial_position',[cp(1,:);vtx(ix(1),:)])
setappdata(hObject,'image_size',size(get(h_image,'CData')))
preButtonMotionFcn = get(hObject,'WindowButtonMotionFcn');
set(hObject,'WindowButtonMotionFcn',{@ButtonMotionFcn_edge,h_axes,h,ix},'WindowButtonUpFcn',{@ButtonUpFcn_edge,preButtonMotionFcn})
end

function ButtonMotionFcn_edge(hObject,~,h_axes,h,ix)
vtx = get(h,'vertices');
cp = get(h_axes,'CurrentPoint');
ip = getappdata(hObject,'initial_position');
imsize = getappdata(hObject,'image_size');
switch get(hObject,'Pointer')
    case {'left','right'}
        newx = ip(2,1) + cp(1,1)-ip(1,1);
        newx(newx < 0.5) = 0.5;
        newx(newx > imsize(2)+0.5) = imsize(2)+0.5;
        vtx(ix,1) = newx;
    case {'top','bottom'}
        newy = ip(2,2) + cp(1,2)-ip(1,2);
        newy(newy < 0.5) = 0.5;
        newy(newy > imsize(1)+0.5) = imsize(1)+0.5;
        vtx(ix,2) = newy;
end
set(h,'vertices',vtx)
end

function ButtonUpFcn_edge(hObject,~,preButtonMotionFcn)
h_axes = get(hObject,'Child');
cp = get(h_axes,'CurrentPoint');
ip = getappdata(hObject,'initial_position');
if ~isequal(cp(1,:),ip(1,:)) % withdraw 
    h = findobj(h_axes,'tag','extract_region');
    rectangle_btn_Callback_continue(hObject,h)
    update_height_width(hObject)
end
set(hObject,'WindowButtonMotionFcn',preButtonMotionFcn,'WindowButtonUpFcn','')
rmappdata(hObject,'initial_position')
rmappdata(hObject,'image_size')
end

function patch_DeleteFcn(hObject,~)
switch get(hObject,'tag')
    case 'extract_region'
        set(ancestor(hObject,'figure'), 'WindowButtonMotionFcn','') % stop WindowButtonMotionFcn
        set(get(hObject,'UserData'),'Enable','off')
    case 'white_region'
        
end
delete(hObject)
end

function [nx, ny, vtx] = decide_dimension(h,scale)
vtx = get(h,'vertices');
vtx(:,3) = [];
vtx_offset = vtx - mean(vtx,1);
[V,D] = eig(vtx_offset.'*vtx_offset,'vector');
pixel_num = sqrt(D);
pixel_num = pixel_num*scale;
v1x = abs(V(1,1));
v2x = abs(V(1,2));
if v1x > v2x % v1 is x-axis
    nx = pixel_num(1);
    ny = pixel_num(2);
else % v2 is x-axis
    nx = pixel_num(2);
    ny = pixel_num(1);
end
end

function white_btn_Callback(hObject,~)
handles = guidata(hObject);
set(groot,'CurrentFigure',handles.view1)
h_axes = get(handles.view1,'Child');
delete(findobj(h_axes,'tag','white_region'));
[x,y,button] = ginput(1);
if button==1
    vtxfun = @() patch_vertices([x,y],h_axes);
    h = patch('vertices',vtxfun(),'faces',1:4,'edgecolor','w','facecolor','none','tag','white_region','DeleteFcn',@patch_DeleteFcn);
    preButtonMotionFcn = get(handles.view1,'WindowButtonMotionFcn');
    set(handles.view1,'WindowButtonMotionFcn',{@ButtonMotionFcn_vertices,vtxfun,h},'WindowButtonUpFcn',{@ButtonUpFcn_whiteBtn,preButtonMotionFcn})
end
end

function vtx = patch_vertices(s,h_axes)
cp = get(h_axes,'CurrentPoint');
cp = cp(1,1:2);
vtx = ones(4,3); % z-coordinate = 1 by axes default
vtx(1,1:2) = s;
vtx(2,1) = cp(1);
vtx(2,2) = s(2);
vtx(3,1:2) = cp;
vtx(4,1) = s(1);
vtx(4,2) = cp(2);
end

function ButtonMotionFcn_vertices(~,~,vtxfun,h)
set(h,'vertices',vtxfun())
end

function ButtonUpFcn_whiteBtn(hObject,~,preButtonMotionFcn)
set(hObject,'WindowButtonMotionFcn',preButtonMotionFcn,'WindowButtonUpFcn','')
h = findobj(hObject,'tag','white_region');
vtx = get(h,'vertices');
if vtx(1,1)~=vtx(3,1) || vtx(1,2)~=vtx(3,2)
    if vtx(1,1) > vtx(3,1) || vtx(1,2) > vtx(3,2)
        vtx = circshift(vtx,2,1); % force point order as left-top, right-top, right-bottom, left-bottom
        set(h,'vertices',vtx)
    end
    xmin = round(vtx(1,1));  xmax = round(vtx(3,1));  nx = xmax - xmin + 1;
    ymin = round(vtx(1,2));  ymax = round(vtx(3,2));  ny = ymax - ymin + 1;
    h_image = findobj(hObject,'type','image');
    X = get(h_image,'CData');
    J = double(X(ymin:ymax,xmin:xmax,:));
    J_mean = mean(reshape(J,ny*nx,1,3),1);
    J_std = std(reshape(J,ny*nx,1,3),0,1);
    set(h,'UserData',[J_mean, J_std])
else
    delete(h)
end
end

function lg = validate_export_status(handles)
lg_value = true(1,2);
if get(handles.custom_size,'Value')
    lg_value(1) = ~isequal(get(handles.height_value,'BackgroundColor'),[1,0,0]);
    lg_value(2) = ~isequal(get(handles.width_value,'BackgroundColor'),[1,0,0]);
end
lg_res = ~isequal(get(handles.resolution_value,'BackgroundColor'),[1,0,0]);
lg_image = isfield(handles,'view1') && ~isempty(findobj(handles.view1,'type','image')) && ~isempty(findobj(handles.view1,'tag','extract_region'));

lg = all(lg_value) && lg_res && lg_image;
if lg
    if strcmp(get(handles.export_btn,'Enable'),'off')
        set(handles.export_btn,'Enable','on')
    end
else
    if strcmp(get(handles.export_btn,'Enable'),'on')
        set(handles.export_btn,'Enable','off')
    end
end
end

function export_btn_Callback(hObject,~)
handles = guidata(hObject);
h_axes = findobj(handles.view1,'type','axes');
XLim = get(h_axes,'XLim');  YLim = get(h_axes,'YLim');
set(hObject,'Enable','off')
h_text = text(mean(XLim),mean(YLim),'Proessing...',...
    'color','r','fontsize',18,'BackgroundColor','w','HorizontalAlignment','center','parent',h_axes);
cleanupObj = onCleanup(@() CleanUpFcn(hObject,h_text));
drawnow

protrait = logical(get(handles.portrait,'Value'));
scale = sscanf(get(handles.resolution_value,'String'),'%f')/100;
algs = get(handles.algorithm_menu,'String');
val = get(handles.algorithm_menu,'Value');
algorithm = algs{val};
imageH = sscanf(get(handles.height_value,'String'),'%f');
imageW = sscanf(get(handles.width_value,'String'),'%f');

h = findobj(handles.view1,'tag','extract_region');
[nx, ny, vtx] = decide_dimension(h,scale);
if protrait
    if nx > ny,  error('Unexpect error'),  end
else
    if nx < ny,  error('Unexpect error'),  end
end
% adjust width and height to fit selected/assigned paper size
if get(handles.auto_size,'Value')==0 
    imratio = imageH/imageW;
    p = (nx*imratio - ny)/(nx*imratio + ny);
    nx = round(nx*(1-p));
    ny = round(ny*(1+p));
end
nx = round(nx);
ny = round(ny);
% get four corner points (p1, p2, p3, p4)
% idx = zeros(1,2);
% [~,idx(1)] = min(sum(vtx,2));  p1 = vtx(idx(1),:);
% [~,idx(2)] = max(sum(vtx,2));  p3 = vtx(idx(2),:);
% idx = setdiff(1:4,idx);
% if vtx(idx(1),1) > vtx(idx(2),1)
%     p2 = vtx(idx(1),:);
%     p4 = vtx(idx(2),:);
% else
%     p2 = vtx(idx(2),:);
%     p4 = vtx(idx(1),:);
% end
h_image = findobj(handles.view1,'type','image');
X = get(h_image,'CData');
imsize = size(X);

% restore rectangle shape before perspective projection
% Pi = [p1; p2; p3; p4];
Pi = vtx;
Ps = [1 1; nx 1; nx ny; 1 ny];
Hs2i = FourPointsTransform(Ps,Pi);
Psx = ones(ny,1)*(1:nx);
Psy = (1:ny).'*ones(1,nx);
Ps = [Psx(:) Psy(:) ones(ny*nx,1)];
Pi = Ps*Hs2i;
Pi = Pi(:,1:2)./Pi(:,3);
Xq = reshape(Pi(:,1),ny,nx);
Yq = reshape(Pi(:,2),ny,nx);
[Piy,Pix] = ndgrid(1:imsize(1),1:imsize(2));
Xnew = zeros(ny, nx, 3);
for i=1:3
    F = griddedInterpolant(Piy,Pix,double(X(:,:,i)),algorithm,'none');
    Xnew(:,:,i) = F(Yq,Xq);
end

% correct white color
h_white_region = findobj(h_axes,'tag','white_region');
if ~isempty(h_white_region)
    white_color = get(h_white_region,'UserData'); %[1*2*3]
    white_mean = white_color(1,1,:);
    white_std = white_color(1,2,:);
    maxval = white_mean + 2*white_std; % [1*1*3]
    Xnew(Xnew < 0) = 0;
    minval = min(reshape(Xnew,nx*ny,1,3),[],1); % [1*1*3]
    Xnew = Xnew - minval;
    Xnew = Xnew./(maxval-minval)*255;
end
Xnew = uint8(Xnew);

% output image
units = get(handles.unit_menu,'String');
val = get(handles.unit_menu,'Value');
unit = units{val};
if strcmp(unit,'Millimeter')
    imageH = imageH/10;  imageW = imageW/10;
    unit = 'Centimeter';
end
filetypes = get(handles.filetype_menu,'String');
val = get(handles.filetype_menu,'Value');
filetype = filetypes{val};
image_path = get(handles.impath_value,'String');
[folder,name,ext_ori] = fileparts(image_path);
if contains(filetype,'.bmp')
    ext = '.bmp';
    if strcmpi(ext_ori,ext),  ext = ext_ori;  end
    image_path = [folder filesep name '_ER' ext];
    imwrite(Xnew,image_path)
elseif contains(filetype,'.png')
    ext = '.png';
    if strcmpi(ext_ori,ext),  ext = ext_ori;  end
    image_path = [folder filesep name '_ER' ext];
    if strcmp(unit,'Pixel')
        imwrite(Xnew,image_path)
    else
        switch unit
            case 'Centimeter'
                resX = nx/imageW*100; % convert unit to pixel/meter
                resY = ny/imageH*100;
            case 'Inch'
                resX = nx/(imageW*2.54)*100;
                resY = ny/(imageH*2.54)*100;
        end
        imwrite(Xnew,image_path,'ResolutionUnit','meter','XResolution',resX,'YResolution',resY)
    end
elseif contains(filetype,'.tif')
    ext = '.tif';
    if strncmpi(ext_ori,ext,4),  ext = ext_ori;  end
    image_path = [folder filesep name '_ER' ext];
    if strcmp(unit,'Pixel')
        imwrite(Xnew,image_path,'Compression','lzw')
    else
        switch unit
            case 'Centimeter'
                resX = nx/imageW*2.54; % convert unit to pixel/inch
                resY = ny/imageH*2.54;
            case 'Inch'
                resX = nx/imageW;
                resY = ny/imageH;
        end
        imwrite(Xnew,image_path,'Resolution',[resX resY],'Compression','lzw')
    end
elseif contains(filetype,'.jpg')
    ext = '.jpg';
    if strncmpi(ext_ori,ext,3),  ext = ext_ori;  end
    image_path = [folder filesep name '_ER' ext];
    imwrite(Xnew,image_path,'Mode','lossy')
end
end

function CleanUpFcn(hObject,h)
set(hObject,'Enable','on')
delete(h)
end

function figure1_CloseRequestFcn(hObject,~)
handles = guidata(hObject);
% close external window
if isfield(handles,'view1')
    delete(handles.view1)
end
delete(hObject)
% remove main figure handle
rmappdata(groot,mfilename)
% remove current folder
rmpath(handles.mainpath)
end
