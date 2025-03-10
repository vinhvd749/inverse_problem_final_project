function [arrivalIndex, aic] = aic_picker(signal)
    N = length(signal);
    aic = zeros(1, N);
    
    % Loop over candidate change points from 2 to N-1
    for k = 2:(N-1)
        segment1 = signal(1:k);
        segment2 = signal(k+1:end);
        
        % Compute variances of the segments
        var1 = var(segment1);
        var2 = var(segment2);
        
        % Avoid taking log(0) by setting AIC to infinity if variance is zero
        if var1 == 0 || var2 == 0
            aic(k) = Inf;
        else
            aic(k) = k * log(var1) + (N - k - 1) * log(var2);
        end
    end

    % Because the minimum AIC value is not always unique, we need to find the first occurrence of the minimum value
    
    % Find index of the max value of signal
    [~, maxIndex] = max(signal);
    % find min aic value between the beginning and the max value of signal
    % [~, arrivalIndex] = min(aic(1:maxIndex));
    
    % avoid mimimun in a flat region
    % find the index of the first 20 local minimums as candidates, then pick one with the most variance with 5 of its neighbors
    
    % aux_aic = aic(1:maxIndex);
    % [~,idx]=ismember(sort(aux_aic),aux_aic);
    % num_candidates = 10;
    % min_idxs=idx(1:num_candidates);

    % % find the min_idx with the most variance with 5 of its neighbors
    % window_size = 5;
    % max_variance = 0;
    % arrivalIndex = 0;
    % for i = 1:num_candidates
    %     if min_idxs(i) < window_size+1 || min_idxs(i) > N-window_size
    %         continue;
    %     end
    %     variance = var(signal(min_idxs(i)-window_size:min_idxs(i)+window_size));
    %     if variance > max_variance
    %         max_variance = variance;
    %         arrivalIndex = min_idxs(i);
    %     end
    % end
    % arrivalIndex = arrivalIndex(1);

    left_aic = aic(1:maxIndex);
    right_aic = aic(maxIndex:end);
    [~, left_arrivalIndex] = min(left_aic);
    [~, right_arrivalIndex] = min(right_aic);

    % find max index between left and right arrivalIndex
    % peekAicIndex is offset by left_arrivalIndex
    [~, peekAicIndex] = max(aic(left_arrivalIndex:maxIndex+right_arrivalIndex - 1));

    peekAicIndex = peekAicIndex + left_arrivalIndex;

    % from the peekAicIndex, go to the left until the aic value is increasing
    arrivalIndex = peekAicIndex;
    while arrivalIndex > 5
        % this should be 8
        slops = [aic(arrivalIndex) - aic(arrivalIndex-1); 
                (aic(arrivalIndex) - aic(arrivalIndex-2)) /2 ; 
                (aic(arrivalIndex) - aic(arrivalIndex-4)) /4 ;
                (aic(arrivalIndex) - aic(arrivalIndex-6)) /6 ;
                (aic(arrivalIndex) - aic(arrivalIndex-8)) /8 ;];
        % slops should be positive while going to the left
        
        % context
        if sum(slops < -1) > 4
            break;
        end

        arrivalIndex = arrivalIndex - 1;
    end

end