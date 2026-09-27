"""Data Communications and Calculus curriculum content."""

from curriculum_base import lesson, q, formula, reference, subject

subject(12, 'Data Communications', 'Networking',
        'Signals • Modulation • Multiplexing • Errors', 'settings_input_antenna')
subject(13, 'Calculus', 'Mathematics',
        'Limits • Derivatives • Integrals • Applications', 'calculate')

# ---------------- Data Communications (24 lessons) ----------------

lesson(12, 1, 'Communication Systems',
    concept='A communication system transmits information from a source to a destination through a channel, using transmitters, receivers, and media.',
    definition='A communication system is the complete set of components that conveys information from a source to a destination via a transmission channel.',
    explanation='Basic model: information source → transmitter (modulates) → channel (medium) → receiver (demodulates) → destination. The channel introduces noise and distortion. Systems are analog (continuous signals) or digital (discrete symbols). Key metrics: bandwidth, data rate, and error rate.',
    worked='Radio: voice → microphone → modulator → antenna → air → antenna → demodulator → speaker → ear',
    eng='Every communication technology — radio, fiber optics, cellular, satellite — follows this fundamental model.',
    mistakes=['Confusing the message with the signal; ignoring noise; assuming all channels are the same.'],
    practice=['What are the five components of a communication system?', 'What is the difference between analog and digital communication?'],
    quiz=[
        q('The channel in a communication system is:', ['The message', 'The transmission medium', 'The source', 'The receiver'], [1], 'Medium.'),
        q('Digital communication uses:', ['Continuous signals', 'Discrete symbols', 'Only sound', 'Only light'], [1], 'Discrete symbols.'),
    ])

lesson(12, 2, 'Analog Signals',
    concept='An analog signal is a continuous waveform that varies smoothly over time, like sound waves and traditional radio.',
    definition='An analog signal is a continuous-time, continuous-amplitude signal that represents information by varying a physical quantity.',
    explanation='Analog signals take any value within a range. Examples: voice (sound pressure), temperature, traditional AM/FM radio. They are susceptible to noise — every amplification adds distortion. Analog processing uses amplifiers, filters, and modulators. Despite digital dominance, analog remains at the physical layer (all wireless is analog).',
    worked='Sine wave: A sin(2πft + φ)\nA = amplitude, f = frequency, φ = phase\nVoice: complex waveform, 300 Hz – 3.4 kHz',
    eng='Sensors output analog signals; audio is analog at the microphone and speaker; radio waves are analog carriers.',
    mistakes=['Assuming analog is obsolete (it\'s the physical layer); confusing analog with digital quality; ignoring noise accumulation.'],
    practice=['Give an example of an analog signal.', 'Why are analog signals susceptible to noise?'],
    quiz=[
        q('An analog signal is:', ['Discrete', 'Continuous in time and amplitude', 'Binary', 'Digital'], [1], 'Continuous.'),
        q('Which is an analog signal?', ['MP3 file', 'Sound wave', 'Text message', 'JPEG image'], [1], 'Sound.'),
    ])

lesson(12, 3, 'Digital Signals',
    concept='A digital signal represents information as discrete symbols (bits), enabling noise immunity, processing, and compression.',
    definition='A digital signal is a discrete-time, discrete-amplitude signal that encodes information as a sequence of bits (0s and 1s).',
    explanation='Digital signals quantize information into symbols. Advantages: noise immunity (regeneration), error detection/correction, compression, encryption, and processing by computers. Disadvantages: requires more bandwidth (sampling), quantization noise. All modern communication is digital at the processing layer.',
    worked='Analog voice → ADC → bits → transmission → DAC → analog voice\nRegeneration: repeaters rebuild the signal, removing noise',
    eng='Digital communication enables the internet, digital TV, and mobile networks; software-defined radio processes digital signals flexibly.',
    mistakes=['Assuming digital is always better (bandwidth cost); confusing digital signals with digital systems; ignoring quantization.'],
    practice=['What are the advantages of digital signals?', 'What is quantization?'],
    quiz=[
        q('Digital signals encode information as:', ['Waves', 'Bits (0s and 1s)', 'Voltages only', 'Frequencies'], [1], 'Bits.'),
        q('A key advantage of digital signals is:', ['Noise immunity', 'Lower bandwidth', 'No processing', 'Analog compatibility'], [0], 'Noise immunity.'),
    ])

lesson(12, 4, 'Bandwidth',
    concept='Bandwidth is the range of frequencies a channel can carry, measured in hertz (Hz), determining the maximum data rate.',
    definition='Bandwidth is the difference between the highest and lowest frequencies a communication channel can transmit, measured in hertz.',
    explanation='Bandwidth limits data rate: more bandwidth = more data. A voice channel uses 300 Hz–3.4 kHz (3.1 kHz bandwidth). Fiber optics use terahertz of bandwidth. Bandwidth is a physical property of the medium and electronics. Nyquist and Shannon theorems relate bandwidth to data rate.',
    worked='Voice channel: 3400 − 300 = 3100 Hz bandwidth\nCat6 cable: 250 MHz bandwidth\nFiber: ~50 THz bandwidth',
    eng='5G uses wider bandwidth (100 MHz channels) for gigabit speeds; fiber\'s enormous bandwidth carries the internet backbone.',
    mistakes=['Confusing bandwidth with data rate; assuming more bandwidth is always available; ignoring that bandwidth is shared.'],
    practice=['What is the bandwidth of a channel from 1 MHz to 5 MHz?', 'What limits bandwidth?'],
    quiz=[
        q('Bandwidth is measured in:', ['Bits', 'Hertz', 'Watts', 'Volts'], [1], 'Hz.'),
        q('Bandwidth determines:', ['Signal color', 'Maximum data rate', 'Power only', 'Distance only'], [1], 'Data rate.'),
    ])

lesson(12, 5, 'Frequency',
    concept='Frequency is the number of cycles per second of a periodic signal, measured in hertz (Hz), inversely related to wavelength.',
    definition='Frequency is the rate at which a periodic signal repeats, measured in cycles per second (hertz), where f = 1/T.',
    explanation='Frequency (f) and period (T) are reciprocals. Higher frequency = shorter period = more data capacity but shorter range and poorer penetration. The electromagnetic spectrum allocates frequencies: radio (kHz–GHz), microwave, infrared, visible light, UV, X-ray. Frequency allocation is regulated to prevent interference.',
    worked='f = 1/T: T = 1 ms → f = 1 kHz\nFM radio: 88–108 MHz\nWi-Fi: 2.4 GHz and 5 GHz',
    eng='5G uses millimeter waves (24–40 GHz) for massive bandwidth; frequency reuse multiplies cellular capacity.',
    mistakes=['Confusing frequency with amplitude; assuming higher frequency always means better; ignoring spectrum regulation.'],
    practice=['What is the frequency of a 2 ms period signal?', 'What frequency bands does Wi-Fi use?'],
    quiz=[
        q('Frequency is measured in:', ['Seconds', 'Hertz', 'Meters', 'Watts'], [1], 'Hz.'),
        q('Frequency and period are:', ['Equal', 'Reciprocals', 'Unrelated', 'Both constant'], [1], 'f = 1/T.'),
    ])

lesson(12, 6, 'Amplitude',
    concept='Amplitude is the maximum displacement of a signal from its rest position, representing signal strength or intensity.',
    definition='Amplitude is the peak value of a signal\'s variation, representing its strength, power, or intensity.',
    explanation='Amplitude carries information in AM (amplitude modulation) and represents signal power. Higher amplitude = stronger signal = better noise immunity, but more power. Amplitude is measured in volts (electrical) or arbitrary units. Attenuation reduces amplitude with distance; amplification restores it.',
    worked='Sine wave: A sin(2πft)\nA = amplitude (peak value)\nPower ∝ A² (doubling amplitude quadruples power)',
    eng='AM radio encodes audio in amplitude; fiber optics use amplitude (light intensity) for on-off keying.',
    mistakes=['Confusing amplitude with frequency; assuming amplitude is constant over distance; ignoring power-amplitude relationship.'],
    practice=['What does amplitude represent?', 'How does power relate to amplitude?'],
    quiz=[
        q('Amplitude represents:', ['Frequency', 'Signal strength', 'Speed', 'Wavelength'], [1], 'Strength.'),
        q('Power is proportional to:', ['Amplitude', 'Amplitude squared', 'Frequency', 'Wavelength'], [1], 'A².'),
    ])

