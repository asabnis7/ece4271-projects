% Arjun Sabnis
% ECE 4271, Spring 2018
% DTMF decoder - dual-tone frequency conversion to phone number

function digits = tt_decode2(x)

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

% Find noise threshold
low_arr = [];
high_arr = [];
for i = 1:M-1:80*M+1
    f1_low = abs(gfft(x(i:i+M-1),N_low,low_ind(1)));
    f2_low = abs(gfft(x(i:i+M-1),N_low,low_ind(2)));
    f3_low = abs(gfft(x(i:i+M-1),N_low,low_ind(3)));
    f4_low = abs(gfft(x(i:i+M-1),N_low,low_ind(4)));
    
    f1_high = abs(gfft(x(i:i+M-1),N_high,high_ind(1)));
    f2_high = abs(gfft(x(i:i+M-1),N_high,high_ind(2)));
    f3_high = abs(gfft(x(i:i+M-1),N_high,high_ind(3)));
    f4_high = abs(gfft(x(i:i+M-1),N_high,high_ind(4)));
    
    low_arr = [f1_low f2_low f3_low f4_low; low_arr];
    high_arr = [f1_high f2_high f3_high f4_high; high_arr];

end
stl = sqrt(var(low_arr,1));
sth = sqrt(var(high_arr,1));
low_arr = mean(low_arr,1);
high_arr = mean(high_arr,1);

% Chebyshev highpass to filter out dial-tone, other artifacts
[b,a] = cheby1(1,1,(2*690/fs),'high');
x = filter(b, a, x);

% FIR Filters per frequency
[O,Fo,Ao,W] = firpmord([1160 1190 1220 1250],[0 1 0],[0.01 0.01 0.01],fs);
C = firpm(O-7,Fo,Ao,W);
hb1 = filter(C,1,x);
[O,Fo,Ao,W] = firpmord([1300 1330 1350 1380],[0 1 0],[0.01 0.01 0.01],fs);
C = firpm(O-7,Fo,Ao,W);
hb2 = filter(C,1,x);
[O,Fo,Ao,W] = firpmord([1440 1470 1490 1520],[0 1 0],[0.01 0.01 0.01],fs);
C = firpm(O-7,Fo,Ao,W);
hb3 = filter(C,1,x);
[O,Fo,Ao,W] = firpmord([1590 1620 1640 1670],[0 1 0],[0.01 0.01 0.01],fs);
C = firpm(O-7,Fo,Ao,W);
hb4 = filter(C,1,x);
% Construct high band
high_band = hb1+hb2+hb3+hb4;

[O,Fo,Ao,W] = firpmord([650 680 700 730],[0 1 0],[0.01 0.01 0.01],fs);
C = firpm(O-7,Fo,Ao,W);
lb1 = filter(C,1,x);
[O,Fo,Ao,W] = firpmord([730 760 780 810],[0 1 0],[0.01 0.01 0.01],fs);
C = firpm(O-7,Fo,Ao,W);
lb2 = filter(C,1,x);
[O,Fo,Ao,W] = firpmord([820 850 870 900],[0 1 0],[0.01 0.01 0.01],fs);
C = firpm(O-7,Fo,Ao,W);
lb3 = filter(C,1,x);
[O,Fo,Ao,W] = firpmord([910 940 960 990],[0 1 0],[0.01 0.01 0.01],fs);
C = firpm(O-7,Fo,Ao,W);
lb4 = filter(C,1,x);
% Construct low band
low_band = lb1+lb2+lb3+lb4;

% Windowing signal to analyze components
% Window shifts by one window length every cycle
% No window overlap required
window_count = 0;
low_freq_prev = 0;
high_freq_prev = 0;
hval = zeros(1,4);
lval = zeros(1,4);
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
    
    lval = [f1_low f2_low f3_low f4_low; lval];
    hval = [f1_high f2_high f3_high f4_high; hval];
    
    % Find index of largest frequency present(if any)
    [l, l_ind] = max([f1_low f2_low f3_low f4_low]);
    [h, h_ind] = max([f1_high f2_high f3_high f4_high]);
    
    % If largest found freq matches calculated index and is above threshold
    if(low_freq_prev == l_ind)&&(high_freq_prev == h_ind)&&(low_arr(l_ind)+stl(l_ind)<l)&&(high_arr(h_ind)+sth(h_ind)<h)
        window_count = window_count + 1;
        sdlval = sqrt(var(lval,1));
        sdhval = sqrt(var(hval,1));
        mlval = mean(lval,1);
        mhval = mean(hval,1);
        % Add digit only once identified, no need to identify multiple times
        % Minimum tone length specified as 80 ms
        if(window_count == floor(0.08/(M/fs)))
            digits = [digits phone(l_ind, h_ind)];
        end
    else
        window_count = 0; % Tone not long enough, reset window count
        lval = zeros(1,4);
        hval = zeros(1,4);
    end
    % Store old kernel calculation for next comparison
    low_freq_prev = l_ind;
    high_freq_prev = h_ind;
end
% Format as required
digits = [digits(1:3) '-' digits(4:6) '-' digits(7:end)];
end