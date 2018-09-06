% Arjun Sabnis
% ECE 4271 - Spring 2018

size_vec = [];
time_vec = [];
mse_vec = [];
total_saved = 0;
total_t = 0;
total_mse = 0;
for i = 1:7
    for j = 1:5
        [et,saved,mse,~] = bitRemove('kodim06.png',i);
        total_saved = total_saved + saved;
        total_t = total_t + et;
        total_mse = total_mse + mse;
    end
    size_vec = [size_vec total_saved/5];
    time_vec = [time_vec total_t/5];
    mse_vec = [mse_vec total_mse/5];
    total_saved = 0;
    total_t = 0;
end
% bar(1:7,mse_vec,0.2);
% hold on, bar(1:7,size_vec), ylabel('Compression Ratio');
% yyaxis right, plot(1:7,time_vec), ylabel('Time Taken (s)');
% xlabel('Integer Factor');