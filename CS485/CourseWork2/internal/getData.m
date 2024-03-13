function [ data_train, data_query, test_img_idx, numBins] = getData( MODE )
% Generate training and testing data
showImg = 0; % Show training & testing images and their image feature vector (histogram representation)

PHOW_Sizes = [4 8 10]; % Multi-resolution, these values determine the scale of each layer.
PHOW_Step = 16; % The lower the denser. Select from {2,4,8,16}

switch MODE
    case 'Caltech' % Caltech dataset
        close all;
        imgSel = [15 15]; % randomly select 15 images each class without replacement. (For both training & testing)
        folderName = './Caltech_101/101_ObjectCategories';
        classList = dir(folderName);
        classList = {classList(3:end).name} % 10 classes
        
        disp('Loading training images...')
        % Load Images -> Description (Dense SIFT)
        cnt = 1;
        if showImg
            figure('Units','normalized','Position',[.05 .1 .4 .9]);
            suptitle('Training image samples');
        end
        % classList는 총 10개의 class 이름을 가짐
        for c = 1:length(classList)
            subFolderName = fullfile(folderName,classList{c});
            % folder에서 jpg를 모두 불러와서 list로 만듬.
            imgList = dir(fullfile(subFolderName,'*.jpg'));
            % 무작위로 permuatate하고 그 중에 train 15개, test 15개를 겹치지 않게 선택
            imgIdx{c} = randperm(length(imgList));
            imgIdx_tr = imgIdx{c}(1:imgSel(1));
            imgIdx_te = imgIdx{c}(imgSel(1)+1:sum(imgSel));
            
            % train img들에 대해서 grayscale 변환 후, SIFT 적용 -> descriptor 생성
            for i = 1:length(imgIdx_tr)
                I = imread(fullfile(subFolderName,imgList(imgIdx_tr(i)).name));
                
                % Visualise
                if i < 6 & showImg
                    subaxis(length(classList),5,cnt,'SpacingVert',0,'MR',0);
                    imshow(I);
                    cnt = cnt+1;
                    drawnow;
                end
                
                if size(I,3) == 3
                    I = rgb2gray(I); % PHOW work on gray scale image
                end
                
                % For details of image description, see http://www.vlfeat.org/matlab/vl_phow.html
                [~, desc_tr{c,i}] = vl_phow(single(I),'Sizes',PHOW_Sizes,'Step',PHOW_Step); %  extracts PHOW features (multi-scaled Dense SIFT)
            end
        end
       
        disp('Building visual codebook...')
        % Build visual vocabulary (codebook) for 'Bag-of-Words method'
        [desc_sel,~] = vl_colsubset(cat(2,desc_tr{:}), 10e4); % Randomly select 100k SIFT descriptors for clustering
        % y에는 이제 index가 있음
        desc_sel = single(desc_sel);
        % K-means clustering
        numBins = 16; 
        %% write your own codes here
        tic
        vocab = vl_kmeans(desc_sel, numBins,'Initialization', 'plusplus','algorithm', 'lloyd') ;
        disp('Encoding Images...')
        % Vector Quantisation
        %% write your own codes here
        % ...
  
        histogram_tr = zeros(length(classList) * imgSel(1), numBins);
        cnt = 1;
        for c = 1:length(classList)
            for i = 1:imgSel(1)
                quantized_descriptors = knnsearch(vocab', single(desc_tr{c, i}'));
                histogram_tr(cnt, :) = histcounts(quantized_descriptors, 1:numBins + 1);
                cnt = cnt + 1;
            end
        end
        % ...
        toc
        test_img_idx = cell(1, length(classList));
        for c = 1:length(classList)
            test_img_idx{c}= imgIdx{c}(imgSel(1)+1:sum(imgSel));
        end
        % Clear unused varibles to save memory
        clearvars desc_tr desc_sel
end

switch MODE
    case 'Caltech'
        if showImg
        figure('Units','normalized','Position',[.05 .1 .4 .9]);
        suptitle('Test image samples');
        end
        disp('Processing testing images...');
        cnt = 1;
        % Load Images -> Description (Dense SIFT)
        for c = 1:length(classList)
            subFolderName = fullfile(folderName,classList{c});
            imgList = dir(fullfile(subFolderName,'*.jpg'));
            imgIdx_te = imgIdx{c}(imgSel(1)+1:sum(imgSel));
            
            for i = 1:length(imgIdx_te)
                I = imread(fullfile(subFolderName,imgList(imgIdx_te(i)).name));
                
                % Visualise
                if i < 6 & showImg
                    subaxis(length(classList),5,cnt,'SpacingVert',0,'MR',0);
                    imshow(I);
                    cnt = cnt+1;
                    drawnow;
                end
                
                if size(I,3) == 3
                    I = rgb2gray(I);
                end
                [~, desc_te{c,i}] = vl_phow(single(I),'Sizes',PHOW_Sizes,'Step',PHOW_Step);
            
            end
        end
        
        % Quantisation
        % disp(size(desc_te)) : 10x15
        % 여기는 test data하는 거 아마 똑같이 quantisation하면 될듯
        %% write your own codes here
        tic
        % ...
        histogram_te = zeros(length(classList) * imgSel(2), numBins);
        cnt = 1;
        for c = 1:length(classList)
            for i = 1:imgSel(2)
                quantized_descriptors = knnsearch(vocab', single(desc_te{c, i}'));
                histogram_te(cnt, :) = histcounts(quantized_descriptors, 1:numBins + 1);
                cnt = cnt + 1;
            end
        end
        % ...
        toc
        

        %% Save the histogram data.
        label_train = ones(size(histogram_tr, 1), 1);
        label_query = ones(size(histogram_te, 1), 1);
        for i = 1:10
            label_train((i-1) * 15 + 1:i * 15) = i;
            label_query((i-1) * 15 + 1:i * 15) = i;
        end
        data_train = histogram_tr;
        data_query = histogram_te;

        data_train(:,size(data_train,2)+1) = label_train;
        data_query(:,size(data_query,2)+1) = label_query;
    otherwise % Dense point for 2D toy data
        xrange = [-1.5 1.5];
        yrange = [-1.5 1.5];
        inc = 0.02;
        [x, y] = meshgrid(xrange(1):inc:xrange(2), yrange(1):inc:yrange(2));
        data_query = [x(:) y(:) zeros(length(x)^2,1)];
end
end

