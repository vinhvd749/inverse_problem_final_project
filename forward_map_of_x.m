% Draw the map forward problem
function [Ms, V] = forward_map_of_x(circle_origins)

% circle_origins is a matrix, each column is a coordinates of circle_origin
% which look like this starting_point = [0 ; 0 ; 0 ; 14; -15; 0];
% M is the mask created by the object
% V is the mask of the circle

cube_size = 1;
res = 64;
V = zeros(res, res);
disk_radius = 29;

% Ms is a matrix, each column is a mask created by a circle_origin
Ms = zeros(res^2, size(circle_origins, 2));

radius_val = [15.0/2, 10.0/2, 10.0/2];

discard_penalty_val = 5;

for h = 1: size(circle_origins, 2)
    continue_flag = 0;
    M = zeros(res, res);

    % get a circle_origin column
    circle_origin = circle_origins(:, h);
    circle_origin = reshape(circle_origin,2,3);
    % circle_origin = [-11.0,  12.0, -2.5;
    %               12.0, 10.0, -13.0];

    % check if the circle_origin is a fesible one
    for l = 1:3
        % check if any cylander is out of the disk
        if sqrt(circle_origin(1, l)^2 + circle_origin(2, l)^2) + radius_val(l) > disk_radius
            continue_flag = 1;
            break
        end
    end

    if continue_flag == 1
        M = ones(res, res)*discard_penalty_val;
        Ms(:, h) = M(:);
        continue;
    end

    % check if any of the cylanders are overlapping
    % check if cylander 1 and 2 are overlapping
    if sqrt((circle_origin(1, 1) - circle_origin(1, 2))^2 + ...
            (circle_origin(2, 1) - circle_origin(2, 2))^2) < radius_val(1) + radius_val(2)
        M = ones(res, res)*discard_penalty_val;
        Ms(:, h) = M(:);
        continue;
    end
    % check if cylander 1 and 3 are overlapping
    if sqrt((circle_origin(1, 1) - circle_origin(1, 3))^2 + ...
            (circle_origin(2, 1) - circle_origin(2, 3))^2) < radius_val(1) + radius_val(3)
        M = ones(res, res)*discard_penalty_val;
        Ms(:, h) = M(:);
        continue;
    end
    % check if cylander 2 and 3 are overlapping
    if sqrt((circle_origin(1, 2) - circle_origin(1, 3))^2 + ...
            (circle_origin(2, 2) - circle_origin(2, 3))^2) < radius_val(2) + radius_val(3)
        M = ones(res, res)*discard_penalty_val;
        Ms(:, h) = M(:);
        continue;
    end




    for j = 1 : res
        for i = 1 : res

            % Define the cube center for the current grid point.
            % The center is offset by 0.5 so that cubes are centered at half-integer positions.

            % this is the coordinate of cube_center
            cube_center = [cube_size*(i - res/2) - 0.5; -(cube_size*(j - res/2) - 0.5); 0];

            for k = 1 : 3
                if sqrt((cube_center(1) - circle_origin(1, k))^2 + ...
                        (cube_center(2) - circle_origin(2, k))^2) <= radius_val(k)
                    M(j, i) = 1;
                end
            end

            if sqrt(cube_center(1)^2 + cube_center(2)^2) <= disk_radius
                V(j, i) = 1;
            end

        end
    end

    Ms(:, h) = M(:);
end

end