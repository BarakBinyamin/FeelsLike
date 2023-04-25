clear all;

% Data Analysis & Data Pre Processing

    one   = "CRND0103-2022-NY_Ithaca_13_E.txt";
    two   = "CRND0103-2021-NY_Ithaca_13_E.txt";
    three = "CRND0103-2020-NY_Ithaca_13_E.txt";
    %%four  = "CRND0103-2019-NY_Ithaca_13_E.txt";
    %%five  = "CRND0103-2018-NY_Ithaca_13_E.txt";
    wind  = "3286650.csv";  %% date in column 6, avg wind in 7
    
    weatherData = readmatrix(three);
    weatherData = cat(1, weatherData, readmatrix(two));
    weatherData = cat(1, weatherData, readmatrix(one)); % date in column 2
    wind        = readmatrix(wind);
    
    [rows, cols] = size(weatherData);
    weatherData = [ weatherData zeros(rows,1) ];
    % Combine Weather data with wind from Rochester to column 9
    for i = 1:size(weatherData,1)
        % If dates are the same add the wind
        if (weatherData(i,2)==wind(i,6))
            weatherData(i,cols+1) = wind(i,7);
        end
    end

    % Generate Feels Like Data
    % AvgTemperature AvgWind AvgHumidity FeelsLike Date
    feelsLikeData = [ weatherData(:,9) weatherData(:,cols+1)  ...
                      weatherData(:,18) zeros(rows,1) weatherData(:,2)];

    % Remove any row with -9999, this represents data that was not collected
    feelsLikeData = cleanUp(feelsLikeData);
    
    %Heat Index Calculations & References: 
    %   https://byjus.com/heat-index-formula/
    %   https://www.wpc.ncep.noaa.gov/html/heatindex_equation.shtml
    %HI = heat index in degrees Fahrenheit
    %HI = c1+c2*T+c3*R+c4T*R+c5*T2+c6*R2+c7*T2*R+c8*T*R2+c9*T2*R2
    %R  = Relative humidity
    %T  = Temperature in ∘F
    c1 = -42.379;
    c2 = -2.04901523;
    c3 = -10.14333127;
    c4 = -0.22475541;
    c5 = -6.83783  * 10^3;
    c6 = -5.481717 * 10^2;
    c7 = -1.22874  * 10^3;
    c8 = 8.5282    * 10^4;
    c9 = -1.99     * 10^6;

    % Windchill reference:
    %   https://www.weather.gov/media/epz/wxcalc/windChill.pdf
    % W = 35.74 + (0.6215 × T) − (35.75 × Windspeed^0.16)+ (0.4275 × T
    %   × Windspeed^0.16)

    % apply windchill <10 C, apply heat index > 26.6667 C
    for row = 1:size(feelsLikeData,1)
        AvgTemperature = feelsLikeData(row,1);
        AvgWind        = feelsLikeData(row,2);
        AvgHumidity    = feelsLikeData(row,3);
        feelsLike      = AvgTemperature;
        if (AvgTemperature<10)
            Fahrenheit = (AvgTemperature * 9/5) + 32;  %(0°C × 9/5) + 32 = 32°F
            WindMpH    = (AvgWind*60)/(6.2137*10^-5);  %%(.1xmeter/6.2137x10^-5 mile)(60*sec/min)
            WindChill  = 35.74 + (0.6215 * AvgTemperature) ...
                - (35.75 * AvgWind^0.16) + (0.4275 * AvgTemperature * AvgWind^0.16);
            Celsius    = (WindChill - 32) * 5/9;       %(0°F − 32) × 5/9 = -17.78°C
            feelsLike  = Celsius;
        elseif(AvgTemperature>24.3)
            Fahrenheit = (AvgTemperature * 9/5) + 32;  %(0°C × 9/5) + 32 = 32°F
            T = AvgTemperature; 
            R = AvgHumidity;
            HeatIndex =  0.5 * (T + 61.0 + (T-68.0)*1.2 + (R*0.094));
            Celsius    = (HeatIndex - 32) * 5/9;       %(0°F − 32) × 5/9 = -17.78°C
            feelsLike  = Celsius;
        end
        feelsLikeData(row,4) = feelsLike;
    end

    % Show Real vs Feels Like
    temp  = feelsLikeData(:,1)';
    dates = feelsLikeData(:,5)';
    formattedDates = [];
    for item=1:length(dates)
       % get into mm/dd/yyyy format
       badStr =  num2str(dates(1,item));
       %goodStr= [ badStr(5:8) badStr(1:4) ];
       formmted = insertAfter(insertAfter(badStr,4,'-'),7,'-');
       dated    = datetime(formmted,'InputFormat','yyyy-MM-dd');
       formattedDates = [formattedDates dated];
    end
    hold on
    scatter(formattedDates, temp)
    scatter(formattedDates, feelsLikeData(:,4)', 'marker', 'X')
    xlabel("Date")
    ylabel("Temperature °C")
    legend("Real", "Feels Like")
    title("Real Vs Feels Like Tempereature in Ithica, NY")

% Data Analysis
% Here is where we'd chart the data vs some other variables to try and
% Understand the relationsip between all the variables and pick the best
% machine learning tools for the job
    
% Hypothesis Formulation
    % We suspect that this is a linear distribution and the factors at play are
    % real-temperature humidity and wind-speed
    
    % Now we can formalize our theory into a model
    % [ ModelParamters ] = (Xdata'Xdata)^-1 x  Xdata'(Ydata)

% Hypthesis optimiztion, Train on dataset 2020-2021
trainSize = floor(.75*size(feelsLikeData,1));
trainX =  [ ones(trainSize,1) feelsLikeData(1:trainSize,1) feelsLikeData(1:trainSize,2) feelsLikeData(1:trainSize,3)];
trainY =  feelsLikeData(1:trainSize,4);
testX  =  [ ones(size(feelsLikeData,1)+1-trainSize, 1) feelsLikeData(trainSize:end,1) feelsLikeData(trainSize:end,2) feelsLikeData(trainSize:end,3)];
testY  =  feelsLikeData(trainSize:end,4);

[ ModelParamters ] = (trainX'*trainX)^-1 *  trainX'*(trainY);
disp("Model Paramters:")
disp(ModelParamters)

% Train error
trainExpectedTemp = trainX*ModelParamters; % Let's Put Our Model To the test
trainError = 0; % (1/n)sum(expected - actual)^2
for i=1:trainSize
        trainError= trainError+ ((trainExpectedTemp(i)-trainY(i))^2);
end
trainError=trainError/trainSize;

% Test on 2022
expectedTemp = testX*ModelParamters; % Let's Put Our Model To the test
hold off; close all;
hold on
plot(formattedDates(trainSize:end), expectedTemp)
scatter(formattedDates(trainSize:end), feelsLikeData(trainSize:end,4)', 'marker', 'X')
xlabel("Date")
ylabel("Temperature °C")
legend("Predicted", "Real Feels Like")
title("Predicted Feels Like Vs Feels Like Tempereature for Ithica, NY")

% Testing error
testError = 0; % (1/n)sum(expected - actual)^2
for i=1:size(feelsLikeData,1)+1-trainSize
        testError= testError+ ((expectedTemp(i)-testY(i))^2);
end
testError=testError/((size(feelsLikeData,1)+1-trainSize));

% :(
% trainError = 69.3143
% testError  = 79.1978

% That was pretty rough, lets use an iterative approach to 
% try and get some better results: Batch-Gradient Decent
trainX =  [ ones(trainSize,1) feelsLikeData(1:trainSize,1) feelsLikeData(1:trainSize,2) feelsLikeData(1:trainSize,3)];
trainY =  feelsLikeData(1:trainSize,4);
testX  =  [ ones(size(feelsLikeData,1)+1-trainSize, 1) feelsLikeData(trainSize:end,1) feelsLikeData(trainSize:end,2) feelsLikeData(trainSize:end,3)];
testY  =  feelsLikeData(trainSize:end,4);

numParamters   = 3;   % Temp Wind Humidity
ThetasWithBias = numParamters+1;
Theta = zeros(ThetasWithBias,1);
TrainError = 100;
a     = .005;       % Learning rate
L     = .01;            % Regularizing param
n     = length(trainX);
error = [];
while (TrainError>99)
    tmp = Theta;
    tmp(1) = Theta(1) - (a*(1/(2*n))*sum( ((trainX*Theta)-trainY).^2 ) );
    for i=2:length(Theta)
        meanSqrdErr = ((trainX*Theta)-trainY).^2;
        regularizer = (L/(2*n))*sum(abs(Theta));
        tmp(i) = Theta(i) - ( a * (1/(2*n) ) * ...
            sum( meanSqrdErr .* trainX(:, i)) + regularizer)
    end
    Theta = tmp;
    TrainError = (1/n)*sum(((trainX*Theta)-trainY).^2)
    error = [ error TrainError];
end
hold off; close all;
semilogy(error);
title('Batch Gradient Decent Attempt: Error Per Round')
xlabel('Epoch')
ylabel('Mean Squared Error')






