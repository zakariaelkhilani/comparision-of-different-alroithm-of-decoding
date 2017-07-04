%************************************************* ***************
%content: Trubo encoder
%************************************************* ***************

function [out,alphaout]=turbo(in);
% Turbo encoder
% In the input sequence, 01.
g=[1 0 1 1;
   1 1 0 1];

% Generate the matrix 1 + d ^ 2 + d ^ 3
% 1 + d + d ^ 3
% 3GPP standard generator matrix
[n,K]=size(g);
m=K-1;
nstates=2^m;
% Determine the number of states
puncture=1;
%Whether more than one non-deleted deleted 0
rate=1/(2+puncture);
% Encoding rate
pattern_ordinal=1:length(in);
%----------------------------------
%[temp,alpha]=sort(rand(1,length(in)));
% Get random interleaver
%----------------------------------
alpha=interleaver_3GPP(pattern_ordinal);
%3GPP Standard Interleaver get
%----------------------------------
en_output=encoderm(in,g,alpha,puncture);
% Encoding
alphaout=alpha;
% Interleaver output
out=en_output;
% Code output