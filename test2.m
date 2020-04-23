close all; clear all; clc;
[output,name_ccaa,iso_ccaa, data_spain] = HistoricDataSpain();

% get CLM data
y = reshape(output.historic{7}.DailyCases,[],1);

T = tonndata(y,false,false);

% Create a Nonlinear Autoregressive Network
feedbackDelays = 1:2; % default one
hiddenLayerSize = 2;  % number of hidden layers
net = narnet(feedbackDelays,hiddenLayerSize); % create the NAR NN
% prepare data for network training (open loop)
[x,xi,ai,t] = preparets(net,{},{},T);
% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 85/100;
net.divideParam.valRatio = 5/100;
net.divideParam.testRatio = 10/100;
net.performFcn = 'mse'; % Mean squared error
net.trainParam.epochs=100;
% Train the Network
[net,tr] = train(net,x,t,xi,ai);
% Test the Network
y = net(x,xi,ai);
e = gsubtract(t,y);

% prepare data for network training (close loop)
[x1,xio,aio,t] = preparets(net,{},{},T);
[y1,xfo,afo] = net(x1,xio,aio);
[netc,xic,aic] = closeloop(net,xfo,afo); % close the loop
[y2,xfc,afc] = netc(cell(0,7),xic,aic); % Predict next 7 values
    
% Plot the close-loop results
tc_mat = cell2mat(t); % convert from cell to matrix
y2_mat = cell2mat(y2);
figure(1), hold on
% Generate the date array for all the timestamps
fechas1 = datetime(output.historic{1}.label_x{3}, 'InputFormat', 'dd-MM-yyyy'):datetime(output.historic{1}.label_x{length(output.historic{1}.label_x)}, 'InputFormat', 'dd-MM-yyyy');
plot(datenum(fechas1), tc_mat, 'b')
% Create the 7 dates following the last recorded date
fechas2 = datetime(output.historic{1}.label_x{length(output.historic{1}.label_x)}, 'InputFormat', 'dd-MM-yyyy') + caldays(1:7); 
plot(datenum(fechas2), y2_mat, 'r-o')
legend('Observed', 'Forecasting')
title('Close-loop results');
datetick('x', 'dd-MM', 'keeplimits')
