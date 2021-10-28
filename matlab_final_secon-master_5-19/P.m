function tmp = P(hashIndexDB, bit)
binHashIndexDB = hexToBinaryVector(hashIndexDB', 4)';
binHashIndexDB = binHashIndexDB(:);
tmp = nan(2, size(hashIndexDB, 1));
for i = 1:size(hashIndexDB, 1)
    p1 = binHashIndexDB((i-1)*bit+1:i*bit);
    p2 = binHashIndexDB(i*bit+1:(i+1)*bit);
    
    tmp(1, i) = mod(binaryVectorToDecimal(p1'), bit);
    tmp(2, i) = mod(binaryVectorToDecimal(p2'), bit);
end
end