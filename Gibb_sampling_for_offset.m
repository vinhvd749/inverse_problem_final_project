function [new_offset] = Gibb_sampling_for_offset(x, A, v, sigma, alpha, beta)
    % offset = linspace(70, 90, 80)';
    offset = linspace(0, 90, 200)';

    circle_origins = x;
    
    [Ms, V] = forward_map_of_x(circle_origins);

    Vs = V(:);
    measures = A * (Vs*beta + Ms*alpha);

    aux_measures = measures * ones(1, size(offset, 1)) + ones(size(measures, 1), 1) * offset';

    aux_v = repmat(v, 1, size(aux_measures, 2));
    p_vec = exp( -sum((aux_v - aux_measures).^2, 1) / (2*sigma^2));
    p_vec = p_vec';
    % --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    p_vec = cumsum(p_vec);
    % Normalize the CDF so that it ranges from 0 to 1.
    p_vec = p_vec ./ p_vec(end);

    new_offset = offset(find(p_vec > rand(1), 1));

end