close all; clear all; clc;

get_prediction_for_day_n(1);
get_prediction_for_day_n(2);
get_prediction_for_day_n(3);
get_prediction_for_day_n(4);
get_prediction_for_day_n(5);
get_prediction_for_day_n(6);
get_prediction_for_day_n(7);

function valores = get_prediction_for_day_n(day)
    [output,name_ccaa,iso_ccaa, data_spain] = HistoricDataSpain();

    % Variables we care about
    variables = containers.Map({'DailyCases','Hospitalized','Critical','DailyDeaths','DailyRecoveries'}, {10,4,5,11,12});
    variables_keys = keys(variables);

    cHeader = {'CCAA' 'FECHA' 'CASOS' 'Hospitalizados','UCI', 'Fallecidos','Recuperados'}; % CSV header
    textHeader = strjoin(cHeader, ','); % Header fields are separated by commas
    fid = fopen(strcat('IGH_SCS_',num2str(day),'.csv'),'w'); % Create the CSV that will contain the predictions
    fprintf(fid,'%s\n',textHeader); % Write header to file

    % Iterate over all the CCAA
    for i=1:length(name_ccaa)
        structura = output.historic{i}; % data of this ccaa
        names = fieldnames(output.historic{i}); % labels of the variables
        valores={1,7};
        valores(1) = iso_ccaa(i);
        next_day = datetime(output.historic{i}.label_x{length(output.historic{i}.label_x)}, 'InputFormat', 'dd-MM-yyyy') + caldays(1:day);
        valores(2) = cellstr(datestr(next_day(day)));

        for j=1:length(variables)  % Iterate over the variables of each CCAA
            n = variables(variables_keys{j});
            y = eval(['structura.' names{n}]);
            y = reshape(y,[],1);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%% Neural Network %%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            T = tonndata(y,false,false);
            % Create a Nonlinear Autoregressive Network
            feedbackDelays = 1:2;
            hiddenLayerSize = 2;
            net = narnet(feedbackDelays,hiddenLayerSize);
            % prepare data for network training
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

            % prepare data for closed-loop NN
            [x1,xio,aio,t] = preparets(net,{},{},T);
            [y1,xfo,afo] = net(x1,xio,aio);
            [netc,xic,aic] = closeloop(net,xfo,afo); % close the loop
            [y2,xfc,afc] = netc(cell(0,1),xic,aic); % Predict next 7 values

            % Write the prediction to the corresponding cell
            valores(j+2) = cellstr(num2str(y2{length(y2)}));
        end
        predict_string = strjoin(valores, ','); % separate the prediction string by commas
        fprintf(fid, '%s\n', predict_string); % write the prediction to the CSV file
    end
    fclose(fid);
end