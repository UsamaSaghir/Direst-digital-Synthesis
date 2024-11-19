# Direct-digital-Synthesis
Direct Digital Synthesis (DDS) is a method used to generate precise analog waveforms, primarily sine waves, from digital signals. It operates by utilizing a stable reference clock to drive a Numerically Controlled Oscillator (NCO), which produces a digital representation of the desired waveform based on a specified frequency.
The matlab file simulates the procedure of direct dgital synthesizer.
Following parameterization is used:
o clock rate = 5 GHz
o output frequency = 950 MHz
o N = 24 bits for the phase accumulator
o P = 6 to 24 bits for the LUT (2^P LUT entries)
o amplitude accuracy of B = 6-16 bits (resolution of the LUT entries)

In this script we evaluate the spurious-free dynamic range (SFDR; power difference between the fundamental tone and the strongest spur), as P is varied (having fixed B=16 bits). Also evaluate the effect of the amplitude quantization on the SFDR, as B is varied between 6-12 bits (while keeping P fixed to 24 bits, i.e., no truncation).
