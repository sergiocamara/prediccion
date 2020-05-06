
function valores = get_prediction_for_day_n(day)
    index_of_day = 55 + day;
    [output,name_ccaa,iso_ccaa, data_spain] = HistoricDataSpain();

    % Variables we care about
    variables = containers.Map({'DailyCases','Hospitalized','Critical','DailyDeaths','DailyRecoveries'}, {10,4,5,11,12});
    variables_keys = keys(variables);

    cHeader = {'CCAA' 'FECHA' 'CASOS' 'Hospitalizados','UCI', 'Fallecidos','Recuperados'}; % CSV header
    textHeader = strjoin(cHeader, ','); % Header fields are separated by commas
    fid = fopen(strcat('IGH_SCS_',num2str(day + 15),'_04_2020.csv'),'w'); % Create the CSV that will contain the predictions
    fprintf(fid,'%s\n',textHeader); % Write header to file

    % Iterate over all the CCAA
    for i=1:length(name_ccaa)
        
        names = fieldnames(output.historic{i}); % labels of the variables
        valores = cell(7);
        
        for j=1:length(variables)  % Iterate over the variables of each CCAA
            n = variables(variables_keys{j});
            y = eval(['structura.' names{n}]);
            y = cell2mat({1:index_of_day});
            y = reshape(y,[],1);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%% Neural Network %%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            T = tonndata(y,false,false);
            % Create a Nonlinear Autoregressive Network
            feedbackDelays = 1:2;
            hiddenLayerSize = 20;
            net = narnet(feedbackDelays,hiddenLayerSize);
            % prepare data for network training
            [x,xi,ai,t] = preparets(net,{},{},T);
            % Setup Division of Data for Training, Validation, Testing
            net.divideParam.trainRatio = 85/100;
            net.divideParam.valRatio = 5/100;
            net.divideParam.testRatio = 5/100;
            net.performFcn = 'mse'; % Mean squared error
            net.trainFcn = 'traingdx';
            net.trainParam.goal	= 0;

            net.trainParam.epochs=100;
                       % Train the Network
            [net,tr] = train(net,x,t,xi,ai);
            % Test the Network
            y = net(x,xi,ai);

            % prepare data for closed-loop NN
            [x1,xio,aio,t] = preparets(net,{},{},T);
            [y1,xfo,afo] = net(x1,xio,aio);
            [netc,xic,aic] = closeloop(net,xfo,afo); % close the loop
            [y2,xfc,afc] = netc(cell(0,7),xic,aic); % Predict next 7 days
            for z=1:length(y2)
                if y2{z} < 0
                    y2{z} = 0;
                end
            end
            % Write the prediction to the corresponding cell
            for w=1:7
                ccaa = iso_ccaa(i);
                valores{w, 1} = ccaa{1};
                next_day = datetime(output.historic{i}.label_x{index_of_day}, 'InputFormat', 'dd-MM-yyyy', 'Format', 'preserveinput') + caldays(1:w);
                valores{w, 2} = datestr(next_day(w),'dd/mm/yyyy');
                valores{w, j+2} = num2str(y2{w});
            end
        end
        for w=1:7
            predict_string = strjoin(valores(w, :), ','); % separate the prediction string by commas
            fprintf(fid, '%s\n', predict_string); % write the prediction to the CSV file
        end
    end
    fclose(fid);
end