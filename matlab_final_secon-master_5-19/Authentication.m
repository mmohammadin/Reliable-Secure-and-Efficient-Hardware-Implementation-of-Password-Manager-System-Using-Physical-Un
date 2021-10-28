function [isAuth] = Authentication(edtUser, edtPass, edtHashPassIndex, etdHashUserPassIndex, ...
    edtDBAddress, edtIndex, tblChRes, isHardware, handles)
db = handles.db;
puf = handles.puf;
bit = handles.bit;
dbAccount = handles.dbAccount;
Opt = handles.hashOpt;
ser = handles.ser;

status(handles.pnlGeneral, 'Please Wait...');

index = 1; found = 0;
for i = 1:size(dbAccount, 1)
    if all(size(dbAccount{i, 1}) == size(edtUser.String)) ...
            && all(dbAccount{i, 1} == edtUser.String)
        index = dbAccount{i, 2};
        found = 1;
        break;
    end
end

if ~found
    warndlg('Account Not Found.','! Warning !');
    isAuth = 2;
    return;
end

edtIndex.String = index;
hashIndexDB = DataHash([edtUser.String edtPass.String num2str(index)], Opt);
etdHashUserPassIndex.String = hashIndexDB;

binHashIndexDB = hexToBinaryVector(hashIndexDB', 4)';
binHashIndexDB = binHashIndexDB(:);
row = binaryVectorToDecimal(binHashIndexDB(1:bit)');
col = binaryVectorToDecimal(binHashIndexDB(bit+1:bit*2)');
edtDBAddress.String = mat2str([row, col]);

hashIndexCR = DataHash([edtPass.String index], Opt);
edtHashPassIndex.String = hashIndexCR;
binHashIndexCR = hexToBinaryVector(hashIndexCR', 4)';
binHashIndexCR = binHashIndexCR(:);
len = floor(length(binHashIndexCR)/(bit*2));
tmp = nan(1, len);
dbtmp = db{row, col};

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
    if ~isempty(dbtmp)
        tblChRes.Data{i, 2} = mat2str([x, y]);
        tblChRes.Data{i, 3} = num2str(tmp(1, i));
        tblChRes.Data{i, 4} = num2str(dbtmp(i));
        if dbtmp(i) ~= tmp(1, i)
            tblChRes.Data{i, 1} = 'X';
        end
    else
        tblChRes.Data{i, 2} = mat2str([x, y]);
        tblChRes.Data{i, 3} = num2str(tmp(1, i));
    end
end

if ~isempty(dbtmp)
    msgbox(['index of defferent points ' mat2str(find(~(dbtmp == tmp)))...
        ' with length ' num2str(length(find(~(dbtmp == tmp))))],'Information!');
end

if all(size(db{row, col}) == size(tmp)) ...
        && (length(find(~(dbtmp == tmp))) < 7)  %% Acceptance threshold
    msgbox('Account Authenticated.','Authentication');
    isAuth = 1;
else
    msgbox('Account Not Authorized.','Authentication');
    isAuth = 0;
end

handles.db = db;
handles.dbAccount = dbAccount;

end
