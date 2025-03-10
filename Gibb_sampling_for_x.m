function [x] = Gibb_sampling_for_x(x, idx, A, v, sigma, gibbs_res, ...
                                    alpha, beta, disk_radius, offset)
    switch idx
        case 1
            anchor = 2;
        case 2
            anchor = 1;
        case 3
            anchor = 4;
        case 4
            anchor = 3;
        case 5
            anchor = 6;
        case 6
            anchor = 5;
    end

    % Determine the maximum absolute value for x(idx) so that the sample stays within the unit circle,
    % given the current x(anchor) coordinate.
    aux_val = sqrt(disk_radius^2 - x(anchor)^2);
    aux_vec = [ -aux_val : 2*aux_val/(gibbs_res-1) : aux_val]';

    % Fix all x(i) apart from x(idx), compute the measure recorded at each reciever
    % This creates a matrix where each row corresponds to a candidate x(1) value.
    circle_origins = repmat(x, 1, size(aux_vec, 1));
    circle_origins(idx,:) = aux_vec';

    [Ms, V] = forward_map_of_x(circle_origins);

    % compute the measure recorded at each reciever
    % Vs is V(:) duplicated for each column of Ms
    Vs = repmat(V(:), 1, size(Ms, 2));
    measures = A * (Vs*beta + Ms*alpha);

    % Compute the likelihood of each candidate based on the sensor model.
    % The model compares the observed sensor readings (v) with the predicted readings (1./distances)
    % and applies a Gaussian error model scaled by sigma.
    % In some case, p_vec get underflowed, 
    
    aux_v = repmat(v - offset, 1, size(measures, 2));

    % if 0.01 > rand(1)
    %     min(min(-sum((aux_v - measures).^2, 1)))
    % end

    % measures = A * (Vs*1.45 + Ms*0.4);plot(measures(:,24)); hold on; plot(v-80); hold off;

    p_vec = exp( -sum((aux_v - measures).^2, 1) / (2*sigma^2));
    p_vec = p_vec';
    % --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    % This part is for sampling the new x(idx) from the likelihood distribution.
    % --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    % Form a cumulative distribution function (CDF) from the likelihood values.
    p_vec = cumsum(p_vec);
    % Normalize the CDF so that it ranges from 0 to 1.
    p_vec = p_vec ./ p_vec(end);
    
    % Draw a random number and select the candidate x(idx) where the CDF exceeds this value,
    % effectively sampling from the distribution.
    try
        x(idx) = aux_vec(find(p_vec > rand(1), 1));
    catch
        % This error is extremely rare, so it not a big problem
        p_vec
        x(idx) = aux_vec(find(p_vec > rand(1), 1));
    end


end
