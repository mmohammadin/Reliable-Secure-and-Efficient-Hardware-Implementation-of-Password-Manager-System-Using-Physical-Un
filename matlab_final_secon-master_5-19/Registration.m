function [db, dbP, dbAccount] = Registration(edtUser, edtPass, edtHashPassIndex, edtHashUserPassIndex, ...
    edtDBAddress, edtIndex, tblChRes, edtDetail, isHardware, handles)
db = handles.db;
puf = handles.puf;
bit = handles.bit;
dbP = handles.dbP;
dbAccount = handles.dbAccount;
Opt = handles.hashOpt;
ser = handles.ser;

status(handles.pnlGeneral, 'Please Wait...');

index = 1; userInd = 0;
for i = 1:size(dbAccount, 1)
    if all(size(dbAccount{i, 1}) == size(edtUser.String)) ...
            && all(dbAccount{i, 1} == edtUser.String)
        index = dbAccount{i, 2};
        userInd = i;
        break;
    else
        userInd = i+1;
    end
end

edtIndex.String = index;
dbAccount{userInd, 2} = index;
dbAccount{userInd, 1} = edtUser.String;

hashIndexDB = DataHash([edtUser.String edtPass.String num2str(index)], Opt);
edtHashUserPassIndex.String = hashIndexDB;

binHashIndexDB = hexToBinaryVector(hashIndexDB', 4)';
binHashIndexDB = binHashIndexDB(:);
row = binaryVectorToDecimal(binHashIndexDB(1:bit)');
col = binaryVectorToDecimal(binHashIndexDB(bit+1:bit*2)');
edtDBAddress.String = mat2str([row, col]);

if ~isempty(db{row, col})
    warndlg('Earlier Account Removed.','! Warning !');
end

dbP{row, col} = P(hashIndexDB, bit);

hashIndexCR = DataHash([edtPass.String index], Opt);
edtHashPassIndex.String = hashIndexCR;
binHashIndexCR = hexToBinaryVector(hashIndexCR', 4)';
binHashIndexCR = binHashIndexCR(:);
len = floor(length(binHashIndexCR)/(bit*2));
tmp = nan(1, len);
for i = 1:len
    x = binaryVectorToDecimal(binHashIndexCR((i-1)*bit+1:i*bit)');
    y = binaryVectorToDecimal(binHashIndexCR(i*bit+1:(i+1)*bit)');
    if ~isHardware
        tmp(1, i) = puf(x, y);
    else
        fprintf(ser, '%d', x);
        pause(0.5)
        tmp(1, i) = fscanf(ser, '%d'); 
        pause(0.5);
        fprintf(ser, '%d', y);
        pause(0.5);
        tmp(1, i) = fscanf(ser, '%d'); 
        pause(0.5);
        tmp(1, i) = mod(fscanf(ser, '%d'), 2); 
    end
    tblChRes.Data{i, 2} = mat2str([x, y]);
    tblChRes.Data{i, 3} = num2str(tmp(1, i));
end

db{row, col} = tmp;

status(handles.pnlGeneral, 'OK...');
dbSave(db, dbP, dbAccount);

handles.db = db;
handles.dbP = dbP;
handles.dbAccount = dbAccount;

end
