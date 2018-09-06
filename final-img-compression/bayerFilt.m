% Arjun Sabnis
% Bayer filtering demosaicing algorithm

function RGB = bayerFilt(filename)
img = double(imread(filename));

R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);
[m, n, ~] = size(img);

bayer = zeros(m,n);

bayer(2:2:m,2:2:n) = R(2:2:m,2:2:n);
figure,imshow(uint8(bayer));
bayer(bayer==0) = G(bayer==0);
figure,imshow(uint8(bayer));
bayer(1:2:m,1:2:n) = B(1:2:m,1:2:n);
figure,imshow(uint8(bayer));

RGB = zeros(m,n,3);

for i = 2:m-1
    for j = 2:n-1
        if(mod(i,2)==1 && mod(j,2)==0) %G1
            RGB(i,j,1) = (bayer(i-1,j)+bayer(i+1,j))/2;
            RGB(i,j,2) = bayer(i,j);
            RGB(i,j,3) = (bayer(i,j-1)+bayer(i,j+1))/2;
        elseif(mod(i,2)==0 && mod(j,2)==1) %G2
            RGB(i,j,1) = (bayer(i,j-1)+bayer(i,j+1))/2;
            RGB(i,j,2) = bayer(i,j);
            RGB(i,j,3) = (bayer(i-1,j)+bayer(i+1,j))/2;
        elseif(mod(i,2)==0 && mod(j,2)==0) %R
            RGB(i,j,1) = bayer(i,j);
            RGB(i,j,2) = mean([bayer(i,j-1), bayer(i,j+1), bayer(i-1,j), bayer(i+1,j)]);
            RGB(i,j,3) = mean([bayer(i-1,j-1), bayer(i-1,j+1), bayer(i+1,j-1), bayer(i+1,j+1)]);
        else %B
            RGB(i,j,1) = mean([bayer(i-1,j-1), bayer(i-1,j+1), bayer(i+1,j-1), bayer(i+1,j+1)]);
            RGB(i,j,2) = mean([bayer(i,j-1), bayer(i,j+1), bayer(i-1,j), bayer(i+1,j)]);
            RGB(i,j,3) = bayer(i,j);
        end
    end
end
        
RGB = uint8(RGB);
figure,imshow(RGB);
end