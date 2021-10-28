function [puf, width, height] = pufGenerator(bit)
% Initialization
width = 2^bit;
height = 2^bit;

% Address Book Creation
puf = logical(rand(width, height, 'single') > 0.5);

% Saving Address Book
save('puf.mat', 'bit', 'puf','width', 'height', '-v7.3');