lesson(12, 7, 'Phase',
    concept='Phase describes the position of a signal within its cycle, measured in degrees or radians, used in modulation and signal processing.',
    definition='Phase is the offset of a periodic signal relative to a reference point, measured in degrees (0–360°) or radians (0–2π).',
    explanation='Phase shifts a waveform in time. Two signals can be in phase (aligned), out of phase (offset), or in antiphase (180° apart). Phase carries information in PM (phase modulation) and QAM. Phase differences enable beamforming and noise cancellation.',
    worked='sin(2πft + φ): φ = phase\nφ = 90° → cosine (shifted quarter cycle)\nφ = 180° → inverted signal',
    eng='QAM modulation encodes data in both amplitude and phase; phased array antennas steer beams by controlling phase.',
    mistakes=['Confusing phase with frequency; assuming phase is always zero; ignoring phase in modulation.'],
    practice=['What is a 180° phase shift?', 'How is phase used in modulation?'],
    quiz=[
        q('Phase is measured in:', ['Hertz', 'Degrees or radians', 'Volts', 'Watts'], [1], 'Degrees/radians.'),
        q('A 180° phase shift:', ['Doubles frequency', 'Inverts the signal', 'Halves amplitude', 'Changes wavelength'], [1], 'Inverts.'),
    ])

lesson(12, 8, 'Sampling',
    concept='Sampling converts a continuous analog signal to discrete samples at regular intervals, governed by the Nyquist theorem.',
    definition='Sampling is the process of measuring a continuous signal at discrete time intervals, converting it to a discrete-time signal.',
    explanation='The sampling rate (samples per second) must exceed twice the highest frequency (Nyquist rate) to avoid aliasing — distortion where high frequencies masquerade as low ones. Anti-aliasing filters remove frequencies above half the sampling rate before sampling. Reconstruction (DAC) interpolates samples back to analog.',
    worked='Audio: 44.1 kHz sampling (Nyquist: 22.05 kHz > 20 kHz)\nUndersampling → aliasing (wagon-wheel effect in video)',
    eng='Digital audio (44.1/48 kHz), digital video, and software-defined radio all rely on proper sampling.',
    mistakes=['Sampling below Nyquist (aliasing); no anti-aliasing filter; assuming more samples always help.'],
    practice=['What is the Nyquist rate for a 10 kHz signal?', 'What is aliasing?'],
    quiz=[
        q('Nyquist rate is ______ the highest frequency.', ['Half', 'Twice', 'Equal to', 'Ten times'], [1], '2×.'),
        q('Aliasing is caused by:', ['Too much sampling', 'Sampling below Nyquist rate', 'High amplitude', 'Low frequency'], [1], 'Undersampling.'),
    ])

lesson(12, 9, 'Nyquist Theorem',
    concept='The Nyquist theorem states that a signal must be sampled at more than twice its highest frequency to be perfectly reconstructed.',
    definition='The Nyquist-Shannon sampling theorem states that a band-limited signal can be perfectly reconstructed if sampled at a rate greater than twice its maximum frequency.',
    explanation='fs > 2 × fmax. The factor 2 is the Nyquist rate; sampling above it leaves a guard band for practical filters. Below it, aliasing corrupts the signal irreversibly. This theorem is the foundation of all digital signal processing and communication.',
    worked='Human hearing: 20 kHz max → CD audio samples at 44.1 kHz\nGuard band: 22.05 − 20 = 2.05 kHz for filter roll-off',
    eng='Telephone systems sample voice at 8 kHz (4 kHz bandwidth); high-res audio uses 96/192 kHz for ultrasonic headroom.',
    mistakes=['Sampling at exactly 2× (need more); ignoring the need for band-limiting; confusing sampling rate with bit depth.'],
    practice=['What sampling rate is needed for a 15 kHz signal?', 'Why sample above 2× rather than exactly 2×?'],
    quiz=[
        q('For a 15 kHz signal, sampling must exceed:', ['15 kHz', '30 kHz', '45 kHz', '7.5 kHz'], [1], '2 × 15 = 30 kHz.'),
        q('The Nyquist theorem enables:', ['Compression', 'Perfect reconstruction from samples', 'Modulation', 'Multiplexing'], [1], 'Reconstruction.'),
    ])

lesson(12, 10, 'Quantization',
    concept='Quantization maps continuous sample amplitudes to discrete levels, introducing quantization noise proportional to bit depth.',
    definition='Quantization is the process of mapping a continuous range of values to a finite set of discrete levels, as in analog-to-digital conversion.',
    explanation='An n-bit quantizer has 2ⁿ levels. Quantization error (noise) is the difference between the actual and quantized values. Signal-to-quantization-noise ratio (SQNR) ≈ 6.02n + 1.76 dB. More bits = finer levels = less noise but more data. Dithering adds noise to reduce quantization distortion.',
    worked='8-bit: 256 levels, SQNR ≈ 50 dB\n16-bit: 65,536 levels, SQNR ≈ 98 dB (CD quality)\n24-bit: SQNR ≈ 146 dB (studio)',
    eng='Audio CDs use 16-bit; studio recording uses 24-bit; telephone uses 8-bit (companded).',
    mistakes=['Confusing sampling with quantization; assuming more bits always help (diminishing returns); ignoring dithering.'],
    practice=['What is the SQNR of a 12-bit ADC?', 'What is dithering?'],
    quiz=[
        q('Quantization maps continuous values to:', ['Frequencies', 'Discrete levels', 'Bits only', 'Samples'], [1], 'Discrete levels.'),
        q('Doubling bit depth ______ SQNR.', ['Halves', 'Increases by ~6 dB', 'Doubles', 'No change'], [1], '+6 dB per bit.'),
    ])

lesson(12, 11, 'PCM — Pulse Code Modulation',
    concept='PCM is the standard method to digitize analog signals: sample, quantize, and encode into binary, used in digital audio and telephony.',
    definition='PCM (Pulse Code Modulation) is a digital representation of an analog signal achieved by sampling, quantizing, and encoding the amplitude at regular intervals.',
    worked='Voice: 8 kHz sampling, 8-bit quantization → 64 kbps (DS0)\nCD audio: 44.1 kHz, 16-bit → 1.411 Mbps',
    explanation='PCM is the foundation of digital telephony (T1/E1), CDs, and WAV files. Variants: DPCM (differential), ADPCM (adaptive). PCM is uncompressed — high quality but large. Compression (MP3, AAC) reduces size by exploiting perceptual redundancy.',
    eng='Digital telephony (T1: 24 PCM channels), CDs, and professional audio all use PCM; VoIP packetizes PCM for transmission.',
    mistakes=['Confusing PCM with compression (PCM is uncompressed); ignoring bit rate calculations; assuming PCM is only for audio.'],
    practice=['What is the bit rate of CD audio?', 'What are the three steps of PCM?'],
    quiz=[
        q('PCM stands for:', ['Pulse Code Modulation', 'Phase Channel Modulation', 'Parallel Communication Method', 'Primary Carrier Mode'], [0], 'Pulse Code Modulation.'),
        q('CD audio bit rate is about:', ['64 kbps', '1.4 Mbps', '10 Mbps', '100 Mbps'], [1], '44.1k × 16 × 2 = 1.411 Mbps.'),
    ])

lesson(12, 12, 'ASK — Amplitude Shift Keying',
    concept='ASK encodes digital data by varying the amplitude of a carrier wave, with on-off keying (OOK) as the simplest form.',
    definition='ASK (Amplitude Shift Keying) is a modulation technique where the amplitude of the carrier is varied to represent digital data.',
    explanation='In OOK (on-off keying), a 1 bit turns the carrier on, a 0 turns it off. ASK is simple but noise-sensitive (amplitude is easily distorted). Used in RFID, optical communication (fiber), and low-cost radio. More advanced forms use multiple amplitude levels (m-ASK) for higher data rates.',
    worked='OOK: bit 1 → carrier on; bit 0 → carrier off\nm-ASK: 4 levels → 2 bits per symbol',
    eng='Fiber optics use OOK (light on/off); RFID tags use ASK; some legacy wireless uses ASK.',
    mistakes=['Assuming ASK is noise-immune (it\'s not); confusing ASK with FSK; ignoring bandwidth requirements.'],
    practice=['What is OOK?', 'Why is ASK noise-sensitive?'],
    quiz=[
        q('ASK varies which property of the carrier?', ['Frequency', 'Amplitude', 'Phase', 'Wavelength'], [1], 'Amplitude.'),
        q('OOK represents 1 bit as:', ['Carrier off', 'Carrier on', 'Frequency change', 'Phase shift'], [1], 'On.'),
    ])

