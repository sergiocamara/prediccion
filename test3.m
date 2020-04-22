
clearvars; clear all;

[output,name_ccaa,iso_ccaa, data_spain] = HistoricDataSpain()

variables = {'DailyCases','Hospitalized','Critical','DailyDeaths','DailyRecoveries'};
posicionesVariables = {'8','2','3','9','10'};

cHeader = {'CCAA' 'FECHA' 'CASOS' 'Hospitalizados','UCI', 'Fallecidos','Recuperados'}; %dummy header
textHeader = strjoin(cHeader, ',');
%textHeader = cell2mat(commaHeader); %cHeader in text with commas
%write header to file
fid = fopen('IGH_SCS.csv','w'); 
fprintf(fid,'%s\n',textHeader)



for i=1:length(name_ccaa)
    structura = output.historic{i};
    names = fieldnames(output.historic{i});
    valores={1,7};
    valores(1) = iso_ccaa(i);
    valores(2) = cellstr('text');

   

    %figure(i)
    %title(name_ccaa{i});
    hold on
    for j=1:length(variables)
        n=str2num(posicionesVariables{j});
        variables{j};
        y = eval(['structura.' names{n}])
        %plot(y)
        y = reshape(y,[],1);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%% Red neuronal
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            net.trainParam.epochs=100;
            % Train the Network
            [net,tr] = train(net,x,t,xi,ai);
            % Test the Network
            y = net(x,xi,ai);
            e = gsubtract(t,y);
            performance = perform(net,t,y)

            [x1,xio,aio,t] = preparets(net,{},{},T);
            [y1,xfo,afo] = net(x1,xio,aio);
            [netc,xic,aic] = closeloop(net,xfo,afo);
            [y2,xfc,afc] = netc(cell(0,1),xic,aic); % Predict next 7 values
            
            valores(j+2) = cellstr(num2str(y2{length(y2)}));
            %Forecast = horzcat(t,y2)
            % Plot the close-loop results
            %tc_mat = cell2mat(t);
            %yc_mat = cell2mat(Forecast);
            %y2_mat = cell2mat(y2);
            %figure(4), hold on
            %plot(3:length(T), tc_mat, 'b')
            %plot(length(T)+1:length(T)+length(y2), y2_mat, 'r-o')
            %legend('Observed', 'Forecasting')
            %title('Close-loop results');
            %set(gca,'xticklabel',fechas')

            nets = removedelay(net);
            [x1,xio,aio,t] = preparets(nets,{},{},T);
            [netc,xic,aic] = nets(x1,xio,aio);
            %stepAheadPerformance = perform(net,ts,ys)  
        
        

        
    end
        %legend(variables,'Location','westoutside')        
        comma = strjoin(valores, ','); %insert commaas
        %campos = cell2mat(comma); %cHeader in text with commas
        
        
        fprintf(fid,'%s\n',comma)
        
        %write data to end of file
        %dlmwrite('yourfile.csv',yourdata,'-append');
        %%dlmwrite('IGH_SCS.csv',comma,'-append')
end
fclose(fid)






