function [soft_out,ex_info]=constituent_decoder_SemiTh(in,app)
%************************************************* ***************
%  content: sub-decoder.
% threshold standard code TURBO-LOG-MAP decoder
% Generate a matrix in accordance [1 1 0 1; 1011]
% Input to the RSC after a soft Gaussian channel input, and outputs for soft output and external information
%************************************************* ***************
x=in(1,:);             % bit input system
y=in(2,:);              % input parity bit
in_length=length(in);
Kw=log(2);

% --- Initialize &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
Infty = -128;
d=zeros(8,2,in_length);    % branching measure, eight possible states, 0 or 1 input
                            %D(S,i,k)
a=Infty*ones(8,in_length);  % prior to the branch measure, A (S, k)
a(1,1)=0;                   % from the all-zero state began to register
b=Infty*ones(8,in_length+1);%measured after the branch, B (S, k)
b(1,in_length+1)=0;           % register all-zero state by the end of

% --- Calculate metrics and LLR &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&for k=1:in_length
    d(1,2,k)=x(k)+y(k)+app(k);
    d(2,2,k)=d(1,2,k);
    d(7,2,k)=d(1,2,k);
    d(8,2,k)=d(1,2,k);
    
    d(3,2,k)=x(k)+app(k);
    d(4,2,k)=d(3,2,k);
    d(5,2,k)=d(3,2,k);
    d(6,2,k)=d(3,2,k);

    d(3,1,k)=y(k);
    d(4,1,k)=d(3,1,k);
    d(5,1,k)=d(3,1,k);
    d(6,1,k)=d(3,1,k);
    
    if k>1
        a(1,k)=max(a(1,k-1),(a(2,k-1)+d(2,2,k-1)))+Kw;
        a(2,k)=max((a(4,k-1)+d(4,1,k-1)),(a(3,k-1)+d(3,2,k-1)))+Kw;
        a(3,k)=max((a(5,k-1)+d(5,1,k-1)),(a(6,k-1)+d(6,2,k-1)))+Kw;
        a(4,k)=max(a(8,k-1),(a(7,k-1)+d(7,2,k-1)))+Kw;
        a(5,k)=max(a(2,k-1),(a(1,k-1)+d(1,2,k-1)))+Kw;
        a(6,k)=max((a(3,k-1)+d(3,1,k-1)),(a(4,k-1)+d(4,2,k-1)))+Kw;
        a(7,k)=max((a(6,k-1)+d(6,1,k-1)),(a(5,k-1)+d(5,2,k-1)))+Kw;
        a(8,k)=max(a(7,k-1),(a(8,k-1)+d(8,2,k-1)))+Kw;      
    end
    
    if k==in_length
        b(1,k)=max(b(1,k+1),(b(5,k+1)+d(1,2,k)))+Kw;
        b(2,k)=max(b(5,k+1),(b(1,k+1)+d(2,2,k)))+Kw;
        b(3,k)=max((b(6,k+1)+d(3,1,k)),(b(2,k+1)+d(3,2,k)))+Kw;
        b(4,k)=max((b(2,k+1)+d(4,1,k)),(b(6,k+1)+d(4,2,k)))+Kw;
        b(5,k)=max((b(3,k+1)+d(5,1,k)),(b(7,k+1)+d(5,2,k)))+Kw;
        b(6,k)=max((b(7,k+1)+d(6,1,k)),(b(3,k+1)+d(6,2,k)))+Kw;
        b(7,k)=max(b(8,k+1),(b(4,k+1)+d(7,2,k)))+Kw;
        b(8,k)=max(b(4,k+1),(b(8,k+1)+d(8,2,k)))+Kw;

         % Of LLR --------------------------------------
        l(k)=max([...
            (a(1,k)+d(1,2,k)+b(5,k+1)),(a(2,k)+d(2,2,k)+b(1,k+1)),...
            (a(3,k)+d(3,2,k)+b(2,k+1)),(a(4,k)+d(4,2,k)+b(6,k+1)),...
            (a(5,k)+d(5,2,k)+b(7,k+1)),(a(6,k)+d(6,2,k)+b(3,k+1)),...
            (a(7,k)+d(7,2,k)+b(4,k+1)),(a(8,k)+d(8,2,k)+b(8,k+1))...
            ])-max([...
            (a(1,k)+b(1,k+1)),(a(2,k)+b(5,k+1)),...
            (a(3,k)+d(3,1,k)+b(6,k+1)),(a(4,k)+d(4,1,k)+b(2,k+1)),...
            (a(5,k)+d(5,1,k)+b(3,k+1)),(a(6,k)+d(6,1,k)+b(7,k+1)),...
            (a(7,k)+b(8,k+1)),(a(8,k)+b(4,k+1))...
            ]);
    end
end

for k=in_length-1:-1:1
        b(1,k)=max(b(1,k+1),(b(5,k+1)+d(1,2,k)))+Kw;
        b(2,k)=max(b(5,k+1),(b(1,k+1)+d(2,2,k)))+Kw;
        b(3,k)=max((b(6,k+1)+d(3,1,k)),(b(2,k+1)+d(3,2,k)))+Kw;
        b(4,k)=max((b(2,k+1)+d(4,1,k)),(b(6,k+1)+d(4,2,k)))+Kw;
        b(5,k)=max((b(3,k+1)+d(5,1,k)),(b(7,k+1)+d(5,2,k)))+Kw;
        b(6,k)=max((b(7,k+1)+d(6,1,k)),(b(3,k+1)+d(6,2,k)))+Kw;
        b(7,k)=max(b(8,k+1),(b(4,k+1)+d(7,2,k)))+Kw;
        b(8,k)=max(b(4,k+1),(b(8,k+1)+d(8,2,k)))+Kw;


          % Of LLR --------------------------------------
        l(k)=max([...
            (a(1,k)+d(1,2,k)+b(5,k+1)),(a(2,k)+d(2,2,k)+b(1,k+1)),...
            (a(3,k)+d(3,2,k)+b(2,k+1)),(a(4,k)+d(4,2,k)+b(6,k+1)),...
            (a(5,k)+d(5,2,k)+b(7,k+1)),(a(6,k)+d(6,2,k)+b(3,k+1)),...
            (a(7,k)+d(7,2,k)+b(4,k+1)),(a(8,k)+d(8,2,k)+b(8,k+1))...
            ])-max([...
            (a(1,k)+b(1,k+1)),(a(2,k)+b(5,k+1)),...
            (a(3,k)+d(3,1,k)+b(6,k+1)),(a(4,k)+d(4,1,k)+b(2,k+1)),...
            (a(5,k)+d(5,1,k)+b(3,k+1)),(a(6,k)+d(6,1,k)+b(7,k+1)),...
            (a(7,k)+b(8,k+1)),(a(8,k)+b(4,k+1))...
            ]);
end
soft_out=l;
ex_info=soft_out-app-x;