lesson(12, 13, 'FSK — Frequency Shift Keying',
    concept='FSK encodes data by shifting the carrier frequency between discrete values, offering better noise immunity than ASK.',
    definition='FSK (Frequency Shift Keying) is a modulation technique where the frequency of the carrier is varied to represent digital symbols.',
    explanation='In binary FSK (BFSK), one frequency represents 1, another represents 0. FSK is more robust than ASK because frequency is less affected by amplitude noise. Used in modems, Bluetooth (GFSK), radio pagers, and weather radios. More levels (m-FSK) increase data rate but need more bandwidth.',
    worked='BFSK: f1 = 1200 Hz (mark), f2 = 2200 Hz (space)\nGFSK (Gaussian FSK): smoothed transitions, used in Bluetooth',
    eng='Bluetooth uses GFSK; amateur radio uses FSK; caller ID uses Bell 202 FSK.',
    mistakes=['Confusing FSK with ASK; assuming FSK needs less bandwidth than ASK (it needs more); ignoring spectral efficiency.'],
    practice=['What is the difference between ASK and FSK?', 'Which Bluetooth modulation is based on FSK?'],
    quiz=[
        q('FSK varies which property?', ['Amplitude', 'Frequency', 'Phase', 'Power'], [1], 'Frequency.'),
        q('FSK is ______ noise-sensitive than ASK.', ['More', 'Less', 'Equally', 'Not'], [1], 'Less.'),
    ])

lesson(12, 14, 'PSK — Phase Shift Keying',
    concept='PSK encodes data by shifting the phase of the carrier, offering excellent noise immunity and spectral efficiency.',
    definition='PSK (Phase Shift Keying) is a modulation technique where the phase of the carrier is varied to represent digital symbols.',
    explanation='BPSK: two phases (0°, 180°) → 1 bit per symbol. QPSK: four phases (0°, 90°, 180°, 270°) → 2 bits per symbol. 8-PSK: 3 bits per symbol. PSK is robust because phase is preserved through amplitude noise. QAM combines PSK with ASK for even higher efficiency. Used in Wi-Fi, satellite, and cable modems.',
    worked='QPSK: 00 → 45°, 01 → 135°, 10 → 225°, 11 → 315°\n2 bits per symbol → double the data rate of BPSK',
    eng='Wi-Fi (802.11) uses QPSK and QAM; satellite TV uses QPSK; 5G uses up to 256-QAM.',
    mistakes=['Confusing PSK with FSK; assuming more phase levels always help (noise sensitivity increases); ignoring coherent detection requirements.'],
    practice=['How many bits per symbol does QPSK carry?', 'What is the difference between BPSK and QPSK?'],
    quiz=[
        q('PSK varies which property?', ['Amplitude', 'Frequency', 'Phase', 'Wavelength'], [2], 'Phase.'),
        q('QPSK carries how many bits per symbol?', ['1', '2', '3', '4'], [1], '2.'),
    ])

lesson(12, 15, 'QAM — Quadrature Amplitude Modulation',
    concept='QAM combines amplitude and phase modulation to encode multiple bits per symbol, maximizing spectral efficiency in modern systems.',
    definition='QAM (Quadrature Amplitude Modulation) is a modulation technique that varies both amplitude and phase of the carrier to represent multiple bits per symbol.',
    explanation='QAM uses two carriers 90° out of phase (quadrature). 16-QAM: 4 bits/symbol; 64-QAM: 6 bits; 256-QAM: 8 bits. Higher QAM = more data but requires higher SNR (noise immunity drops). Adaptive modulation (Wi-Fi, 5G) switches QAM order based on channel quality.',
    worked='16-QAM: 16 combinations of amplitude + phase → 4 bits\n256-QAM: 256 combinations → 8 bits\nSNR requirement: 16-QAM ~20 dB, 256-QAM ~30+ dB',
    eng='Cable modems (DOCSIS), Wi-Fi 6, and 5G use high-order QAM; adaptive modulation maximizes throughput in varying conditions.',
    mistakes=['Assuming higher QAM is always better (SNR limits); confusing QAM with QPSK (QPSK is 4-QAM); ignoring adaptive modulation.'],
    practice=['How many bits per symbol in 64-QAM?', 'Why does higher QAM need higher SNR?'],
    quiz=[
        q('64-QAM carries how many bits per symbol?', ['4', '6', '8', '16'], [1], 'log₂(64) = 6.'),
        q('QAM combines which two properties?', ['Frequency and phase', 'Amplitude and phase', 'Amplitude and frequency', 'Phase and wavelength'], [1], 'Amplitude + phase.'),
    ])

lesson(12, 16, 'Multiplexing',
    concept='Multiplexing combines multiple signals into one channel: FDM (frequency), TDM (time), WDM (wavelength), and CDM (code).',
    definition='Multiplexing is a technique that shares a communication channel among multiple signals by dividing the channel\'s capacity.',
    explanation='FDM: each signal gets a frequency band (radio stations). TDM: each signal gets a time slot (telephony). WDM: each signal gets a wavelength (fiber). CDM: each signal gets a code (cellular). Multiplexing maximizes channel utilization — one fiber carries terabits via WDM.',
    worked='T1 line: 24 voice channels × TDM = 1.544 Mbps\nFiber: 80 wavelengths × 100 Gbps = 8 Tbps (DWDM)',
    eng='DWDM (dense WDM) carries the internet backbone; 5G uses TDM and FDM together; CDMA was 2G cellular.',
    mistakes=['Confusing multiplexing with modulation; assuming multiplexing is free (overhead); ignoring crosstalk.'],
    practice=['What is the difference between FDM and TDM?', 'What is WDM used for?'],
    quiz=[
        q('TDM divides the channel by:', ['Frequency', 'Time', 'Wavelength', 'Code'], [1], 'Time slots.'),
        q('WDM is used in:', ['Radio', 'Fiber optics', 'Copper', 'Satellite only'], [1], 'Fiber.'),
    ])

lesson(12, 17, 'FDM — Frequency Division Multiplexing',
    concept='FDM assigns each signal a different frequency band within the channel, transmitting simultaneously without interference.',
    definition='FDM (Frequency Division Multiplexing) is a technique that divides a channel\'s bandwidth into frequency bands, each carrying a separate signal.',
    explanation='Each signal modulates a different carrier frequency; guard bands prevent overlap. FDM is analog-friendly and used in radio/TV broadcasting, ADSL (voice + data on one phone line), and early cellular. The receiver filters and demodulates its band. Contrast with TDM (time slots).',
    worked='FM radio: 88–108 MHz divided into 200 kHz stations\nADSL: 0–4 kHz voice, 25 kHz–1.1 MHz data',
    eng='Cable TV delivers 100+ channels via FDM; LTE uses OFDM (orthogonal FDM) for spectral efficiency.',
    mistakes=['Guard bands too narrow (crosstalk); assuming FDM is digital; confusing FDM with TDM.'],
    practice=['How does FDM prevent interference between channels?', 'Where is FDM used?'],
    quiz=[
        q('FDM divides the channel by:', ['Time', 'Frequency', 'Code', 'Phase'], [1], 'Frequency.'),
        q('FDM is used in:', ['T1 lines', 'Radio broadcasting', 'Ethernet', 'USB'], [1], 'Radio.'),
    ])

lesson(12, 18, 'TDM — Time Division Multiplexing',
    concept='TDM assigns each signal a recurring time slot, interleaving samples from multiple sources into one stream.',
    definition='TDM (Time Division Multiplexing) is a technique that divides a channel into time slots, each assigned to a different signal in rotation.',
    explanation='Each source gets a fixed slot in a repeating frame. Synchronous TDM assigns slots regardless of activity (wasteful if idle); statistical TDM allocates on demand (efficient but needs buffering). TDM is the backbone of digital telephony (T1/E1, SONET/SDH).',
    worked='T1: 24 channels × 8 bits × 8000 frames/s = 1.544 Mbps\nEach channel gets one 8-bit slot per frame',
    eng='SONET/SDH use TDM for fiber backbone; 4G/5G use TDM within frames; TDM is the foundation of digital telephony.',
    mistakes=['Assuming TDM slots are always full (synchronous waste); confusing TDM with FDM; ignoring framing overhead.'],
    practice=['What is the difference between synchronous and statistical TDM?', 'What is a T1 line?'],
    quiz=[
        q('TDM divides the channel by:', ['Frequency', 'Time', 'Wavelength', 'Code'], [1], 'Time.'),
        q('T1 carries how many voice channels?', ['8', '24', '32', '64'], [1], '24.'),
    ])

