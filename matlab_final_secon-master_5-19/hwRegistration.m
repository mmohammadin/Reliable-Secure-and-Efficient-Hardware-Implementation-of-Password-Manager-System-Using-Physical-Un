function [db, dbP, dbAccount] = hwRegistration(edtUser, edtPass, edtHashPassIndex, edtHashUserPassIndex, ...
    edtDBAddress, edtIndex, tblChRes, edtDetail, isHardware, handles)
db = handles.db;
bit = handles.bit;
dbP = handles.dbP;
dbAccount = handles.dbAccount;
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

hw = hwReader(ser, edtUser.String, edtPass.String, index);

edtHashPassIndex.String = hw.hashxorpwindex(:)';
edtHashUserPassIndex.String = hw.hashxoruserpwindex(:)';

binHashIndexDB = hexToBinaryVector(hw.hashxoruserpwindex(:)')';
binHashIndexDB = binHashIndexDB(:);
row = binaryVectorToDecimal(binHashIndexDB(1:bit)');
col = binaryVectorToDecimal(binHashIndexDB(bit+1:bit*2)');
edtDBAddress.String = mat2str([row, col]);

if ~isempty(db{row, col})
    warndlg('Earlier Account Removed.','! Warning !');
end

% dbP{row, col} = P(hw.hashxoruserpwindex, bit);

tblChRes.Data = {};

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
    tblChRes.Data{i, 5} = hex2dec(hw.pufbit(i, :));
end

edtDetail.String = {};
edtDetail.String{end+1} = 'Shift result:';
edtDetail.String{end+1} = hw.shift(:)';

edtDetail.String{end+1} = '';
edtDetail.String{end+1} = 'MD result:';
edtDetail.String{end+1} = hw.mdresult(:)';

db{row, col} = hw.pufbit';

status(handles.pnlGeneral, 'OK...');
dbSave(db, dbP, dbAccount);

handles.db = db;
handles.dbP = dbP;
handles.dbAccount = dbAccount;

end
