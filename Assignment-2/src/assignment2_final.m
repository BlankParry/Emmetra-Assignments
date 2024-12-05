function DenoiseSharpnessUIApp
    % Create the main UI figure
    fig = uifigure('Name', 'Denoise and Sharpness Techniques', 'Position', [100, 100, 900, 600]);

    % Set background color
    fig.Color = [0.9, 0.95, 1]; % Light blue background

    % Add a title label
    uilabel(fig, ...
        'Text', 'Denoise and Sharpness Techniques', ...
        'FontSize', 18, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'Position', [200, 520, 500, 40], ...
        'BackgroundColor', [0.7, 0.85, 1], ... % Slightly darker blue
        'FontColor', [0, 0.3, 0.6]); % Darker blue text

    % Upload button
    uploadButton = uibutton(fig, 'Text', 'Upload RAW Image', ...
        'FontSize', 14, 'FontWeight', 'bold', ...
        'Position', [350, 350, 200, 50], ...
        'BackgroundColor', [0.6, 1, 0.6], ... % Light green button
        'FontColor', [0, 0.4, 0], ... % Dark green text
        'ButtonPushedFcn', @(btn, event) uploadImage());

    % Generate output button
    generateButton = uibutton(fig, 'Text', 'Generate Output', ...
        'FontSize', 14, 'FontWeight', 'bold', ...
        'Position', [350, 250, 200, 50], ...
        'BackgroundColor', [1, 0.8, 0.6], ... % Light orange button
        'FontColor', [0.6, 0.3, 0], ... % Dark orange text
        'ButtonPushedFcn', @(btn, event) generateOutput());

    % Placeholder for storing processed image data
    appData = struct();
    appData.white_balanced_image = [];
    appData.denoised_images = [];
    appData.snr_values = [];
    appData.edge_strengths = [];
    appData.sharpened_image = [];

    % Function to upload the RAW image
    function uploadImage()
        [file, path] = uigetfile('*.raw', 'Select RAW Image');
        if isequal(file, 0)
            uialert(fig, 'No file selected.', 'Error', 'Icon', 'error');
            return;
        end
        file_path = fullfile(path, file);
        appData.white_balanced_image = processRawImage(file_path);
        uialert(fig, 'Image uploaded and processed successfully.', 'Success', 'Icon', 'info');
    end

    % Function to generate and display the output
    function generateOutput()
        if isempty(appData.white_balanced_image)
            uialert(fig, 'Please upload a RAW image first.', 'Error', 'Icon', 'error');
            return;
        end

        % Generate outputs for all denoising methods
        appData.denoised_images.median = applyMedianFilter(appData.white_balanced_image);
        appData.denoised_images.bilateral = applyBilateralFilter(appData.white_balanced_image);
        appData.denoised_images.gaussian = applyGaussianFilter(appData.white_balanced_image);
        appData.denoised_images.dncnn = applyDnCNN(appData.white_balanced_image);
        appData.sharpened_image = applyLaplacianFilter(appData.white_balanced_image);

        % Convert all images to 24-bit RGB format
        appData.white_balanced_image = convertTo24Bit(appData.white_balanced_image);
        appData.denoised_images.median = convertTo24Bit(appData.denoised_images.median);
        appData.denoised_images.bilateral = convertTo24Bit(appData.denoised_images.bilateral);
        appData.denoised_images.gaussian = convertTo24Bit(appData.denoised_images.gaussian);
        appData.denoised_images.dncnn = convertTo24Bit(appData.denoised_images.dncnn);
        appData.sharpened_image = convertTo24Bit(appData.sharpened_image);

        % Compute SNR for each method
        appData.snr_values.white_balanced = computeAllSNR(appData.white_balanced_image);
        appData.snr_values.median = computeAllSNR(appData.denoised_images.median);
        appData.snr_values.bilateral = computeAllSNR(appData.denoised_images.bilateral);
        appData.snr_values.gaussian = computeAllSNR(appData.denoised_images.gaussian);
        appData.snr_values.dncnn = computeAllSNR(appData.denoised_images.dncnn);

        % Compute Edge Strength for each method
        appData.edge_strengths.white_balanced = computeEdgeStrength(appData.white_balanced_image);
        appData.edge_strengths.median = computeEdgeStrength(appData.denoised_images.median);
        appData.edge_strengths.bilateral = computeEdgeStrength(appData.denoised_images.bilateral);
        appData.edge_strengths.gaussian = computeEdgeStrength(appData.denoised_images.gaussian);
        appData.edge_strengths.dncnn = computeEdgeStrength(appData.denoised_images.dncnn);
        appData.edge_strengths.laplacian = computeEdgeStrength(appData.sharpened_image);

        % Display output in a new figure
        outputFig = uifigure('Name', 'Comparison Window', 'Position', [100, 100, 1200, 800]);
        outputFig.Color = [1, 0.95, 0.8]; % Light yellow background

        methods = {'White Balanced', 'Median Filter', 'Bilateral Filter', ...
                   'Gaussian Filter', 'DnCNN Model', 'Laplacian Enhanced'};
        images = {appData.white_balanced_image, appData.denoised_images.median, ...
                  appData.denoised_images.bilateral, appData.denoised_images.gaussian, ...
                  appData.denoised_images.dncnn, appData.sharpened_image};
        snrData = {appData.snr_values.white_balanced, appData.snr_values.median, ...
                   appData.snr_values.bilateral, appData.snr_values.gaussian, ...
                   appData.snr_values.dncnn, []};
        edgeStrengths = {appData.edge_strengths.white_balanced, appData.edge_strengths.median, ...
                         appData.edge_strengths.bilateral, appData.edge_strengths.gaussian, ...
                         appData.edge_strengths.dncnn, appData.edge_strengths.laplacian};

        for i = 1:length(images)
            ax = uiaxes(outputFig, 'Position', [(mod(i-1, 3)*400)+20, 800-(ceil(i/3)*350), 360, 300]);
            imshow(images{i}, 'Parent', ax);
            title(ax, methods{i}, 'FontSize', 14);

            % Display SNR and Edge Strength
            if ~isempty(snrData{i}) || ~isempty(edgeStrengths{i})
                snrStr = '';
                esStr = '';
                if ~isempty(snrData{i})
                    snrStr = sprintf('SNR (Light: %.2f, Medium: %.2f, Dark: %.2f)', ...
                        snrData{i}(1), snrData{i}(2), snrData{i}(3));
                end
                if ~isempty(edgeStrengths{i})
                    esStr = sprintf('Edge Strength: %.2f', edgeStrengths{i});
                end
                uilabel(outputFig, 'Text', [snrStr, newline, esStr], ...
                    'Position', [(mod(i-1, 3)*400)+60, 780-(ceil(i/3)*350), 300, 60], ...
                    'HorizontalAlignment', 'center', ...
                    'BackgroundColor', [0.9, 1, 0.9], ... % Light green background
                    'FontSize', 12, 'FontWeight', 'bold');
            end
        end
    end

    function img = convertTo24Bit(img)
        img = uint8(img * 255); % Scale to [0, 255] and convert to 8-bit per channel
    end
