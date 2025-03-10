% Clear workspace and variables
clear;
clear all;

% Set resolution parameters and cube size.
res = 64;             % Number of grid points along one axis for scanning
m_res = 64;           % Resolution for the measurement (number of receivers per scan)
cube_size = 1;        % Size of the cube (assumed to be 1 unit per side)
radius_val = res/2 - 3;  % A radius value (unused in this snippet) computed from res

% Generate x, y coordinates of the receivers locations
theta = linspace(pi/2, -3*pi/2, m_res + 1); % Generate angles (extra point for full circle)
theta(end) = []; % Remove the last point to keep 64 points

x = radius_val * cos(theta); % Convert to x-coordinates
y = radius_val * sin(theta); % Convert to y-coordinates

% Create a vector of evenly spaced values from 0 to res.
t = [0 : res/(m_res-1) : res];

rec_pos = [x; y; 0*t];
tr_pos_aux = [rec_pos(:,1), rec_pos(:,24), rec_pos(:,43)];

% Open a waitbar to indicate progress in building the A matrix.
% h = waitbar(0, 'A matrix.');

% Initialize an empty array to hold all computed A matrices.
A_aux = [];

f1 = figure;

% Loop over each transmitter group and position.
for k_1 = 1 : 3
    
    % Retrieve current transmitter position (tr_pos) and receiver positions (rec_pos).
    % tr_pos: current transmitter location.
    % rec_pos: corresponding receiver positions for the current group.
    tr_pos = tr_pos_aux(:,k_1);

    % Initialize iteration counters and auxiliary vectors.
    iter_num = 0;
    n_iter = res.^2;       % Total number of cube positions to be evaluated (grid size)
    aux_vec = zeros(n_iter,1);

    % % Record the starting time for progress estimation.
    % t_val = now;

    % Pre-allocate matrices to store cube center coordinates for visualization (optional).
    X = zeros(res);
    Y = X;

    % Compute the ray directions from the transmitter to each receiver.
    % The subtraction is done column-wise so that each receiver gets a direction vector.
    directions = rec_pos - tr_pos(:, ones(1, size(rec_pos,2)));

    figure;
    for l = 1:res
        start_point = tr_pos;
        end_point = start_point + directions(:,l);
        plot([start_point(1) end_point(1)], [start_point(2) end_point(2)], 'r')
        hold on;
    end
    hold off;

    % Initialize matrix A to store line integral values for the current transmitter
    % over all cube positions.
    A = zeros(m_res, n_iter);

    % Loop over a 2D grid to define cube center positions.
    % i: iterates over x-coordinate positions; j: iterates over y-coordinate positions.
    for i = 1 : res
        for j = 1 : res

            % Define the cube center for the current grid point.
            % The center is offset by 0.5 so that cubes are centered at half-integer positions.
            % j_true = j - res/2;
            % i_true = i - res/2;
            % cube_center = [cube_size*j_true - 0.5; cube_size*i_true - 0.5; 0];

            cube_center = [cube_size*(i - res/2) - 0.5; -(cube_size*(j - res/2) - 0.5); 0];

            % Increment the iteration counter.
            iter_num = iter_num + 1;

            % Store the x and y coordinates of the cube center for potential plotting.
            % X(iter_num) = cube_center(1);
            % Y(iter_num) = cube_center(2);

            % Compute the line integrals (i.e. the ray segment lengths within the cube)
            % for the current cube position, using the previously defined function.
            % check if the cube center is within the circle
            if sqrt(cube_center(1)^2 + cube_center(2)^2) <= radius_val
                A(:, iter_num) = line_integrals(tr_pos, directions, cube_center, cube_size);
                
                % Store the x and y coordinates of the cube center for potential plotting.
                X(iter_num) = cube_center(1);
                Y(iter_num) = cube_center(2);

                % scatter(X,Y,10,'filled');
                % axis equal;
            end

            % % Update the waitbar every so often (approximately 50 updates total).
            % if mod(iter_num, ceil(n_iter/50)) == 0
            %     % Estimate the remaining time based on progress so far.
            %     waitbar(iter_num/n_iter, h, ['A matrix. Ready approx: ' datestr((n_iter/iter_num - 1)*(now - t_val) + now)]);
            % end
            % % scatter plot of the cube centers

        end

    end
    % scatter(X,Y,10,'filled');
    % axis equal;

    % for p = 1:64
    %     imagesc(reshape(A(p,:), 64, 64));
    %     drawnow;
    %     pause(0.1)
    % end


    % Concatenate the current A matrix (for this transmitter) vertically to A_aux.
    A_aux = [A_aux ; A];
    
end

% After processing all transmitters and receivers, assign the complete matrix to A.
A = A_aux;

% Save the resulting A matrix into a .mat file.
save sound_loc_matrix.mat A;

% % Close the waitbar.
% close(h);
