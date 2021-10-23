% Guassian Filter With Gaussian White Noise

clc;%clear all the previous commands
% We have 10 images in repoistory for carrying out the process
for i=1:10
    filename=strcat('Image',string(i),'.png'); % Files are in format of Image1.png,Image2.png,...Image10.png
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
    noisy = imnoise(Ground_Truth,'gaussian', 0,0.1);
    % Denoising the noisy images using gaussian filter.
    Denoised= imgaussfilt(noisy,1);
     
    % Plotting the Images of Ground Truth, Noisy, Denoised images.
    figure(i);
    set(gcf, 'Position', get(0,'ScreenSize'));
    subplot(1,3,1),imshow(Ground_Truth),title('Ground Truth Image');
    subplot(1,3,2),imshow(noisy),title('Noisy Image');
    subplot(1,3,3),imshow(Denoised),title('Denoised Image');

    %PSNR calculation and printing the error.
    [peaksnr1, snr1] = psnr(Ground_Truth, Denoised); 
    fprintf('\n The Peak-SNR value between Ground Truth and Denoised of Image %0.4f is %0.4f',i, peaksnr1);
    
    % MSE calculation and printing the error.
    err1 = immse(Ground_Truth, Denoised);
    fprintf('\n The mean-squared error between Ground Truth and Denoised of Image %0.4f is %0.4f\n',i, err1);
end