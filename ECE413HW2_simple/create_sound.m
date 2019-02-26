%{
Karol Wadolowski

This function returns a vector of the sound of an instrument in a certain
note.

Inputs: 
    instrument  : struct
    notes        : struct containing duration and note information
    constants   : struct containing constants

Outputs:
    soundSample : sample of sound for the chosen instrument

%}

function [soundSample]=create_sound(instrument,notes,constants)
    %Base frequency. Values based on equal temperament with A4 = 440Hz. 
    %This only selects starting frequencie and not equal or just.
    if notes.note == "C4"
        freq = 261.63;
    elseif notes.note == "E4"
        freq = 329.63;
    else    %G4/default
        freq = 392;
    end
    
    %Equal or Just temperament
    if instrument.temperament == "Equal"
        twv = (2)^(1/12);       %Twelfth root of 2
        freqs = [1, twv^3, twv^4, twv^7];   %Frequencies needed for major/minor
    else    %Just/default
        freqs = [1, 6/5, 5/4, 3/2];
    end
    freqs = freq*freqs;         %Scale appropriately
    
    %Major or Minor chord or note
    if instrument.mode == "Major"
        freqs = freqs([1,3,4]);
    elseif instrument.mode == "Minor"
        freqs = freqs([1,2,4]);
    else %Note/default
        freqs = freqs(1);
    end
    
    t = 0:1/constants.fs:(constants.durationChord-1/constants.fs);  %Time vector
    soundSample = zeros(1,length(t));
    
    %Generate sound based on synthesis type
    if instrument.sound == "Additive"
        %Bell from Jerse Fig 4.28
        amps = [1,.67,1,1.8,2.67,1.67,1.46,1.33,1.33,1,1.33];   %Amplitudes
        durs = constants.durationChord*...
            [1,.9,.65,.55,.325,.35,.25,.2,.15,.1,.075];         %Durations
        rs = freqs'*([.56,.56,.92,.92,1.19,1.7,2,2.74,3,3.76,4.07] + ...
            [0,1,0,1.7,0,0,0,0,0,0,0]);                         %Frequencies
        f2s = 2.^(-10*(1./durs')*t);            %Waveform Envelope
        
        env = repmat(amps',1,length(t)).*f2s;   %Envelope scaled by amplitudes
        
        for ii = 1:length(freqs)
            temp = sin(2*pi*(rs(ii,:)')*t);
            soundSample = soundSample + sum(env.*temp,1);     %Modulate and add in
        end
        
        
    elseif instrument.sound == "Subtractive"
        %Square wave tthat moves resonant freq from high to low
        
        r = .9;                         %Radius of pole locations
        th = linspace(pi,0,length(t));  %Theta value at each time
        
        %Make resonant freq have gain of 0dB
        amps = abs(exp(2*1j*th)-2*r*cos(th).*exp(1j*th)+r^2); %Scaling factor
        
        sq = square(freqs'*t);     %Square waves   
        
        %Apply difference equation
        %y[n] = amps[n]x[n] - 2rcos(th[n])y[n-1] -r^2)y[n-2]
        y = repmat(soundSample,length(freqs),1);
        y(:,1) = sum(amps(1)*sq(:,1));
        y(:,2) = sum(amps(2)*sq(:,2) +2*r*cos(th(2))*y(:,1));
        
        for ii = 3:length(t)
            y(:,ii) = sum(amps(ii)*sq(:,ii) +2*r*cos(th(ii))*y(:,ii-1) - (r^2)*y(:,ii-2),2);
        end
        soundSample = sum(y,1);
        
    elseif instrument.sound == "FM"
        %Bell from Jerse 5.9b
        amp = 1;            %Amplitude
        IMAX = 10;          %Variable from Jerse
        
        fm = freqs*7/5;     %Modulation frequencies
        %s1 is left path from figure
        s1 = amp*2.^(-10*(1/constants.durationChord)*t);
        
        %s2 is right path from figure
        s2 = (fm')*IMAX*2.^(-10*(1/constants.durationChord)*t);
        s2 = s2.*sin(2*pi*fm'*t);
        s2 = s2 + sin(2*pi*freqs'*t);
        
        soundSample = s1.*(sum(s2,1));

    else %Waveshaper
        %Clarinet from Jerse Fig 5.28
        amp = 1;
        rise = round(.085*constants.fs);    %Index of last rise time
        decay = round((constants.durationChord-.64)*constants.fs);  %Index of first decay time
        
        %Envelope (Rise, Sustain, Decay)
        env = [linspace(0,255,rise),255*ones(1,decay-rise-1),linspace(255,0,length(t)-decay+1)];
        s1 = repmat(env,length(freqs),1).*sin(2*pi*freqs'*t) + 256;
        
        %Put the signal throught the F(x) function
        F1 = (s1<200).*(s1/400-1);
        F2 = (200<=s1 & s1<=312).*(s1/112-32/14);
        F3 = (312<s1).*(s1/398 + 1/2-312/398);
        
        soundSample = amp*(sum(F1+F2+F3,1));
    end
    
end

    
    
    
    
    
    
    
    
    
    
    