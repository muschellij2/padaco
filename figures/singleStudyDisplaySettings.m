function varargout = singleStudyDisplaySettings(varargin)
% SINGLESTUDYDISPLAYSETTINGS MATLAB code for singleStudyDisplaySettings.fig
%      SINGLESTUDYDISPLAYSETTINGS, by itself, creates a new SINGLESTUDYDISPLAYSETTINGS or raises the existing
%      singleton*.
%
%      H = SINGLESTUDYDISPLAYSETTINGS returns the handle to a new SINGLESTUDYDISPLAYSETTINGS or the handle to
%      the existing singleton*.
%
%      SINGLESTUDYDISPLAYSETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SINGLESTUDYDISPLAYSETTINGS.M with the given input arguments.
%
%      SINGLESTUDYDISPLAYSETTINGS('Property','Value',...) creates a new SINGLESTUDYDISPLAYSETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before singleStudyDisplaySettings_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to singleStudyDisplaySettings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help singleStudyDisplaySettings

% Last Modified by GUIDE v2.5 01-Aug-2018 09:31:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @singleStudyDisplaySettings_OpeningFcn, ...
                   'gui_OutputFcn',  @singleStudyDisplaySettings_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before singleStudyDisplaySettings is made visible.
function singleStudyDisplaySettings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to singleStudyDisplaySettings (see VARARGIN)

% Choose default command line output for singleStudyDisplaySettings
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes singleStudyDisplaySettings wait for user response (see UIRESUME)
% uiwait(handles.figure_singleStudyDisplaySettings);


% --- Outputs from this function are returned to the command line.
function varargout = singleStudyDisplaySettings_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes during object creation, after setting all properties.
function edit_scale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function edit_scale_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_scale_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_offset_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_offset_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_label_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_label_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
