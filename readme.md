# Acoustic Setup for Object Localization

## Overview
This project aims to localize 3 foam cylinders located inside a disk. The setup utilizes sound transmitters and receivers placed around the cylinders. The localization relies on the assumption that there is no significant reflection or absorption and the signal goes in a straight line. Because sound moving through the cylinder foam has a different velocity than it does moving in air, measuring these different arrival times allows us to identify the location of the cylinders.

## Data
* The provided data includes sound signals recorded at 64 receivers. 
* These signals originate from 3 transmitters located at positions 1, 24, and 43. 
* Simulated data recorded without the cylinders is also included for calibration.

## Methodology
The problem is solved using the following three main steps:

### 1. Estimate Signal Arrival Time
Arrival times are estimated from the recorded data using two methods:
* **Integration Method:** Computes the signal's energy (the square of the signal) and defines the arrival time as the moment the cumulative energy reaches a certain threshold, such as 10% of total signal energy.
* **AIC Method:** Identifies two phases of the signal (before and after arrival) with different variances, finding the phase divider that yields the minimum Akaike Information Criterion (AIC). This algorithm is implemented in `aic_picker.m`.

### 2. Forward Problem
An algorithm generates signal arrival time data given the coordinates of the 3 cylinders.
* This step utilizes a modified implementation of algorithms from a ground layers permittivity problem.
* The forward matrix `A` is computed in the `circle_ground_layer_matrix_with_comment.m` file.
* Maps based on cylinder coordinates are drawn using the `forward_map_of_x.m` function.

### 3. Backward Problem
Gibbs sampling is used to find the most likely coordinates of the 3 cylinders from the recorded data.
* Individual sampling processes are separated into specific scripts: `Gibb_sampling_for_x.m`, `Gibb_sampling_for_alpha.m`, `Gibb_sampling_for_beta.m`, and `Gibb_sampling_for_offset.m`.

## Key Findings & Discussion
* **Sampling Stability:** Attempting Gibbs sampling on all variables (coordinates, alpha, beta, offset) simultaneously is very unstable and fails to converge. 
* **Parameter Tuning:** Simulated data is used to estimate `beta` to avoid having to sample for it, which dictates how stretched out the forward signal is in the vertical direction. 
* **Impact of Alpha:** Using a large `alpha` (e.g., set to 1) is critical to stabilize the process; if `alpha` is too small, the effect of the cylinders' coordinates mixes with noise. A larger `alpha` amplifies the signal involving the cylinders, helping to match it with real measured data.

## Order to read this report:
1. Read `MY_REPORT.html` or `MY_REPORT.pdf` 
2. Read `Present.mlx`
3. Read other `*.m` files
* **Results:** By setting a large `alpha` and a `beta` of 1.40, the shape of the calculated solution fit the real data much better than lower `beta` values, yielding final coordinates that were quite near to the true solution.
