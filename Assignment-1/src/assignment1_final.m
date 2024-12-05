classdef assignment1_final < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                   matlab.ui.Figure
        LoadImageButton            matlab.ui.control.Button
        DenoiseSlider              matlab.ui.control.Slider
        DenoiseSliderLabel         matlab.ui.control.Label
        GammaSlider                matlab.ui.control.Slider
        GammaSliderLabel           matlab.ui.control.Label
        SharpenSlider              matlab.ui.control.Slider
        SharpenSliderLabel         matlab.ui.control.Label
        WhiteBalanceSlider         matlab.ui.control.Slider
        WhiteBalanceSliderLabel    matlab.ui.control.Label
        ApplyButton                matlab.ui.control.Button
        DemosaicButton             matlab.ui.control.Button 
        ImageAxes                  matlab.ui.control.UIAxes
    end

    properties (Access = private)
        BayerImage          % Bayer image data
        ColorImage          % Demosaiced image data
        ProcessedImage      % Processed image data
    end

    methods (Access = private)
        
        % Load Image Button pushed function
        function LoadImageButtonPushed(app, ~)
            [file, path] = uigetfile('*.raw', 'Select the RAW image');
            if isequal(file, 0)
                return;
            end
            filepath = fullfile(path, file);
            fid = fopen(filepath, 'r');
            bayer_raw = fread(fid, [1920, 1280], '*uint16');
            fclose(fid);
            bayer_raw = bayer_raw';
            bayer_raw = double(bayer_raw) / 4095;
            app.BayerImage = bayer_raw;
            imshow(app.BayerImage, 'Parent', app.ImageAxes);
        end
        
        % Demosaic Button pushed function
        function DemosaicButtonPushed(app, ~)
            if isempty(app.BayerImage)
                return;
            end

            % Apply Demosaic
            app.ColorImage = demosaic(uint16(app.BayerImage * 65535), 'grbg');
            app.ColorImage = double(app.ColorImage) / 65535;

            % Display the color image
            imshow(app.ColorImage, 'Parent', app.ImageAxes);
        end
        
        % Apply Button pushed function
        function ApplyButtonPushed(app, ~)
            if isempty(app.ColorImage)
                return;
            end

            color_image = app.ColorImage;

            % Apply Quick Color Balance
            R = color_image(:, :, 1);
            G = color_image(:, :, 2);
            B = color_image(:, :, 3);
            R = R * (mean(G(:)) / mean(R(:)));
            B = B * (mean(G(:)) / mean(B(:)));
            color_image = cat(3, R, G, B);

            % Apply White Balance
            wb_factor = app.WhiteBalanceSlider.Value;
            gray_world_factor = mean(G(:));
            R = R * (gray_world_factor / mean(R(:))) * wb_factor;
            G = G * wb_factor;
            B = B * (gray_world_factor / mean(B(:))) * wb_factor;
            white_balanced_image = cat(3, R, G, B);

            % Apply Denoise
            denoise_strength = app.DenoiseSlider.Value;
            denoised_image = imgaussfilt(white_balanced_image, denoise_strength);

            % Apply Gamma Correction
            gamma_value = app.GammaSlider.Value;
            gamma_corrected_image = denoised_image .^ (1 / gamma_value);

            % Apply Sharpening
            sharpen_amount = app.SharpenSlider.Value;
            sharpened_image = imsharpen(gamma_corrected_image, 'Amount', sharpen_amount);

            % Enhance contrast and brightness
            sharpened_image = imadjust(sharpened_image, stretchlim(sharpened_image, [0.01 0.99]), []);

            % Improve color saturation using HSV color space
            hsv_image = rgb2hsv(sharpened_image);
            hsv_image(:, :, 2) = hsv_image(:, :, 2) * 1.2;
            hsv_image(:, :, 3) = hsv_image(:, :, 3) * 1.1;
            sharpened_image = hsv2rgb(hsv_image);

            % Convert to 24-bit RGB (uint8)
            app.ProcessedImage = uint8(sharpened_image * 255);

            % Display the processed image
            imshow(app.ProcessedImage, 'Parent', app.ImageAxes);
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 800 600];
            app.UIFigure.Name = 'Image Processing App';

            % Create LoadImageButton
            app.LoadImageButton = uibutton(app.UIFigure, 'push');
            app.LoadImageButton.ButtonPushedFcn = @(~, ~)app.LoadImageButtonPushed();
            app.LoadImageButton.Position = [25 520 150 30];
            app.LoadImageButton.Text = 'Load Image';
            app.LoadImageButton.FontWeight = 'bold';
            app.LoadImageButton.BackgroundColor = [0.6, 0.6, 1];

            % Create DenoiseSliderLabel
            app.DenoiseSliderLabel = uilabel(app.UIFigure);
            app.DenoiseSliderLabel.Position = [25 460 150 22];
            app.DenoiseSliderLabel.Text = 'Denoise Strength';
            app.DenoiseSliderLabel.FontWeight = 'bold';

            % Create DenoiseSlider
            app.DenoiseSlider = uislider(app.UIFigure);
            app.DenoiseSlider.Position = [25 440 200 3];
            app.DenoiseSlider.Limits = [0 5];
            app.DenoiseSlider.Value = 1;  % Default value

            % Create GammaSliderLabel
            app.GammaSliderLabel = uilabel(app.UIFigure);
            app.GammaSliderLabel.Position = [25 390 150 22];
            app.GammaSliderLabel.Text = 'Gamma Correction';
            app.GammaSliderLabel.FontWeight = 'bold';

            % Create GammaSlider
            app.GammaSlider = uislider(app.UIFigure);
            app.GammaSlider.Position = [25 370 200 3];
            app.GammaSlider.Limits = [0 3];
            app.GammaSlider.Value = 2.2;  % Default value

            % Create SharpenSliderLabel
            app.SharpenSliderLabel = uilabel(app.UIFigure);
            app.SharpenSliderLabel.Position = [25 320 150 22];
            app.SharpenSliderLabel.Text = 'Sharpen Amount';
            app.SharpenSliderLabel.FontWeight = 'bold';

            % Create SharpenSlider
            app.SharpenSlider = uislider(app.UIFigure);
            app.SharpenSlider.Position = [25 300 200 3];
            app.SharpenSlider.Limits = [0 3];
            app.SharpenSlider.Value = 0.7;  % Default value

            % Create WhiteBalanceSliderLabel
            app.WhiteBalanceSliderLabel = uilabel(app.UIFigure);
            app.WhiteBalanceSliderLabel.Position = [25 250 150 22];
            app.WhiteBalanceSliderLabel.Text = 'White Balance';
            app.WhiteBalanceSliderLabel.FontWeight = 'bold';

            % Create WhiteBalanceSlider
            app.WhiteBalanceSlider = uislider(app.UIFigure);
            app.WhiteBalanceSlider.Position = [25 230 200 3];
            app.WhiteBalanceSlider.Limits = [0 3];
            app.WhiteBalanceSlider.Value = 1;  % Default value

            % Create ApplyButton
            app.ApplyButton = uibutton(app.UIFigure, 'push');
            app.ApplyButton.ButtonPushedFcn = @(~, ~)app.ApplyButtonPushed();
            app.ApplyButton.Position = [25 150 150 30];
            app.ApplyButton.Text = 'Apply';
            app.ApplyButton.FontWeight = 'bold';
            app.ApplyButton.BackgroundColor = [0.6, 0.6, 1];

            % Create DemosaicButton
            app.DemosaicButton = uibutton(app.UIFigure, 'push'); % New Demosaic Button
            app.DemosaicButton.ButtonPushedFcn = @(~, ~)app.DemosaicButtonPushed();
            app.DemosaicButton.Position = [25 110 150 30];
            app.DemosaicButton.Text = 'Demosaic';
            app.DemosaicButton.FontWeight = 'bold';
            app.DemosaicButton.BackgroundColor = [0.6, 0.6, 1];
            
            % Create ImageAxes
            app.ImageAxes = uiaxes(app.UIFigure);
            app.ImageAxes.Position = [250 100 500 400];
            app.ImageAxes.Title.String = 'Processed Image';
        end
    end

    % App initialization and construction
    methods (Access = public)

        % Construct app
        function app = assignment1_final

            % Create UIFigure and components
            app.createComponents();

            % Register the app with App Designer
            registerApp(app, app.UIFigure);

            if nargout == 0
                clear app;
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure);
        end
    end
end
