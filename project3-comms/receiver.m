function est_bits=receiver(signal)
% Define data length
samples = 5;

% Find mean high and low amplitudes for filter
amp_h = mean(signal(signal>0));
amp_l = mean(signal(signal<0));

% Created matched filters;
high = amp_h*ones(1,samples);
low = amp_l*ones(1,samples);

% Filter signal, reshape to find mean for each possible bit
filtered_sig = (filter(high,1,signal)-filter(low,1,signal));    
est_bits = mean(reshape(filtered_sig,samples,[]));

% Sort by threshold
k_opt = mean(signal);
est_bits(est_bits>k_opt) = 1;
est_bits(est_bits<k_opt) = 0;
end