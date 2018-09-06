% Arjun Sabnis
% Downsampling algorithm

function [et,saved,mse,imNew] = dnSample(filename,val)
tic
img = double(imread(filename));

[m,n,p] = size(img);
m2 = floor(m/val);
n2 = floor(n/val);

if(mod(m2,val) ~= 0)
    for i = 1:(val-mod(m2,val))*val
        if(p==1)
            img = [img; img(end,:)];
        elseif (p==3)
            img = [img; img(end,:,:)];
        end
    end
end
if(mod(n2,val) ~= 0)
    for i = 1:(val-mod(n2,val))*val
        if(p==1)
            img = [img, img(:,end)];
        elseif (p==3)
            img = [img, img(:,end,:)];
        end
    end
end

[m,n,p] = size(img);
m2 = floor(m/val);
n2 = floor(n/val);

% figure, imshow(uint8(img)), title('Original Image');

if(p == 1)
    imNew = zeros(m2,n2,1);
elseif (p==3)
    imNew = zeros(m2,n2,3);
end
for k = 1:p
    for i = 1:m2
        for j = 1:n2
            imNew(i,j,k) = img(val*i,val*j,k);
        end
    end
    imNew = uint8(imNew);
end
et = toc;

imNew = imresize(imNew,val);
figure, imshow(imNew), title(['Image Downsampled by ', num2str(val)]);

original = (m*n*p)/1024;
new = (m2*n2*p)/1024;
saved = original/new;
[m3,n3,~] = size(imNew);
if (m3~=m)|| (n3~=n)
    img = img(1:m3,1:n3,:);
end
mse = immse(uint8(img),imNew);

% sprintf('Downsampling by %d saves %2.2f kilobytes of data, and takes %2.2f seconds to run.',val,saved,et)
end