lesson(12, 19, 'Transmission Media',
    concept='Transmission media carry signals: twisted pair, coaxial cable, fiber optics (guided), and radio, microwave, satellite (unguided).',
    definition='A transmission media is the physical path between transmitter and receiver, classified as guided (wired) or unguided (wireless).',
    explanation='Twisted pair: cheap, short-range (Ethernet, phone). Coaxial: higher bandwidth, longer (cable TV). Fiber: enormous bandwidth, immune to EMI, long-haul (internet backbone). Unguided: radio (Wi-Fi, cellular), microwave (point-to-point), satellite (global). Choice depends on bandwidth, distance, cost, and environment.',
    worked='Twisted pair: 1 Gbps up to 100 m (Cat6)\nFiber: 100+ Tbps over km\nWi-Fi: Gbps over meters',
    eng='Submarine fiber cables carry intercontinental traffic; 5G uses microwave and mmWave; satellite covers remote areas.',
    mistakes=['Assuming fiber is always best (cost); ignoring distance limits; confusing bandwidth with data rate.'],
    practice=['Compare twisted pair, coaxial, and fiber.', 'What is the difference between guided and unguided media?'],
    quiz=[
        q('Fiber optics use:', ['Electrical signals', 'Light', 'Sound', 'Radio waves'], [1], 'Light.'),
        q('Which is an unguided medium?', ['Twisted pair', 'Coaxial', 'Fiber', 'Radio'], [3], 'Radio.'),
    ])

lesson(12, 20, 'Error Detection',
    concept='Error detection identifies corrupted data using redundancy: parity, checksums, and CRC, enabling retransmission or correction.',
    definition='Error detection is the process of identifying data corruption during transmission by adding redundant information that reveals discrepancies.',
    explanation='Parity: one bit makes the count of 1s even/odd — detects single-bit errors. Checksum: sum of data words — detects many errors. CRC (Cyclic Redundancy Check): polynomial division — detects bursts up to the polynomial length, extremely reliable. CRC is used in Ethernet, Wi-Fi, storage, and ZIP files.',
    worked='CRC-32: polynomial division, 32-bit remainder\nDetects all 1–32 bit bursts, all odd-bit errors\nEthernet frames end with CRC-32',
    eng='CRC protects every Ethernet frame; storage (ZFS) uses checksums; QR codes use Reed-Solomon correction.',
    mistakes=['Assuming parity detects all errors (only odd counts); confusing detection with correction; ignoring CRC polynomial choice.'],
    practice=['What is the difference between parity and CRC?', 'What errors does CRC detect?'],
    quiz=[
        q('Parity detects:', ['All errors', 'Odd numbers of bit errors', 'No errors', 'Only even errors'], [1], 'Odd counts.'),
        q('CRC is based on:', ['Addition', 'Polynomial division', 'Multiplication', 'Lookup tables only'], [1], 'Polynomial division.'),
    ])

lesson(12, 21, 'Parity',
    concept='Parity adds a bit to make the total number of 1s even (even parity) or odd (odd parity), detecting single-bit errors.',
    definition='Parity is a simple error-detection scheme that appends a bit to data so the total count of 1s is even or odd.',
    explanation='Even parity: parity bit makes 1s count even. Odd parity: makes it odd. The receiver checks the count; a mismatch indicates an error. Parity detects any odd number of bit flips but cannot detect even numbers, and cannot correct. Used in serial communication (UART), memory (ECC extends it), and simple protocols.',
    worked='Data: 1011001 (four 1s, even)\nEven parity bit: 0 → 10110010 (still even)\nIf one bit flips → odd count → error detected',
    eng='ECC memory extends parity to correct single-bit errors and detect double-bit errors in servers.',
    mistakes=['Assuming parity detects all errors; confusing even and odd parity; thinking parity corrects errors.'],
    practice=['What is the even parity bit for 1011001?', 'Can parity detect two bit errors?'],
    quiz=[
        q('Parity can ______ errors.', ['Correct', 'Detect (some)', 'Ignore', 'Create'], [1], 'Detect.'),
        q('Parity detects ______ numbers of bit errors.', ['Even', 'Odd', 'All', 'None'], [1], 'Odd.'),
    ])

lesson(12, 22, 'CRC — Cyclic Redundancy Check',
    concept='CRC detects errors by dividing the data by a generator polynomial and appending the remainder, catching burst errors reliably.',
    definition='CRC (Cyclic Redundancy Check) is an error-detecting code that computes a checksum via polynomial division over GF(2), appended to the data.',
    explanation='Treat data as a polynomial; divide by a generator polynomial (e.g., CRC-32: x³²+x²⁶+x²³+x²²+x¹⁶+x¹²+x¹¹+x¹⁰+x⁸+x⁷+x⁵+x⁴+x²+x+1). The remainder is the CRC. The receiver divides again; a non-zero remainder indicates errors. CRC detects all bursts ≤ polynomial degree and is hardware-efficient (shift registers).',
    worked='CRC-32: detects all 1–32 bit bursts\nUsed in Ethernet, Wi-Fi, PNG, ZIP\nComputation: XOR-based polynomial division',
    eng='CRC-32 protects every Ethernet frame; CRC-16 in USB; CRC in storage (ZFS, Btrfs) detects silent data corruption.',
    mistakes=['Confusing CRC with a hash (CRC is not cryptographic); assuming CRC detects all errors; ignoring polynomial selection.'],
    practice=['What does CRC stand for?', 'What errors does CRC-32 detect?'],
    quiz=[
        q('CRC detects all burst errors up to:', ['1 bit', 'The polynomial degree', '10 bits', '100 bits'], [1], 'Polynomial degree.'),
        q('CRC is based on:', ['Addition', 'Polynomial division', 'Multiplication', 'Substitution'], [1], 'Polynomial division.'),
    ])

lesson(12, 23, 'Data Rate',
    concept='Data rate is the number of bits transmitted per second (bps), determined by bandwidth, modulation, and signal levels.',
    definition='Data rate (bit rate) is the number of bits conveyed or processed per unit time, measured in bits per second (bps).',
    explanation='Nyquist: C = 2B log₂(M) for noiseless channels (B = bandwidth, M = levels). Shannon: C = B log₂(1 + SNR) for noisy channels — the theoretical maximum. Data rate depends on bandwidth, modulation efficiency (bits per symbol), and SNR. Real systems approach Shannon limits with advanced coding (LDPC, turbo codes).',
    worked='B = 3 kHz, 4 levels → C = 2 × 3000 × log₂(4) = 12 kbps\nB = 1 MHz, SNR = 30 dB → C = 1e6 × log₂(1001) ≈ 10 Mbps',
    eng='Shannon\'s limit drives research: 5G and fiber approach it with massive MIMO and advanced modulation.',
    mistakes=['Confusing data rate with bandwidth; assuming Shannon limit is achievable; ignoring SNR.'],
    practice=['What is the Nyquist formula?', 'What is Shannon\'s limit?'],
    quiz=[
        q('Data rate is measured in:', ['Hertz', 'Bits per second', 'Volts', 'Watts'], [1], 'bps.'),
        q('Shannon\'s formula includes:', ['Bandwidth and SNR', 'Only bandwidth', 'Only modulation', 'Only distance'], [0], 'B and SNR.'),
    ])

lesson(12, 24, 'Signal-to-Noise Ratio',
    concept='SNR measures signal power relative to noise power, in decibels, determining the maximum achievable data rate.',
    definition='SNR (Signal-to-Noise Ratio) is the ratio of signal power to noise power, expressed in decibels (dB), indicating signal quality.',
    explanation='SNR (dB) = 10 log₁₀(Psignal/Pnoise). Higher SNR = cleaner signal = higher data rates (Shannon) and lower error rates. Typical values: voice ~30 dB, Wi-Fi 20–40 dB, fiber >50 dB. SNR can be improved by increasing signal power, reducing noise, or using better modulation/coding.',
    worked='Signal = 1 mW, noise = 1 μW → SNR = 10 log₁₀(1000) = 30 dB\n30 dB SNR → Shannon capacity ≈ 10× bandwidth',
    eng='Fiber achieves high SNR (low noise); wireless struggles with noise and interference; SNR margins determine link reliability.',
    mistakes=['Confusing SNR with signal strength; assuming SNR is constant; ignoring noise sources.'],
    practice=['What is the SNR in dB for signal 10 mW and noise 0.1 mW?', 'How does SNR affect data rate?'],
    quiz=[
        q('SNR is measured in:', ['Watts', 'Decibels', 'Hertz', 'Volts'], [1], 'dB.'),
        q('Higher SNR allows:', ['Lower data rates', 'Higher data rates', 'No change', 'More noise'], [1], 'Higher rates.'),
    ])

formula('Data Communications', 'Nyquist Rate', 'C = 2B log₂(M)', 'C: capacity; B: bandwidth; M: levels', 'Noiseless channel capacity')
formula('Data Communications', 'Shannon Capacity', 'C = B log₂(1 + SNR)', 'C: capacity; B: bandwidth; SNR: signal-to-noise ratio', 'Noisy channel limit')
formula('Data Communications', 'SNR (dB)', 'SNR_dB = 10 log₁₀(P_signal / P_noise)', 'P: power in watts', 'Signal quality')

