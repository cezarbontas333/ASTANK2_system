%% Constant definitions & other inputs
% Constants
Lp = 0.04; %m
S = 0.00007854; %m^2
ro = 1000; % kg/m^3
alfa = 0.127;
L = 0.08; %m
l = 0.14; %m
H = 0.25; %m
teta = pi/12; % grade
g = 9.8; %m/s^2
A2 = 0.021; %m^2
AT = 0.1273; %m^2
a1 = 4.2175 * 10^(-5); %m^2
a2 = 4.4842 * 10^(-5); %m^2
ac = 4.307 * 10^(-6); %m^2
Q_neg = 1.1667 * 10^(-4); %m^3/s
Qp1 = 0.5 * 10^(-4); %m^3/s
Qp2 = 0.5 * 10^(-4); %m^3/s
h0 = 0.17; %m
kp = 7*(10^(-3))/600; % L/(secunde*V)
Kev = 1;
Tev = 0.0125; %s

% To be noted: U is a static voltage for the water pump that is used to
% transport the water from the bottom basin to the top ones.
U=3:10;
Q=kp*U;
u1=25/100;
u2=75/100;

% Debits of valves
Qs=(u1/(u1+u2))*((u1/100)+(u2/100))*Q/2;
Qd=(u2/(u1+u2))*((u1/100)+(u2/100))*Q/2;
Qin1=Qs;
Qin2=Qd;

%% Curve fitting
% Values are chosen from the scopes of the heights generated from the
% Simulink model based on visual observation, where there is an estimated 
% time delta when the growth is considered "to have stopped".
X1 = [1211.091 1261.181 1400.716 1372.093 1350.626 1307.692 1293.381 1411.449];
X2 = [1384.970 1421.885 1390.244 1439.024 1474.621 1435.069 1478.576 1436.388];
Y1 = [1.019 1.020 1.021 1.021 1.021 1.021 1.021 1.022];
Y2 = [1.649 1.650 1.650 1.651 1.652 1.652 1.653 1.653];
cftool(X1, Y1)
cftool(X2, Y2)
% There could also be an automated pull of the data, to be much more
% accurate, but that is to be done later.

%% Liniarization
for i = 1:length(U)
    [state_temp, input_temp, output_temp] = trim('diagram_linear', [], U(i), [], [], 1, []);
    astank_state(i, :) = state_temp;
    astank_input(i, :) = input_temp;
    astank_output(i, :) = output_temp;
    [A(:, :, i), B(:, :, i), C(:, :, i), D(:, :, i)] = linmod('diagram_linear', astank_state(i, :), astank_input(i, :));
end

% [state_temp, input_temp, output_temp] = trim('diagram_linear', [], U(4), [], [], 1, []);
% [A_test, B_test, C_test, D_test] = linmod('diagram_linear', state_temp, input_temp);

% To be noted: For U = 3V, from the model generated, the system is not
% properly created. That's why in "heights_linear.slx" the system is not
% present. However, from the linear model aproximation, it seems most
% responses do not work. That's why, starting from the next section, there
% will be new data generated to create new responses. The data does not
% represent the system simulated above.

%% Error calculation
u_new = linspace(0, 3, 14);
y_lin = [0 0.0043 0.0087 0.0125 0.0174 0.0222 0.0264 0.0308 0.0347 0.0388 0.0433 0.0480 0.0517 0.0568];
y_nonlin = [0.003 0.012 0.026 0.045 0.071 0.104];
for i = 1 : length(y_lin)
    for j = 2 : 4
        errors_lin(i, j - 1) = abs((y_lin(i) - y_nonlin(j))/ y_nonlin(j));
    end
end

for i = 1 : 3
    cftool(u_new, errors_lin(:, i));
end

% From cftool, looking at the lowest point in the interpolation, the errors
% are as follows: -0.31, -0.12 +0.3 for 1V, 1.5V and 2V respectively. The
% lowest is for 1.5V.