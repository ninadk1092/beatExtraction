function [t,xcr,D,onsetenv,oesr] = tempo2(d,sr,tmean,tsd,debug, onsetenv)
%%% Estimate the overall tempo of a track and its onset strength waveform
% _________________________________________________________________________
%%              Inputs
% =========================================================================
% d:         is the input audio at sampling rate sr
% sr:        sampling rate (usually 44.1kHz)
% tmean:     is the mode for BPM weighting (in bpm)
% tsd:       is its spread (in octaves)  
% debug:     causes a debugging plot
% onsetenv:  if onset env is input, ignore d and directly calculate tempo
% _________________________________________________________________________ 
%%              Outputs
% =========================================================================
% t:         t(1) is the lower BPM estimate, 
%            t(2) is the faster,
%            t(3) is the relative weight for t(1) compared to t(2)
% xcr:       windowed autocorrelation from which the BPM peaks were picked
% D:         mel-freq spectrogram
% onsetenv   "onset strength waveform", used for beat tracking
% oesr       sampling rate of onsetenv and D.

%%              Functions used (files to accompany this script)
% uses:      localmax, fft2melmx, specgram

%%              Info
%   LabROSA-coversongID is free software; you can redistribute it and/or 
%   modify it under the terms of the GNU General Public License version 2 
%   as published by the Free Software Foundation.
% 
%   LabROSA-coversongID is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License
%   along with LabROSA-coversongID; if not, write to the Free Software
%   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
%   02110-1301 USA
% 
%   See the file "COPYING" for the text of the license.

%%              Default inputs
if nargin < 3;   tmean = 110; end
if nargin < 4;   tsd = 0.9; end
if nargin < 5;   debug = 0; end
%%              Main
if sr < 2000
  % we were passed an onset env, not a waveform
  oesr = sr;
  onsetenv = d;
else
  onsetenv = [];
  % STFT with window size 32ms and window hop 4ms
  % 32ms @ 8kHz = 256 samples per window
  % 4ms @ 8kHz = 32 samples window hop
  sro = 8000;
  swin = 256;
  shop = 32;
  % mel channels
  nmel = 40;
  % sample rate for specgram frames (granularity for rest of processing)
  oesr = sro / shop;
end

% autocorrelation up to 4sec
acmax = round(4*oesr);
% init mel spectrogram
mel_D = 0;  

