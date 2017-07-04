function [hard_out,soft_out]=decoder_all_algorithm(in,alphain,num_iterate,algorithm)
%************************************************* ***************
% content: three algorithms, turbo decoder, in which RSC encoder output
% Generate a matrix in accordance [1 1 0 1; 1011]
% Input to the RSC after a soft Gaussian channel input, and output to hard and soft output

%****************************************************************
m=3;    % register number
L_seq=length(in);
in1=in(1:2,:);
in2=in(3:4,:);

e_p=zeros(1,L_seq);

for it=1:num_iterate
    a_p(alphain)=e_p(1:L_seq-m);  % deinterleaving
    a_p(L_seq-m+1:L_seq)=0; % not counting the tail bit part of the external information
    switch algorithm
        case 1
            [so,e_p] = constituent_decoder_logmap(in1,a_p); % log-map decoding
        case 2
            [so,e_p] = constituent_decoder_max(in1,a_p); % max-log-map decoding
        case 3
            [so,e_p] = constituent_decoder_Th(in1,a_p);% threshold max-log-map decoding
    end
    
    a_p(1:L_seq-m)=e_p(alphain);  % mixed
    a_p(L_seq-m+1:L_seq)=0;  % not counting the tail bit part of the external information
    switch algorithm
        case 1
            [so,e_p] = constituent_decoder_logmap(in2,a_p); % log-map decoding
        case 2
            [so,e_p] = constituent_decoder_max(in2,a_p);% max-log-map decoding
        case 3
            [so,e_p] = constituent_decoder_Th(in2,a_p);% threshold max-log-map decoding
    end
end
% Decoding end, the output --------------------
soft_out(alphain)=so(1:L_seq-m);
hard_out=(sign(soft_out)+1)/2;
end