end

% --------------------------------------------------------------------
% Helper Functions
% --------------------------------------------------------------------

% (Helper functions like processRawImage, applyMedianFilter, etc. remain the same)

function [white_balanced_image] = processRawImage(file_path)
    % Load and preprocess the Bayer RAW image
    width = 1920;
    height = 1280;
    fid = fopen(file_path, 'r');
    bayer_raw = fread(fid, [width, height], '*uint16');
    fclose(fid);
    bayer_raw = bayer_raw';
    bayer_raw = double(bayer_raw) / 4095;
    raw_image = demosaic(uint16(bayer_raw * 65535), 'grbg');
    raw_image = double(raw_image) / 65535;

    % White Balance (Gray World Algorithm)
    R = raw_image(:, :, 1);
    G = raw_image(:, :, 2);
    B = raw_image(:, :, 3);
    R = R * (mean(G(:)) / mean(R(:)));
    B = B * (mean(G(:)) / mean(B(:)));
    white_balanced_image = cat(3, R, G, B);
end

function img = applyMedianFilter(img)
    img = cat(3, medfilt2(img(:, :, 1), [3 3]), ...
                 medfilt2(img(:, :, 2), [3 3]), ...
                 medfilt2(img(:, :, 3), [3 3]));
end

function img = applyBilateralFilter(img)
    for i = 1:3
        img(:, :, i) = imbilatfilt(img(:, :, i), 0.1, 1);
    end
end

function img = applyGaussianFilter(img)
    img = imgaussfilt(img, 1);
end

function img = applyDnCNN(img)
    net = denoisingNetwork('DnCNN');
    img = cat(3, ...
        denoiseImage(im2single(img(:, :, 1)), net), ...
        denoiseImage(im2single(img(:, :, 2)), net), ...
        denoiseImage(im2single(img(:, :, 3)), net));
end

function img = applyLaplacianFilter(img)
    for i = 1:3
        img(:, :, i) = img(:, :, i) - imfilter(img(:, :, i), fspecial('laplacian', 0.5));
    end
    img = mat2gray(img);
end

function snrValues = computeAllSNR(image)
    roi_light = [50, 150, 50, 150];
    roi_medium = [200, 300, 200, 300];
    roi_dark = [350, 450, 350, 450];
    snrValues = [computeSNR(image, roi_light), ...
                 computeSNR(image, roi_medium), ...
                 computeSNR(image, roi_dark)];
end

function snrValue = computeSNR(image, roi)
    % Extract the region of interest (ROI)
    region = image(roi(1):roi(2), roi(3):roi(4), :);
    % Convert the region to double for numerical operations
    region = double(region);
    % Compute SNR
    snrValue = mean(region(:)) / std(region(:));
end


function edgeStrength = computeEdgeStrength(image)
    % Ensure the input image is normalized to [0, 1]
    image = double(image) / 255;

    % Convert to grayscale if the image is RGB
    if size(image, 3) == 3
        gray_image = rgb2gray(image);
    else
        gray_image = image;
    end

    % Compute gradients
    [Gx, Gy] = imgradientxy(gray_image);

    % Compute edge strength as the mean gradient magnitude
    edgeStrength = mean(sqrt(Gx.^2 + Gy.^2), 'all');
end
