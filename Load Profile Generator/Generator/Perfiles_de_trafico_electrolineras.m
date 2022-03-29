clear all
close all
clc

%% Datos de prueba de llegada de coches

Daily_cars=1000;
Perfil=1; % 1:Universidad, 2:Electrolineras Barcelona (Laborables), 2:Electrolineras Barcelona (Festivos)

if Perfil==1
    % datos de llegada y salida de vehículos [Vehículos/hora]
    DATA_ARRIVING_CARS=[10 0 5 0 50 100 300 600 250 300 150 225 150 200 100 200 170 210 180 200 150 100 50 10];
    DATA_DEPARTURE_CARS=[10 0 5 0 20 50 75 100 150 175 160 190 180 220 250 290 400 300 250 200 100 110 90 39];

    % Normalizar datos y pasarlo a probabilidad por segundo
    DATA_ARRIVING_CARS_Normalized=DATA_ARRIVING_CARS/sum(DATA_ARRIVING_CARS);
    DATA_DEPARTURE_CARS_Normalized=DATA_DEPARTURE_CARS/sum(DATA_DEPARTURE_CARS);

    Probability_Array_seconds_ARRIVING=zeros(1,24*60*60);
    Probability_Array_seconds_DEPARTURE=zeros(1,24*60*60);
    x=1;
    while x<= length(DATA_ARRIVING_CARS_Normalized)
        Probability_Array_seconds_ARRIVING(x*3600-3599:x*3600)=ones(1,3600)*DATA_ARRIVING_CARS_Normalized(x)/3600;
        Probability_Array_seconds_DEPARTURE(x*3600-3599:x*3600)=ones(1,3600)*DATA_DEPARTURE_CARS_Normalized(x)/3600;
        x=x+1;
    end
elseif Perfil==2
    load("PDF_Kernels.mat")
    DATA_ARRIVING_CARS=pdf(pdKer_Weekday_Arrival, 1:1:24);
    DATA_DEPARTURE_CARS=pdf(pdKer_Weekday_Departures, 1:1:24);
    Probability_Array_seconds_ARRIVING = pdf(pdKer_Weekday_Arrival, 1/3600:1/3600:24)/3600;
    Probability_Array_seconds_ARRIVING=Probability_Array_seconds_ARRIVING/sum(Probability_Array_seconds_ARRIVING);
    Probability_Array_seconds_DEPARTURE = pdf(pdKer_Weekday_Departures, 1/3600:1/3600:24)/3600;
    Probability_Array_seconds_DEPARTURE = Probability_Array_seconds_DEPARTURE/sum(Probability_Array_seconds_DEPARTURE);

elseif Perfil==3
    load("PDF_Kernels.mat")
    DATA_ARRIVING_CARS=pdf(pdKer_Weekend_Arrival, 1:1:24);
    DATA_DEPARTURE_CARS=pdf(pdKer_Weekend_Departures, 1:1:24);
    Probability_Array_seconds_ARRIVING = pdf(pdKer_Weekend_Arrival, 1/3600:1/3600:24)/3600;
    Probability_Array_seconds_ARRIVING=Probability_Array_seconds_ARRIVING/sum(Probability_Array_seconds_ARRIVING);
    Probability_Array_seconds_DEPARTURE = pdf(pdKer_Weekend_Departures, 1/3600:1/3600:24)/3600;
    Probability_Array_seconds_DEPARTURE = Probability_Array_seconds_DEPARTURE/sum(Probability_Array_seconds_DEPARTURE);

    
end

