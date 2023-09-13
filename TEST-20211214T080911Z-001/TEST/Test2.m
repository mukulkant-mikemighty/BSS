%--------------------------------------------------------------------------

%% ICA demo (pre-mixed audio)
% TODO(brimoor): how to get this to work?
%
% Audio descriptions
%
% rsm2_mA/B: music + counting english
%  rss_mA/B: counting english + counting spanish
%  rssd_A/B: talking english + talking spanish
%

rng(42);

% Knobs
Fs    = 16000; % Sampling rate of input audio
paths = {'C:\Users\somna\Documents\MATLAB\pca_ica\TEST\rsm2_mA.wav','C:\Users\somna\Documents\MATLAB\pca_ica\TEST\rsm2_mB.wav'};
%paths = {'audio/rss_mA.wav','audio/rss_mB.wav'};
%paths = {'audio/rssd_A.wav','audio/rssd_B.wav'};
[d, r] = deal(numel(paths));
r = r + 1;

% Load audio
Zmixed = loadAudio(paths);

% Fast ICA (negentropy)
Zica1 = normalizeAudio(fastICA(Zmixed,r,'negentropy'));

% Fast ICA (kurtosis)
Zica2 = normalizeAudio(fastICA(Zmixed,r,'kurtosis'));

% Max-kurtosis ICA
%Zica3 = normalizeAudio(kICA(Zmixed,min(r,d)));

%Max likelyhood ICA
Zica3 = normalizeAudio(fastICA(Zmixed,r,'Maxlikelihood'));

%--------------------------------------------------------------------------
% Plot results
%--------------------------------------------------------------------------
audio = [];

% Mixed waveforms
for i = 1:d
    audio(end + 1).y = Zmixed(i,:); %#ok
    audio(end).Fs    = Fs;
    audio(end).name  = sprintf('mixed - %d',i);
end

% Fast ICA (negentropy) waveforms
for i = 1:r
    audio(end + 1).y = Zica1(i,:); %#ok
    audio(end).Fs    = Fs;
    audio(end).name  = sprintf('fastICA - neg - %d',i);
end

% Fast ICA (kurtosis) waveforms
for i = 1:r
    audio(end + 1).y = Zica2(i,:); %#ok
    audio(end).Fs    = Fs;
    audio(end).name  = sprintf('fastICA - kur - %d',i);
end

% Max-kurtosis ICA waveforms
%for i = 1:min(r,d)
%    audio(end + 1).y = Zica3(i,:); %#ok
%    audio(end).Fs    = Fs;
 %   audio(end).name  = sprintf('kICA - %d',i);
%end

% Fast ICA (Maxlikelihood) waveforms
for i = 1:r
    audio(end + 1).y = Zica3(i,:); %#ok
    audio(end).Fs    = Fs;
    audio(end).name  = sprintf('fastICA - Max - %d',i);
end



% Play audio
PlayAudio(audio);
%--------------------------------------------------------------------------
