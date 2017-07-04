function [output, state] = encode_bit(g, input, state)


% This function takes as an input a single bit to be encoded,

% It returns as output n encoded data bits, where 1/n is the
% code rate.

% the rate is 1/n
% k is the constraint length
% m is the amount of memory

[n,k] = size(g);
m = k-1;

% determine the next output bit
for i=1:n
   output(i) = g(i,1)*input;
     % First register a bit before encoding value
   for j = 2:k
      output(i) = xor(output(i),g(i,j)*state(j-1));
      % Xor binary adder
   end;
end

state = [input, state(1:m-1)];
% Register state transition