% Aplicar la aleatoriedad para la hora de llegada
ARRIVING_seconds=zeros(1,24*60*60);
DEPARTURE_seconds=zeros(1,24*60*60+12*3600);
x=1;
while x<=Daily_cars
    Rand_hour=rand;
    % ARRIVING
    X=1;
    while Rand_hour>=Probability_Array_seconds_ARRIVING(X)
        Rand_hour=Rand_hour-Probability_Array_seconds_ARRIVING(X);
        X=X+1;
    end
        
    Data_ARRIVING(x)= X;
    ARRIVING_seconds(X)=ARRIVING_seconds(X)+1;
    
    % DEPARTURE
    
    % Se asume que los vehículos que llegan antes de las 20:00 salen ese
    % mismo día
    if Data_ARRIVING(x)<=20*3600
    
        Probability_Probability_Array_seconds_DEPARTURE_=Probability_Array_seconds_DEPARTURE(X:end)/sum(Probability_Array_seconds_DEPARTURE(X:end));
        Rand_hour=rand;
            XX=1;
        while Rand_hour>=Probability_Probability_Array_seconds_DEPARTURE_(XX)
            Rand_hour=Rand_hour-Probability_Probability_Array_seconds_DEPARTURE_(XX);
            XX=XX+1;
        end
        
        Data_DEPARTURE(x)= X+XX;
        DEPARTURE_seconds(X+XX)=DEPARTURE_seconds(X+XX)+1;
        
        
    % Se asume que los vehículos que llegan despues de las 20:00 salen al
    % día siguiente a la mañana antes de las 12:00
    else
         Probability_Probability_Array_seconds_DEPARTURE_=Probability_Array_seconds_DEPARTURE(1:12*3600)/sum(Probability_Array_seconds_DEPARTURE(1:12*3600));
        Rand_hour=rand;
            XX=1;
        while Rand_hour>=Probability_Probability_Array_seconds_DEPARTURE_(XX)
            Rand_hour=Rand_hour-Probability_Probability_Array_seconds_DEPARTURE_(XX);
            XX=XX+1;
        end
        
        Data_DEPARTURE(x)= 24*3600+XX;
        DEPARTURE_seconds(24*3600+XX)=DEPARTURE_seconds(24*3600+XX)+1;
    end
    
    
        
    x=x+1;
end


%% Graficar los resultados (en segundos,horas y 15 min)

% ARRIVING
figure
plot(1/3600:1/3600:24,ARRIVING_seconds)
hold on
ylabel('Vehículos/segundo','FontName','times','FontSize',10)
yyaxis right
plot(1:1:24,DATA_ARRIVING_CARS)

title('Llegada de vehículos','FontName','times','FontSize',12)
legend('Estimación','Datos Paper','FontName','times','FontSize',10,'Location','NorthWest')
xlabel('Tiempo [horas]','FontName','times','FontSize',10)
ylabel('Vehículos/hora','FontName','times','FontSize',10)
grid on


x=1;
while x<=24*4
    ARRIVING_15min(x)=sum(ARRIVING_seconds(x*15*60-(15*60-1):x*15*60));
    
    x=x+1;
end

figure
yyaxis left
plot(1/4:1/4:24,ARRIVING_15min,'*')
hold on
ylabel('Vehículos/15min','FontName','times','FontSize',10)
yyaxis right
plot(1:1:24,DATA_ARRIVING_CARS)

title('Llegada de vehículos','FontName','times','FontSize',12)
legend('Estimación','Datos Paper','FontName','times','FontSize',10,'Location','NorthWest')
xlabel('Tiempo [horas]','FontName','times','FontSize',10)
ylabel('Vehículos/hora','FontName','times','FontSize',10)
grid on


x=1;
while x<=24
    ARRIVING_hour(x)=sum(ARRIVING_seconds(x*3600-3599:x*3600));
    
    x=x+1;
end

figure
yyaxis left
plot(1:1:24,ARRIVING_hour,'*')
hold on
ylabel('Vehículos/hora','FontName','times','FontSize',10)
yyaxis right
plot(1:1:24,DATA_ARRIVING_CARS)

title('Llegada de vehículos','FontName','times','FontSize',12)
legend('Estimación','Datos Paper','FontName','times','FontSize',10,'Location','NorthWest')
xlabel('Tiempo [horas]','FontName','times','FontSize',10)
ylabel('Vehículos/hora','FontName','times','FontSize',10)
grid on


