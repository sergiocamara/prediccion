function [output, name_countries, iso_countries] = HistoricData()

no_last_day = false;

if ~isfolder('data')        
    mkdir('data');
end


%% Import data
resultsRecovered = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv';
websave("data/recuperados.csv", resultsRecovered);
CRecovered = readcell("data/recuperados.csv", 'DatetimeType', 'text');

resultsDeaths = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv';
websave("data/fallecidos.csv", resultsDeaths);
CDeaths = readcell("data/fallecidos.csv", 'DatetimeType', 'text');

resultsConfirmed = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv';
websave("data/confirmados.csv", resultsConfirmed);
CConfirmed = readcell("data/confirmados.csv", 'DatetimeType', 'text');

iso_data = readcell('data/countries-iso-3166-1-alpha-3-v1_matlab.txt','Delimiter',{';','\n'});


%% Historic data
historic = cell(1,2); % (# countries, 2)


%% Confirmed
l_confirmed = {'no_valid'};

for ix_country = 2 : size(CConfirmed, 1)
    
    country = CConfirmed{ix_country, 2};
    ix_country_rep = [];
    
    if ~isempty(historic{1,1})
        ix_country_rep = find(ismember(historic(:,1), country));
    else
        historic(1,:) = [];
    end
 
    if isempty(find(ismember(l_confirmed(1,:), country)))
        
        AcumulatedCases = cell2mat(CConfirmed(ix_country, 5:end-no_last_day));
        Days = CConfirmed(1, 5:end-no_last_day);
        
        if isempty(ix_country_rep)
            
            data = struct;
            data.AcumulatedCases = AcumulatedCases;
            data.label_x = cellstr(datetime(Days, 'InputFormat', 'MM/dd/yy', 'Format', 'dd-MM-yyyy'));
            
            historic{end+1,1} = country;
            historic{end,2} = data; 
             
            if isempty(find(ismember(iso_data(:, 2), country))) 
                disp(country);
                historic{end,3} = upper(country(1:3));
            else
                historic{end,3} = iso_data{find(ismember(iso_data(:, 2), country)), 1};
            end
            
        else        
            
            historic{ix_country_rep,2}.AcumulatedCases = AcumulatedCases; 
            historic{ix_country_rep,2}.label_x = cellstr(datetime(Days, 'InputFormat', 'MM/dd/yy', 'Format', 'dd-MM-yyyy'));
            
        end
        
        l_confirmed(find(ismember(l_confirmed, 'no_valid'))) = [];
        l_confirmed{end+1} = country;
        
    else
        
        data = historic{ix_country_rep, 2};
        data.AcumulatedCases = data.AcumulatedCases + cell2mat(CConfirmed(ix_country, 5:end-no_last_day));
        historic{ix_country_rep, 2} = data;
        
    end
    
end


%% Deaths
l_deaths = {'no_valid'};

for ix_country = 2 : size(CDeaths, 1)
    
    country = CDeaths{ix_country, 2};
    ix_country_rep = find(ismember(historic(:,1), country));

    if isempty(find(ismember(l_deaths(1,:), country)))
        
        if isempty(ix_country_rep)     
            continue;
        end      
            
        historic{ix_country_rep,2}.Deaths = cell2mat(CDeaths(ix_country, 5:end-no_last_day));
        
        l_deaths(find(ismember(l_deaths, 'no_valid'))) = [];
        l_deaths{end+1} = country;
        
    else
        
        data = historic{ix_country_rep, 2};       
        data.Deaths = data.Deaths + cell2mat(CDeaths(ix_country, 5:end-no_last_day));        
        historic{ix_country_rep, 2} = data;
        
    end

end


%% Recovered old cvs
l_recovered = {'no_valid'};
all_days = cellstr(datetime(CConfirmed(1, 5:end-no_last_day), 'InputFormat', 'MM/dd/yy', 'Format', 'MM-dd-yyyy'));
day_end = '03-22-2020';
ix_end_day = find(ismember(all_days, day_end));

for ix_country = 2 : size(CRecovered, 1)
    
    country = CRecovered{ix_country, 2};
    ix_country_rep = find(ismember(historic(:,1), country));

    if isempty(find(ismember(l_recovered(1,:), country)))

        if isempty(ix_country_rep)     
            continue;
        end

        historic{ix_country_rep,2}.AcumulatedRecoveries = cell2mat(CRecovered(ix_country, 5:4+ix_end_day));
        
        l_recovered(find(ismember(l_recovered, 'no_valid'))) = [];
        l_recovered{end+1} = country;

    else

        data = historic{ix_country_rep, 2};  
        data.AcumulatedRecoveries = data.AcumulatedRecoveries + cell2mat(CRecovered(ix_country, 5:4+ix_end_day)); 
        historic{ix_country_rep, 2} = data;

    end

end


%% Recovered new daily cvs
url_daily_recovered_csv = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_daily_reports/';

for idx_day = 1 + ix_end_day : length(all_days)
   
    websave(['data/', all_days{idx_day}, '.csv'], [url_daily_recovered_csv, all_days{idx_day}, '.csv']);
    CDayRecovered = readcell(['data/', all_days{idx_day}, '.csv'], 'DatetimeType', 'text');
    l_recovered = {'no_valid'};

    for ix_country = 2 : size(CDayRecovered, 1)
       
        country = CDayRecovered{ix_country, 4};
        ix_country_rep = find(ismember(historic(:,1), country));

        if isempty(find(ismember(l_recovered(1,:), country)))

            if isempty(ix_country_rep)     
                continue;
            end
     
            if isfield(historic{ix_country_rep,2}, 'AcumulatedRecoveries')
                historic{ix_country_rep,2}.AcumulatedRecoveries(idx_day) = CDayRecovered{ix_country, 10};
            else
                historic{ix_country_rep,2}.AcumulatedRecoveries = [zeros(1, idx_day-1), CDayRecovered{ix_country, 10}];
            end
            
            l_recovered(find(ismember(l_recovered, 'no_valid'))) = [];
            l_recovered{end+1} = country;

        else

            data = historic{ix_country_rep, 2};  
            data.AcumulatedRecoveries(end) = data.AcumulatedRecoveries(end) + CDayRecovered{ix_country, 10}; 
            historic{ix_country_rep, 2} = data;

        end
        
    end
    
end


%% Cases and Daily data
for idx_country = 1 : size(historic, 1)

    data = historic{idx_country, 2}; 
    
    if ~isfield(data, 'AcumulatedRecoveries')
        data.AcumulatedRecoveries = zeros(1, length(data.label_x));
    end
    
    if ~isfield(data, 'Deaths')
        data.Deaths = zeros(1, length(data.label_x));
    end
    
    data.Cases = data.AcumulatedCases - data.Deaths - data.AcumulatedRecoveries;
    
    data.DailyCases = data.AcumulatedCases(1);
    data.DailyDeaths = data.Deaths(1);
    data.DailyRecoveries = data.AcumulatedRecoveries(1);
    
    for idx_day = 1 : length(data.label_x) - 1
        
        data.DailyCases(idx_day+1) = data.AcumulatedCases(idx_day+1) - data.AcumulatedCases(idx_day);
        data.DailyCases(find(data.DailyCases<0)) = 0;
        
        data.DailyDeaths(idx_day+1) = data.Deaths(idx_day+1) - data.Deaths(idx_day);
        data.DailyDeaths(find(data.DailyDeaths<0)) = 0;
        
        data.DailyRecoveries(idx_day+1) = data.AcumulatedRecoveries(idx_day+1) - data.AcumulatedRecoveries(idx_day);
        data.DailyRecoveries(find(data.DailyRecoveries<0)) = 0;
        
    end
    
    historic{idx_country, 2} = data;
    
end


%% Only data

output = struct;
output.historic = historic(:,2);

name_countries = historic(:,1);
iso_countries = historic(:,3);

end
    