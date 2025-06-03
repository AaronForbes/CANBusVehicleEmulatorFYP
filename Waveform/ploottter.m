clear all
close all
clc
% Open .csv file
filename = 'WAVE1.CSV';
pathname = 'C:\Users\aaron\OneDrive - Loughborough University\Work\Part D\FYP\waveform\';
% if isequal(filename,0)
%     disp('User canceled file selection.');
%     return;
% end
filepath = fullfile(pathname, filename);

% Read CSV data
data = readmatrix(filepath);

% Time vector (assume first column is time, or just index if not present)
if size(data, 2) >= 1
    x = data(:,1);
else
    x = (1:size(data,1))';
end
y = data(:,2);

% Plot original data
figure;
plot(x, y, 'b');
title('Original Data');
xlabel('X');
ylabel('Y (2nd Column)');
grid on;

% Get trimming range from user
disp('Click two points on the plot to define the trimming range.');
[x_trim, ~] = ginput(2);
x_min = min(x_trim);
x_max = max(x_trim);

% Find indices within the selected range
trim_idx = x >= x_min & x <= x_max;
x_trimmed = x(trim_idx);
y_trimmed = movmean(y(trim_idx),15);

% Plot trimmed data
figure;
plot(x_trimmed, y_trimmed, 'k');
grid on;

ylabel('Potential Difference between CAN high and CAN low (mV)')
xlabel('Index')
title('Waveform of CAN message')
ylim([-50 2500])

% Threshold the waveform
binary_waveform = y_trimmed > 1000;

% Find first rising edge (0 -> 1)
rising_edge_index = find(diff(binary_waveform) == 1, 1, 'first');

if isempty(rising_edge_index)
    error('No rising edge found in the waveform.');
end

% Define bit parameters
bit_interval = 60;       % Number of indices per bit
sampling_offset = 30;    % Offset to sample in the middle of the bit

% Sample positions starting from first rising edge
start_index = rising_edge_index + sampling_offset;
sample_indices = start_index : bit_interval : length(binary_waveform);

% Ensure we don't exceed the array bounds
sample_indices = sample_indices(sample_indices <= length(binary_waveform));

% Extract bits
extracted_bits = binary_waveform(sample_indices);

% Display result
disp('Extracted binary bits:');
disp((extracted_bits<1)');

figure
plot(x_trimmed,binary_waveform<1,'k-')
ylabel('Binary Value Transmitted on CAN bus')
xlabel('Index')
title('Binary of CAN message')
ylim([-0.1 1.1])




