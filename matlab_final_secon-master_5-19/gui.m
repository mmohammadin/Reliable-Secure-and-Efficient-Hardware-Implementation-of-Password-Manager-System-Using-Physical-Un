function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 11-Apr-2019 10:17:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

pnlDataGenerator = findobj(handles.pnlSetting.Children, 'Tag', 'pnlDataGenerator');
edtBits = findobj(pnlDataGenerator.Children, 'Tag', 'edtBits');
if ~exist('./puf.mat', 'file')
    [puf, width, height] = pufGenerator(9);
    handles.puf = puf;
    handles.bit = 9;
    edtBits.String = num2str(9);
else
    load('./puf.mat');
    handles.puf = puf;
    handles.bit = bit;
    edtBits.String = num2str(bit);
end

if ~exist('./db.mat', 'file')
    db = cell(width, height);
    handles.db = db;
    save('db.mat', 'db');
else
    load('./db.mat');
    handles.db = db;
end

if ~exist('./dbP.mat', 'file')
    dbP = cell(width, height);
    handles.dbP = dbP;
    save('dbP.mat', 'dbP');
else
    load('./dbP.mat');
    handles.dbP = dbP;
end

if ~exist('./dbAccount.mat', 'file')
    dbAccount = cell(1, 2); % { [UserName], [IndexCounter] }
    handles.dbAccount = dbAccount;
    save('dbAccount.mat', 'dbAccount');
else
    load('./dbAccount.mat');
    handles.dbAccount = dbAccount;
end

handles.ser = [];

handles.hashOpt.Format = 'HEX';
handles.hashOpt.Input = 'array';
pnlDataGenerator = findobj(handles.pnlSetting.Children, 'Tag', 'pnlDataGenerator');
ppmHashMethod = findobj(pnlDataGenerator.Children, 'Tag', 'ppmHashMethod');
handles.hashOpt.Method = ppmHashMethod.String{ppmHashMethod.Value};

handles.pnlSetting.Position = [0 0 1 1];
handles.pnlSetting.Visible = 'on';
handles.pnlGeneral.Visible = 'off';

pnlDB = findobj(handles.pnlSetting.Children, 'Tag', 'pnlDB');
tblAccountDB = findobj(pnlDB.Children, 'Tag', 'tblAccountDB');
tblAccountDB.Data = dbAccount;
tblPUF = findobj(pnlDB.Children, 'Tag', 'tblPUF');
tblPUF.Data = puf;

btngConnection = findobj(handles.pnlSetting.Children, 'Tag', 'btngConnection');
ppmSerialList = findobj(btngConnection.Children, 'Tag', 'ppmSerialList');
ppmBaudRate = findobj(btngConnection.Children, 'Tag', 'ppmBaudRate');
btnTest = findobj(btngConnection.Children, 'Tag', 'btnTest');
edtTestPoint = findobj(btngConnection.Children, 'Tag', 'edtTestPoint');
edtTestResult = findobj(btngConnection.Children, 'Tag', 'edtTestResult');
pnlDataGenerator = findobj(handles.pnlSetting.Children, 'Tag', 'pnlDataGenerator');
btnReadPUF = findobj(pnlDataGenerator.Children, 'Tag', 'btnReadPUF');

% Default options for btngConnection panel
ppmSerialList.String = ['Select' seriallist];
ppmSerialList.Enable = 'off';
ppmBaudRate.Enable = 'off';
btnReadPUF.Enable = 'Off';
btnTest.Enable = 'off';
edtTestPoint.Enable = 'off';
edtTestResult.Enable = 'off';

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected object is changed in btngConnection.
function btngConnection_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in btngConnection 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

btngConnection = findobj(handles.pnlSetting.Children, 'Tag', 'btngConnection');
ppmSerialList = findobj(btngConnection.Children, 'Tag', 'ppmSerialList');
ppmBaudRate = findobj(btngConnection.Children, 'Tag', 'ppmBaudRate');
btnTest = findobj(btngConnection.Children, 'Tag', 'btnTest');
edtTestPoint = findobj(btngConnection.Children, 'Tag', 'edtTestPoint');
edtTestResult = findobj(btngConnection.Children, 'Tag', 'edtTestResult');
pnlDataGenerator = findobj(handles.pnlSetting.Children, 'Tag', 'pnlDataGenerator');
btnReadPUF = findobj(pnlDataGenerator.Children, 'Tag', 'btnReadPUF');

