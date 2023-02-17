%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main.m 
%
% Created Feb, 2023
% Elyes Balti
% The University of Texas at Austin
%
% If you use this code or any (modified) part of it in any publication, please cite 
% the following paper: 
% 
% E. Balti, C. Dick and B. L. Evans,
% "Low Complexity Hybrid Beamforming for mmWave Full-Duplex Integrated Access and Backhaul," 
% GLOBECOM 2022 - 2022 IEEE Global Communications Conference, Rio de Janeiro, Brazil, 2022, pp. 1606-1611
%
%
% Contact email: ebalti@utexas.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Description
% This script defines the variables with their assigned values 
%% Parameters 
% CostAnalog, Ja: effective self-interference power in the analog domain
% CostHybrid, Jh: effective self-interference power in the hybrid analog/digital domain
% MonteCarlo: number of generation of random samples
% maxIter: number of iterations to obtain the convergence of Algorithm I
% Hb: backhaul channel
% Ha: access channel
% Hs: self-interference channel
% Ncl: number of clusters
% Nray: number of rays per cluster
% std_phi: AoD angular spread
% std_theta: AoA angular spread
% Pr: average received power per cluster
% Nbs: number of BS antennas
% Nue: number of UE antennas
% BSpos: ULA BS array position in lambda/2
% UEpos: ULA UE array position in lambda/2
% d: distance between the TX and RX arrays at the full-duplex BS
% an: angle separation between the TX and RX arrays at the full-duplex BS
% Nrf:number of RF chains
% Ns: number of spatial streams
% kappa: Rician factor
% Ps: self-interference power
% noise_var_dB (noise_var): noise variance defined in dB (Watt)
% SNR: signal-to-noise-ratio for which we normalize the average received
% power to 0 dB so that Ps is the amount of self-interference measured
% above the average received power. Hence, we vary the SNR by changing the
% noise variance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all;close all;clc
dbstop if error
params

%% Initialize the cost function
CostAnalog = zeros(maxIter,MonteCarlo);
CostHybrid = zeros(maxIter,MonteCarlo);


for kk=1:MonteCarlo
    kk
Hb=GenChannel(Ncl,Nray,std_phi,std_theta,Pr,Nbs,Nbs,BSpos,BSpos);
Ha=GenChannel(Ncl,Nray,std_phi,std_theta,Pr,Nbs,Nue,BSpos,UEpos);
Hs = SelfInterferenceChannel(d,an,kappa,Ncl,Nray,std_phi,std_theta,Pr,Nbs,Nbs,BSpos,BSpos);


[Jh,Ja] = EvalSelfInterferencePower(Hb,Ha,Hs,Ns,Nrf,Ps,SNR,maxIter);

CostAnalog(:,kk) = real(Ja).';
CostHybrid(:,kk) = real(Jh).';
end


%% Averaging over Monte Carlo Iterations
Qa = mean(CostAnalog,2);
Qh = mean(CostHybrid,2);

figure; hold on
plot(0:maxIter-1,Qa,'-^','linewidth',2);
plot(0:maxIter-1,Qh,'-o','linewidth',2);
legend('Analog Cancellation','Analog and Digital Cancellation')
ylabel('Effective SI Power')
xlabel('Iterations')