# ---------------- Calculus (25 lessons) ----------------

lesson(13, 1, 'Introduction to Calculus',
    concept='Calculus is the mathematical study of continuous change, built on two pillars: differential calculus (rates of change) and integral calculus (accumulation).',
    definition='Calculus is a branch of mathematics that studies rates of change (derivatives) and accumulation of quantities (integrals), founded by Newton and Leibniz.',
    explanation='Calculus answers two fundamental questions: How fast is something changing? (derivative) and How much has accumulated? (integral). It underpins physics, engineering, economics, and machine learning. The two operations are inverses (Fundamental Theorem of Calculus). Limits form the rigorous foundation of both.',
    worked='Speed = derivative of position\nDistance = integral of speed\nArea under a curve = definite integral',
    eng='Calculus models everything from rocket trajectories to neural network training (gradient descent is calculus).',
    mistakes=['Confusing calculus with algebra; ignoring limits; thinking derivatives and integrals are unrelated.'],
    practice=['What are the two branches of calculus?', 'Who founded calculus?'],
    quiz=[
        q('Calculus studies:', ['Discrete numbers', 'Continuous change', 'Geometry only', 'Statistics'], [1], 'Continuous change.'),
        q('The two main operations are derivatives and:', ['Limits', 'Integrals', 'Functions', 'Equations'], [1], 'Integrals.'),
    ])

lesson(13, 2, 'Functions',
    concept='A function maps each input to exactly one output, expressed as f(x), forming the language of calculus.',
    definition='A function is a relation between a set of inputs (domain) and a set of outputs (range) where each input maps to exactly one output.',
    explanation='Functions model relationships: f(x) = x² maps 3 → 9. Types: polynomial, rational, exponential, logarithmic, trigonometric. Domain: valid inputs. Range: possible outputs. Composition: f(g(x)). Inverse: f⁻¹(x). Functions are the objects calculus operates on.',
    worked='f(x) = 2x + 1: f(3) = 7\ng(x) = x²: g(f(3)) = g(7) = 49 (composition)\nDomain of √x: x ≥ 0',
    eng='Every engineering model — stress vs strain, voltage vs time — is a function; calculus analyzes how they behave.',
    mistakes=['Confusing functions with equations; ignoring domain restrictions; assuming all relations are functions.'],
    practice=['What is the domain of f(x) = 1/x?', 'What is a function composition?'],
    quiz=[
        q('A function maps each input to:', ['Multiple outputs', 'Exactly one output', 'No output', 'Two outputs'], [1], 'One output.'),
        q('The domain of 1/x is:', ['All real numbers', 'x ≠ 0', 'x > 0', 'x = 0'], [1], 'x ≠ 0.'),
    ])

lesson(13, 3, 'Limits',
    concept='A limit describes the value a function approaches as the input approaches some point, the foundation of all calculus.',
    definition='A limit is the value that a function f(x) approaches as x approaches a point a, written lim(x→a) f(x) = L.',
    explanation='Limits describe behavior near a point, even if the function is undefined there. One-sided limits (left, right) must agree for the limit to exist. Limits at infinity describe end behavior. Techniques: direct substitution, factoring, rationalizing, and L\'Hôpital\'s rule. Use this app\'s Limit calculator for numerical exploration.',
    worked='lim(x→2) (x² − 4)/(x − 2) = lim(x→2) (x + 2) = 4\nDirect substitution fails (0/0), so factor and cancel.',
    eng='Limits define derivatives and integrals rigorously; engineers use them to analyze system behavior near critical points.',
    mistakes=['Assuming limits equal function values; ignoring one-sided limits; not simplifying indeterminate forms.'],
    practice=['Evaluate lim(x→3) (x² − 9)/(x − 3).', 'What is a one-sided limit?'],
    quiz=[
        q('lim(x→2) (x² − 4)/(x − 2) equals:', ['0', '4', 'Undefined', '2'], [1], 'Factor: (x+2) → 4.'),
        q('Limits describe:', ['Function values only', 'Behavior as x approaches a point', 'Derivatives only', 'Integrals only'], [1], 'Approach behavior.'),
    ])

lesson(13, 4, 'Continuity',
    concept='A function is continuous if it has no breaks, jumps, or holes — the limit equals the function value at every point.',
    definition='A function f is continuous at a point a if lim(x→a) f(x) = f(a) — the function is defined, the limit exists, and they agree.',
    explanation='Continuity means you can draw the graph without lifting your pen. Discontinuities: removable (hole), jump, infinite. Continuous functions have the Intermediate Value Theorem: they take every value between f(a) and f(b). Most functions in engineering are continuous on their domains.',
    worked='f(x) = x² is continuous everywhere\ng(x) = 1/x is continuous except at x = 0 (infinite discontinuity)',
    eng='Continuity ensures physical systems behave predictably — no instantaneous jumps in temperature or voltage.',
    mistakes=['Assuming all functions are continuous; confusing continuity with differentiability; ignoring domain restrictions.'],
    practice=['Is f(x) = |x| continuous at x = 0?', 'What are the three conditions for continuity?'],
    quiz=[
        q('A continuous function has:', ['Breaks', 'No breaks or jumps', 'Holes', 'Asymptotes'], [1], 'No breaks.'),
        q('Continuity requires the limit to ______ the function value.', ['Differ from', 'Equal', 'Be less than', 'Be greater than'], [1], 'Equal.'),
    ])

lesson(13, 5, 'Derivatives',
    concept='The derivative measures the instantaneous rate of change of a function — the slope of the tangent line at a point.',
    definition='The derivative of f at x is f\'(x) = lim(h→0) [f(x+h) − f(x)]/h, representing the instantaneous rate of change.',
    explanation='The derivative generalizes slope to any function. Interpretations: velocity (derivative of position), acceleration (derivative of velocity), marginal cost (derivative of cost). Notation: f\'(x), dy/dx, Df. Differentiability implies continuity (but not vice versa). Use this app\'s Derivative calculator for polynomials.',
    worked='f(x) = x² → f\'(x) = 2x\nf\'(3) = 6: the slope of the tangent at x = 3 is 6',
    eng='Derivatives optimize everything: gradient descent trains neural networks; derivatives find maximum efficiency points in engineering.',
    mistakes=['Confusing derivatives with integrals; assuming all continuous functions are differentiable; ignoring units in applications.'],
    practice=['What is the derivative of x³?', 'What does the derivative represent physically?'],
    quiz=[
        q('The derivative of x³ is:', ['x²', '3x²', '3x', 'x³/3'], [1], 'Power rule.'),
        q('The derivative represents:', ['Area', 'Instantaneous rate of change', 'Accumulation', 'Average value'], [1], 'Rate of change.'),
    ])

lesson(13, 6, 'Derivative Rules',
    concept='Derivative rules — power, product, quotient, chain — enable efficient differentiation of complex functions.',
    definition='Derivative rules are formulas for differentiating functions: power rule, constant multiple, sum, product, quotient, and chain rules.',
    explanation='Power rule: d/dx[xⁿ] = nxⁿ⁻¹. Product: (fg)\' = f\'g + fg\'. Quotient: (f/g)\' = (f\'g − fg\')/g². Chain: d/dx[f(g(x))] = f\'(g(x))·g\'(x). These rules let you differentiate any elementary function. Use this app\'s Derivative calculator to verify.',
    worked='d/dx[x²·sin(x)] = 2x·sin(x) + x²·cos(x) (product)\nd/dx[sin(3x)] = 3cos(3x) (chain)',
    eng='Engineers differentiate complex models (stress, heat transfer) using these rules; symbolic calculators automate them.',
    mistakes=['Misapplying the chain rule (forgetting the inner derivative); product rule as f\'g\'; quotient rule sign errors.'],
    practice=['Differentiate x²·eˣ using the product rule.', 'Differentiate sin(2x) using the chain rule.'],
    quiz=[
        q('The chain rule applies to:', ['Sums', 'Compositions of functions', 'Products', 'Constants'], [1], 'Compositions.'),
        q('d/dx[x⁵] =', ['5x⁴', 'x⁴', '5x⁵', '4x⁵'], [0], 'Power rule.'),
    ])

