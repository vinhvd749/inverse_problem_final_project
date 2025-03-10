function [new_alpha] = Gibb_sampling_for_alpha(x, A, v, sigma, offset, beta)
    % alpha is a parameter that in range [0.1, 10] with step 0.1
    alpha = linspace(0.1, 2, 100);
    circle_origins = x;
    
    [Ms, V] = forward_map_of_x(circle_origins);

    Vs = repmat(V(:), 1, size(alpha, 2));
    measures = A * (Vs*beta + Ms*alpha);

    aux_v = repmat(v - offset, 1, size(measures, 2));
    p_vec = exp( -sum((aux_v - measures).^2, 1) / (2*sigma^2));
    p_vec = p_vec';
    % --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    p_vec = cumsum(p_vec);
    % Normalize the CDF so that it ranges from 0 to 1.
    p_vec = p_vec ./ p_vec(end);

    new_alpha = alpha(find(p_vec > rand(1), 1));
end