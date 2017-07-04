

clc;
clear all;

algorithm = input('decoding algorithm [1: SIMPLIFIED-MAP, 2: MAX-MAP (the default),]:');
if isempty(algorithm)
   algorithm =2;
end

length_interleave = input('cutting length = frame length - the length of tail bits [1024]:');
if isempty(length_interleave)
   length_interleave = 1024;
end

iter = input('number of iterations [[1,2,3]]:');
if isempty(iter)
   iter =[1 2 3];
end

ferrlim = input('limit of error frames (up to this limit to stop the current SNR point test) [10]:');
if isempty(ferrlim)
   ferrlim =10;
end

max_EbNo = input('test the maximum Eb / No (dB) [2.4]:');
if isempty(max_EbNo)
   max_EbNo =2.4;
end

step_EbNo = input('Test Eb / No step size (dB) [0.2]:');
if isempty(step_EbNo)
   step_EbNo=0.2;
end

save_mat = input('to save the simulation results to a MAT-file [1 - Save (default), 0 - do not save]:');
if isempty(save_mat)
   save_mat=1;
end

if save_mat==1
    matFileName = input('enter file name','s');
    matFileName = strcat(matFileName,'.mat')
    if isempty(matFileName)
        matFileName='temporary test data. mat';
    end
end

time_begin=datestr(now);
rate=1/3;           %rate
m=3;                    % tail bits
fading_a=1;             %Fading amplitude
EbNo=0:step_EbNo:max_EbNo;                            %EbNo of sampling points
EbNoLinear=10.^(EbNo.*0.1);
num_block_size=length_interleave+m;    % test block size, that contains the last bit of the soft-input system series length
err_counter=zeros(max(iter),length(EbNo));        % initialization error bit counter
nferr= zeros(max(iter),length(EbNo));             % initialization error frame counter
ber=zeros(max(iter),length(EbNo));                 % initialization error bit rate

random_in=round(rand(1,length_interleave)); % random number
[turbod_out,alphain]=turbo(random_in);     % coding

for ii=1:length(iter)
    for nEN=1:length(EbNo)
        L_c=4*fading_a*EbNoLinear(nEN)*rate;
        sigma=1/sqrt(2*rate*EbNoLinear(nEN));
        nframe = 0;    % clear counter of transmitted frames
        if nEN==1 | ber(iter(ii),nEN-1)>9.0e-6
            while nferr(iter(ii),nEN)<ferrlim       % nferr: current iteration number, EbNo point of error frames
                nframe = nframe + 1; 
                noice=randn(4,num_block_size);   % noise
                soft_in=L_c*(turbod_out+sigma*noice);            % noise superimposed information
                [hard_out,soft_out]=decoder_all_algorithm(soft_in,alphain,iter(ii),algorithm);% decoding
                errs=length(find(hard_out(1:length_interleave)~=random_in));% current point error bit number
                
                if errs>0 
                    err_counter(iter(ii),nEN)=err_counter(iter(ii),nEN)+errs;
                    nferr(iter(ii),nEN)=nferr(iter(ii),nEN)+1;
                end
%                 fprintf('Current EbNo points:%1.2fdB; has been calculated:%2.0f frames; of which:%2.0f false frame \n',...
%                     EbNo(nEN),nframe,nferr(iter(ii),nEN));
            end
            ber(iter(ii),nEN) = err_counter(iter(ii),nEN)/nframe/(length_interleave);%bit error rate
            %fer(iter,nEN) = nferr(iter,nEN)/nframe; % frame error rate
        else
            ber(iter(ii),nEN)=NaN;
        end
        fprintf('the number of iterations:%1.0f; EbNo:%1.2fdB; error rate:%8.4e; \n',...
            iter(ii),EbNo(nEN),ber(iter(ii),nEN));
        if save_mat==1
            save (matFileName,'EbNo','ber');
        end
    end
end
semilogy(EbNo,ber(iter,: ));
grid on;
xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate');


time_end=datestr(now);

fprintf('------------------Congratulations! test is completed !-------------------\n'); 
disp(['Simulation start time:',time_begin,'=>',time_end])
fprintf('cutting length =%4dbit; number of iterations =%2d \n',length_interleave,iter);
fprintf('test the maximum Eb / No =%2.1fdB; test Eb / No step =%2.1fdB \n',max_EbNo,step_EbNo);
switch algorithm
    case 1
        fprintf('decoding algorithms: SIMPLIFIED-MAP \n');
    case 2
        fprintf('decoding algorithms: MAX-MAP \n');
    case 3
        fprintf('decoding algorithms: threshold MAX-LOG-MAP \n');
end
if save_mat==1
    fprintf('save the simulation results to =% 4s \n',matFileName);
end    
