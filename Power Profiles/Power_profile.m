clc
clearvars
close all

%% Load data

dt = 1/3600; % Hours
% Traffic_data = load("App\Results_Tool\VPPC_Data_1.mat").Profile_EV;
% Car_data = readtable("App\Data\EV\BCN_AMB_EV_Info_wP.csv");

Traffic_data = load("App\Results_Tool\VPPC_User.mat").Profile_EV;
Car_data = readtable("App\Data\EV\Default_EV.csv");

%% Build power array
last_day = max(Traffic_data.Departure_Day);

t = 0:dt:last_day*24;
P = zeros(1,length(t));
traffic = zeros(1,length(t));
arrivals = [];
departures = [];

for k = 1:height(Traffic_data)

    % Retrieve car data
    car = Traffic_data(k, :);

    % Get maximum charge power from model
    car_idx = matches(Car_data.Model, car.EV);
    P_ch = max(Car_data.Max_Charge_P(car_idx));
    P_ch = min(50, P_ch);

    % Get car arrival and departure hour info
    car_ar_t = datetime(car.Arrival, "InputFormat", "HH:mm");
    arrival_hour = 24*(car.Arrival_Day - 1) + ...
        hour(car_ar_t) + minute(car_ar_t)/60;
    arrivals = [arrivals, arrival_hour];

    car_dep_t = datetime(car.Departure, "InputFormat", "HH:mm");
    departure_hour = 24*(car.Departure_Day - 1) + ...
        hour(car_dep_t) + minute(car_dep_t)/60;
    departures = [departures, departure_hour];

    % Charge end by time
    charge_end = min(departure_hour, arrival_hour + car.EkWh_Charge/P_ch);

    % Build P
    start_idx = ceil(arrival_hour/dt + 1);
    end_idx = floor(charge_end/dt + 1);
    P(start_idx:end_idx) = P(start_idx:end_idx) + P_ch;
    % traffic(start_idx:end_idx) = traffic(start_idx:end_idx) + 1;
    traffic(start_idx:floor(departure_hour/dt + 1)) = traffic(start_idx:floor(departure_hour/dt + 1)) + 1;

end

% Plot results
figure('Renderer', 'painters', 'Position', [10 10 540 500])
ha(1) = subplot(3,1,1);
hold on;
grid on;
histogram(departures/24, 0:0.75/24:5, 'FaceColor','red', 'FaceAlpha',0.5);
histogram(arrivals/24, 0:0.75/24:5, 'FaceColor','cyan', 'FaceAlpha',0.5);
legend(["Departures", "Arrivals"], "Location","northeast");
ylabel("# EV")
curtick = get(gca, 'xTick');
xticks(unique(round(curtick)));
xticklabels([])

ha(2) = subplot(3,1,2);
hold on
grid on
plot(t/24, traffic, '-k')
ylabel("# Parked EV")
curtick = get(gca, 'xTick');
xticks(unique(round(curtick)));
xticklabels([])

ha(3) = subplot(3,1,3);
hold on
grid on
plot(t/24, P, '-', Color="#8a0000")
ylabel("P [kW]")
xlabel("t [h]")
curtick = get(gca, 'xTick');
xticks(unique(round(curtick)));
xticklabels([])

linkaxes(ha, 'x')
ha(1).XLim = [0 (last_day-1)*24/24];

% Save Power Profile
Profile = table;
Profile.t = t';
Profile.P = P';
%writetable(Profile, "Power Profiles/profile.csv")