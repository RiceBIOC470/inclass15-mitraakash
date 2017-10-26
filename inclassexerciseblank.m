% Akash Mitra
% am132

%% step 1: write a few lines of code or use FIJI to separately save the
% nuclear channel of the image Colony1.tif for segmentation in Ilastik

% Image provided contains nuclear channel

%% step 2: train a classifier on the nuclei
% try to get the get nuclei completely but separe them where you can
% save as both simple segmentation and probabilities

% Completed in Ilastik

%% step 3: use h5read to read your Ilastik simple segmentation
% and display the binary masks produced by Ilastik 

% (datasetname = '/exported_data')
% Ilastik has the image transposed relative to matlab
% values are integers corresponding to segmentation classes you defined,
% figure out which value corresponds to nuclei

segment_im = h5read('/Users/amitra2/Documents/CompbioRice17/inclass15.h5', '/exported_data');
segment_im = squeeze(segment_im);
imshow(segment_im, []);

%% step 3.1: show segmentation as overlay on raw data

img=imread('48hColony1_DAPI.tif');
imshow(img, []);
hold on;
imshow(segment_im, []);
hold off;

%% step 4: visualize the connected components using label2rgb
% probably a lot of nuclei will be connected into large objects

connected_comp=label2rgb(img);
imshow(connected_comp);

%% step 5: use h5read to read your Ilastik probabilities and visualize
% it will have a channel for each segmentation class you defined

segment_im = h5read('/Users/amitra2/Documents/CompbioRice17/inclass15Prob.h5', '/exported_data');
prob_im=squeeze(prob_im);
imshow(prob_im);

%% step 6: threshold probabilities to separate nuclei better

bw_im=prob_im > 0.95;
imshow(bw_im);

%% step 7: watershed to fill in the original segmentation (~hysteresis threshold)

img2 = bwconncomp(bw_im);
cell_props = regionprops(img2,'Area');
area_props = [cell_props.Area];
im_sqrt = round(1.2*sqrt(mean(area_props))/pi);
im_erode = imerode(bw_im,strel('disk',im_sqrt));
im_outside = ~imdilate(bw_im,strel('disk',1));
im_basin = imcomplement(bwdist(im_outside));
im_basin = imimposemin(im_basin,im_erode|im_outside);
im_watershed = watershed(im_basin);
imshow(im_watershed, []);


%% step 8: perform hysteresis thresholding in Ilastik and compare the results
% explain the differences

%Ilastik performed better at edge detection and segmentation of areas where
%the nuclei overlapped as compared to Matlab. This could potentiall be due 
% to the erosion performed during the watershed that eroded some of the 
% edges of the nuclei.

%% step 9: clean up the results more if you have time 
% using bwmorph, imopen, imclose etc

