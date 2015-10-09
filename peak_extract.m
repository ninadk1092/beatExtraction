 % BleeTech
 % Tejas Gokhale
 % 06-10-2015
 %% Init
 close all;
 clear all;
 clc;
 %% Read Audio
 filename = 'instant_crush.wav';
 dir = 'C:\Users\Tejas\bleetech\audio\';
 in_path = strcat(dir, filename);
 
 audio_in = wavread(in_path);
 audio_en = abs(audio_in);
 
 %% Basic Parameters
 f_samp = 44.1e3;
 downsamp_ratio = 16;
 block_size = 2^15;
 samp_per_block = block_size/downsamp_ratio;
 
 %% Downsampling
 for i=0:1:floor(size(audio_en, 1)/downsamp_ratio)-1
     local_max = max(audio_en((i*downsamp_ratio +1):(i+1)*downsamp_ratio));
     audio_en_ds((i*downsamp_ratio +1):(i+1)*downsamp_ratio) = local_max;
 end
 
 
%  % for easy-zero crossing.... 0 to 0.05 = 0
%  for i=1:1:size(audio_en_ds)
%      if audio_en_ds(i) <0.1
%          audio_en_ds(i) = 0;
%      end
%  end
audio_en_ds = audio_en_ds';
L = size(audio_en_ds, 1);

%% Peak Detection
%%Now divide the track into blocks of 8192 samples
 %%% Our aim is to find the max from the 8 values
 for b = 1:1:floor(L/block_size)-1
     for i=0:1:(block_size/downsamp_ratio)-1;
     block_values(i+1) = audio_en_ds(((b-1)*block_size)+(i*downsamp_ratio) + (downsamp_ratio/2));
     [block_max(b) peak_timestamps(b)] = max(block_values);
     peak_timestamps_loc(b) = peak_timestamps(b)*downsamp_ratio + ((b-1)*block_size);
     end
 end
 
 beats = zeros(L, 1);
 for i=1:1:size(peak_timestamps, 2)
     beats(peak_timestamps_loc(i)) = 1;
 end
 
 %% Rhythm-Fitting
d1_peak_timestamp_loc = zeros(size(peak_timestamps_loc, 2)-1, 1);
d2_peak_timestamp_loc = zeros(size(peak_timestamps_loc, 2)-2, 1);
for i=1:1:size(peak_timestamps_loc, 2)-1
    d1_peak_timestamp_loc (i+1) = peak_timestamps_loc(i+1) - peak_timestamps_loc(i);
end
% NFFT = 8192;            %% musical instruments dont usually go about 5000Hz
% fft_complex = fft(audio_en_ds, NFFT)/L;
% fft_mag = abs(fft_complex(1:NFFT/2+1));
% f = (f_samp/2)*linspace(0, 1, NFFT/2+1);
% plot(f, fft_mag);



%% Phase Correction and Beat Interval Optimization
hist_time_intervals = hist(d1_peak_timestamp_loc, downsamp_ratio:downsamp_ratio:downsamp_ratio*(2*samp_per_block-1));
[intensity, index] = max(hist_time_intervals);

beat_interval = mode(index) *downsamp_ratio;       %% Must be a better method for this
% Lagrangian Multipliers for Optimization
% Constrained optimization

 for i=1:1:size(d1_peak_timestamp_loc, 1)
if ((beat_interval - 512 < d1_peak_timestamp_loc(i)) & (d1_peak_timestamp_loc(i) < beat_interval+ 512))
start_loc = peak_timestamps_loc(i);
break
end
end
%% Save vibration pattern
vibr_pattern = zeros(L, 1);
for i = start_loc:beat_interval:L
    vibr_pattern(i) = 1;
end


retraced_vibr_loc = start_loc:-beat_interval:1;
vib1 = min(retraced_vibr_loc);
for i= vib1:beat_interval:start_loc-1
    vibr_pattern(i) = 1;
end


out_path = strcat(dir, 'vib_', filename);
wavwrite(vibr_pattern, 44100, out_path);

%% Plots
plot(audio_en_ds); hold; plot(beats, 'g'); plot(vibr_pattern, '-r');
figure; hist(d1_peak_timestamp_loc, 1:1024:downsamp_ratio*(2*samp_per_block-1));