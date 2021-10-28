function [ser, state] = hardware(handles)
if isempty(handles.ser)
    btngConnection = findobj(handles.pnlSetting.Children, 'Tag', 'btngConnection');
    ppmSerialList = findobj(btngConnection.Children, 'Tag', 'ppmSerialList');
    ppmBaudRate = findobj(btngConnection.Children, 'Tag', 'ppmBaudRate');
    serialPort = ppmSerialList.String;
    if iscellstr(ppmSerialList.String)
        serialPort = ppmSerialList.String{ppmSerialList.Value};
    end
    baudRate = ppmBaudRate.String{ppmBaudRate.Value};
    if ~strcmp(serialPort, 'Select')
        handles.ser = serial(serialPort);
        handles.ser.Baudrate = str2num(baudRate);
        handles.ser.InputBufferSize = 15000;
        fopen(handles.ser);
        state = 1;
    else
        state = 0;
    end
else
    state = 1;
end

ser = handles.ser;