lesson(13, 7, 'Product Rule',
    concept='The product rule differentiates products of functions: (fg)\' = f\'g + fg\'.',
    definition='The product rule states that the derivative of a product is the derivative of the first times the second, plus the first times the derivative of the second.',
    explanation='For f(x)·g(x), the derivative is f\'(x)g(x) + f(x)g\'(x). This is NOT f\'g\'. The rule extends to more factors. Applications: differentiating x·eˣ, x²·sin(x), and any product of elementary functions.',
    worked='d/dx[x²·sin(x)] = 2x·sin(x) + x²·cos(x)\nCheck: at x = 0, derivative = 0 (both terms vanish)',
    eng='Product rule appears in physics (work = force × distance) and economics (revenue = price × quantity).',
    mistakes=['Writing (fg)\' = f\'g\' (wrong); forgetting one term; misidentifying f and g.'],
    practice=['Differentiate x³·ln(x).', 'Why is (fg)\' ≠ f\'g\'?'],
    quiz=[
        q('(fg)\' equals:', ['f\'g\'', 'f\'g + fg\'', 'f\'g − fg\'', 'fg'], [1], 'Product rule.'),
        q('d/dx[x·eˣ] =', ['eˣ', 'x·eˣ', 'eˣ + x·eˣ', 'x·eˣ − eˣ'], [2], 'eˣ + xeˣ.'),
    ])

lesson(13, 8, 'Quotient Rule',
    concept='The quotient rule differentiates ratios of functions: (f/g)\' = (f\'g − fg\')/g².',
    definition='The quotient rule states that the derivative of a quotient is (derivative of numerator × denominator − numerator × derivative of denominator) over denominator squared.',
    explanation='For f(x)/g(x), the derivative is [f\'(x)g(x) − f(x)g\'(x)] / [g(x)]². The order matters: numerator derivative first, minus. Mnemonic: "low d-high minus high d-low, over low squared." Applications: differentiating tan(x) = sin(x)/cos(x), rational functions.',
    worked='d/dx[sin(x)/cos(x)] = [cos(x)·cos(x) − sin(x)·(−sin(x))]/cos²(x)\n= [cos²(x) + sin²(x)]/cos²(x) = 1/cos²(x) = sec²(x)',
    eng='Quotient rule derives derivatives of tangent, cotangent, and rational transfer functions in control theory.',
    mistakes=['Sign errors (minus becomes plus); squaring only the denominator; confusing numerator and denominator.'],
    practice=['Differentiate (x² + 1)/(x − 1).', 'What is the derivative of tan(x)?'],
    quiz=[
        q('(f/g)\' equals:', ['(f\'g + fg\')/g²', '(f\'g − fg\')/g²', 'f\'/g\'', '(fg\' − f\'g)/g²'], [1], 'Quotient rule.'),
        q('d/dx[tan(x)] =', ['sec²(x)', 'sec(x)', 'tan²(x)', '1/cos(x)'], [0], 'sec²(x).'),
    ])

lesson(13, 9, 'Chain Rule',
    concept='The chain rule differentiates composite functions: d/dx[f(g(x))] = f\'(g(x))·g\'(x) — the derivative of the outside times the derivative of the inside.',
    definition='The chain rule states that the derivative of a composition f(g(x)) is f\'(g(x)) multiplied by g\'(x).',
    explanation='For nested functions, differentiate outside-in, multiplying each layer\'s derivative. Extended: d/dx[f(g(h(x)))] = f\'(g(h(x)))·g\'(h(x))·h\'(x). The chain rule is the most important differentiation rule — it handles eˣ², sin(3x), ln(x²+1), and more.',
    worked='d/dx[sin(3x)] = cos(3x)·3 = 3cos(3x)\nd/dx[eˣ²] = eˣ²·2x = 2xeˣ²',
    eng='Backpropagation in neural networks is the chain rule applied to millions of parameters.',
    mistakes=['Forgetting the inner derivative; differentiating inside-out; stopping after one layer.'],
    practice=['Differentiate eˣ².', 'Differentiate ln(x² + 1).'],
    quiz=[
        q('The chain rule applies to:', ['Products', 'Compositions', 'Quotients', 'Sums'], [1], 'Compositions.'),
        q('d/dx[sin(3x)] =', ['cos(3x)', '3cos(3x)', '−3cos(3x)', 'sin(3x)'], [1], '3cos(3x).'),
    ])

lesson(13, 10, 'Implicit Differentiation',
    concept='Implicit differentiation finds dy/dx for equations where y is not isolated, differentiating both sides with respect to x.',
    definition='Implicit differentiation is a technique for finding the derivative of y with respect to x when y is defined implicitly by an equation in x and y.',
    explanation='When y cannot be easily solved for (e.g., x² + y² = 25), differentiate both sides, treating y as a function of x (apply the chain rule: d/dx[y] = dy/dx). Then solve for dy/dx. Used for curves, related rates, and inverse functions.',
    worked='x² + y² = 25\n2x + 2y·dy/dx = 0\ndy/dx = −x/y',
    eng='Implicit differentiation analyzes curves in engineering (stress-strain relationships) and derives derivatives of inverse trig functions.',
    mistakes=['Forgetting dy/dx when differentiating y terms; not applying the chain rule; algebraic errors solving for dy/dx.'],
    practice=['Find dy/dx for x² + y² = 25.', 'What is implicit differentiation used for?'],
    quiz=[
        q('Implicit differentiation is used when:', ['y is explicit', 'y is defined implicitly', 'x is constant', 'Functions are linear'], [1], 'Implicit.'),
        q('d/dx[y²] =', ['2y', '2y·dy/dx', '2·dy/dx', 'y²'], [1], 'Chain rule.'),
    ])

lesson(13, 11, 'Higher-Order Derivatives',
    concept='Higher-order derivatives differentiate repeatedly: second derivative (acceleration), third (jerk), and beyond.',
    definition='A higher-order derivative is the derivative of a derivative: f\'\'(x) is the second derivative, f\'\'\'(x) the third, and so on.',
    explanation='First derivative: rate of change (velocity). Second: rate of change of rate (acceleration). Third: jerk (rate of change of acceleration). Notation: f\'\'(x), f⁽ⁿ⁾(x), d²y/dx². Higher-order derivatives appear in Taylor series, differential equations, and motion analysis.',
    worked='f(x) = x³\nf\'(x) = 3x²\nf\'\'(x) = 6x\nf\'\'\'(x) = 6\nf⁽⁴⁾(x) = 0',
    eng='Jerk matters in elevator and roller coaster design; higher-order derivatives appear in beam deflection equations.',
    mistakes=['Confusing higher-order with higher powers; notation errors (d²y/dx² ≠ (dy/dx)²); ignoring physical meaning.'],
    practice=['Find the second derivative of x⁴.', 'What does the second derivative represent physically?'],
    quiz=[
        q('The second derivative of x⁴ is:', ['4x³', '12x²', '12x', '24x'], [1], '12x².'),
        q('The second derivative of position is:', ['Velocity', 'Acceleration', 'Jerk', 'Force'], [1], 'Acceleration.'),
    ])

lesson(13, 12, 'Applications of Derivatives',
    concept='Derivatives find maxima/minima, rates of change, and tangent lines — essential for optimization and analysis in engineering.',
    definition='Applications of derivatives include finding extrema (maxima/minima), determining rates of change, and approximating functions with tangent lines.',
    explanation='Critical points (f\' = 0 or undefined) are candidates for extrema. Second derivative test: f\'\' > 0 → minimum, f\'\' < 0 → maximum. Related rates connect changing quantities via differentiation. Linear approximation: f(x) ≈ f(a) + f\'(a)(x − a). Optimization: maximize efficiency, minimize cost.',
    worked='Maximize area with fixed perimeter:\nA = xy, P = 2x + 2y → y = (P − 2x)/2\nA(x) = x(P − 2x)/2 → A\'(x) = (P − 4x)/2 = 0 → x = P/4 (square!)',
    eng='Engineers optimize designs: minimum material for maximum strength, maximum range for minimum fuel.',
    mistakes=['Not checking endpoints in optimization; confusing maxima and minima; ignoring constraints.'],
    practice=['Find the maximum of f(x) = −x² + 4x.', 'What is a critical point?'],
    quiz=[
        q('Critical points occur where:', ['f\' = 0 or undefined', 'f = 0', 'f\'\' = 0', 'f is maximum'], [0], 'f\' = 0 or DNE.'),
        q('f\'\' > 0 at a critical point indicates:', ['Maximum', 'Minimum', 'Inflection', 'Nothing'], [1], 'Minimum.'),
    ])

lesson(13, 13, 'Optimization',
    concept='Optimization finds the best solution — maximum or minimum — of a function subject to constraints, using derivatives.',
    definition='Optimization is the process of finding the maximum or minimum value of a function, often subject to constraints, using calculus.',
    explanation='Steps: define the objective function, find critical points (f\' = 0), evaluate at critical points and boundaries, select the best. Constraints reduce variables (substitute). Applications: minimize cost, maximize profit, minimize material, maximize efficiency. Lagrange multipliers handle multiple constraints.',
    worked='Minimize surface area of a cylinder with fixed volume:\nV = πr²h → h = V/(πr²)\nA = 2πr² + 2πrh → A\'(r) = 0 → optimal r, h',
    eng='Optimization is everywhere: structural design, machine learning (loss minimization), logistics, and economics.',
    mistakes=['Not verifying it\'s a max or min; ignoring constraints; forgetting boundary checks.'],
    practice=['A farmer has 100 m of fencing. What rectangular dimensions maximize area?', 'What are the steps of optimization?'],
    quiz=[
        q('Optimization finds:', ['Averages', 'Maxima or minima', 'Derivatives only', 'Integrals only'], [1], 'Extrema.'),
        q('The first step in optimization is:', ['Integrate', 'Define the objective function', 'Differentiate twice', 'Plot'], [1], 'Objective function.'),
    ])

