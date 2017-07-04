function y=max_th(a,b)
%************************************************* ***************
% content: approximate threshold function.
%************************************************* ***************

%ln2=log(2);
if abs(a-b)<1
    y=max(a,b)+0.6931;
else
    y=max(a,b);
end