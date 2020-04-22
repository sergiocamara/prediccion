
[output,name_ccaa,iso_ccaa, data_spain] = HistoricDataSpain()

plt = 0;
y = reshape(output.historic{1}.DailyCases,[],1)
T = tonndata(y,false,false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create the Neural Network %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
feedbackDelays = 1:2; % Default one
hiddenLayerSize = 10; % Number of hidden layer
trainFcn = 'trainbr'; % We use trainbr instead of trainlm to avoid overfitting
net = narnet(feedbackDelays,hiddenLayerSize,'open', trainFcn);

% Configure all the parameters of the NN
net.adaptFcn = 'adaptwb'; % setup dynamic weights and biases

% Setup Division of Data for Training, Validation, Testing
net.divideFcn = 'divideblock'; % divide data into blocks
net.divideMode = 'time'; % divide up every value
net.divideParam.trainRatio = 85/100;
net.divideParam.valRatio = 5/100;
net.divideParam.testRatio = 10/100;
net.performFcn = 'mse'; % Mean squared error
net.trainParam.epochs=2000;
% For MSE, normalize errors of multiple outputs in different ranges
net.performParam.normalization = 'standard';
% Choose the plot functions
net.plotFcns = {'plotperform','plottrainstate','plotresponse', ...
    'ploterrcorr','plotinerrcorr','plotwb','ploterrhist','plotfit', ...
    'plotregression',};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Train the Network   %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[xo,xio,aio,to] = preparets(net,{},{},T);

% Train the Neural Network
[net,tr,Yo,Eo,xfo,aio] = train(net,xo,to,xio,aio);

% Plot the open loop training results
to_mat = cell2mat(to);
yo_mat = cell2mat(Yo);
plt = plt + 1;
figure(plt), hold on
plot(3:length(T), to_mat, 'b')
plot(3:length(T), yo_mat, 'r--')
legend('TARGET', 'OUTPUT')
title('Open-loop results');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Validate the open-loop network   %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Yo, Xfo, Afo] = net(xo,xio,aio);
Eo = gsubtract(to,Yo);
ol_mse_perf = mse(net, to, Yo);
ol_perf = perform(net, to, Yo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Close the loop   %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[netc, xic, aic] = closeloop(net,xio,aio);
netc.name = [net.name ' - closed loop'];

[xc,xic,aic,tc] = preparets(netc,{},{},T);
[netc,tr,Yo,Eo,xfo,aio] = train(netc,xc,tc,xic,aic);
[yc,xfc,afc] = netc(xc,xic,aic);

% Plot the close-loop results
tc_mat = cell2mat(tc);
yc_mat = cell2mat(yc);
plt = plt + 1;
figure(plt), hold on
plot(3:length(T), tc_mat, 'b')
plot(3:length(T), yc_mat, 'r--')
legend('TARGET', 'OUTPUT')
title('Close-loop results');

% Test the Network
%y = net(x,xi,ai);
%e = gsubtract(t,y);
%performance = perform(net,t,y)
% View the Network
%view(net)
% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, plotresponse(t,y)
%figure, ploterrcorr(e)
%figure, plotinerrcorr(x,e)
% Closed Loop Network
% Use this network to do multi-step prediction.
% The function CLOSELOOP replaces the feedback input with a direct
% connection from the outout layer.


%netc = closeloop(net);
%[xc,xic,aic,tc] = preparets(netc,{},{},T);
%yc = netc(xc,xic,aic);
%perfc = perform(net,tc,yc)


%[x1,xio,aio,t] = preparets(net,{},{},T);
%  [y1,xfo,afo] = net(x1,xio,aio);
% [netc,xic,aic] = closeloop(net,xfo,afo);
[y2,xfc,afc] = netc(cell(0,67),xic,aic); % Predict next 7 values

% Step-Ahead Prediction Network
% For some applications it helps to get the prediction a timestep early.
% The original network returns predicted y(t+1) at the same time it is given y(t+1).
% For some applications such as decision making, it would help to have predicted
% y(t+1) once y(t) is available, but before the actual y(t+1) occurs.
% The network can be made to return its output a timestep early by removing one delay
% so that its minimal tap delay is now 0 instead of 1.  The new network returns the
% same outputs as the original network, but outputs are shifted left one timestep.

%nets = removedelay(net);
%[xs,xis,ais,ts] = preparets(nets,{},{},T);
%ys = nets(xs,xis,ais);
%stepAheadPerformance = perform(net,ts,ys)

%nets = removedelay(net);
%[x1,xio,aio,t] = preparets(nets,{},{},T);
%[netc,xic,aic] = nets(x1,xio,aio);


%stepAheadPerformance = perform(net,ts,ys)