lesson(13, 14, 'Related Rates',
    concept='Related rates find how changing quantities are connected by differentiating their relationship with respect to time.',
    definition='Related rates problems determine the rate of change of one quantity by relating it to other quantities whose rates of change are known.',
    explanation='Steps: identify variables and their rates, find an equation relating them, differentiate with respect to time (implicit differentiation), substitute known values, solve for the unknown rate. Classic problems: expanding shadows, filling tanks, moving ladders.',
    worked='Ladder 5 m, base slides at 1 m/s. How fast does the top fall when base is 3 m?\nx² + y² = 25 → 2x·dx/dt + 2y·dy/dt = 0\nAt x = 3, y = 4: dy/dt = −(3/4)·1 = −0.75 m/s',
    eng='Related rates model connected systems: pressure-volume-temperature in engines, current-voltage in circuits.',
    mistakes=['Differentiating without respect to time; substituting before differentiating; unit mismatches.'],
    practice=['A balloon inflates at 10 cm³/s. How fast does the radius grow at r = 5 cm?', 'What are the steps for related rates?'],
    quiz=[
        q('Related rates connect:', ['Unrelated variables', 'Changing quantities via their relationship', 'Only constants', 'Only derivatives'], [1], 'Connected rates.'),
        q('Related rates differentiate with respect to:', ['x', 'Time', 'y', 'The variable'], [1], 'Time.'),
    ])

lesson(13, 15, 'Integrals',
    concept='An integral accumulates quantities — the area under a curve — and is the inverse operation of differentiation.',
    definition='An integral is a mathematical object representing accumulation: the definite integral computes the area under a curve; the indefinite integral finds antiderivatives.',
    explanation='Indefinite integral: ∫f(x)dx = F(x) + C where F\' = f. Definite integral: ∫[a,b] f(x)dx = F(b) − F(a) (Fundamental Theorem). Integrals compute areas, volumes, distances, work, and accumulated change. Use this app\'s Integral calculator for polynomials.',
    worked='∫x² dx = x³/3 + C\n∫[0,2] x² dx = 8/3 − 0 = 8/3 (area under x² from 0 to 2)',
    eng='Integrals compute work (force × distance), energy, center of mass, and probabilities in engineering.',
    mistakes=['Confusing definite and indefinite integrals; forgetting +C; ignoring the Fundamental Theorem.'],
    practice=['What is ∫x³ dx?', 'What does a definite integral compute?'],
    quiz=[
        q('∫x³ dx =', ['x⁴/4 + C', '3x² + C', 'x⁴ + C', 'x²/2 + C'], [0], 'Power rule for integrals.'),
        q('The definite integral computes:', ['Slope', 'Area under a curve', 'Rate of change', 'Maximum'], [1], 'Area.'),
    ])

lesson(13, 16, 'Indefinite Integrals',
    concept='An indefinite integral finds the antiderivative — a function whose derivative is the integrand — plus a constant of integration.',
    definition='An indefinite integral ∫f(x)dx is the family of all antiderivatives of f, expressed as F(x) + C.',
    explanation='Since derivatives of constants vanish, antiderivatives differ by a constant C. Basic rules: ∫xⁿdx = xⁿ⁺¹/(n+1) + C (n ≠ −1), ∫eˣdx = eˣ + C, ∫sin(x)dx = −cos(x) + C. Linearity: ∫[af + bg] = a∫f + b∫g. Use this app\'s Basic Integral calculator.',
    worked='∫(3x² + 2x + 1)dx = x³ + x² + x + C\nCheck: d/dx = 3x² + 2x + 1 ✓',
    eng='Antiderivatives recover position from velocity, velocity from acceleration — essential in dynamics.',
    mistakes=['Forgetting +C; power rule errors (n = −1); not checking by differentiating.'],
    practice=['Find ∫(2x + 3)dx.', 'Why is +C needed?'],
    quiz=[
        q('∫(2x + 3)dx =', ['2x² + 3x + C', 'x² + 3x + C', 'x² + 3 + C', '2 + C'], [1], 'x² + 3x + C.'),
        q('The constant C is needed because:', ['It looks nice', 'Derivatives of constants vanish', 'It is required by law', 'It cancels out'], [1], 'Constants vanish in derivatives.'),
    ])

lesson(13, 17, 'Definite Integrals',
    concept='A definite integral computes the net area under a curve between two limits, evaluated via the Fundamental Theorem of Calculus.',
    definition='A definite integral ∫[a,b] f(x)dx is the net signed area between f(x) and the x-axis from a to b, equal to F(b) − F(a).',
    explanation='The definite integral accumulates over an interval. Properties: linearity, additivity over intervals, and ∫[a,b] = −∫[b,a]. The Fundamental Theorem connects definite integrals to antiderivatives. Applications: total distance, work, charge, and average value.',
    worked='∫[1,3] 2x dx = x²|[1,3] = 9 − 1 = 8\nArea under 2x from 1 to 3 is 8',
    eng='Definite integrals compute total energy consumption, total charge flow, and accumulated rainfall in engineering.',
    mistakes=['Sign errors in evaluation; confusing net area with total area; ignoring limits.'],
    practice=['Evaluate ∫[0,2] (x² + 1)dx.', 'What does a negative definite integral mean?'],
    quiz=[
        q('∫[0,2] (x² + 1)dx =', ['14/3', '4', '8/3', '10/3'], [0], '[x³/3 + x] = 8/3 + 2 = 14/3.'),
        q('The Fundamental Theorem connects:', ['Derivatives and integrals', 'Limits and continuity', 'Sums and products', 'Functions and relations'], [0], 'Derivatives ↔ integrals.'),
    ])

lesson(13, 18, 'Fundamental Theorem of Calculus',
    concept='The Fundamental Theorem of Calculus links differentiation and integration: they are inverse operations.',
    definition='The Fundamental Theorem of Calculus states that if F is an antiderivative of f, then ∫[a,b] f(x)dx = F(b) − F(a), and d/dx ∫[a,x] f(t)dt = f(x).',
    explanation='Part 1: the derivative of the integral of f is f (integration undoes differentiation). Part 2: definite integrals can be evaluated via antiderivatives. This theorem unifies the two branches of calculus and makes computation practical.',
    worked='d/dx ∫[0,x] t² dt = x² (Part 1)\n∫[0,2] x² dx = 8/3 via antiderivative (Part 2)',
    eng='The FTC is the cornerstone of calculus — it makes computing areas, work, and accumulated quantities tractable.',
    mistakes=['Confusing the two parts; thinking the theorem is obvious (it\'s profound); misapplying to non-continuous functions.'],
    practice=['State the two parts of the FTC.', 'Evaluate ∫[1,4] 2x dx using the FTC.'],
    quiz=[
        q('The FTC states that differentiation and integration are:', ['Unrelated', 'Inverse operations', 'The same', 'Linear'], [1], 'Inverses.'),
        q('∫[1,4] 2x dx =', ['15', '16', '12', '8'], [0], 'x²|₁⁴ = 16 − 1 = 15.'),
    ])

lesson(13, 19, 'Integration Rules',
    concept='Integration rules — power, constant multiple, sum, and substitution — enable integration of complex functions.',
    definition='Integration rules are formulas for finding antiderivatives: power rule, linearity, and substitution (reverse chain rule).',
    explanation='Power rule: ∫xⁿdx = xⁿ⁺¹/(n+1) + C. Linearity: ∫[af + bg] = a∫f + b∫g. Substitution: ∫f(g(x))g\'(x)dx = ∫f(u)du where u = g(x). Substitution is the reverse of the chain rule and handles composite integrands.',
    worked='∫2x·eˣ² dx: u = x², du = 2x dx\n= ∫eᵘ du = eᵘ + C = eˣ² + C',
    eng='Integration by substitution and parts are workhorses in physics and engineering analysis.',
    mistakes=['Forgetting to substitute back; not adjusting for du; misidentifying u.'],
    practice=['Integrate ∫2x·eˣ² dx using substitution.', 'What is the power rule for integration?'],
    quiz=[
        q('Substitution is the reverse of:', ['Product rule', 'Chain rule', 'Quotient rule', 'Power rule'], [1], 'Chain rule.'),
        q('∫x⁴ dx =', ['x⁵/5 + C', '4x³ + C', 'x⁵ + C', 'x³/3 + C'], [0], 'Power rule.'),
    ])

