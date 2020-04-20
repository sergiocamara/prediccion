close all,clear all, clc, plt=0;

[output,name_ccaa,iso_ccaa, data_spain] = HistoricDataSpain();
%LLamamiento a la función
%[output, name_ccaa, iso_ccaa, data_spain] = HistoricDataSpain()
id_comunidad=7; % id comunidad
name_ccaa{id_comunidad};   % nombre de comunidad
output.historic{id_comunidad}; % estrucutura


% Redes autoregresivas: tratan de predecir algo basándose en previos casos
% de ese algo. Tratan de capturar un patrón. 

y = reshape(output.historic{1}.DailyCases,[],1); % reshape daily cases in andalucia 
targetSeries = tonndata(y,false,false); % convert data to neural network array form
net = narnet(1:4,10); % arbitrary until here
net.divideParam.trainRatio = 85/100; % 85% of data for training
net.divideParam.valRatio = 5/100; % 5% of data for validation
net.divideParam.testRatio = 10/100; % 10% of data for testing
[X,Xi,Ai,t] = preparets(net,{},{},targetSeries); % prepare time series, for open-lop NN
[net,tr] = train(net,X,t,Xi,Ai); % train the neural network
netc = closeloop(net); % convert neural network to closed loop
[Xc,Xic,Aic,Tc] = preparets(netc,{},{},targetSeries); % prepare time series, for closed-loop NN
% NOW it's getting interesting:
outputc = netc(Xc,Xic,Aic);