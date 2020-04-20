[output,name_ccaa,iso_ccaa, data_spain] = HistoricDataSpain()
%LLamamiento a la función
%[output, name_ccaa, iso_ccaa, data_spain] = HistoricDataSpain()
id_comunidad=7 % id comunidad
name_ccaa{id_comunidad}   % nombre de comunidad
output.historic{id_comunidad} % estrucutura



n_comunidades = length(name_ccaa)

for i=1:n_comunidades
    figure(1)
        hold on
        ycases=output.historic{i}.DailyCases% serie temporal de
       
        hc(i) = plot(ycases,'DisplayName',name_ccaa{i}) %dibuja casos diarios
        title("Casos")
        
end
legend(hc, name_ccaa,'Location','westoutside')

for i=1:n_comunidades
    figure(2)
        hold on
        yhospitalized=output.historic{i}.Hospitalized% serie temporal de
       
        hh(i) = plot(yhospitalized,'DisplayName',name_ccaa{i}) %dibuja casos hospitalizados
        title("Hospitalizados")
end
legend(hh, name_ccaa,'Location','westoutside')

for i=1:n_comunidades
    figure(3)
        hold on
        yuci=output.historic{i}.Critical% serie temporal de
       
        hu(i) = plot(yuci,'DisplayName',name_ccaa{i}) %dibuja casos uci
        title("UCI")
end
legend(hu, name_ccaa,'Location','westoutside')

for i=1:n_comunidades
    figure(4)
        hold on
        ydeaths=output.historic{i}.DailyDeaths% serie temporal de
       
        hd(i) = plot(ydeaths,'DisplayName',name_ccaa{i}) %dibuja casos fallecidos
        title("Fallecidos")
end
legend(hd, name_ccaa,'Location','westoutside')

for i=1:n_comunidades
    figure(5)
        hold on
        yrecoveries=output.historic{i}.DailyRecoveries% serie temporal de
       
        hr(i) = plot(yrecoveries,'DisplayName',name_ccaa{i}) %dibuja casos recuperados
        title("Recuperados")
end
legend(hr, name_ccaa,'Location','westoutside')
