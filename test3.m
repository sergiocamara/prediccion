
clearvars; clear all;

[output,name_ccaa,iso_ccaa, data_spain] = HistoricDataSpain()

variables = {'DailyCases','Hospitalized','Critical','DailyDeaths','DailyRecoveries'};
posicionesVariables = {'8','2','3','9','10'};


for i=1:length(name_ccaa)
    structura = output.historic{i};
    names = fieldnames(output.historic{i});
    figure(i)
    title(name_ccaa{i});
    hold on
    for j=1:length(variables)
        n=str2num(posicionesVariables{j});
        variables{j};
        y = eval(['structura.' names{n}])
        plot(y)
    end
end






