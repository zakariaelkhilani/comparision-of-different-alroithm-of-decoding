function pattern=interleaver_3GPP(x)
%************************************************* ***************
%  content: 3GPP Standard Interleaver
%************************************************* ***************
%   K	Number of bits input to Turbo code internal interleaver
%   R	Number of rows of rectangular matrix
%   C	Number of columns of rectangular matrix
%   p	Prime number
%   v	Primitive root
%   T   Inter-row permutation patterns


K=length(x);
%(1)	Determine the number of rows of the rectangular matrix, R
if K>=40 & K<=159
    R=5;
    T=[4, 3, 2, 1, 0]+1;
elseif (K>=160 & K<=200)|(K>=481 & K<=530)
    R=10;
    T=[9, 8, 7, 6, 5, 4, 3, 2, 1, 0]+1;
elseif (K>=2281 & K<=2480)|(K>=3161 & K<=3210)
    R=20;
    T=[19, 9, 14, 4, 0, 2, 5, 7, 12, 18, 16, 13, 17, 15, 3, 1, 6, 11, 8, 10]+1;
else
    R=20;
    T=[19, 9, 14, 4, 0, 2, 5, 7, 12, 18, 10, 8, 13, 17, 3, 1, 16, 6, 15, 11]+1;
end

%(2)	Determine the prime number to be used in the intra-permutation, p,
%and the number of columns of rectangular matrix, C
p_table=[7	11	13	17	19	23	29	31	37	41	43 ...
    47	53	59	61	67	71	73	79	83	89	97 ...
    101	103	107	109	113	127	131	137	139	149	151 ...
    157	163	167	173	179	181	191	193	197	199	211 ...
    223	227	229	233	239	241	251	257];
if K>=481 & K<=530
    p=53;
    C=p;
else
    %Find minimum prime number p from p_table
    ii=1;
    while (p_table(ii)+1)*R<K
        ii=ii+1;
    end
    p=p_table(ii);
    %determine C 
    if K<=(p-1)*R
        C=p-1;
    elseif K>(p-1)*R & K<=R*p
        C=p;
    elseif K>R*p
        C=p+1;
    end
end
        
%(3)Write the input bit sequence into the R*C rectangular matrix row by row
if K~=R*C
    x(1,(K+1):(R*C))=0; %dummy bits are padded 
end
matrix_unpermutation=(reshape(x,C,R))';
% Note: This sort of reshape according to the column, and also need to transpose what

%---------------------------- Intra-row and inter-row permutatio
v_table=[
     3     2     2     3     2     5     2     3     2     6     3 ...
     5     2     2     2     2     7     5     3     2     3     5 ...
     2     5     2     6     3     3     2     3     2     2     6 ...
     5     2     5     2     2     2    19     5     2     3     2 ...
     3     2     6     3     7     7     6     3     ];
%(1)	Select a primitive root v from the table
 if K>=481 & K<=530
     v=2;
 else
     v=v_table(ii);
 end
 
%(2)	Construct the base sequence s(j)   for intra-row permutation
s(1)=1;
for j=2:p-1
    s(j)=mod(v*s(j-1),p);
end
%(3)    determine the prime integer qi
q(1)=1;
q(1,2:R)=6;
for i=2:R
    while ((gcd(q(i),p-1)==1) & (q(i)>6) & (q(i)>q(i-1)))==0
        q(i)=q(i)+1;
    end
end
%(4)	Permute the sequence  qi to make the sequence  ri
r(T)=q;

%(5)	Perform the i-th (i = 0, 1, бн, R - 1) intra-row permutation
for i=1:R
    if C==p
        for j=1:p-1
            U(i,j)=s(mod(j*r(i),p-1)+1);
        end
        U(i,p)=0;
    elseif C==p+1
        for j=1:p-1
            U(i,j)=s(mod(j*r(i),p-1)+1);
        end
        U(i,p)=0;
        U(i,p+1)=p;
        if K==R*C & i==R
            temp=U(R,p+1);
            U(R,p+1)=U(R,1);
            U(R,1)=temp;
        end
    elseif C==p-1
        for j=1:p-1
            U(i,j)=s(mod(j*r(i),p-1)+1)-1;
        end
    end
end

for i=1:R
    matrix_intra_row_permutated(i,:)=matrix_unpermutation(i,U(i,:)+1);
end
    
for i=1:C
    matrix_interleaved(:,i)=matrix_intra_row_permutated(T,i);
end

k=1;
for i=1:C
    for j=1:R
         if matrix_interleaved(j,i)~=0
             pattern(k)=matrix_interleaved(j,i);
             k=k+1;
         end
    end
end
   
