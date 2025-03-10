load measured_1_left.dat
load measured_1_right.dat
load measured_24_left.dat
load measured_24_right.dat
load measured_43_left.dat
load measured_43_right.dat

signals{1} = measured_1_left;
signals{2} = measured_24_left;
signals{3} = measured_43_left;

intergrated_arival_times = zeros(192, 1);
threshold = 0.05;

count = 0;
for j = 1:3
    signal = signals{j};
    for i = 1:64
        count = count + 1;
        if max(signal(i,:)) == 0
            continue;
        end
        
        energy = signal(i,:).^2;
        cum_sum_energy = cumsum(energy);
        cum_sum_energy = cum_sum_energy / max(cum_sum_energy);
        
        % draw a vertical line at the time of arrival
        arrival_time = find(cum_sum_energy > threshold, 1);
        intergrated_arival_times(count, :) = arrival_time;
    end
end

% intergrated_arival_times

save intergrated_arival_times.mat intergrated_arival_times;


aic_arival_times = zeros(192, 1);

count = 0;
for j = 1:3
    signal = signals{j};
    for i = 1:64
        count = count + 1;
        if max(signal(i,:)) == 0
            continue;
        end
        
        [arrivalIndex, aic] = aic_picker(signal(i,:));
        aic_arival_times(count, :) = arrivalIndex;
       
    end
end

% aic_arival_times

save aic_arival_times.mat aic_arival_times;

figure(1);
plot(aic_arival_times);
hold on;
plot(intergrated_arival_times)
hold off;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% Now we do the simulated data %%%%%%%%%%%%%%%%%%%%%%%%%

load simulated_1.dat
load simulated_24.dat
load simulated_43.dat

signals{1} = simulated_1;
signals{2} = simulated_24;
signals{3} = simulated_43;

intergrated_arival_times_simulated = zeros(192, 1);
threshold = 0.05;

count = 0;
for j = 1:3
    signal = signals{j};
    for i = 1:64
        count = count + 1;
        if max(signal(i,:)) == 0
            continue;
        end
        
        energy = signal(i,:).^2;
        cum_sum_energy = cumsum(energy);
        cum_sum_energy = cum_sum_energy / max(cum_sum_energy);
        
        % draw a vertical line at the time of arrival
        arrival_time = find(cum_sum_energy > threshold, 1);
        intergrated_arival_times_simulated(count, :) = arrival_time;
    end
end

% intergrated_arival_times_simulated

save intergrated_arival_times_simulated.mat intergrated_arival_times_simulated;


% aic_arival_times = zeros(192, 1);
% 
% count = 0;
% for j = 1:3
%     signal = signals{j};
%     for i = 1:64
%         count = count + 1;
%         if max(signal(i,:)) == 0
%             continue;
%         end
% 
%         [arrivalIndex, aic] = aic_picker(signal(i,:));
%         aic_arival_times(count, :) = arrivalIndex;
% 
%     end
% end
% 
% aic_arival_times
% 
% save aic_arival_times_simulated.mat aic_arival_times;

% plot three signals in the same figure with legend and save to file 
figure(2);
plot(intergrated_arival_times, 'DisplayName', 'Integrated arrival times');
hold on;
plot(aic_arival_times, 'DisplayName', 'AIC arrival times');
plot(intergrated_arival_times_simulated, 'DisplayName', 'Integrated arrival times (simulated)');
ylim([0 240])
hold off;

legend;

saveas(gcf, 'measured_signals.png');
