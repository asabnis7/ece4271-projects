% Arjun Sabnis
% Bit removal algorithm

function [et,saved,mse,compressed] = bitRemove(filename,rm)
tic
img = imread(filename);
% figure, imshow(img), title('Original Image');
[row, col, d] = size(img);
compressed = zeros(row,col,d);
de2bi = [1 2 4 8 16 32 64 128 256];

for k = 1:d
    for i = 1:row
        for j = 1:col
            binEq = dec2bin(img(i,j,k))-'0';
            intNum = sum(fliplr(de2bi(rm+1:length(binEq))).*binEq(1:end-rm));
            compressed(i,j,k) = intNum;
        end
    end
end
compressed = uint8(compressed);
% figure, imshow(compressed), title(['Image with ', num2str(8-rm), ' Bits Per Pixel']);
et = toc;

original = (row*col*d)/1024;
new = ((row*col*d*(8-rm))/8)/1024;
saved = original/new;
mse = immse(img,compressed);

% sprintf('Removing %d bits saves %2.2f kilobytes of data, and takes %2.2f seconds to run.',rm,saved,et)
end