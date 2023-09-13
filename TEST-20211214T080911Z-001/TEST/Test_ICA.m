%--------------------------------------------------------------------------

%% ICA demo (audio)
%
% Audio descriptions
%
% source1: siren
% source2: news (stocks)
% source3: foreign 1
% source4: news (food)
% source5: music (classical)
% source6: foreign 2
% source7: music (opera)
% source7: foreign 3
% source9: music (pop)
%
% voice1: talking (linear algebra)
% voice2: talking (sports)
%

rng(42);

% Knobs
Fs = 8000; % Sampling rate of input audio
paths = {'source1.wav','source2.wav','source3.wav'};
%paths = {'audio/voice1.mat','audio/voice2.mat'};
[p, d, r] = deal(numel(paths));
A = randomMixingMatrix(d,p);
%A = [0.6, 0.4; 0.4, 0.6];

% Load audio
Ztrue = loadAudio(paths);

% Generate mixed signals
Zmixed = normalizeAudio(A * Ztrue);

% Fast ICA (negentropy)
Zica1 = normalizeAudio(fastICA(Zmixed,r,'negentropy'));
temp1 = Zica1;
for i=1:3 
    for j =1:3
        temp2 = Zica1(j,:)-Ztrue(i,:);
        if(length(find(temp2>0.5))<100)
            temp1(i,:) = Zica1(j,:);
        end    
    end          
end
Zica1 = temp1;

% Fast ICA (kurtosis)
Zica2 = normalizeAudio(fastICA(Zmixed,r,'kurtosis'));
temp1 = Zica2;
for i=1:3 
    for j =1:3
        temp2 = Zica2(j,:)-Ztrue(i,:);
        if(length(find(temp2>0.5))<100)
            temp1(i,:) = Zica2(j,:);
        end    
    end          
end
Zica2 = temp1;

% Max-kurtosis ICA
%Zica3 = normalizeAudio(kICA(Zmixed,r));

%Maxlikelihood ICA 
Zica3 = normalizeAudio(fastICA(Zmixed,r,'Maxlikelihood'));
temp1 = Zica3;
for i=1:3 
    for j =1:3
        temp2 = Zica3(j,:)-Ztrue(i,:);
        if(length(find(temp2>0.5))<100)
            temp1(i,:) = Zica3(j,:);
        end    
    end          
end
Zica3 = temp1;
%---------------------------------------------------------------------------
% plots for SDRs
%source 1
figure(1);
pow1 = 10*log(bandpower(Ztrue(1,:)));
[r1,TD1] = sinad(Zica1(1,:));
SDR1 = pow1-TD1;

pow2 = 10*log(bandpower(Ztrue(1,:)));
[r2,TD2] = sinad(Zica2(1,:));
SDR2 = pow2-TD2;

pow3 = 10*log(bandpower(Ztrue(1,:)));
[r3,TD3] = sinad(Zica3(1,:));
SDR3 = pow3-TD3;

ax = categorical({'Negentropy','Kurtosis','Maxlikelihood'});
ax = reordercats(ax,{'Negentropy','Kurtosis','Maxlikelihood'});

%bar(ax,[-SDR1 ,-SDR2 ,-SDR3]);
title("Signal to noise distortion ratio for source 1");

%source2
figure(2);
pow1 = 10*log(bandpower(Ztrue(2,:)));
[r1,TD1] = sinad(Zica1(2,:));
SDR1 = pow1-TD1;

pow2 = 10*log(bandpower(Ztrue(2,:)));
[r2,TD2] = sinad(Zica2(2,:));
SDR2 = pow2-TD2;

pow3 = 10*log(bandpower(Ztrue(2,:)));
[r3,TD3] = sinad(Zica3(2,:));
SDR3 = pow3-TD3;

ax = categorical({'Negentropy','Kurtosis','Maxlikelihood'});
ax = reordercats(ax,{'Negentropy','Kurtosis','Maxlikelihood'});
bar(ax,[-SDR1 ,-SDR2 ,-SDR3]);
title("Signal to noise distortion ratio for source 2");

%source3
figure(3);
pow1 = 10*log(bandpower(Ztrue(3,:)));
[r1,TD1] = sinad(Zica1(3,:));
SDR1 = pow1-TD1;

pow2 = 10*log(bandpower(Ztrue(3,:)));
[r2,TD2] = sinad(Zica2(3,:));
SDR2 = pow2-TD2;

pow3 = 10*log(bandpower(Ztrue(3,:)));
[r3,TD3] = sinad(Zica3(3,:));
SDR3 = pow3-TD3;

ax = categorical({'Negentropy','Kurtosis','Maxlikelihood'});
ax = reordercats(ax,{'Negentropy','Kurtosis','Maxlikelihood'});

bar(ax,[-SDR1 ,-SDR2 ,-SDR3]);
title("Signal to noise distortion ratio for source 3");




%--------------------------------------------------------------------------
% Plot results
%--------------------------------------------------------------------------
audio = [];

% True waveforms
for i = 1:p
    audio(end + 1).y = Ztrue(i,:); %#ok
    audio(end).Fs    = Fs;
    audio(end).name  = sprintf('true - %d',i);
end

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

%Max-kurtosis ICA waveforms
%for i = 1:r
%    audio(end + 1).y = Zica3(i,:); %#ok
%    audio(end).Fs    = Fs;
%    audio(end).name  = sprintf('kICA - %d',i);
%end


% Fast ICA (Maxlikelihood) waveforms
for i = 1:r
    audio(end + 1).y = Zica3(i,:); %#ok
    audio(end).Fs    = Fs;
    audio(end).name  = sprintf('fastICA - Maxlike - %d',i);
end

% Play audio
PlayAudio(audio);