% DEPARTURE

figure
plot(1/3600:1/3600:24+12,DEPARTURE_seconds)
hold on
ylabel('Vehículos/segundo','FontName','times','FontSize',10)
yyaxis right
plot(1:1:24+12,horzcat(DATA_DEPARTURE_CARS,DATA_DEPARTURE_CARS(1:12)))

title('Salida de vehículos','FontName','times','FontSize',12)
legend('Estimación','Datos Paper','FontName','times','FontSize',10,'Location','NorthWest')
xlabel('Tiempo [horas]','FontName','times','FontSize',10)
ylabel('Vehículos/hora','FontName','times','FontSize',10)
grid on

x=1;
while x<=(24+12)*4
    DEPARTURE_15min(x)=sum(DEPARTURE_seconds(x*15*60-(15*60-1):x*15*60));
    
    x=x+1;
end

figure
yyaxis left
plot(1/4:1/4:24+12,DEPARTURE_15min,'*')
hold on
ylabel('Vehículos/15 min','FontName','times','FontSize',10)
yyaxis right
plot(1:1:24+12,horzcat(DATA_DEPARTURE_CARS,DATA_DEPARTURE_CARS(1:12)))

title('Salida de vehículos','FontName','times','FontSize',12)
legend('Estimación','Datos Paper','FontName','times','FontSize',10,'Location','NorthWest')
xlabel('Tiempo [horas]','FontName','times','FontSize',10)
ylabel('Vehículos/hora','FontName','times','FontSize',10)
grid on



x=1;
while x<=24+12
    DEPARTURE_hour(x)=sum(DEPARTURE_seconds(x*3600-3599:x*3600));
    
    x=x+1;
end

figure
yyaxis left
plot(1:1:24+12,DEPARTURE_hour,'*')
hold on
ylabel('Vehículos/hora','FontName','times','FontSize',10)
yyaxis right
plot(1:1:24+12,horzcat(DATA_DEPARTURE_CARS,DATA_DEPARTURE_CARS(1:12)))

title('Salida de vehículos','FontName','times','FontSize',12)
legend('Estimación','Datos Paper','FontName','times','FontSize',10,'Location','NorthWest')
xlabel('Tiempo [horas]','FontName','times','FontSize',10)
ylabel('Vehículos/hora','FontName','times','FontSize',10)
grid on



% DEPARTURE Real (Considerando las salidas de los coches que pasan la 
% noche en el garaje)

DEPARTURE_Total_seconds=DEPARTURE_seconds(1:24*3600);
x=24*3600+1;
while x <= length(DEPARTURE_seconds)
   
    DEPARTURE_Total_seconds(x-24*3600)=DEPARTURE_Total_seconds(x-24*3600)+DEPARTURE_seconds(x);
    x=x+1;
end



figure
plot(1/3600:1/3600:24,DEPARTURE_Total_seconds)
hold on
ylabel('Vehículos/segundos','FontName','times','FontSize',10)
yyaxis right
plot(1:1:24,DATA_DEPARTURE_CARS)

title('Salida de vehículos (Total)','FontName','times','FontSize',12)
legend('Estimación','Datos Paper','FontName','times','FontSize',10,'Location','NorthWest')
xlabel('Tiempo [horas]','FontName','times','FontSize',10)
ylabel('Vehículos/hora','FontName','times','FontSize',10)
grid on

x=1;
while x<=(24)*4
    DEPARTURE_Total_15min(x)=sum(DEPARTURE_Total_seconds(x*15*60-(15*60-1):x*15*60));
    
    x=x+1;
end

figure
yyaxis left
plot(1/4:1/4:24,DEPARTURE_Total_15min,'*')
hold on
ylabel('Vehículos/15min','FontName','times','FontSize',10)
yyaxis right
plot(1:1:24,DATA_DEPARTURE_CARS)

