function out=trellis_simple(in_s,state)
%************************************************* ***************
%content: a simplified grid function
%************************************************* ***************

if state==1
    if in_s==-1
        out=-1;
    else
        out=1;
    end
end
if state==2
    if in_s==-1
        out=-1;
    else
        out=1;
    end
end

if state==3
    if in_s==-1
        out=1;
    else
        out=-1;
    end
end

if state==4
    if in_s==-1
        out=1;
    else
        out=-1;
    end
end

