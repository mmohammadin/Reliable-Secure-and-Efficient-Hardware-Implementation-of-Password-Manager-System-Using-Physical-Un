function [isAuth] = hwAuthentication(edtUser, edtPass, edtHashPassIndex, etdHashUserPassIndex, ...
    edtDBAddress, edtIndex, tblChRes, edtDetail, isHardware, handles)
db = handles.db;
bit = handles.bit;
dbAccount = handles.dbAccount;
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

hw = hwReader(ser, edtUser.String, edtPass.String, index);

edtHashPassIndex.String = hw.hashxorpwindex(:)';
edtHashUserPassIndex.String = hw.hashxoruserpwindex(:)';

binHashIndexDB = hexToBinaryVector(hw.hashxoruserpwindex(:)')';
binHashIndexDB = binHashIndexDB(:);
row = binaryVectorToDecimal(binHashIndexDB(1:bit)');
col = binaryVectorToDecimal(binHashIndexDB(bit+1:bit*2)');
edtDBAddress.String = mat2str([row, col]);

tblChRes.Data = {};

dbtmp = db{row, col};
readpuf = hw.pufbit';
for i = 1:length(dbtmp)
    tblChRes.Data{i, 5} = dbtmp(i);
    if dbtmp(i) ~= readpuf(i)
        tblChRes.Data{i, 1} = 'X';
    end
end

for i = 1:size(hw.rawaddr, 1)
    tblChRes.Data{i, 2} = hex2dec(hw.rawaddr(i, :));
end

for i = 1:size(hw.maskbit, 1)
    tblChRes.Data{i, 3} = hex2dec(hw.maskbit(i, :));
end

for i = 1:size(hw.refinedaddr, 1)
    tblChRes.Data{i, 4} = hex2dec(hw.refinedaddr(i, :));
end

for i = 1:size(hw.pufbit, 1)
    tblChRes.Data{i, 6} = hex2dec(hw.pufbit(i, :));
end

edtDetail.String = {};
edtDetail.String{end+1} = 'Shift result:';
edtDetail.String{end+1} = hw.shift(:)';

edtDetail.String{end+1} = '';
edtDetail.String{end+1} = 'MD result:';
edtDetail.String{end+1} = hw.mdresult(:)';

if ~isempty(dbtmp)
    msgbox(['index of defferent points ' mat2str(find(~(dbtmp == readpuf)))...
        ' with length ' num2str(length(find(~(dbtmp == readpuf))))],'Information!');
end

if all(size(db{row, col}) == size(readpuf)) ...
        && (length(find(~(dbtmp == readpuf))) < 7)  %% Acceptance threshold
    msgbox('Account Authenticated.','Authentication');
    isAuth = 1;
else
    msgbox('Account Not Authorized.','Authentication');
    isAuth = 0;
end

handles.db = db;
handles.dbAccount = dbAccount;

end
