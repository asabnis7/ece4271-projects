% Arjun Sabnis
% ECE 4271 - Spring 2018

function values = BERvsSNR
values = zeros(2,11);
for i = -2:8
    BER = transceiver(100000, i);
    values(1,i+3) = BER;
end
SNR = -2:8;
theoretical_BER = qfunc(sqrt(2.*(10.^(SNR./10))));
values(2,:) = theoretical_BER;

semilogy(SNR,values(1,:));
hold on, semilogy(SNR,values(2,:));
title('BER vs SNR'), xlabel('SNR (dB)'), ylabel('BER');
legend({'Experimental BER', 'Theoretical BER'});
end