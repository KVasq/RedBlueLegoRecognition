function [numA,numB] = count_lego(I)
I1 = I

%seperate color layers and apply red filter
R = I1(:,:,1);
G = I1(:,:,2);
B = I1(:,:,3);
redmask = R>55 & G<35 & B<50;
R(~redmask) = 255; G(~redmask) = 255; B(~redmask) = 255;

JR = cat(3,R,G,B);
%figure(6); montage(cat(4,I1,JR),'Size',[1 2]);

%seperate again and repeat with blue filter
R = I1(:,:,1);
G = I1(:,:,2);
B = I1(:,:,3);
bluemask = B>65 & R<70 & G<105;
R(~bluemask) = 255; G(~bluemask) = 255; B(~bluemask) = 255;

JB = cat(3,R,G,B);
%figure(7); montage(cat(4,I1,JB),'Size',[1 2]);
%%
%convert red and blue images to binary
Rbw = im2bw(JR , 0.5)
Bbw = im2bw(JB, 0.5)

figure(8); imshowpair(Rbw, Bbw, 'montage');

%%
%invert black and white
Bcomp = imcomplement(Bbw)
Rcomp = imcomplement(Rbw)

%remove smaller objects that are smaller than pixel valued area
Rbwopen = bwareaopen(Rcomp, 12000)
Bbwopen = bwareaopen(Bcomp, 22000)

figure(9); imshowpair(Rbwopen, Bbwopen, 'montage');
%%

%fill in holes to make remaining objects more solid
Rfilled = imfill(Rbwopen, 'holes')
Bfilled = imfill(Bbwopen, 'holes')
figure(10); imshowpair(Rfilled, Bfilled, 'montage');

%%
%This portion on regionprops was inspired by user Akira Agata on the Matlab forum
%https://uk.mathworks.com/matlabcentral/answers/357682-extraction-of-rectangular-blob-from-binary-image

%use region props to retrieve the area bounding boxes and perimeter of each
%detected object
Bstats = regionprops(Bfilled,{'Area','BoundingBox','perimeter'});
Bstats = struct2table(Bstats);
% Metric 1 is the ratio between perimeter and length of the bounding box
Bstats.Metric1 = 2*sum(Bstats.BoundingBox(:,3:4),2)./Bstats.Perimeter;
m1 = abs(1 - Bstats.Metric1) < 0.35;
% Metric 2 is the ratio between object area and bounding box area
Bstats.Metric2 = Bstats.Area./(Bstats.BoundingBox(:,3).*Bstats.BoundingBox(:,4));
m2 = Bstats.Metric2 > 0.1;
mcombine = m1 & m2;
Bstats(~mcombine,:) = [];
% show the result
figure(1);
imshow(Bfilled);
hold on
for kk = 1:height(Bstats)
rectangle('Position', Bstats.BoundingBox(kk,:),...
    'LineWidth',    3,...
    'EdgeColor',    'g',...
    'LineStyle',    ':');
end
hold off
bluebricks = height(Bstats)
numA = int8(bluebricks) % assgin to output

%fprintf('there are %f blue bricks', bluebricks)
%%
%This portion on regionprops was inspired by user Akira Agata on the Matlab forum
%https://uk.mathworks.com/matlabcentral/answers/357682-extraction-of-rectangular-blob-from-binary-image

Rstats = regionprops(Rfilled,{'Area','BoundingBox','perimeter'});
Rstats = struct2table(Rstats);
% Metric 1 is the ratio between perimeter and length of the bounding box
%for k =1: numberofBlobs
Rstats.Metric1 = 2*sum(Rstats.BoundingBox(:,3:4),2)./Rstats.Perimeter;
m1 = abs(1 - Rstats.Metric1) < 0.3;
% Metric 2 is the ratio between object area and bounding box area
Rstats.Metric2 = Rstats.Area./(Rstats.BoundingBox(:,3).*Rstats.BoundingBox(:,4));
m2 = Rstats.Metric2 > 0.1;
% Metric 3 is a limiter on the perimeter to exclude rectangles
Rstats.Metric3 = Rstats.Perimeter < 800;
m3 = Rstats.Metric3
mcombine = m1 & m2 & m3; %must satisfy all conditions to be counted
Rstats(~mcombine,:) = [];
% show the result
figure(2);
imshow(Rfilled);
hold on
for kk = 1:height(Rstats)
rectangle('Position', Rstats.BoundingBox(kk,:),...
    'LineWidth',    3,...
    'EdgeColor',    'g',...
    'LineStyle',    ':');
end
hold off
redbricks = height(Rstats)
numB = int8(redbricks) %assign to output

%fprintf('there are %f red bricks', redbricks)
end

