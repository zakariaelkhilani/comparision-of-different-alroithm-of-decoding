function y = rsc_encode(g, x, end1)

% encodes a block of data x (0/1)with a recursive systematic
% convolutional code with generator vectors in g, and
% returns the output in y (0/1).
% if end1>0, the trellis is perfectly terminated
% if end1<0, it is left unterminated;

% determine the constraint length (K), memory (m), and rate (1/n)
% and number of information bits.
%************************************************* **********************
% Rsc encoder
% Input
% G generator matrix
% X the input sequence
% Endl tail sign bit processing
%> 0 there are m-bit code to the end of the last bit of x reaches the last register
% <X 0 is not the end of the last bit into the bit encoder
% Output
% Coded bits (information bits 1 parity bit parity 2.. N-1 parity bit information bit ????)
%************************************************* **********************
[n,K] = size(g);
m = K - 1;
if end1>0
  L_info = length(x);
  L_total = L_info + m;
else
  L_total = length(x);
  L_info = L_total - m;
end  
% To determine the encoding output according to endl
%> 0 an increase of m tail bits m is the number of encoder register
% <0 without tail bits

% initialize the state vector
state = zeros(1,m);

% The encoder register is initialized to all 0
% Generate the codeword

for i = 1:L_total
   if end1<0 | (end1>0 & i<=L_info)
       % | Or
       % & And
      d_k = x(1,i);
        % Normal coding
   elseif end1>0 & i>L_info
      % terminate the trellis
      d_k = rem( g(1,2:K)*state', 2 );
      % Last bit processing
   end
 
   a_k = rem( g(1,:)*[d_k state]', 2 );
     % A_k is the first register in the encoder input;
   [output_bits, state] = encode_bit(g, a_k, state);
   % since systematic, first output is input bit
   output_bits(1,1) = d_k;
    % Coded bits of the first bit of information
   y(n*(i-1)+1:n*i) = output_bits;
   % Coded bits (information bits 1 parity bit parity 2.. N-1 parity bit information bit ????)
end