switch hObject.String
    case 'Hardware'
        ppmSerialList.Enable = 'on';
        ppmBaudRate.Enable = 'on';
        btnReadPUF.Enable = 'on';
        btnTest.Enable = 'on';
        edtTestPoint.Enable = 'on';
        edtTestResult.Enable = 'on';
    case 'Software'
        ppmSerialList.Enable = 'off';
        ppmBaudRate.Enable = 'off';
        btnReadPUF.Enable = 'off';
        btnTest.Enable = 'off';
        edtTestPoint.Enable = 'off';
        edtTestResult.Enable = 'off';
end

if ~isempty(handles.ser)
    fclose(handles.ser);
    handles.ser = [];
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in ppmSerialList.
function ppmSerialList_Callback(hObject, eventdata, handles)
% hObject    handle to ppmSerialList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.ser)
    fclose(handles.ser);
    handles.ser = [];
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ppmSerialList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppmSerialList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ppmBaudRate.
function ppmBaudRate_Callback(hObject, eventdata, handles)
% hObject    handle to ppmBaudRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.ser)
    fclose(handles.ser);
    handles.ser = [];
end
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ppmBaudRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppmBaudRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnTest.
function btnTest_Callback(hObject, eventdata, handles)
% hObject    handle to btnTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
status(handles.pnlSetting, 'Starting Hardware Connection ... Please Wait!')
[ser, state] = hardware(handles);
pause(0.5);
handles.ser = ser;
if state
    btngConnection = findobj(handles.pnlSetting.Children, 'Tag', 'btngConnection');
    edtTestPoint = findobj(btngConnection.Children, 'Tag', 'edtTestPoint');
    testPoint = str2num(edtTestPoint.String);
    fprintf(handles.ser, '%d', testPoint(1));
    pause(0.5);
    result = fscanf(handles.ser, '%d');
    pause(0.5);
    fprintf(handles.ser, '%d', testPoint(2));
    pause(0.5);
    result = fscanf(handles.ser, '%d');
    pause(0.5);
    result = fscanf(handles.ser, '%d');
    edtTestResult = findobj(btngConnection.Children, 'Tag', 'edtTestResult');
    edtTestResult.String = num2str(result);
    status(handles.pnlSetting, 'OK ...')
else
    status(handles.pnlSetting, 'Not OK ...!')
end

% Update handles structure
guidata(hObject, handles);


function edtTestPoint_Callback(hObject, eventdata, handles)
% hObject    handle to edtTestPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtTestPoint as text
%        str2double(get(hObject,'String')) returns contents of edtTestPoint as a double


% --- Executes during object creation, after setting all properties.
function edtTestPoint_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtTestPoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtTestResult_Callback(hObject, eventdata, handles)
% hObject    handle to edtTestResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtTestResult as text
%        str2double(get(hObject,'String')) returns contents of edtTestResult as a double


% --- Executes during object creation, after setting all properties.
function edtTestResult_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtTestResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function mnuSetting_Callback(hObject, eventdata, handles)
% hObject    handle to mnuSetting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.pnlSetting.Position = [0 0 1 1];
handles.pnlSetting.Visible = 'on';
handles.pnlGeneral.Visible = 'off';

set(handles.output, 'PaperPositionMode', 'auto');
print(handles.output, '-dpng', 'mnuSetting.png');