%%              Resample to 8kHz
if length(onsetenv) == 0
  % no onsetenv provided - have to calculate it
  % resample to 8 kHz
  if (sr ~= sro)
    d = resample(d,sro,sr);
    sr = sro;
  end
  
  %%            STFT with window-width 32ms and window-advance 4ms
  mel_D = specgram(d, swin, sr, swin, swin-shop);
  
  %%            FFT to Mel-bands mapping 
  % (to convert to an approximate auditory representation
  % Construct db-magnitude-mel-spectrogram
  mlmx = fft2melmx(swin,sr,nmel);
  mel_db_D = 20 * log10(max(1e-10, mlmx(:,1:(swin/2+1))*abs(mel_D)));
  % Only look at the top 80 dB
  max_db = max(max(mel_db_D));
  % pull up values to a minimum of 'max_db-80'
  D = max(mel_db_D, max_db - 80);
  
  %% The raw onset decision waveform
  
  % First order difference along time
  diff_D = diff(D')';
  % Half-Wave rectification (make all -ve values 0)
  hw_rect_D = max(0, diff_D);
  % Mean along frequency
  mean_D = mean(hw_rect_D);
  % dc-removed
  onsetenv = filter([1 -1], [1 -.99],mean_D); % filter(num, den, signal)
end

%%              Find approximate global period
% Find rough global period
% Only use the 1st 90 sec to estimate global period (avoid glitches?)
maxd = 60;
maxt = 120; % sec
maxcol = min(round(maxt*oesr), length(onsetenv));
mincol = max(1,maxcol-round(maxd*oesr));
xcr = xcorr(onsetenv(mincol:maxcol),onsetenv(mincol:maxcol),acmax);

% find local max in the global ac
rawxcr = xcr(acmax+1+[0:acmax]);
% window it around default bpm
bpms = 60*oesr./([0:acmax]+0.1);
xcrwin = exp(-.5*((log(bpms/tmean)/log(2)/tsd).^2));
xcr = rawxcr.*xcrwin;
xpks = localmax(xcr);  
% will not include any peaks in first down slope (before goes below
% zero for the first time)
xpks(1:min(find(xcr<0))) = 0;
% largest local max away from zero
maxpk = max(xcr(xpks));

% ?? then period is shortest period with a peak that approaches the max
%maxpkthr = 0.4;
%startpd = -1 + min(find( (xpks.*xcr) > maxpkthr*maxpk ) );
%startpd = -1 + (find( (xpks.*xcr) > maxpkthr*maxpk ) );

%% no, just largest peak after windowing
%startpd = -1 + find((xpks.*xcr) == max(xpks.*xcr));
%% ??Choose acceptable peak closest to 120 bpm
%%[vv,spix] = min(abs(60./(startpd/oesr) - 120));
%%startpd = startpd(spix);
%% No, just choose shortest acceptable peak
%startpd = startpd(1);
%
%% Choose best peak out of .33 .5 2 3 x this period
%candpds = round([.33 .5 2 3]*startpd);
%candpds = candpds(candpds < acmax);
%
%[vv,xx] = max(xcr(1+candpds));
%
%startpd2 = candpds(xx);


%% Add in 2x, 3x, choose largest combined peak
%xcr2 = resample(xcr,1,2);
%xcr2 = xcr2 + xcr(1:length(xcr2));
%xcr3 = resample(xcr,1,3);
%xcr3 = xcr3 + xcr(1:length(xcr3));
% Quick and dirty explicit downsampling
lxcr = length(xcr);
xcr00 = [0, xcr, 0];
%wts = exp(-wt^2);
%sc = 1/(1+2*wts);
%xcr2 = xcr(1:ceil(lxcr/2))+sc*(wts*xcr00(1:2:lxcr)+xcr00(2:2:lxcr+1)+wts*xcr00(3:2:lxcr+2));
%xcr3 = xcr(1:ceil(lxcr/3))+sc*(wts*xcr00(1:3:lxcr)+xcr00(2:3:lxcr+1)+wts*xcr00(3:3:lxcr+2));

xcr2 = xcr(1:ceil(lxcr/2))+.5*(.5*xcr00(1:2:lxcr)+xcr00(2:2:lxcr+1)+.5*xcr00(3:2:lxcr+2));
xcr3 = xcr(1:ceil(lxcr/3))+.33*(xcr00(1:3:lxcr)+xcr00(2:3:lxcr+1)+xcr00(3:3:lxcr+2));

%subplot(413)
%plot(xcr2);
%hold on;
%plot(xcr3,'c');
%hold off

if max(xcr2) > max(xcr3)
  [vv, startpd] = max(xcr2);
  startpd = startpd -1;
  startpd2 = startpd*2;
else
  [vv, startpd] = max(xcr3);
  startpd = startpd -1;
  startpd2 = startpd*3;
end

% Weight by superfactors
pratio = xcr(1+startpd)/(xcr(1+startpd)+xcr(1+startpd2));

t = [60/(startpd/oesr) 60/(startpd2/oesr) pratio];

% ensure results are lowest-first
if t(2) < t(1)
  t([1 2]) = t([2 1]);
  t(3) = 1-t(3);
end  

startpd = (60/t(1))*oesr;
startpd2 = (60/t(2))*oesr;
 %% Plots
if debug > 0

  % Report results and plot weighted autocorrelation with picked peaks
  disp(['Global bt pd = ',num2str(t(1)),' @ ',num2str(t(3)),[' / ' ...
                      ''],num2str(t(2)),' bpm @ ',num2str(1-t(3))]);

  subplot(414)
  plot([0:acmax],xcr,'-b', ...
       [0:acmax],xcrwin*maxpk,'-r', ...
       [startpd startpd], [min(xcr) max(xcr)], '-g', ...
       [startpd2 startpd2], [min(xcr) max(xcr)], '-c');
  grid;

end

%% localmax function
function m = localmax(x)
% return 1 where there are local maxima in x (columnwise)
% don't include first point, maybe last point
[nr,nc] = size(x);
if nr == 1
  lx = nc;
elseif nc == 1
  lx = nr;
  x = x';
else
  lx = nr;
end

if (nr == 1) || (nc == 1)
  m = (x > [x(1),x(1:(lx-1))]) & (x >= [x(2:lx),1+x(lx)]);
  if nc == 1
    % retranspose
    m = m';
  end
else
  % matrix
  lx = nr;
  m = (x > [x(1,:);x(1:(lx-1),:)]) & (x >= [x(2:lx,:);1+x(lx,:)]);
end