lesson(13, 20, 'Integration by Substitution',
    concept='Integration by substitution (u-substitution) simplifies integrals by changing variables, the reverse of the chain rule.',
    definition='Integration by substitution is a method that transforms ∫f(g(x))g\'(x)dx into ∫f(u)du by substituting u = g(x).',
    explanation='Choose u as the inner function (or the function inside another). Compute du = g\'(x)dx, substitute, integrate in u, then substitute back. Look for a function and its derivative in the integrand. Definite integrals: change limits to u-values.',
    worked='∫x·√(x²+1) dx: u = x² + 1, du = 2x dx\n= (1/2)∫√u du = (1/2)·(2/3)u³/² + C = (1/3)(x²+1)³/² + C',
    eng='Substitution integrates complex physics integrands: Gaussian functions, exponential decay, and oscillatory terms.',
    mistakes=['Forgetting to substitute back to x; wrong du; not changing limits in definite integrals.'],
    practice=['Integrate ∫x·√(x²+1) dx.', 'When do you use substitution?'],
    quiz=[
        q('Substitution works when the integrand contains:', ['A function and its derivative', 'Only polynomials', 'Only exponentials', 'Only trig functions'], [0], 'Function + derivative.'),
        q('After integrating in u, you must:', ['Stop', 'Substitute back to x', 'Differentiate', 'Integrate again'], [1], 'Back-substitute.'),
    ])

lesson(13, 21, 'Integration by Parts',
    concept='Integration by parts integrates products of functions: ∫u dv = uv − ∫v du, the reverse of the product rule.',
    definition='Integration by parts is a technique based on the product rule: ∫u dv = uv − ∫v du, useful for products of functions.',
    explanation='Choose u (to differentiate) and dv (to integrate) using LIATE (Log, Inverse trig, Algebraic, Trig, Exponential). Apply the formula. May need multiple applications or algebraic solving (cyclic integrals). Handles ∫x·eˣdx, ∫ln(x)dx, ∫x·sin(x)dx.',
    worked='∫x·eˣ dx: u = x, dv = eˣ dx → du = dx, v = eˣ\n= x·eˣ − ∫eˣ dx = x·eˣ − eˣ + C',
    eng='Integration by parts derives Fourier transforms and solves differential equations in engineering.',
    mistakes=['Choosing u and dv poorly; sign errors; not applying the formula correctly.'],
    practice=['Integrate ∫x·eˣ dx by parts.', 'What is the LIATE rule?'],
    quiz=[
        q('Integration by parts is based on:', ['Chain rule', 'Product rule', 'Quotient rule', 'Power rule'], [1], 'Product rule.'),
        q('∫x·eˣ dx =', ['x·eˣ + C', 'x·eˣ − eˣ + C', 'eˣ + C', 'x²·eˣ + C'], [1], 'xeˣ − eˣ + C.'),
    ])

lesson(13, 22, 'Applications of Integration',
    concept='Integration computes areas, volumes, work, and accumulated quantities — the practical power of calculus.',
    definition='Applications of integration include computing areas between curves, volumes of revolution, work, and total accumulated change.',
    explanation='Area between curves: ∫[a,b] (top − bottom) dx. Volume by disks/washers: ∫πr² dx. Work: ∫F(x) dx. Average value: (1/(b−a))∫[a,b] f(x)dx. These tools turn physical problems into computable integrals.',
    worked='Area between y = x² and y = x from 0 to 1:\n∫[0,1] (x − x²) dx = [x²/2 − x³/3] = 1/2 − 1/3 = 1/6',
    eng='Integration computes center of mass, moment of inertia, fluid pressure, and total energy in engineering design.',
    mistakes=['Wrong order (top − bottom); ignoring units; not sketching the region.'],
    practice=['Find the area between y = x² and y = x from 0 to 1.', 'What does integration compute in physics?'],
    quiz=[
        q('Area between curves uses:', ['∫(top − bottom)dx', '∫(bottom − top)dx', '∫(top + bottom)dx', '∫top·bottom dx'], [0], 'Top minus bottom.'),
        q('Work is computed as:', ['∫F dx', 'F·x', 'F/x', 'dF/dx'], [0], 'Integral of force.'),
    ])

lesson(13, 23, 'Area Under Curves',
    concept='The definite integral computes the area between a curve and the x-axis, with regions below the axis contributing negatively.',
    definition='The area under a curve f(x) from a to b is the definite integral ∫[a,b] f(x)dx, representing net signed area.',
    explanation='For f(x) ≥ 0, the integral is the area. For regions below the axis, the integral is negative; total area uses |f(x)| or splits at zeros. Applications: total distance, accumulated flow, and probability. Use this app\'s Definite Integral calculator with numerical methods.',
    worked='∫[0,π] sin(x) dx = −cos(x)|[0,π] = 2\nArea under one hump of sine is 2',
    eng='Area under a velocity curve gives displacement; under a power curve gives energy.',
    mistakes=['Confusing net area with total area; not splitting at zeros; sign errors.'],
    practice=['Find the area under sin(x) from 0 to π.', 'What does a negative integral mean for area?'],
    quiz=[
        q('∫[0,π] sin(x) dx =', ['0', '1', '2', 'π'], [2], '2.'),
        q('For total area (not net), you must:', ['Use absolute value', 'Ignore signs', 'Differentiate', 'Integrate twice'], [0], 'Absolute value.'),
    ])

lesson(13, 24, 'Differential Equations Introduction',
    concept='A differential equation relates a function to its derivatives, modeling how systems change over time.',
    definition='A differential equation is an equation that relates a function to its derivatives, describing rates of change in dynamic systems.',
    explanation='Differential equations model everything that changes: population growth, cooling, circuits, motion. Order: highest derivative. Types: ordinary (ODE, one variable) and partial (PDE, multiple variables). Solutions: general (with constants) and particular (with initial conditions). Separation of variables solves first-order ODEs.',
    worked='dy/dx = ky → dy/y = k dx → ln|y| = kx + C → y = Ceᵏˣ\nExponential growth/decay',
    eng='Newton\'s laws are differential equations; circuit analysis uses them; control theory is built on them.',
    mistakes=['Confusing ODEs with PDEs; not applying initial conditions; integration errors.'],
    practice=['What is a differential equation?', 'Solve dy/dx = 2x.'],
    quiz=[
        q('A differential equation relates:', ['Functions to integrals', 'Functions to derivatives', 'Variables to constants', 'Equations to graphs'], [1], 'Derivatives.'),
        q('dy/dx = 2x has solution:', ['y = 2x + C', 'y = x² + C', 'y = 2 + C', 'y = x³ + C'], [1], 'x² + C.'),
    ])

lesson(13, 25, 'Engineering Applications of Calculus',
    concept='Calculus is the language of engineering: derivatives for rates and optimization, integrals for accumulation and design.',
    definition='Engineering applications of calculus include optimization, dynamics, signal processing, control systems, and structural analysis.',
    explanation='Mechanics: velocity/acceleration (derivatives), work/energy (integrals). Electrical: charge/current relationships, circuit analysis. Control: system response and stability. Structural: beam deflection, stress analysis. Thermodynamics: heat transfer rates. Calculus transforms physical laws into solvable models.',
    worked='Beam deflection: EI·d²y/dx² = M(x)\nIntegrate twice with boundary conditions → deflection curve',
    eng='Every engineering discipline relies on calculus: it is the mathematical foundation of the profession.',
    mistakes=['Applying calculus without understanding the physics; ignoring boundary conditions; unit errors.'],
    practice=['Give three engineering applications of derivatives.', 'Give three engineering applications of integrals.'],
    quiz=[
        q('In engineering, derivatives model:', ['Static systems', 'Rates of change and optimization', 'Only geometry', 'Only statistics'], [1], 'Rates.'),
    ])

formula('Calculus', 'Power Rule (Derivative)', 'd/dx[xⁿ] = nxⁿ⁻¹', 'n: any real number', 'Differentiation')
formula('Calculus', 'Power Rule (Integral)', '∫xⁿ dx = xⁿ⁺¹/(n+1) + C', 'n ≠ −1', 'Integration')
formula('Calculus', 'Fundamental Theorem', '∫[a,b] f(x)dx = F(b) − F(a)', 'F: antiderivative of f', 'Definite integrals')
formula('Calculus', 'Chain Rule', 'd/dx[f(g(x))] = f\'(g(x))·g\'(x)', 'f, g: differentiable', 'Composite functions')
