clc; %clear all the previous commands;
for z=1:10
    filename=strcat('Image',string(z),'.png'); % Files are in format of Image1.png,Image2.png,...Image10.png
    Ground_Truth = imread(filename); % Reading the Ground Truth image file 
    [w,b,r]=size(Ground_Truth); % w,b,r are the respective dimension 
    % r=1 => the image is in gray scale
    % r!=1 => the image is in coloured scale and we need to convert in gray
    % scale
    % from below condition we have converted into the grayscale
    if (r~=1)
        Ground_Truth=Ground_Truth(:,:,3);
    end
    % Add Gaussian Type Noise with Mean 0 and Standard Deviation 0.1 in the ground truth
    Img = imnoise(Ground_Truth,'gaussian', 0,0.1);
    %map=colormap(I);
    [m,n] = size(Img);
 
    f=2; %neighborhood window size = 2f+1 , ie 5x5
    t=3; % similarity window size = 2t+1 , ie 7x7
 
    % Making gaussian kernel
    std=1;          %standard deviation of gaussian kernel
    sma=0;          % sum of all kernel elements (for normalization)
    ks= 2*f+1;     % size of kernel (same as neighborhood window size)
	
    ker = zeros(ks,ks);    % Initiating kernel with all zeros
    for x=1:ks % Transversing in the horizontal direction
        for y=1:ks % Transversing in the vertical direction
            width = x-f-1;   % horizontal distance of pixel from center(f+1, f+1)
            height = y-f-1;  % vertical distance of pixel from center (f+1, f+1)
            ker(x,y) = 100*exp((width+height)*(width+height))/(-2*(std*std));
            sma = sma + ker(x,y);
        end
    end
    kernel = ker ./ f;
    kernel = kernel / sma;   % normalization
 
    noisex = Img; 
    noisy = double(noisex);
 
    % Assign a clear output image and intialize all the values with zeros.
    Denoised = zeros(m,n);
 
    %Degree of filtering
    h=40;
    % Replicate boundaries of noisy image
    noisy2 = padarray(noisy,[f,f],'symmetric');
 
    % Now we'll calculate ouput for each pixel
    for i=1:m
        for j=1:n
            im = i+f;   % to compensate for shift due to padarray function
            jn= j+f;% neighborhood of concerned pixel (similarity window)
            W1 = noisy2(im-f:im+f , jn-f:jn+f);
            % Boundaries of similarity window for that pixel
			% so that we dont go out of the image boundary, similarity window
            rmin = max(im-t, f+1);
            rmax = min(im+t, m+f);
            smin = max(jn-t, f+1);
            smax = min(jn+t, n+f);
            % Calculate weighted average next
            NL=0;    % same as cleared (i,j) but for simplicity
            Z =0;    % sum of all s(i,j)
            % Run loop through all the pixels in similarity window
            for r=rmin:rmax
                for s=smin:smax
                    W2 = noisy2(r-f:r+f, s-f:s+f);  % neighborhood of pixel 'j' being compared for similarity
                    d2 = sum(sum(kernel.*(W1-W2).*(W1-W2))); % square of weighted euclidian distances
                    % weight of similarity between both pixels : s(i,j)
                    sij = exp(-d2/(h*h)); % According to the formula discussed in paper.
                    % update Z and NL (since Z was the summation of all the s(i,j) values)
                    Z = Z + sij;
                    NL = NL + (sij*noisy2(r,s));
                end
            end
         % normalization of NL
           Denoised(i,j) = NL/Z;
       end
    end
    % convert cleared to uint8
    Denoised = uint8(Denoised);

 
    % Plotting the Images of Ground Truth, Noisy, Denoised images.
    figure(z);
    set(gcf, 'Position', get(0,'ScreenSize'));
    subplot(1,3,1),imshow(Ground_Truth),title('Ground Truth Image');
    subplot(1,3,2),imshow(noisex),title('Noisy Image');
    subplot(1,3,3),imshow(Denoised),title('Denoised Image');

    %PSNR calculation and printing the error.
    [peaksnr1, snr1] = psnr(Ground_Truth, Denoised); 
    fprintf('\n The Peak-SNR value between Ground Truth and Denoised of Image %0.4f is %0.4f',z, peaksnr1);
    
    % MSE calculation and printing the error.
    err1 = immse(Ground_Truth, Denoised);
    fprintf('\n The mean-squared error between Ground Truth and Denoised of Image %0.4f is %0.4f\n',z, err1);
end