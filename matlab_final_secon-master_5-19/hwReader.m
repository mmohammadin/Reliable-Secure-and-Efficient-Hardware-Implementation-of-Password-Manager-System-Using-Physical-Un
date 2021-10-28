function hw = hwReader(ser, user, pass, index)
pause(3);   % this delay is important to be more than 2 sec to cummunicate with MCU correctely

fwrite(ser, user);
pause(0.1);
fwrite(ser, 10);
pause(0.5);

% binary = reshape(dec2bin(pass, 8).'-'0',1,[]);
% xorbin = xor(binary, dec2bin(index, length(binary)));
% PW = char(bin2dec(reshape(char(xorbin+'0'), 8,[]).'))';
fwrite(ser, pass);
pause(0.1);
fwrite(ser, 10);

rawdata = fread(ser, 15000);
strdata = char(transpose(rawdata));

idxorpw = [];
pos = strfind(strdata, 'ID XOR PW XOR INDEX:');
for i=1:32
    idxorpw = [idxorpw; strdata(pos+21+3*i : pos+22+3*i)];
end

hashxoruserpwindex = [];
pos = strfind(strdata, 'H(ID XOR PW XOR INDEX):');
for i=1:32
    hashxoruserpwindex = [hashxoruserpwindex; strdata(pos+24+3*i : pos+25+3*i)];
end

hashxorpwindex = [];
pos = strfind(strdata, 'H(PW XOR INDEX):');
for i=1:32
    hashxorpwindex = [hashxorpwindex; strdata(pos+17+3*i : pos+18+3*i)];
end

shift = [];
pos = strfind(strdata, 'Shift result:');
for i=0:7
    shift = [shift; strdata(pos+15+(32*3+2)*i : pos+19+(32*3+2)*i)];
end

mdresult = [];
pos = strfind(strdata, 'MD results:');
for j=0:7
    for i=1:32
        mdresult = [mdresult; strdata(pos+15+3*i+j*(32*3+7) : pos+16+3*i+j*(32*3+7))];
    end
end

rawaddr = [];
pos = strfind(strdata, 'Raw addresses:');
for i=1:128
    rawaddr = [rawaddr; strdata(pos+11+5*i : pos+14+5*i)];
end

refinedaddr = [];
pos = strfind(strdata, 'Refined addresses:');
for i=1:128
    refinedaddr = [refinedaddr; strdata(pos+15+5*i : pos+18+5*i)];
end

maskbit = [];
pos = strfind(strdata, 'SRAM fuzzy bits mask:');
for i=1:128
    maskbit = [maskbit; strdata(pos+22+i)];
end

pufbit = [];
pos = strfind(strdata, 'Read SRAM bits:');
for i=1:128
    pufbit = [pufbit; strdata(pos+16+i)];
end

hw.idxorpw = idxorpw;
hw.hashxoruserpwindex = hashxoruserpwindex;
hw.hashxorpwindex = hashxorpwindex;
hw.shift = shift;
hw.mdresult = mdresult;
hw.rawaddr = rawaddr;
hw.refinedaddr = refinedaddr;
hw.maskbit = maskbit;
hw.pufbit = pufbit;

save('hw.mat','hw');

end
