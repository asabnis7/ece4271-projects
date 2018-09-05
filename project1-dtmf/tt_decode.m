% Arjun Sabnis
% ECE 4271, Spring 2018
% DTMF decoder - dual-tone frequency conversion to phone number

function digits = tt_decode(x)

digits = []; % Output phone digits
fs = 8000; % Sampling frequency 
data_l = length(x); % Signal length

% Define dual-tone frequency bands
low_freq = [692 770 852 941];
high_freq = [1209 1336 1477 1633];

% Define dialpad digit layout
phone = ['1', '2', '3', 'A'; 
          '4', '5', '6', 'B'; 
          '7', '8', '9', 'C';
          '*', '0', '#', 'D'];

% Chebyshev highpass to filter out dial-tone, other artifacts
[b,a] = cheby1(1,1,(2*690/fs),'high');
x = filter(b, a, x);

% High-order FIR filters are giving better performance than IIR here
% FIR bandpass for lowband
[O,Fo,Ao,W] = firpmord([660 680 960 980],[0 1 0],[0.01 0.01 0.01],fs);
B = firpm(O-7,Fo,Ao,W);
low_band = filter(B,1,x);

% FIR bandpass for highband
[O,Fo,Ao,W] = firpmord([1160 1190 1660 1680],[0 1 0],[0.01 0.01 0.01],fs);
C = firpm(O-7,Fo,Ao,W);
high_band = filter(C,1,x);

% Find optimum N/k for low/high bands using brute-force technique
M = 110; % Window size -> allows at least two full windows in 40 ms
n_max = 400; % Limit for N to maintain computation speed
valid_range = 0.015; % DTMT error threshold allowed = 1.5%
sample_separation = 2; % Different freqs must be k >= 2 indices apart

N_low = [];
N_high = [];
low_ind = [];
high_ind = [];

% Keep all possible candidates for N
for n = M:n_max
    k_low = round(low_freq*(n/fs));
    k_high = round(high_freq*(n/fs));
    low_error = abs(((k_low*(fs/n))-low_freq)./low_freq);
    high_error = abs(((k_high*(fs/n))-high_freq)./high_freq);
    
    if(all(low_error <= valid_range) && all(diff(k_low) >= sample_separation))
        N_low = [N_low n];
    end
    if(all(high_error <= valid_range) && all(diff(k_high) >= sample_separation))
        N_high = [N_high n];
    end
end

% Large number of N candidates - even smaller values are adequate
% Hence choose median value for DFT length for low/high bands
N_low = N_low(round(end/2));
N_high = N_high(round(end/2));
% Calculate respective k using N for each freq band
low_ind = round(low_freq*(N_low/fs));
high_ind = round(high_freq*(N_high/fs));

% Windowing signal to analyze components
% Window shifts by one window length every cycle
% No window overlap required
window_count = 0;
low_freq_prev = 0;
high_freq_prev = 0;
low_arr = [];
high_arr = [];

% We are only concerned about the magnitude of the FFT
% Use Goertzel's algorithm to calculate DFT kernel at given k
for i = 1:M-1:data_l-M+1
    f1_low = abs(gfft(low_band(i:i+M-1),N_low,low_ind(1)));
    f2_low = abs(gfft(low_band(i:i+M-1),N_low,low_ind(2)));
    f3_low = abs(gfft(low_band(i:i+M-1),N_low,low_ind(3)));
    f4_low = abs(gfft(low_band(i:i+M-1),N_low,low_ind(4)));
    
    f1_high = abs(gfft(high_band(i:i+M-1),N_high,high_ind(1)));
    f2_high = abs(gfft(high_band(i:i+M-1),N_high,high_ind(2)));
    f3_high = abs(gfft(high_band(i:i+M-1),N_high,high_ind(3)));
    f4_high = abs(gfft(high_band(i:i+M-1),N_high,high_ind(4)));
    
    % Find index of largest frequency present(if any)
    [lval, l_ind] = max([f1_low f2_low f3_low f4_low]);
    [hval, h_ind] = max([f1_high f2_high f3_high f4_high]);
    
    % Use averaging of highest obtained values to determine noise threshold
    low_arr = [low_arr lval];
    high_arr = [high_arr hval];
    mean_low = mean(low_arr);
    mean_high = mean(high_arr);
    
    % If largest found freq matches calculated index and is above threshold
    if(low_freq_prev == l_ind)&&(high_freq_prev == h_ind)&&(mean_low<lval)&&(mean_high<hval)
        window_count = window_count + 1;        
        % Add digit only once identified, no need to identify multiple times
        % Minimum tone length specified as 80 ms         
        if(window_count == floor(0.08/(M/fs))) 
            digits = [digits phone(l_ind, h_ind)];
        end
    else
        window_count = 0; % Tone not long enough, reset window count
    end
    % Store old kernel calculation for next comparison
    low_freq_prev = l_ind;
    high_freq_prev = h_ind;
end
% Format as required
digits = [digits(1:3) '-' digits(4:6) '-' digits(7:end)];
end