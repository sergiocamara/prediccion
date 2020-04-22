clearvars; clear all;
[output,name_ccaa,iso_ccaa, data_spain] = HistoricDataSpain()

  
y = reshape(output.historic{1}.DailyCases,[],1)
T = tonndata(y,false,false);
% Create a Nonlinear Autoregressive Network
feedbackDelays = 1:2;
hiddenLayerSize = 2;
net = narnet(feedbackDelays,hiddenLayerSize);
% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer states.
% Using PREPARETS allows you to keep your original time series data unchanged, while
% easily customizing it for networks with differing numbers of delays, with
% open loop or closed loop feedback modes.
[x,xi,ai,t] = preparets(net,{},{},T);
% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 85/100;
net.divideParam.valRatio = 5/100;
net.divideParam.testRatio = 10/100;
net.performFcn = 'mse'; % Mean squared error
net.trainParam.epochs=2000;
% Train the Network
[net,tr] = train(net,x,t,xi,ai);
% Test the Network
y = net(x,xi,ai);
e = gsubtract(t,y);
performance = perform(net,t,y)

[x1,xio,aio,t] = preparets(net,{},{},T);
[y1,xfo,afo] = net(x1,xio,aio);
[netc,xic,aic] = closeloop(net,xfo,afo);
[y2,xfc,afc] = netc(cell(0,7),xic,aic); % Predict next 7 values
    
Forecast = horzcat(t,y2)
% Plot the close-loop results
tc_mat = cell2mat(t);
yc_mat = cell2mat(Forecast);
figure(4), hold on
plot(3:length(T), tc_mat, 'b')
plot(3:length(T), yc_mat, 'r--')
legend('TARGET', 'OUTPUT')
title('Close-loop results');


nets = removedelay(net);
[x1,xio,aio,t] = preparets(nets,{},{},T);
[netc,xic,aic] = nets(x1,xio,aio);
%stepAheadPerformance = perform(net,ts,ys)