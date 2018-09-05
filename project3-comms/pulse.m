% Arjun Sabnis
% ECE 4271 - Spring 2018

function s = pulse(bits, SNR)
% Define pulse sample width and period
samples = 5;
T = 0.1;
signal = rectpulse(bits,samples);

% Determine signal amplitude to transmit
power = 10^(SNR/10); % Signal power
n0 = 2; % Noise power must be 1
A = sqrt((power*n0)/(2*T));
s = A*(signal-0.5);
end