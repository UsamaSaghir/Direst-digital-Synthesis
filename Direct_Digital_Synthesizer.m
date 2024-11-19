% COMM.SYS.660 HW# 5 Q2
% Parameters given,

clk_rate = 5e9;
f_out = 950e6;
N = 24;
P = 6:24;
B = 6:16;

% Generating sinwave LUT entries
% For fixed B =16, varying P from 6:24 

for j = 1:length(P)
    for i = 1:2^P(length(P))
        if i > 2^(P(j))
            LUT_fixed_B(i, j) = nan;
        else
            LUT_fixed_B(i, j) = floor(2^16*sin((2*pi*(i-1))/(2^P(j)))+0.5)/2^16;
        end
    end
end

% For fixed P =24 , varying B from 6:16 
for j = 1:length(B)
    LUT_fixed_P(:, j) = floor(2^B(j)*sin((2*pi*((1:2^24)-1))/(2^24))+0.5)/2^B(j);
end

phase_inc = uint32(f_out / clk_rate * 2^N);        % Phase increment calculation for 24-bit phase
num_samples = 0.1e-3*clk_rate;                     % Number of samples in 0.1msec time
phase = uint32(0);                                 % Inital starting phase = 0.
% For fixed B = 16 , converting phase to amplitude 
for var_p = 1: length(P) 
    for i = 1:num_samples
        index = bitshift(phase, -(N-P(var_p)))+1;           % Taking P most significant bits out of N for LUT index.
        x_fixed_B(i, var_p) = LUT_fixed_B(index, var_p);    % Using LUT for phase to amplitude conversion
        phase = mod(phase + phase_inc, 2^N);                % Accumulate phase
    end
    % Calculate PSD and SFDR
    PSD = fft(kaiser(length(x_fixed_B(:,var_p)),7).*x_fixed_B(:,var_p));        % Calculating generated signal PSD
    PSD_dB_P(:, var_p) = 20 * log10(abs(PSD(1:length(PSD)/2)));                 % linear PSD -> PSD in dB
    fun_freq_ind = find(0:clk_rate/length(PSD):clk_rate/2-clk_rate/length(PSD) == f_out);
    fun_freq_pow = PSD_dB_P(fun_freq_ind,var_p);    % Fundamental tone power
    [~, max_ind] = max(PSD_dB_P(:,var_p));
    if max_ind == fun_freq_ind
        PSD_dB_P(max_ind, var_p) = -Inf;            % Excluding the power at fundamental freq
        [~, max_ind] = max(PSD_dB_P(:, var_p));
    end
    spur_pow = PSD_dB_P(max_ind, var_p);            % Strongest spur power
    sfdr_p(var_p) = fun_freq_pow - spur_pow;        % SFDR value
end

% For fixed P = 24 , converting phase to amplitude
phase = uint32(0);
for var_b = 1:length(B)
    for i = 1:num_samples
        index = bitshift(phase, -(N-24))+1;                 % Taking P most significant bits out of N for LUT index.
        x_fixed_P(i, var_b) = LUT_fixed_P(index, var_b);    % Using LUT for phase to amplitude conversion
        phase = mod(phase + phase_inc, 2^N);                % Accumulate phase
    end
    % Calculate PSD and SFDR
    PSD = fft(kaiser(length(x_fixed_P(:,var_b)),7).*x_fixed_P(:,var_b));        % Calculating PSD of generated signal
    PSD_dB(:, var_b) = 20 * log10(abs(PSD(1:length(PSD)/2)));                   % PSD linear -> PSD dB
    fun_freq_ind = find(0:clk_rate/length(PSD):clk_rate/2-clk_rate/length(PSD) == f_out);
    fun_freq_pow = PSD_dB(fun_freq_ind,var_b);      % Fundamental tone power
    [~, max_ind] = max(PSD_dB(:,var_b));
    if max_ind == fun_freq_ind
        PSD_dB(max_ind, var_b) = -Inf;              % Excluding the power at fundamental freq
        [~, max_ind] = max(PSD_dB(:, var_b));
    end
    spur_pow = PSD_dB(max_ind, var_b);              % Strongest spur power
    sfdr_b(var_b) = fun_freq_pow - spur_pow;        % SFDR value
end

% Plotting SFDR vs P
figure(1)
plot(P, sfdr_p); grid on;title('SFDR vs P (Phase bits used in LUT)');
ylabel('SFDR in dB');xlabel('Number of bits used for Phase encoding in LUT (P), fixed B = 16');

% Plotting SFDR vs B
figure(2)
plot(B, sfdr_b); grid on;title('SFDR vs B (Amplitude bits used in LUT)');
ylabel('SFDR in dB');xlabel('Number of bits used for Amplitude encoding in LUT (B), fixed P = 24');

% Plotting the spectra of generated time signal x(n) with B = 16 and
% varying P.
figure(3)
plot((0:clk_rate/length(PSD):clk_rate/2-clk_rate/length(PSD))/1e6,PSD_dB_P(:, 3)); grid on;
xlabel('Frequency MHz'); ylabel('Power Spectral Density (dB)');
title('PSD of generated time signal x(n) with B = 16 and P = 8');
    
figure(4)
plot((0:clk_rate/length(PSD):clk_rate/2-clk_rate/length(PSD))/1e6,PSD_dB_P(:, 8)); grid on;
xlabel('Frequency MHz'); ylabel('Power Spectral Density (dB)');
title('PSD of generated time signal x(n) with B = 16 and P = 13');

figure(5)
plot((0:clk_rate/length(PSD):clk_rate/2-clk_rate/length(PSD))/1e6,PSD_dB_P(:, 17)); grid on;
xlabel('Frequency MHz'); ylabel('Power Spectral Density (dB)');
title('PSD of generated time signal x(n) with B = 16 and P = 22');

% Plotting the spectra of generated time signal x(n) with P = 24 and
% varying B.
figure(6)
plot((0:clk_rate/length(PSD):clk_rate/2-clk_rate/length(PSD))/1e6,PSD_dB(:, 2)); grid on;
xlabel('Frequency MHz'); ylabel('Power Spectral Density (dB)');
title('PSD of generated time signal x(n) with B = 7 and P = 24');

figure(7)
plot((0:clk_rate/length(PSD):clk_rate/2-clk_rate/length(PSD))/1e6,PSD_dB(:, 7)); grid on;
xlabel('Frequency MHz'); ylabel('Power Spectral Density (dB)');
title('PSD of generated time signal x(n) with B = 12 and P = 24');

figure(8)
plot((0:clk_rate/length(PSD):clk_rate/2-clk_rate/length(PSD))/1e6,PSD_dB(:, 10)); grid on;
xlabel('Frequency MHz'); ylabel('Power Spectral Density (dB)');
title('PSD of generated time signal x(n) with B = 15 and P = 24');

