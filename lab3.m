%% Solids Lab
% Trevor Burgoyne 7 Dec 2022
% AEM 4602W, Lab Group 3Bi

%% Conversions
mm2in = 0.0393701; % in/mm
psi2mpa = 0.00689476; % MPa/psi

%% Extensometer Calibration
d = 0.1*mm2in; % mm -> in, micrometer distance
V = [0.953, 0.956, 0.955]; % Volts, extensometer reading
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

AL6061.fmax = 1118.2; % lb
AL6061.xmax = 0.021; % in
AL6061.fb = 920.4; % lb
AL6061.xb = 0.024; % in
AL6061.true_strain = log(AL6061.xb + AL6061.l / AL6061.l); % unitless, true strain at failure



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

% SS304.fmax = 1750.7; % lb
% SS304.xmax = 0.021; % in
% SS304.fb = 1227.9; % lb
% SS304.xb = 0.029; % in
% SS304.true_strain = log(SS304.xb + SS304.l / SS304.l); % unitless, true strain at failure


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

SS1018.fmax = 1750.7; % lb
SS1018.xmax = 0.021; % in
SS1018.fb = 1227.9; % lb
SS1018.xb = 0.029; % in
SS1018.true_strain = log(SS1018.xb + SS1018.l / SS1018.l); % unitless, true strain at failure


%% AL6061 Test
% time, Chan101 (Volts, load cell), time, Chan102 (Volts, crosshead), time, Chan103 (Volts, extensometer)
data = readtable('dataALTest1.csv');
idx = find(data.Chan103 == 0.345908) - 1; % idx where extensometer was removed

AL6061.volts2lbs = AL6061.fmax / max(data.Chan101); % lbs/volt using recorded max force
AL6061.volts2in  = AL6061.xmax / max(data.Chan102); % in/volt using recorded max displacement

AL6061.stress = (data.Chan101(2:end)*AL6061.volts2lbs / AL6061.a)*psi2mpa; % MPa, engineering stress
AL6061.strain = data.Chan103(2:idx)*ext_volts2in / AL6061.l; % unitless, engineering strain
AL6061.strain = [AL6061.strain', data.Chan102(idx+1:end)'*AL6061.volts2in / AL6061.l]'; % Use crosshead data after extensometer was removed

AL6061.tough = trapz(AL6061.strain, AL6061.stress); % MPa, toughness
AL6061.strength = AL6061.stress(idx); % MPa, ultimate strength (where necking starts)

% Young’s Modulus 
% Poisson ratio
% yield stress (0.2 percent offset)
 

%% Plot
plot(AL6061.strain, AL6061.stress, '-x')
xlabel('Strain (unitless)'); ylabel('Stress (MPa)'); title('AL6061');
grid on






