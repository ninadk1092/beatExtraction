%%% Beat Extraction
% Tejas Gokhale
% 2015-10-30
% =========================================================================
%% Description
% This script uses beat2.m by LabROSA with a few modifications
% The highest bpm is chosen as the starting bpm to compute metronome
% A 'tapping-pattern' is recorded by the human
% Using this pattern as a template, the metronome is converted to a
% rhythmic beat
% _________________________________________________________________________
%% Inputs and Defaults
% =========================================================================
clear all;
close all;

sr = 44100;
oesr = 250;
song = 'californication.wav';
path = 'C:\Users\Tejas\bleetech\audio\';
filename = strcat(path, 'audio_', song);
au_in = wavread(filename);

duration = size(au_in, 1)/sr;

test

au_in = abs(au_in);
nargin = 2;
% _________________________________________________________________________
%% Metronome creation
[b, tempo, onsetenv, oesr] = beat2(au_in,sr);
% output 'b' in seconds. Convert to sample number
b = round(b*250);

%% User input
nbit = 8;
bpm = 200;

user_array_zeros = [2 4 0];

%% Locations of beats
% With appropriate deletions based on user_array_zeros
for i=1:1:size(b, 2)
    tap_loc(i, 1) = b(i);
    if sum(mod(i, 8) == user_array_zeros(:))
        tap_loc(i, 1) = 0;
    end
end

tap_loc = tap_loc(tap_loc~=0);

%% Correction of bpm
if tempo(2)/bpm < 1.1 & tempo(2)/bpm > 0.9
    bpm = tempo(2);
elseif tempo(2)/bpm < 0.55 & tempo(2)/bpm > 0.45
    bpm = tempo(2);
elseif tempo(2)/bpm < 2.2 & tempo(2)/bpm > 1.8
    bpm = 2*tempo(2);
end
% Samples per beat
spb = fix(60 * (1/bpm) * oesr);

%% Beat pattern signal 
% Of the same length as onsetenv
% Why onsetenv?
% We are processing at 250Hz and length(onsetenv) = length(au_in @250Hz)
length = fix(ceil(size(onsetenv, 2)/bpm)*bpm);
pat = zeros(length, nbit);
for i=1:1:size(tap_loc,1)
    pat(tap_loc(i), 1) = 1;  
end

%% Circular Shift
for i = 1:1:nbit-1
    pat(:, i+1) = circshift(pat(:,1),spb*i);
end
%% Receive tapping info from user-interface
% % Will be implemented later.
% % Temporarily,
% user_input = pat(:,1); 

user_tap = zeros(length, 1);
% create a rectangular pulse of 25 samp (100ms) centered around the beat
% 100ms is the minimum duration for discerning two sounds distinctly
for i = 1:1:size(user_input, 1)    
    if user_input(i, 1) == 1;
        if i <= 12
            user_tap(i:i+12, 1) = 1;
        elseif i< length-12
            user_tap(i-12:i+12, 1) = 1;
        else
            user_tap(i-12:i) =1;
        end
    end
end
%% Element-wise mult
xcr = zeros(length, nbit);
for i=1:1:nbit
    xcr(:, i) = times(pat(:, i), user_tap);
end

sum_xcr = sum(xcr);
[maxval, maxloc] = max(sum_xcr);

%% Beat Pattern
% now we know maxloc
% use the info from tap thing (which are zeros, which are ones)
% remove those elements from metronome locations b
% then create "beats" and write it to .wav file
for i=1:1:size(b, 2)
    beat_loc(i, 1) = b(i);
    if sum(mod(i, nbit) == mod(user_array_zeros(:)+ maxloc, nbit))
        beat_loc(i, 1) = 0;
    end
end

beat_loc = beat_loc(beat_loc~=0);
beats = zeros(size(au_in, 1 ), 1);
for i=1:1:size(beat_loc, 1)
    beats(fix(beat_loc(i)*44100/250), 1) =1;
end
%%
outname = strcat(path, 'beats_', song);
wavwrite(beats, 44100, outname);