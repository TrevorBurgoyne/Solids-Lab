%% Solids Lab
% Trevor Burgoyne 7 Dec 2022
% AEM 4602W, Lab Group 3Bi

%% Conversions
mm2in = 0.0393701; % in/mm
psi2mpa = 0.00689476; % MPa/psi
mpa2gpa = .001; % GPa/MPa
volts2lbs = 5620/10; % lbs/volt tensile test machine conversion
volts2in  = 2/10; % in/volt tensile test machine conversion

%% Extensometer Calibration
d = 0.1*mm2in; % mm -> in, micrometer distance
V = [0.953, 0.956, 0.955]; % Volts, extensometer reading at d
V_avg = mean(V);
ext_volts2in = d/V_avg; % in/Volt, extensometer conversion

%% Metal Properties
l = 2.7575; % in, gage length
% Aluminim 6061
AL6061 = struct();

w = [.1955, .193, .193]; % in, sample width
t = [.118, .1115, .1155]; % in, sample thickness
AL6061.w = mean(w); % in
AL6061.t = mean(t); % in
AL6061.a = AL6061.w*AL6061.t; % in^2, cross-sectional area
AL6061.l = l; % in, gage length

wb = [.149, .1615]; % in, sample width at break
tb = [.082, .0885]; % in, sample thickness at break
AL6061.wb = mean(wb); % in
AL6061.tb = mean(tb); % in
AL6061.ab = AL6061.wb*AL6061.tb; % in^2, cross-sectional area of break
AL6061.a_red = (1 - AL6061.ab/AL6061.a)*100; % percent reduction of area at failure
AL6061.true_strain = log(AL6061.a / AL6061.ab); % unitless, true strain at failure, assumes zero volume change

AL6061.fmax = 1118.2; % lb
AL6061.xmax = 0.021; % in
AL6061.fb = 920.4; % lb
AL6061.xb = 0.024; % in




% Steel 304
SS304 = struct();

w = [.1935, .1945, .1935]; % in, sample width
t = [.1135, .118, .1135]; % in, sample thickness
SS304.w = mean(w); % in
SS304.t = mean(t); % in
SS304.a = SS304.w*SS304.t; % in^2, cross-sectional area
SS304.l = l; % in, gage length

% wb = [.1205, .123]; % in, sample width at break
% tb = [.083, .083]; % in, sample thickness at break
% SS304.wb = mean(wb); % in
% SS304.tb = mean(tb); % in
% SS304.ab = SS304.wb*SS304.tb; % in^2, cross-sectional area of break
% SS304.a_red = (1 - SS304.ab/SS304.a)*100; % percent reduction of area at failure
% SS304.true_strain = log(SS304.a / SS304.ab); % unitless, true strain at failure, assumes zero volume change

% SS304.fmax = 1750.7; % lb
% SS304.xmax = 0.021; % in
% SS304.fb = 1227.9; % lb
% SS304.xb = 0.029; % in


% Steel 1018
SS1018 = struct();

w = [.193, .192, .1945]; % in, sample width
t = [.1135, .115, .118]; % in, sample thickness
SS1018.w = mean(w); % in
SS1018.t = mean(t); % in
SS1018.a = SS1018.w*SS1018.t; % in^2, cross-sectional area
SS1018.l = l; % in, gage length

wb = [.1205, .123]; % in, sample width at break
tb = [.083, .083]; % in, sample thickness at break
SS1018.wb = mean(wb); % in
SS1018.tb = mean(tb); % in
SS1018.ab = SS1018.wb*SS1018.tb; % in^2, cross-sectional area of break
SS1018.a_red = (1 - SS1018.ab/SS1018.a)*100; % percent reduction of area at failure
SS1018.true_strain = log(SS1018.a / SS1018.ab); % unitless, true strain at failure, assumes zero volume change

SS1018.fmax = 1750.7; % lb
SS1018.xmax = 0.021; % in
SS1018.fb = 1227.9; % lb
SS1018.xb = 0.029; % in