% --------------------------------------------------------------------
function mnuGeneral_Callback(hObject, eventdata, handles)
% hObject    handle to mnuGeneral (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.pnlGeneral.Position = [0 0 1 1];
handles.pnlGeneral.Visible = 'on';
handles.pnlSetting.Visible = 'off';

set(handles.output, 'PaperPositionMode', 'auto');
print(handles.output, '-dpng', 'mnuGeneral.png');


% --- Executes on button press in btnRandomPUF.
function btnRandomPUF_Callback(hObject, eventdata, handles)
% hObject    handle to btnRandomPUF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pnlDataGenerator = findobj(handles.pnlSetting.Children, 'Tag', 'pnlDataGenerator');
edtBits = findobj(pnlDataGenerator.Children, 'Tag', 'edtBits');
status(handles.pnlSetting, 'PUF Matrix Under Generation... Please Wait!');
pufGenerator(str2num(edtBits.String));
pnlDB = findobj(handles.pnlSetting.Children, 'Tag', 'pnlDB');
tblPUF = findobj(pnlDB.Children, 'Tag', 'tblPUF');
load('./puf.mat'); tblPUF.Data = puf; handles.puf = puf;
status(handles.pnlSetting, 'OK ...');

guidata(hObject, handles);


% --- Executes on button press in btnReadPUF.
function btnReadPUF_Callback(hObject, eventdata, handles)
% hObject    handle to btnReadPUF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
loc = 2^handles.bit+1;
status(handles.pnlSetting, 'Reading PUF from hardware... please wait!')
pnlDB = findobj(handles.pnlSetting.Children, 'Tag', 'pnlDB');
tblPUF = findobj(pnlDB.Children, 'Tag', 'tblPUF');
[ser, state] = hardware(handles);
pause(0.5);
handles.ser = ser;
if state
    fprintf(handles.ser,"%d",loc);
    pause(0.5)
    fprintf(handles.ser,"%d",loc);
    pause(0.5)
    for i = 1:size(handles.puf, 1)
        for j = 1:size(handles.puf, 2)
            handles.puf(i, j) = fscanf(handles.ser, '%d');
            tblPUF.Data = handles.puf;
        end
    end
    save puf.mat handles.puf handles.bit -v7.3
    status(handles.pnlSetting, 'OK ...!')
else
    status(handles.pnlSetting, 'Not OK ...!')
end

guidata(hObject, handles);


function edtBits_Callback(hObject, eventdata, handles)
% hObject    handle to edtBits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtBits as text
%        str2double(get(hObject,'String')) returns contents of edtBits as a double


% --- Executes during object creation, after setting all properties.
function edtBits_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtBits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ppmHashMethod.
function ppmHashMethod_Callback(hObject, eventdata, handles)
% hObject    handle to ppmHashMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pnlDataGenerator = findobj(handles.pnlSetting.Children, 'Tag', 'pnlDataGenerator');
ppmHashMethod = findobj(pnlDataGenerator.Children, 'Tag', 'ppmHashMethod');
handles.hashOpt.Method = ppmHashMethod.String{ppmHashMethod.Value};

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ppmHashMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppmHashMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtUser_Callback(hObject, eventdata, handles)
% hObject    handle to edtUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtUser as text
%        str2double(get(hObject,'String')) returns contents of edtUser as a double


% --- Executes during object creation, after setting all properties.
function edtUser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtUser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtPass_Callback(hObject, eventdata, handles)
% hObject    handle to edtPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtPass as text
%        str2double(get(hObject,'String')) returns contents of edtPass as a double


% --- Executes during object creation, after setting all properties.
function edtPass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnReg.
function btnReg_Callback(hObject, eventdata, handles)
% hObject    handle to btnReg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pnlAccount = findobj(handles.pnlGeneral.Children, 'Tag', 'pnlAccount');
edtUser = findobj(pnlAccount.Children, 'Tag', 'edtUser');
edtPass = findobj(pnlAccount.Children, 'Tag', 'edtPass');

pnlDetails = findobj(handles.pnlGeneral.Children, 'Tag', 'pnlDetails');
edtHashPassIndex = findobj(pnlDetails.Children, 'Tag', 'edtHashPassIndex');
etdHashUserPassIndex = findobj(pnlDetails.Children, 'Tag', 'etdHashUserPassIndex');
edtDBAddress = findobj(pnlDetails.Children, 'Tag', 'edtDBAddress');
edtIndex = findobj(pnlDetails.Children, 'Tag', 'edtIndex');
tblChRes = findobj(pnlDetails.Children, 'Tag', 'tblChRes');
edtDetail = findobj(pnlDetails.Children, 'Tag', 'edtDetail');

btngConnection = findobj(handles.pnlSetting.Children, 'Tag', 'btngConnection');
SelectedObject = btngConnection.SelectedObject.String;
if strcmp(SelectedObject, 'Software')
[db, dbP, dbAccount] = Registration(edtUser, edtPass, edtHashPassIndex, etdHashUserPassIndex, ...
    edtDBAddress, edtIndex, tblChRes, edtDetail, 0, handles);
else
[ser, state] = hardware(handles);
pause(0.5);
handles.ser = ser;
% OLD VERSION
% [db, dbP, dbAccount] = Registration(edtUser, edtPass, edtHashPassIndex, etdHashUserPassIndex, ...
%     edtDBAddress, edtIndex, tblChRes, edtDetail, 1, handles);
[db, dbP, dbAccount] = hwRegistration(edtUser, edtPass, edtHashPassIndex, etdHashUserPassIndex, ...
    edtDBAddress, edtIndex, tblChRes, edtDetail, 1, handles);
end

handles.db = db;
handles.dbP = dbP;
handles.dbAccount = dbAccount;

pnlDB = findobj(handles.pnlSetting.Children, 'Tag', 'pnlDB');
tblAccountDB = findobj(pnlDB.Children, 'Tag', 'tblAccountDB');
tblAccountDB.Data = dbAccount;

% Update handles structure
guidata(hObject, handles);

set(handles.output, 'PaperPositionMode', 'auto');
print(handles.output, '-dpng', 'btnReg.png');

% --- Executes on button press in btnAuth.
function btnAuth_Callback(hObject, eventdata, handles)
% hObject    handle to btnAuth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pnlAccount = findobj(handles.pnlGeneral.Children, 'Tag', 'pnlAccount');
edtUser = findobj(pnlAccount.Children, 'Tag', 'edtUser');
edtPass = findobj(pnlAccount.Children, 'Tag', 'edtPass');

pnlDetails = findobj(handles.pnlGeneral.Children, 'Tag', 'pnlDetails');
edtHashPassIndex = findobj(pnlDetails.Children, 'Tag', 'edtHashPassIndex');
etdHashUserPassIndex = findobj(pnlDetails.Children, 'Tag', 'etdHashUserPassIndex');
edtDBAddress = findobj(pnlDetails.Children, 'Tag', 'edtDBAddress');
edtIndex = findobj(pnlDetails.Children, 'Tag', 'edtIndex');
tblChRes = findobj(pnlDetails.Children, 'Tag', 'tblChRes');
edtDetail = findobj(pnlDetails.Children, 'Tag', 'edtDetail');

btngConnection = findobj(handles.pnlSetting.Children, 'Tag', 'btngConnection');
SelectedObject = btngConnection.SelectedObject.String;
if strcmp(SelectedObject, 'Software')
Authentication(edtUser, edtPass, edtHashPassIndex, etdHashUserPassIndex, ...
    edtDBAddress, edtIndex, tblChRes, 0, handles);
else
[ser, state] = hardware(handles);
pause(0.5);
handles.ser = ser;
% OLD VERSION
% Authentication(edtUser, edtPass, edtHashPassIndex, etdHashUserPassIndex, ...
%     edtDBAddress, edtIndex, tblChRes, edtDetail, 1, handles);
hwAuthentication(edtUser, edtPass, edtHashPassIndex, etdHashUserPassIndex, ...
    edtDBAddress, edtIndex, tblChRes, edtDetail, 1, handles);
end
% Update handles structure
guidata(hObject, handles);

set(handles.output, 'PaperPositionMode', 'auto');
print(handles.output, '-dpng', 'btnAuth.png');



% --- Executes on button press in btnForgot.
function btnForgot_Callback(hObject, eventdata, handles)
% hObject    handle to btnForgot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pnlAccount = findobj(handles.pnlGeneral.Children, 'Tag', 'pnlAccount');
edtUser = findobj(pnlAccount.Children, 'Tag', 'edtUser');
edtPass = findobj(pnlAccount.Children, 'Tag', 'edtPass');

pnlDetails = findobj(handles.pnlGeneral.Children, 'Tag', 'pnlDetails');
edtHashPassIndex = findobj(pnlDetails.Children, 'Tag', 'edtHashPassIndex');
etdHashUserPassIndex = findobj(pnlDetails.Children, 'Tag', 'etdHashUserPassIndex');
edtDBAddress = findobj(pnlDetails.Children, 'Tag', 'edtDBAddress');
edtIndex = findobj(pnlDetails.Children, 'Tag', 'edtIndex');
tblChRes = findobj(pnlDetails.Children, 'Tag', 'tblChRes');
edtDetail = findobj(pnlDetails.Children, 'Tag', 'edtDetail');

btngConnection = findobj(handles.pnlSetting.Children, 'Tag', 'btngConnection');
SelectedObject = btngConnection.SelectedObject.String;
if strcmp(SelectedObject, 'Software')
[db, dbP, dbAccount] = ForgottenPass(edtUser, edtPass, edtHashPassIndex, etdHashUserPassIndex, ...
    edtDBAddress, edtIndex, tblChRes, 0, handles);
else
[ser, state] = hardware(handles);
pause(0.5);
handles.ser = ser;
% OLD VERSION
% [db, dbP, dbAccount] = ForgottenPass(edtUser, edtPass, edtHashPassIndex, etdHashUserPassIndex, ...
%     edtDBAddress, edtIndex, tblChRes, edtDetail, 1, handles);
[db, dbP, dbAccount] = hwForgottenPass(edtUser, edtPass, edtHashPassIndex, etdHashUserPassIndex, ...
    edtDBAddress, edtIndex, tblChRes, edtDetail, 1, handles);
end

pnlDB = findobj(handles.pnlSetting.Children, 'Tag', 'pnlDB');
tblAccountDB = findobj(pnlDB.Children, 'Tag', 'tblAccountDB');
tblAccountDB.Data = dbAccount;

handles.db = db;
handles.dbP = dbP;
handles.dbAccount = dbAccount;

% Update handles structure
guidata(hObject, handles);

set(handles.output, 'PaperPositionMode', 'auto');
print(handles.output, '-dpng', 'btnForgot.png');


function edtHashPassIndex_Callback(hObject, eventdata, handles)
% hObject    handle to edtHashPassIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtHashPassIndex as text
%        str2double(get(hObject,'String')) returns contents of edtHashPassIndex as a double


% --- Executes during object creation, after setting all properties.
function edtHashPassIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtHashPassIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function etdHashUserPassIndex_Callback(hObject, eventdata, handles)
% hObject    handle to etdHashUserPassIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of etdHashUserPassIndex as text
%        str2double(get(hObject,'String')) returns contents of etdHashUserPassIndex as a double


% --- Executes during object creation, after setting all properties.
function etdHashUserPassIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to etdHashUserPassIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtIndex_Callback(hObject, eventdata, handles)
% hObject    handle to edtIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtIndex as text
%        str2double(get(hObject,'String')) returns contents of edtIndex as a double


% --- Executes during object creation, after setting all properties.
function edtIndex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtIndex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtDBAddress_Callback(hObject, eventdata, handles)
% hObject    handle to edtDBAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtDBAddress as text
%        str2double(get(hObject,'String')) returns contents of edtDBAddress as a double


% --- Executes during object creation, after setting all properties.
function edtDBAddress_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtDBAddress (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close fig.
function fig_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.ser)
    fclose(handles.ser);
    handles.ser = [];
end

% Update handles structure
guidata(hObject, handles);

% Hint: delete(hObject) closes the figure
delete(hObject);



function edtDetail_Callback(hObject, eventdata, handles)
% hObject    handle to edtDetail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtDetail as text
%        str2double(get(hObject,'String')) returns contents of edtDetail as a double


% --- Executes during object creation, after setting all properties.
function edtDetail_CreateFcn(hObject, ~, handles)
% hObject    handle to edtDetail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
