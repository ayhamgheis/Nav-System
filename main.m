clc; clear; close all;

% Load accelerometer data for various orientations
orientations = {'Left', 'Right', 'Screen', 'Top', 'Back', 'Bottom'};
fileNames = {'Accelerometerleft.csv', 'Accelerometerright.csv', 'Accelerometerscreen.csv', ...
             'Accelerometertop.csv', 'Accelerometerback.csv', 'Accelerometerbottom.csv'};

for i = 1:length(orientations)
    accelData = readtable(fileNames{i});
    plotAccelerometerData(accelData, orientations{i});
    plotAccelerometerAngles(accelData, orientations{i});
end

% Process linear acceleration data with gravity subtraction
accelerometer = readtable('Accelerometerp4.csv');
gravity_data = readtable('Gravityp4.csv');
linear_acceleration = accelerometer{:, {'x', 'y', 'z'}} - gravity_data{:, {'x', 'y', 'z'}};

% Step Detection
threshold = 1; % Define a threshold for step detection
[peaks, locs] = findpeaks(linear_acceleration(:,3), 'MinPeakHeight', threshold);

% Speed and Displacement Calculation
dt = 0.01; % Sample time interval
velocity = cumtrapz(dt, linear_acceleration);
displacement = cumtrapz(dt, velocity);

% Plotting displacement
figure;
plot(displacement);
xlabel('Seconds');
ylabel('Distance (m)');
title('Calculated Distance Walked Over Time');
legend('X', 'Y', 'Z');
ax = gca; % Get current axis
xticks = get(ax, 'XTick'); % Get current x-tick marks
newXTickLabels = arrayfun(@(x) sprintf('%.1f', x / 10), xticks, 'UniformOutput', false); % Generate new labels
set(ax, 'XTickLabel', newXTickLabels); % Set new x-tick labels
function plotAccelerometerData(accelData, orientation)
    % Assuming 'seconds_elapsed' column exists for filtering data
    if ismember('seconds_elapsed', accelData.Properties.VariableNames)
        filteredData = accelData(accelData.seconds_elapsed <= 4, :);
    else
        filteredData = accelData;
    end
    
    figure;
    plot(filteredData.x, 'r', 'DisplayName', 'X-axis');
    hold on;
    plot(filteredData.y, 'g', 'DisplayName', 'Y-axis');
    plot(filteredData.z, 'b', 'DisplayName', 'Z-axis');
    hold off;
    
    xlabel('Seconds');
    ylabel('Acceleration (m/s^2)');
    title(['Accelerometer Data (', orientation, ')']);
    legend show;
    grid on;
end

function plotAccelerometerAngles(accelData, orientation)
    % Assuming 'seconds_elapsed' column exists for filtering data
    if ismember('seconds_elapsed', accelData.Properties.VariableNames)
        filteredData = accelData(accelData.seconds_elapsed <= 4, :);
    else
        filteredData = accelData;
    end
    
    roll = atan2(filteredData.y, filteredData.z) * (180/pi);
    pitch = atan2(-filteredData.x, sqrt(filteredData.y.^2 + filteredData.z.^2)) * (180/pi);
    
    figure;
    subplot(2,1,1);
    plot(roll, 'r', 'DisplayName', 'Roll');
    xlabel('Seconds');
    ylabel('Angle (degrees)');
    title(['Roll Angle (', orientation, ')']);
    legend show;
    grid on;
    
    subplot(2,1,2);
    plot(pitch, 'b', 'DisplayName', 'Pitch');
    xlabel('Seconds');
    ylabel('Angle (degrees)');
    title(['Pitch Angle (', orientation, ')']);
    legend show;
    grid on;
end
