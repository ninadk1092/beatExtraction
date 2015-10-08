 % BleeTech
 % Tejas Gokhale
 % 06-10-2015
 close all;
 clear all;
 clc;
 audio_in = wavread('C:\Users\Tejas\bleetech\work\Audio\bohemian_rhapsody.wav');
 audio_en = abs(audio_in);
 
 %%% Sampling Rate = 44.1 kHz
 %%% Downsample 1024
 f_samp = 44.1e3;
 downsamp_ratio = 4096;
 block_size = downsamp_ratio*4;
 
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
%%Now divide the track into blocks of 8192 samples
 %%% Our aim is to find the max from the 8 values
 for b = 1:1:floor(L/block_size)-1
     for i=0:1:(block_size/downsamp_ratio)-1;
     block_values(i+1) = audio_en_ds(((b-1)*block_size)+(i*downsamp_ratio) + (downsamp_ratio/2));
     [block_max(b) max_timestamps(b)] = max(block_values);
     max_timestamps_loc(b) = max_timestamps(b)*downsamp_ratio + ((b-1)*block_size);
     end
 end
 
 beats = zeros(L, 1);
 for i=1:1:size(max_timestamps, 2)
     beats(max_timestamps_loc(i)) = 1;
 end
 
 
 for i=1:1:size(max_timestamps_loc, 2)-1
timestamp_interval (i+1) = max_timestamps_loc(i+1)-max_timestamps_loc(i);
end
% NFFT = 8192;            %% musical instruments dont usually go about 5000Hz
% fft_complex = fft(audio_en_ds, NFFT)/L;
% fft_mag = abs(fft_complex(1:NFFT/2+1));
% f = (f_samp/2)*linspace(0, 1, NFFT/2+1);
% plot(f, fft_mag);
plot(audio_en); hold; plot(audio_en_ds, '-r'); plot(beats, 'g');