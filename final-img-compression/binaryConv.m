% Arjun Sabnis
% Represent uint8 image in binary equivalent

function low_img = binaryConv(img)
[row, col] = size(img);
binInd = 0;
while(2^binInd < max(max(img)))
    binInd = binInd + 1;
end
low_img = zeros(row,col);
de2bi = [1 2 4 8 16 32 64 128 256];
binOut = [];
intNum = 0;
for i = 1:row
    for j = 1:col
        for k = binInd:-1:0
            if (2^k > img(i,j))
                binOut = [binOut 0];
            else
                img(i,j) = img(i,j)-2^k;
                binOut = [binOut 1];
            end
        end
        binOut = binOut(1:end-1);
        intNum = sum(fliplr(de2bi(2:length(binOut)+1)).*binOut);
        low_img(i,j) = intNum;
        binOut = [];
        intNum = 0;
        zeroCheck = 1;
    end
end
low_img = uint8(low_img);
end