title('Salida de vehículos (Total)','FontName','times','FontSize',12)
legend('Estimación','Datos Paper','FontName','times','FontSize',10,'Location','NorthWest')
xlabel('Tiempo [horas]','FontName','times','FontSize',10)
ylabel('Vehículos/hora','FontName','times','FontSize',10)
grid on


x=1;
while x<=24
    DEPARTURE_Total_hour(x)=sum(DEPARTURE_Total_seconds(x*3600-3599:x*3600));
    
    x=x+1;
end

figure
yyaxis left
plot(1:1:24,DEPARTURE_Total_hour,'*')
hold on
ylabel('Vehículos/hora','FontName','times','FontSize',10)
yyaxis right
plot(1:1:24,DATA_DEPARTURE_CARS)

title('Salida de vehículos (Total)','FontName','times','FontSize',12)
legend('Estimación','Datos Paper','FontName','times','FontSize',10,'Location','NorthWest')
xlabel('Tiempo [horas]','FontName','times','FontSize',10)
ylabel('Vehículos/hora','FontName','times','FontSize',10)
grid on

% Comparación DEPARTURE VS DEPARTURE_Total

figure
yyaxis left
plot(1:1:24,DEPARTURE_Total_hour,'*')
hold on
plot(1:1:24,DEPARTURE_hour(1:24),'o')
ylabel('Vehículos/hora','FontName','times','FontSize',10)
yyaxis right
plot(1:1:24,DATA_DEPARTURE_CARS)

title('Salida de vehículos (Departure VS Total)','FontName','times','FontSize',12)
legend('Estimación_Total','Estimación','Datos Paper','FontName','times','FontSize',10,'Location','NorthWest')
xlabel('Tiempo [horas]','FontName','times','FontSize',10)
ylabel('Vehículos/hora','FontName','times','FontSize',10)
grid on




% Calcular tiempo de espera
TIEMPO_ESPERA=Data_DEPARTURE-Data_ARRIVING;

TIEMPO_ESPERA_=TIEMPO_ESPERA;
x=1;
while x<=length(TIEMPO_ESPERA_)
    if TIEMPO_ESPERA_(x)<=0
        TIEMPO_ESPERA_(x)=[];
        x=x-1;
    end
    x=x+1;
end

TIEMPO_ESPERA_MIN=min(TIEMPO_ESPERA)/3600;
TIEMPO_ESPERA_MEDIO=mean(TIEMPO_ESPERA)/3600;
TIEMPO_ESPERA_MAX=max(TIEMPO_ESPERA)/3600;


% Generar ARRAY de tráfico

ARRAY_Coches=horzcat(Data_ARRIVING',Data_DEPARTURE');    
[~, s] = sort(ARRAY_Coches(:, 1));
ARRAY_Coches=ARRAY_Coches(s, :);


figure
errorbar(1:1:1000,((ARRAY_Coches(:,2)-ARRAY_Coches(:,1))/2+ARRAY_Coches(:,1))/3600,((ARRAY_Coches(:,2)-ARRAY_Coches(:,1))/2)/3600,'.')



%% Calcular número de vehiculos

N_Vehiculos_Garaje(1)=sum(DEPARTURE_seconds(24*3600+1:36*3600));



x=1;
while x<=length(ARRIVING_seconds)
    N_Vehiculos_Garaje(x+1)=N_Vehiculos_Garaje(x)-DEPARTURE_Total_seconds(x)+ARRIVING_seconds(x);
    x=x+1;
end


figure
yyaxis left
plot(0:1/3600:24,N_Vehiculos_Garaje)
hold on
ylabel('Vehículos','FontName','times','FontSize',10)
yyaxis right
plot(1:1:24,ARRIVING_hour)
plot(1:1:24,DEPARTURE_Total_hour)

title('','FontName','times','FontSize',12)
legend('Núm. vehículos','Llegadas','Salidas','FontName','times','FontSize',10,'Location','NorthWest')
xlabel('Tiempo [horas]','FontName','times','FontSize',10)
ylabel('Vehículos/hora','FontName','times','FontSize',10)
grid on


    











