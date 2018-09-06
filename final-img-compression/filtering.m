% Arjun Sabnis
% ECE 4271 - Spring 2018

% If Laplacian, param between 0-1
% If Gaussian, param any value greater than 0

function modified = filtering(img, type, param)
if (strcmp('gaussian',type) == 1)
    h = fspecial('gaussian',3,param);
end
if (strcmp('laplacian',type) == 1)
    h = fspecial('laplacian', param);
end

modified = imfilter(img,h);
end