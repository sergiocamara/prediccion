close all,clear all, clc, plt=0;

[output,name_ccaa,iso_ccaa, data_spain] = HistoricDataSpain()
%LLamamiento a la función
%[output, name_ccaa, iso_ccaa, data_spain] = HistoricDataSpain()
id_comunidad=7 % id comunidad
name_ccaa{id_comunidad}   % nombre de comunidad
output.historic{id_comunidad} % estrucutura



y = reshape(output.historic{1}.DailyCases,[],1);
 targetSeries = tonndata(y,false,false);
    net = narnet(1:4,10); % arbitrary until here
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;
    [X,Xi,Ai,t] = preparets(net,{},{},targetSeries);
    [net,tr] = train(net,X,t,Xi,Ai);
    netc = closeloop(net);
    [Xc,Xic,Aic,Tc] = preparets(netc,{},{},targetSeries);
    % NOW it's getting interesting:
    outputc = netc(Xc,Xic,Aic);