function en_output = encoderm( x, g, alpha, puncture )
% uses interleaver map 'alpha'
% if puncture = 1, unpunctured, produces a rate 1/3 output of fixed length
% if puncture = 0, punctured, produces a rate 1/2 output 
% multiplexer chooses odd check bits from RSC1 
% and even check bits from RSC2

% determine the constraint length (K), memory (m) 
% and number of information bits plus tail bits.
%************************************************* ****************
% Of the input x for turbo coding
%************************************************* *****************
% To be coding sequence x
% Generating polynomial g
% Mixed alpha map
% J = alpha (i) i of the original bit mapped to position j
% Coefficient of puncturing puncture
% Puncture = 0 using the puncturing
% Puncture = 1 without puncturing
%************************************************* *************************
% Using the puncturing, the parity bit encoder using the first component of the odd bits
% Two even bits
%************************************************* **************************
% Encoded output has been modulated into +1 -1 sequence.

[n,K] = size(g); 
m = K - 1;
L_info = length(x); 
L_total = L_info + m;  
% Based on the decision matrix to generate additional tail bits
% = Number of registers encoder tail bits
% Generate the codeword corresponding to the 1st RSC coder
% End = 1, perfectly terminated;
input = x;
output1 = rsc_encode(g,input,puncture);
% Rsc coding for the input x
% Make a matrix with first row corresponing to info sequence
% Second row corresponsing to RSC # 1's check bits.
% Third row corresponsing to RSC # 2's check bits.

y(1,:) = output1(1:2:2*L_total);
y(2,:) = output1(2:2:2*L_total);
% Output of the encoding process (information-bit parity check bits of information bits.)
% Y (1,:) information bit
% Y (2,:) parity bit           

% interleave input to second encoder
for i = 1:L_info
   input1(1,i) = y(1,alpha(i)); 
end
% Interleave input to second encoder
output2 = rsc_encode(g, input1(1,1:L_info),puncture);
y(3,:) = output2(1:2:2*L_total);    % after interleaving information bits and tail bits
y(4,:) = output2(2:2:2*L_total);    % after interleaving information bits encoded parity bits and tail bits


if puncture > 0		% unpunctured
   for i = 1:L_total
       for j = 1:3
           en_output(1,3*(i-1)+j) = y(j,i);
       end
   end
else			% punctured into rate 1/2
   for i=1:L_total
       en_output(1,n*(i-1)+1) = y(1,i);
       if rem(i,2)
      % odd check bits from RSC1
          en_output(1,n*i) = y(2,i);
       else
      % even check bits from RSC2
          en_output(1,n*i) = y(3,i);
       end 
    end  
end

% antipodal modulation: +1/-1
% Serial output is as follows:
%en_output = 2 * en_output - ones(size(en_output));

% Parallel output is as follows:
en_output = 2 * y - ones(size(y));
% Modulation to a modulation into a +1
% 0-1
