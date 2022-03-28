clc
clearvars
close all

%% Load Probability Distribution Kernels
% It contains PFs for Arrivals and Departures for Weekdays and Weekends
    %"pdKer_Weekday_Arrival"
    %"pdKer_Weekend_Arrival"
    %"pdKer_Weekday_Departures"
    %"pdKer_Weekend_Departures"
load("PDF_Kernels.mat")

%% Build probability array from a Kernel
% We will focus on the Weekday Arrival Kernel
    % 1: build PF in hour scale
hour_PDF = pdf(pdKer_Weekday_Arrival, 0:1/3600:24);
figure
plot(0:1/3600:24, hour_PDF)
    % 2: Pass to seconds
seconds_PDF = hour_PDF/3600;
figure
plot(0:24*3600, seconds_PDF)