%% AL6061 Test
% time, Chan101 (Volts, load cell), time, Chan102 (Volts, crosshead), time, Chan103 (Volts, extensometer)
data = readtable('dataALTest1.csv');
idx = find(data.Chan103 == 0.345908) - 1; % idx where extensometer was removed
end_idxs = find(data.Chan101 < 0.03); % idx where sample broke
end_idx = end_idxs(1) - 1;

AL6061.volts2lbs = AL6061.fmax / max(data.Chan101); % lbs/volt using recorded max force
AL6061.volts2in  = AL6061.xb / data.Chan102(end_idx); % in/volt using recorded max displacement

AL6061.stress = (data.Chan101(2:end_idx)*AL6061.volts2lbs / AL6061.a)*psi2mpa; % MPa, engineering stress

AL6061.strain = data.Chan103(2:idx)*ext_volts2in / AL6061.w; % unitless, engineering strain
eu = AL6061.strain(end); % Last value of extensometer strain 
cross_eu = data.Chan102(idx); % Volts, value of crosshead reading when extensometer was removed 
AL6061.strain = [AL6061.strain', (data.Chan102(idx+1:end_idx)-cross_eu)'*AL6061.volts2in / AL6061.w + eu]'; % Use crosshead data after extensometer was removed

AL6061.tough = trapz(AL6061.strain, AL6061.stress); % MPa, toughness
AL6061.strength = AL6061.stress(idx); % MPa, ultimate strength (where necking starts)

range = 20:100; % Idx range for E calculation
AL6061.E = mean(diff(AL6061.stress(range))./diff(AL6061.strain(range))); % MPa, Young's Modulus

test = AL6061.stress ./ (AL6061.strain - .002); % Slope of .2% offset line at each point
idxs = find(test >= AL6061.E); % Find which best matches E
AL6061.yield = AL6061.stress(idxs(1)); % MPa, yield stress (.2% offset)

% Poisson ratio

%% Plot
figure()
hold on
% plot(AL6061.strain(1:idx), AL6061.stress(1:idx), '-x')
plot(AL6061.strain, AL6061.stress, '-x')

% range = linspace(0,0.005,100);
% plot(range, (AL6061.E/mpa2gpa)*range + .002);
xlabel('Strain (unitless)'); ylabel('Stress (MPa)'); title('AL6061');
grid on


%% SS1018 Test (No extensometer)
% time, Chan101 (Volts, load cell), time, Chan102 (Volts, crosshead), time, Chan103 (Volts, extensometer)
data = readtable('dataSS1018.csv');
end_idxs = find(data.Chan101 < 0.03); % idx where sample broke
end_idx = end_idxs(1) - 1;

SS1018.volts2lbs = SS1018.fmax / max(data.Chan101); % lbs/volt using recorded max force
SS1018.volts2in  = SS1018.xb / data.Chan102(end_idx); % in/volt using recorded max displacement

SS1018.stress = (data.Chan101(2:end_idx)*SS1018.volts2lbs / SS1018.a)*psi2mpa; % MPa, engineering stress
SS1018.strain = data.Chan102(2:end_idx)*SS1018.volts2in / SS1018.l; % unitless, engineering strain

SS1018.tough = trapz(SS1018.strain, SS1018.stress); % MPa, toughness
SS1018.strength = SS1018.stress(idx); % MPa, ultimate strength (where necking starts)

range = 20:100; % Idx range for E calculation
SS1018.E = mean(diff(SS1018.stress(range))./diff(SS1018.strain(range))); % MPa, Young's Modulus

test = SS1018.stress ./ (SS1018.strain - .002); % Slope of .2% offset line at each point
idxs = find(test >= SS1018.E); % Find which best matches E
SS1018.yield = SS1018.stress(idxs(1)); % MPa, yield stress (.2% offset)

% Poisson ratio

%% Plot
figure()
hold on
plot(SS1018.strain*(SS1018.l/SS1018.w), SS1018.stress, '-x')

xlabel('Strain (unitless)'); ylabel('Stress (MPa)'); title('SS1018');
grid on





















