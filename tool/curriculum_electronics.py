"""Electronics and Embedded Systems curriculum content."""

from curriculum_base import lesson, q, formula, reference, subject

subject(10, 'Electronics', 'Electronics',
        'Circuits • Components • Op-Amps • Signals', 'bolt')
subject(11, 'Embedded Systems', 'Hardware',
        'Microcontrollers • GPIO • UART • RTOS', 'developer_board')

# ---------------- Electronics (26 lessons) ----------------

lesson(10, 1, 'Basic Electronics',
    concept='Electronics is the study and application of electrical components and circuits to control the flow of electrons for useful functions.',
    definition='Basic electronics is the foundation of electrical circuits: voltage, current, resistance, and the components that manipulate them.',
    explanation='Electronics uses active components (transistors, ICs) and passive components (resistors, capacitors, inductors) to build circuits. Core quantities: voltage (V, energy per charge), current (I, charge flow), resistance (V/I), power (VI). Circuits range from simple LED drivers to computers. Ohm\'s law and Kirchhoff\'s laws are the starting point for all analysis.',
    worked='Simple circuit: battery → resistor → LED\nV = IR determines current\nP = VI determines power dissipated',
    eng='Every electronic device — phones, cars, medical equipment, satellites — starts with these fundamentals.',
    mistakes='Confusing voltage with current; ignoring power ratings; assuming ideal components.',
    practice=['What are the three core electrical quantities?', 'What is the difference between active and passive components?'],
    quiz=[
        q('Voltage is measured in:', ['Amperes', 'Volts', 'Ohms', 'Watts'], [1], 'Voltage is in volts.'),
        q('Current is the flow of:', ['Protons', 'Electrons', 'Neutrons', 'Photons'], [1], 'Current is electron flow.'),
    ])

lesson(10, 2, 'Voltage',
    concept='Voltage (electric potential difference) is the energy per unit charge that drives current through a circuit.',
    definition='Voltage is the electrical potential difference between two points, measured in volts (V), representing energy per unit charge.',
    explanation='Voltage is the "pressure" that pushes charge through a conductor. 1 volt = 1 joule per coulomb. Sources: batteries (DC), generators (AC). Voltage is measured in parallel with a component. In circuits, voltage drops across components as energy is used.',
    worked='Battery: 9 V potential difference\nAcross a resistor: V = IR drop\nVoltmeter connects in parallel to measure',
    eng='Power grids transmit at hundreds of kilovolts to reduce current (and losses); phone chargers convert to 5 V USB.',
    mistakes=['Measuring voltage in series; confusing voltage with current; ignoring polarity.'],
    practice=['How do you measure voltage?', 'What is the unit of voltage?'],
    quiz=[
        q('Voltage is measured:', ['In series', 'In parallel', 'With power off', 'In amperes'], [1], 'Voltmeters connect in parallel.'),
        q('1 volt equals 1 joule per:', ['Ampere', 'Coulomb', 'Ohm', 'Watt'], [1], 'V = J/C.'),
    ])

lesson(10, 3, 'Current',
    concept='Current is the rate of flow of electric charge through a conductor, measured in amperes (A).',
    definition='Electric current is the flow of electric charge past a point per unit time, measured in amperes (1 A = 1 coulomb/second).',
    explanation='Current flows from higher to lower potential (conventional current: positive to negative). 1 ampere = 6.24 × 10¹⁸ electrons per second. Current is measured in series with an ammeter. Ohm\'s law relates current to voltage and resistance: I = V/R.',
    worked='Circuit: 9 V battery, 1 kΩ resistor\nI = V/R = 9/1000 = 9 mA\nAmmeter in series measures this flow',
    eng='USB-C delivers up to 5 A; house circuits are 15–20 A; microamps drive sensors.',
    mistakes=['Measuring current in parallel (damages meter); confusing AC/DC current; ignoring current limits.'],
    practice=['How do you measure current?', 'What is 1 ampere in coulombs per second?'],
    quiz=[
        q('Current is measured:', ['In parallel', 'In series', 'With ohmmeter', 'In volts'], [1], 'Ammeters connect in series.'),
        q('1 ampere equals 1 coulomb per:', ['Second', 'Minute', 'Hour', 'Volt'], [0], 'Current is charge per time.'),
    ])

lesson(10, 4, 'Resistance',
    concept='Resistance is the opposition to current flow, measured in ohms (Ω), determined by material, length, and cross-section.',
    definition='Resistance is a material\'s opposition to electric current, measured in ohms (Ω), where R = V/I.',
    explanation='Resistance depends on resistivity (ρ), length (L), and cross-sectional area (A): R = ρL/A. Resistors are components that provide specific resistance, limiting current and dividing voltage. Resistance converts electrical energy to heat (P = I²R). Conductors have low resistance; insulators have very high resistance.',
    worked='Resistor color code: Brown-Black-Red-Gold\n1-0-2 → 10 × 10² = 1 kΩ ±5%\nR = ρL/A for any conductor',
    eng='Precision resistors (0.1%) are essential in measurement equipment; thermistors use temperature-dependent resistance for sensing.',
    mistakes=['Confusing resistance with resistivity; ignoring resistor power ratings; misreading color bands.'],
    practice=['What determines a wire\'s resistance?', 'How do you read a resistor color code?'],
    quiz=[
        q('Resistance is measured in:', ['Volts', 'Amperes', 'Ohms', 'Watts'], [2], 'Ohms (Ω).'),
        q('Doubling a wire\'s length ______ its resistance.', ['Halves', 'Doubles', 'Quadruples', 'No change'], [1], 'R ∝ L.'),
    ])

lesson(10, 5, 'Ohm\'s Law',
    concept='Ohm\'s law states V = I × R: voltage equals current times resistance, the fundamental relationship in circuit analysis.',
    definition='Ohm\'s law is the principle that the current through a conductor is directly proportional to the voltage across it: V = IR.',
    explanation='Ohm\'s law relates the three core quantities. Given any two, you can find the third: V = IR, I = V/R, R = V/I. It applies to resistive (ohmic) components at constant temperature. This law is the first tool for analyzing any circuit. Use this app\'s Ohm\'s Law calculator to verify values instantly.',
    worked='V = 12 V, R = 6 Ω → I = 12/6 = 2 A\nI = 2 A, R = 6 Ω → V = 2 × 6 = 12 V\nR = 12 V, I = 2 A → R = 12/2 = 6 Ω',
    eng='Circuit designers use Ohm\'s law to size resistors for LEDs, calculate voltage drops, and determine power requirements.',
    mistakes=['Applying Ohm\'s law to non-ohmic devices (diodes, transistors); confusing the three forms; ignoring temperature effects.'],
    practice=['A circuit has 9 V and 3 Ω. What is the current?', 'What voltage produces 0.5 A through 100 Ω?'],
    quiz=[
        q('V = 12 V, R = 6 Ω. Current equals:', ['0.5 A', '2 A', '18 A', '72 A'], [1], 'I = V/R = 2 A.'),
        q('Ohm\'s law states:', ['V = I/R', 'V = IR', 'I = VR', 'R = VI'], [1], 'V = I × R.'),
    ])

lesson(10, 6, 'Power',
    concept='Electrical power is the rate of energy transfer, P = V × I, measured in watts (W).',
    definition='Electrical power is the rate at which electrical energy is transferred, calculated as P = VI (watts).',
    explanation='Power combines voltage and current: P = VI. Using Ohm\'s law: P = I²R = V²/R. Power ratings specify how much energy a component can safely dissipate. Batteries store energy (Wh); devices consume power (W). Understanding power prevents overheating and blown fuses.',
    worked='V = 12 V, I = 2 A → P = 12 × 2 = 24 W\nI = 2 A, R = 6 Ω → P = I²R = 4 × 6 = 24 W\nAll forms agree: 24 W',
    eng='Power supplies are sized by wattage; energy bills charge by kilowatt-hours (kWh); processors are limited by thermal design power (TDP).',
    mistakes=['Confusing power (W) with energy (J or Wh); exceeding component power ratings; ignoring efficiency.'],
    practice=['A device draws 2 A at 12 V. What is its power?', 'What is the difference between power and energy?'],
    quiz=[
        q('Power is measured in:', ['Volts', 'Amperes', 'Ohms', 'Watts'], [3], 'Watts (W).'),
        q('P = V × I. For V=12, I=2:', ['6 W', '14 W', '24 W', '48 W'], [2], 'P = 24 W.'),
    ])

lesson(10, 7, 'Kirchhoff\'s Laws',
    concept='Kirchhoff\'s Current Law (KCL) conserves charge at junctions; Kirchhoff\'s Voltage Law (KVL) conserves energy around loops.',
    definition='Kirchhoff\'s laws are two circuit analysis principles: KCL (sum of currents at a junction is zero) and KVL (sum of voltages around a loop is zero).',
    explanation='KCL: current entering a node equals current leaving (charge conservation). KVL: the sum of voltage rises equals the sum of voltage drops around any closed loop (energy conservation). Together with Ohm\'s law, they form the complete toolkit for analyzing any DC circuit.',
    worked='KCL: I1 = I2 + I3 at a junction\nKVL: 12 V = V1 + V2 + V3 around a loop\nSolving these gives all currents and voltages',
    eng='Circuit simulation software (SPICE) solves Kirchhoff\'s laws for complex circuits with thousands of nodes.',
    mistakes=['Sign errors in KVL; not accounting for all branches; assuming KCL applies to voltage.'],
    practice=['State KCL in words.', 'State KVL in words.'],
    quiz=[
        q('KCL conserves:', ['Voltage', 'Current (charge)', 'Power', 'Energy'], [1], 'Charge conservation.'),
        q('KVL applies to:', ['Junctions', 'Closed loops', 'Open circuits', 'Single components'], [1], 'Loops.'),
    ])

lesson(10, 8, 'Series Circuits',
    concept='Series circuits connect components end-to-end so the same current flows through each, with voltages adding.',
    definition='A series circuit connects components in a single path so identical current flows through all, and total resistance is the sum of individual resistances.',
    explanation='In series: current is the same everywhere (I_total = I1 = I2 = ...). Voltages add: V_total = V1 + V2 + .... Resistances add: R_total = R1 + R2 + .... Series is used for voltage dividers, current limiting, and Christmas lights (older styles).',
    worked='R1 = 2 Ω, R2 = 3 Ω in series → R_total = 5 Ω\nV = 10 V → I = 10/5 = 2 A\nV1 = 2×2 = 4 V, V2 = 2×3 = 6 V (sum = 10 V)',
    eng='Battery cells in series add voltages (1.5 V × 4 = 6 V for AA batteries); current-limiting resistors for LEDs are series.',
    mistakes=['Assuming current splits in series; adding voltages across same-current components incorrectly; ignoring total resistance.'],
    practice=['Two 4 Ω resistors in series: total resistance?', 'What is the current in a series circuit?'],
    quiz=[
        q('In series, ______ is the same through all components.', ['Voltage', 'Current', 'Resistance', 'Power'], [1], 'Current is constant in series.'),
        q('Two 4 Ω resistors in series total:', ['2 Ω', '4 Ω', '8 Ω', '16 Ω'], [2], 'Resistances add.'),
    ])

lesson(10, 9, 'Parallel Circuits',
    concept='Parallel circuits connect components across the same two nodes so voltage is equal across each, with currents adding.',
    definition='A parallel circuit connects components across common nodes so identical voltage appears across each branch, and total current is the sum of branch currents.',
    explanation='In parallel: voltage is the same across each branch (V_total = V1 = V2 = ...). Currents add: I_total = I1 + I2 + .... Resistances combine as 1/R_total = 1/R1 + 1/R2 + .... Parallel is used for household wiring, independent loads, and redundancy.',
    worked='R1 = 4 Ω, R2 = 4 Ω in parallel\n1/R = 1/4 + 1/4 = 1/2 → R_total = 2 Ω\nV = 12 V → I1 = 3 A, I2 = 3 A, I_total = 6 A',
    eng='House outlets are parallel (each gets 120/230 V independently); server power supplies are paralleled for redundancy.',
    mistakes=['Assuming voltage splits in parallel; using series formulas for parallel; ignoring total current limits.'],
    practice=['Two 4 Ω resistors in parallel: total resistance?', 'What is the same across parallel branches?'],
    quiz=[
        q('In parallel, ______ is the same across all branches.', ['Current', 'Voltage', 'Resistance', 'Power'], [1], 'Voltage is constant in parallel.'),
        q('Two 4 Ω resistors in parallel total:', ['1 Ω', '2 Ω', '4 Ω', '8 Ω'], [1], '1/R = 1/4+1/4 → R=2 Ω.'),
    ])

lesson(10, 10, 'Voltage Divider',
    concept='A voltage divider uses two series resistors to produce a fraction of the input voltage: Vout = Vin × R2/(R1+R2).',
    definition='A voltage divider is a series resistor circuit that outputs a predictable fraction of the input voltage based on the resistance ratio.',
    explanation='The output voltage across R2 is Vout = Vin × R2/(R1+R2). The divider ratio depends only on resistances. Loading effects matter: a load across R2 changes the effective resistance. Voltage dividers are used for sensor interfacing, level shifting, and reference voltages. Use this app\'s Voltage Divider calculator.',
    worked='Vin = 10 V, R1 = R2 = 1 kΩ\nVout = 10 × 1/(1+1) = 5 V\nVin = 5 V, R1 = 1 kΩ, R2 = 2 kΩ\nVout = 5 × 2/3 = 3.33 V',
    eng='Potentiometers are adjustable voltage dividers (volume controls); resistor dividers scale sensor voltages for ADC inputs.',
    mistakes=['Ignoring load effects on the divider; using high resistor values with high-impedance loads; confusing which resistor is R2.'],
    practice=['Design a divider to get 3.3 V from 5 V.', 'What is Vout for equal resistors?'],
    quiz=[
        q('Vout = Vin × ___', ['R1/(R1+R2)', 'R2/(R1+R2)', '(R1+R2)/R2', 'R1/R2'], [1], 'R2 over total.'),
        q('Equal resistors divide the voltage:', ['Evenly (half)', '2:1', '1:2', 'Doesn\'t divide'], [0], 'Half each.'),
    ])

lesson(10, 11, 'Current Divider',
    concept='A current divider splits current among parallel branches inversely proportional to resistance: I1 = Itotal × R2/(R1+R2).',
    definition='A current divider is a parallel resistor circuit where the total current splits among branches inversely proportional to their resistances.',
    explanation='For two parallel resistors: I1 = Itotal × R2/(R1+R2), I2 = Itotal × R1/(R1+R2). The lower-resistance branch carries more current. Current dividers are used for current sensing, biasing, and metering. Use this app\'s Current Divider calculator.',
    worked='Itotal = 6 A, R1 = 4 Ω, R2 = 2 Ω\nI1 = 6 × 2/(4+2) = 2 A (through 4 Ω)\nI2 = 6 × 4/(4+2) = 4 A (through 2 Ω)\nLower resistance → more current',
    eng='Shunt resistors use current division for ammeter ranges; current mirrors in ICs use matched transistors.',
    mistakes=['Assuming current splits equally; confusing current divider with voltage divider; sign errors.'],
    practice=['Two parallel resistors 2 Ω and 4 Ω with 12 A total: how much through each?', 'Which branch carries more current?'],
    quiz=[
        q('In a current divider, current splits ______ to resistance.', ['Directly', 'Inversely', 'Equally', 'Randomly'], [1], 'Inversely.'),
        q('Itotal = 12 A, R1 = 2 Ω, R2 = 4 Ω. I1 (through R1) =:', ['4 A', '8 A', '6 A', '12 A'], [1], 'I1 = 12 × 4/6 = 8 A.'),
    ])

lesson(10, 12, 'Capacitors',
    concept='A capacitor stores energy in an electric field between two conductive plates, measured in farads (F).',
    definition='A capacitor is a passive component that stores electrical energy in an electric field, characterized by capacitance C = Q/V (farads).',
    explanation='Capacitance is charge stored per volt. Capacitors block DC, pass AC, and smooth voltage. Charging: V(t) = V0(1 − e^(−t/RC)). Time constant τ = RC. Applications: filtering, timing, energy storage, coupling. Types: ceramic, electrolytic, tantalum — each with voltage and polarity considerations.',
    worked='C = 100 μF, R = 1 kΩ → τ = 0.1 s\nCharging to 63% in 0.1 s, 95% in 3τ\nEnergy = ½CV²',
    eng='Supercapacitors store farads for backup power; decoupling capacitors (100 nF) stabilize IC power pins.',
    mistakes=['Reverse-polarizing electrolytic capacitors (they explode); ignoring voltage ratings; confusing capacitance with charge.'],
    practice=['What is the time constant of R=1kΩ, C=100μF?', 'What does a capacitor do to DC?'],
    quiz=[
        q('Capacitance is measured in:', ['Ohms', 'Farads', 'Henries', 'Volts'], [1], 'Farads (F).'),
        q('A capacitor ______ DC current.', ['Passes', 'Blocks', 'Amplifies', 'Doubles'], [1], 'Blocks DC.'),
    ])

lesson(10, 13, 'Inductors',
    concept='An inductor stores energy in a magnetic field when current flows, measured in henries (H), opposing changes in current.',
    definition='An inductor is a passive component (usually a coil) that stores energy in a magnetic field and resists changes in current.',
    explanation='Inductance (L) relates voltage to the rate of current change: V = L(di/dt). Inductors pass DC, block AC (especially high frequencies). Time constant τ = L/R. Applications: filters, transformers, motors, and energy storage. Inductors are the complement of capacitors.',
    worked='L = 10 mH, R = 100 Ω → τ = L/R = 0.1 ms\nCurrent rises slowly: I(t) = (V/R)(1 − e^(−t/τ))\nEnergy = ½LI²',
    eng='Switching power supplies use inductors for energy transfer; electric motors are essentially engineered inductors.',
    mistakes=['Confusing inductors with capacitors; ignoring DC resistance; saturation in power inductors.'],
    practice=['What is V = L(di/dt)?', 'What is the time constant of an RL circuit?'],
    quiz=[
        q('Inductance is measured in:', ['Farads', 'Henries', 'Ohms', 'Teslas'], [1], 'Henries (H).'),
        q('An inductor opposes changes in:', ['Voltage', 'Current', 'Resistance', 'Power'], [1], 'Current.'),
    ])

lesson(10, 14, 'Diodes',
    concept='A diode is a semiconductor device that conducts current in one direction only, with a forward voltage drop (~0.7 V silicon).',
    definition='A diode is a two-terminal semiconductor that allows current to flow in one direction (forward-biased) and blocks it in the other (reverse-biased).',
    explanation='Forward bias: current flows when voltage exceeds the threshold (0.7 V Si, 0.3 V Ge, ~2 V LED). Reverse bias: minimal leakage current until breakdown. Applications: rectification (AC to DC), protection (reverse polarity), signal demodulation, and voltage clamping.',
    worked='Forward: V > 0.7 V → conducts\nReverse: V < breakdown → blocks\nI-V curve: exponential in forward, flat in reverse',
    eng='Bridge rectifiers convert AC to DC in every power supply; Schottky diodes (0.3 V drop) are used for high-speed switching.',
    mistakes=['Exceeding reverse breakdown voltage; ignoring forward voltage drop; confusing diode direction.'],
    practice=['What is the forward voltage drop of a silicon diode?', 'How does a diode rectify AC?'],
    quiz=[
        q('A silicon diode conducts forward at about:', ['0.3 V', '0.7 V', '1.5 V', '5 V'], [1], '0.7 V typical.'),
        q('A diode conducts in ______ direction(s).', ['Both', 'One', 'Neither', 'AC only'], [1], 'One direction.'),
    ])

lesson(10, 15, 'LEDs',
    concept='An LED (Light Emitting Diode) emits light when forward-biased, requiring a current-limiting resistor to prevent destruction.',
    definition='An LED is a diode that emits light when current flows through it in the forward direction, with a characteristic forward voltage and current rating.',
    explanation='LEDs need current limiting: without a resistor, they draw excessive current and burn out. Resistor R = (Vsupply − Vf)/If. Forward voltages: red ~2 V, blue/white ~3 V. LEDs are polarized: long leg (anode) to positive. Applications: indicators, displays, lighting, and optoisolation.',
    worked='Vsupply = 5 V, Vf = 2 V (red), If = 20 mA\nR = (5 − 2)/0.02 = 150 Ω\nUse nearest standard: 150 Ω',
    eng='LED lighting is replacing incandescent bulbs; high-power LEDs need constant-current drivers and heat sinking.',
    mistakes=['Connecting LEDs without resistors; exceeding max current; reverse-connecting LEDs.'],
    practice=['Calculate the resistor for a 5 V supply, red LED (Vf=2V, If=20mA).', 'Why does an LED need a resistor?'],
    quiz=[
        q('A current-limiting resistor for an LED is:', ['Optional', 'Required', 'Only for high voltage', 'Never needed'], [1], 'Required to limit current.'),
        q('Red LED forward voltage is about:', ['0.7 V', '2 V', '3.3 V', '5 V'], [1], '~2 V.'),
    ])

lesson(10, 16, 'Zener Diodes',
    concept='A Zener diode operates in reverse breakdown to maintain a stable voltage, used for voltage regulation and reference.',
    definition='A Zener diode is a diode designed to operate reliably in reverse breakdown, maintaining a nearly constant voltage (Zener voltage) across it.',
    explanation='When reverse voltage exceeds the Zener voltage (Vz), the diode conducts heavily while maintaining ~Vz across it. A series resistor limits current. Applications: voltage regulation, reference voltages, overvoltage protection, and clipping. Power rating determines maximum current: P = Vz × I.',
    worked='Vz = 5.1 V, Vin = 12 V, load needs 5.1 V\nR = (12 − 5.1)/I_total\nVoltage across load stays ~5.1 V',
    eng='Zener diodes protect ADC inputs from overvoltage; precision references (bandgap) use temperature-compensated Zener principles.',
    mistakes=['Not limiting current through the Zener; ignoring power dissipation; confusing Zener with regular diode direction.'],
    practice=['What is a Zener diode used for?', 'How does a Zener maintain constant voltage?'],
    quiz=[
        q('A Zener diode regulates voltage in ______ bias.', ['Forward', 'Reverse', 'Both', 'Neither'], [1], 'Reverse breakdown.'),
        q('Zener voltage is maintained across:', ['The resistor', 'The diode', 'The supply', 'The ground'], [1], 'The diode.'),
    ])

lesson(10, 17, 'Transistors',
    concept='A transistor is a three-terminal semiconductor used as a switch or amplifier: base, collector, emitter (BJT) or gate, drain, source (MOSFET).',
    definition='A transistor is a semiconductor device that amplifies or switches electronic signals, with three terminals controlling current flow.',
    explanation='BJT (Bipolar Junction Transistor): current-controlled — small base current controls larger collector current. MOSFET (Metal-Oxide-Semiconductor FET): voltage-controlled — gate voltage controls drain-source current. Transistors are the building blocks of all digital logic (billions per CPU) and analog amplification.',
    worked='BJT switch: base current turns on collector-emitter path\nMOSFET switch: gate voltage creates conduction channel\nBoth act as electrically controlled switches',
    eng='Modern CPUs contain billions of MOSFETs; audio amplifiers use BJT/MOSFET output stages; power electronics use IGBTs.',
    mistakes=['Confusing BJT with MOSFET control (current vs voltage); exceeding current/voltage ratings; ignoring heat sinking.'],
    practice=['What are the three terminals of a BJT?', 'What is the difference between BJT and MOSFET control?'],
    quiz=[
        q('A BJT is controlled by:', ['Voltage', 'Current', 'Light', 'Temperature'], [1], 'Base current.'),
        q('A MOSFET is controlled by:', ['Current', 'Voltage', 'Magnetism', 'Pressure'], [1], 'Gate voltage.'),
    ])

lesson(10, 18, 'BJT',
    concept='The Bipolar Junction Transistor (BJT) amplifies current: a small base current controls a larger collector current, with gains β (hFE).',
    definition='A BJT is a current-controlled transistor with NPN or PNP structure, where base current modulates collector-emitter current.',
    explanation='BJT operation: base-emitter junction forward-biased, base-collector reverse-biased. Collector current IC = β × IB (β typically 50–300). Modes: cutoff (off), active (amplification), saturation (fully on, switch). BJTs are used in amplifiers, switches, and analog circuits.',
    worked='IB = 20 μA, β = 100 → IC = 2 mA\nVBE ≈ 0.7 V (silicon)\nSwitch: drive base hard into saturation',
    eng='Audio amplifiers use BJTs for linear amplification; BJT arrays (ULN2803) drive relays and motors.',
    mistakes=['Operating in active region when switching (waste heat); ignoring base current requirements; confusing NPN with PNP.'],
    practice=['What is β (beta)?', 'What are the three operating regions of a BJT?'],
    quiz=[
        q('Collector current equals:', ['β × IB', 'IB / β', 'IB + β', 'IB − β'], [0], 'IC = βIB.'),
        q('VBE of a conducting silicon BJT is about:', ['0.3 V', '0.7 V', '1.2 V', '5 V'], [1], '0.7 V.'),
    ])

lesson(10, 19, 'MOSFET',
    concept='The MOSFET is a voltage-controlled transistor with high input impedance, the dominant device in digital integrated circuits.',
    definition='A MOSFET (Metal-Oxide-Semiconductor Field-Effect Transistor) is a voltage-controlled transistor where gate voltage modulates drain-source current.',
    explanation='MOSFET types: enhancement/depletion, N-channel/P-channel. Gate voltage creates (or removes) a conductive channel between drain and source. Advantages: extremely high input impedance (almost no gate current), fast switching, small size. Billions form CMOS digital logic. Used in power switching, motor drives, and amplification.',
    worked='N-channel enhancement: VGS > Vth (threshold) → conducts\nLogic: pull-up + pull-down MOSFET pairs form inverters\nPower: low RDS(on) for efficient switching',
    eng='CMOS (Complementary MOSFET) technology builds nearly all modern chips; GaN MOSFETs enable fast chargers and RF.',
    mistakes=['Exceeding VGS max (gate oxide damage); not driving gates fully; ignoring body diode.'],
    practice=['What does MOSFET stand for?', 'Why is MOSFET dominant in digital ICs?'],
    quiz=[
        q('MOSFET is controlled by:', ['Base current', 'Gate voltage', 'Collector voltage', 'Temperature'], [1], 'Gate voltage.'),
        q('CMOS stands for:', ['Complementary MOS', 'Current MOS', 'Combined MOS', 'Capacitive MOS'], [0], 'Complementary Metal-Oxide-Semiconductor.'),
    ])

lesson(10, 20, 'Operational Amplifiers',
    concept='An op-amp is a high-gain differential amplifier with two inputs and one output, used with feedback for amplification, filtering, and math operations.',
    definition='An operational amplifier (op-amp) is a high-gain voltage amplifier with differential inputs and a single output, designed for feedback configurations.',
    explanation='Ideal op-amp: infinite gain, infinite input impedance, zero output impedance. Real op-amps approximate this. Key configurations: inverting (gain = −R2/R1), non-inverting (gain = 1 + R2/R1), differential, integrator, comparator. "Virtual short": with negative feedback, V+ ≈ V−. Op-amps are the workhorse of analog design.',
    worked='Inverting amp: Vout = −(R2/R1) × Vin\nR1 = 1 kΩ, R2 = 10 kΩ → gain = −10\nNon-inverting: gain = 1 + R2/R1 = 11',
    eng='Op-amps filter sensor signals, drive audio, compute (integrators/differentiators), and buffer high-impedance sources.',
    mistakes=['Ignoring supply rail limits (output can\'t exceed rails); no feedback (comparator mode); offset voltage in precision apps.'],
    practice=['What is the gain of an inverting amp with R1=1k, R2=10k?', 'What is the virtual short principle?'],
    quiz=[
        q('Inverting op-amp gain equals:', ['R2/R1', '−R2/R1', '1 + R2/R1', '−(1 + R2/R1)'], [1], '−R2/R1.'),
        q('An ideal op-amp has ______ input impedance.', ['Zero', 'Infinite', '1 kΩ', 'Variable'], [1], 'Infinite.'),
    ])

lesson(10, 21, 'Rectifiers',
    concept='A rectifier converts AC to DC using diodes: half-wave (one diode), full-wave bridge (four diodes), with filtering.',
    definition='A rectifier is a circuit that converts alternating current (AC) to direct current (DC) using diodes that allow current in one direction.',
    explanation='Half-wave rectifier: one diode passes only positive halves — 50% efficiency, high ripple. Full-wave bridge: four diodes steer both halves to the same output polarity — 100% utilization, double frequency ripple. A filter capacitor smooths the pulsating DC. Output: VDC ≈ Vpeak − 2×Vdiode (bridge).',
    worked='AC 12 V RMS → Vpeak = 17 V\nBridge rectifier: VDC ≈ 17 − 1.4 = 15.6 V\nWith capacitor filter: ~15.6 V DC with small ripple',
    eng='Every power supply (phone charger, PC PSU) starts with a bridge rectifier; precision rectifiers use op-amps for small signals.',
    mistakes=['Insufficient filter capacitance (excessive ripple); ignoring diode voltage drops; exceeding diode current ratings.'],
    practice=['What is the difference between half-wave and full-wave rectification?', 'Why is a filter capacitor needed?'],
    quiz=[
        q('A bridge rectifier uses how many diodes?', ['1', '2', '4', '8'], [2], 'Four diodes.'),
        q('Rectifiers convert:', ['DC to AC', 'AC to DC', 'Voltage to current', 'AC to AC'], [1], 'AC to DC.'),
    ])

lesson(10, 22, 'Filters',
    concept='Filters pass or block frequency ranges: low-pass, high-pass, band-pass, and band-stop, built from resistors, capacitors, and inductors.',
    definition='An electronic filter is a circuit that selectively passes or attenuates signals based on frequency.',
    explanation='Low-pass: passes low frequencies, blocks high (RC: fc = 1/(2πRC)). High-pass: passes high, blocks low. Band-pass: passes a range. Band-stop (notch): blocks a range. Filters are characterized by cutoff frequency, roll-off (dB/decade), and order. Active filters use op-amps for better performance.',
    worked='RC low-pass: R = 1 kΩ, C = 100 nF\nfc = 1/(2π × 1000 × 100e-9) ≈ 1.6 kHz\nAbove 1.6 kHz: attenuated',
    eng='Audio crossovers filter frequencies to speakers; anti-aliasing filters prevent sampling artifacts; EMI filters suppress noise.',
    mistakes=['Confusing low-pass with high-pass; ignoring filter order (roll-off); loading effects changing fc.'],
    practice=['What is the cutoff frequency of an RC low-pass with R=1k, C=100nF?', 'What does a low-pass filter do?'],
    quiz=[
        q('A low-pass filter ______ high frequencies.', ['Passes', 'Blocks', 'Amplifies', 'Inverts'], [1], 'Blocks.'),
        q('Cutoff frequency fc for RC filter:', ['1/(2πRC)', '2πRC', 'RC/2π', '1/RC'], [0], '1/(2πRC).'),
    ])

lesson(10, 23, 'ADC — Analog to Digital Conversion',
    concept='An ADC converts continuous analog signals to discrete digital values through sampling, quantization, and encoding.',
    definition='An ADC (Analog-to-Digital Converter) samples an analog signal at intervals and quantizes each sample to a digital value with finite resolution.',
    explanation='Sampling: measure at regular intervals (Nyquist: sample rate > 2× highest frequency). Quantization: map to discrete levels (n bits → 2ⁿ levels). Resolution: step size = Vref/2ⁿ. A 10-bit ADC with 3.3 V ref: step = 3.3/1024 ≈ 3.2 mV. Types: SAR (successive approximation, common), flash (fast, expensive), delta-sigma (high resolution).',
    worked='10-bit ADC, Vref = 3.3 V\nResolution = 3.3/1024 = 3.22 mV per step\nInput 1.65 V → code = 1.65/0.00322 = 512',
    eng='Microcontrollers have built-in SAR ADCs (STM32: 12-bit); audio uses delta-sigma (24-bit); oscilloscopes use flash ADCs.',
    mistakes=['Sampling below Nyquist (aliasing); ignoring reference voltage accuracy; not accounting for input impedance.'],
    practice=['What is the resolution of a 12-bit ADC with 5 V reference?', 'What is the Nyquist rate?'],
    quiz=[
        q('An n-bit ADC has how many levels?', ['n', '2n', '2^n', 'n²'], [2], '2ⁿ levels.'),
        q('Nyquist requires sampling above:', ['The signal frequency', 'Twice the signal frequency', 'Half the signal frequency', 'Ten times the frequency'], [1], '2× max frequency.'),
    ])

lesson(10, 24, 'DAC — Digital to Analog Conversion',
    concept='A DAC converts digital values to analog voltages, using resistor ladders (R-2R) or pulse-width modulation.',
    definition='A DAC (Digital-to-Analog Converter) converts digital codes to proportional analog voltages or currents.',
    explanation='R-2R ladder: a network of R and 2R resistors creates binary-weighted currents summed into an output voltage. PWM: varies pulse width, filtered to average voltage. DAC specs: resolution (bits), settling time, output range, and linearity. DACs generate audio, waveforms, and control voltages.',
    worked='8-bit DAC, Vref = 5 V\nCode 128 → Vout = 5 × 128/256 = 2.5 V\nCode 255 → Vout ≈ 4.98 V',
    eng='Audio DACs (24-bit) reconstruct music; function generators use fast DACs; motor controllers use DACs or PWM.',
    mistakes=['Ignoring settling time; PWM without filtering; confusing resolution with accuracy.'],
    practice=['What is the output of a 10-bit DAC with code 512 and 4 V reference?', 'What is an R-2R ladder?'],
    quiz=[
        q('A DAC converts:', ['Analog to digital', 'Digital to analog', 'AC to DC', 'Voltage to current'], [1], 'Digital to analog.'),
        q('8-bit DAC code 128 with 5 V ref gives:', ['1.25 V', '2.5 V', '3.75 V', '5 V'], [1], '5 × 128/256 = 2.5 V.'),
    ])

lesson(10, 25, 'Sensors',
    concept='A sensor converts physical quantities (temperature, light, pressure) into electrical signals for measurement and control.',
    definition='A sensor is a device that detects a physical property and converts it into a measurable electrical signal.',
    explanation='Sensors bridge the physical and digital worlds. Temperature: thermistors, thermocouples, RTDs. Light: photodiodes, LDRs. Pressure: piezoresistive, capacitive. Motion: accelerometers, gyroscopes (MEMS). Proximity: ultrasonic, infrared. Key specs: range, accuracy, resolution, response time, and interface (analog, I2C, SPI).',
    worked='Thermistor: resistance varies with temperature\nNTC: 10 kΩ at 25°C, decreases with heat\nRead via voltage divider → ADC → temperature',
    eng='Smartphones contain 15+ sensors (accelerometer, gyro, magnetometer, barometer, proximity); cars have hundreds.',
    mistakes=['Ignoring sensor accuracy specs; not calibrating; electrical noise without filtering.'],
    practice=['Name three types of sensors and what they measure.', 'What is the difference between accuracy and resolution?'],
    quiz=[
        q('A thermistor measures:', ['Light', 'Temperature', 'Pressure', 'Sound'], [1], 'Temperature.'),
        q('A sensor converts physical quantities to:', ['Mechanical motion', 'Electrical signals', 'Light only', 'Sound'], [1], 'Electrical signals.'),
    ])

lesson(10, 26, 'Signal Conditioning',
    concept='Signal conditioning prepares raw sensor signals for processing: amplification, filtering, linearization, and isolation.',
    definition='Signal conditioning is the manipulation of analog signals to make them suitable for digitization or control systems.',
    explanation='Raw sensor signals are often small (mV), noisy, or non-linear. Conditioning stages: amplification (op-amp gain), filtering (remove noise), linearization (correct sensor curves), and isolation (protect from high voltages). An instrumentation amplifier excels at amplifying small differential signals with high common-mode rejection.',
    worked='Strain gauge: mV-level differential signal\n→ instrumentation amp (gain 1000)\n→ low-pass filter (remove 50/60 Hz noise)\n→ ADC',
    eng='Medical devices (ECG, EEG) condition microvolt signals with extreme precision; industrial 4–20 mA loops transmit conditioned signals.',
    mistakes=['Amplifying noise with the signal; not filtering before ADC; ignoring common-mode voltage.'],
    practice=['Why amplify a sensor signal before ADC?', 'What is common-mode rejection?'],
    quiz=[
        q('Signal conditioning prepares signals for:', ['Storage only', 'Digitization or control', 'Transmission only', 'Display only'], [1], 'Conditioning prepares signals.'),
        q('An instrumentation amplifier excels at:', ['High voltage', 'Amplifying small differential signals', 'Digital conversion', 'Wireless transmission'], [1], 'Small differential signals.'),
    ])

formula('Electronics', 'Ohm\'s Law', 'V = I × R', 'V: volts; I: amperes; R: ohms', 'Circuit analysis')
formula('Electronics', 'Power', 'P = V × I = I²R = V²/R', 'P: watts', 'Power calculations')
formula('Electronics', 'RC Time Constant', 'τ = R × C', 'τ: seconds; R: ohms; C: farads', 'RC circuit timing')
formula('Electronics', 'Cutoff Frequency', 'fc = 1/(2πRC)', 'fc: hertz', 'Filter design')

# ---------------- Embedded Systems (22 lessons) ----------------

lesson(11, 1, 'Introduction to Embedded Systems',
    concept='An embedded system is a dedicated computer system designed for specific functions within a larger mechanical or electrical system.',
    definition='An embedded system is a microcontroller or microprocessor-based system designed to perform dedicated functions, often with real-time constraints.',
    explanation='Embedded systems combine hardware and software for specific tasks: washing machine controllers, car ECUs, medical devices, IoT sensors. They are constrained by power, cost, size, and often require real-time response. Unlike general-purpose computers, they run a fixed program with predictable behavior.',
    worked='Microcontroller + sensors + actuators + firmware\nExample: thermostat reads temperature, controls heater\nReal-time: responds within guaranteed time bounds',
    eng='Cars contain 50–100 ECUs; IoT devices number in the billions; medical devices rely on embedded reliability.',
    mistakes=['Confusing embedded systems with PCs; ignoring resource constraints; neglecting real-time requirements.'],
    practice=['What is an embedded system?', 'How does an embedded system differ from a PC?'],
    quiz=[
        q('An embedded system is designed for:', ['General computing', 'Specific dedicated functions', 'Gaming only', 'Web browsing'], [1], 'Dedicated functions.'),
        q('Embedded systems are often constrained by:', ['Nothing', 'Power, cost, and size', 'Internet speed', 'Screen size'], [1], 'Resource constraints.'),
    ])

lesson(11, 2, 'Microcontrollers',
    concept='A microcontroller (MCU) is a compact integrated circuit with a CPU, memory, and peripherals on one chip, designed for embedded control.',
    definition='A microcontroller is a single-chip computer containing a processor core, volatile memory (RAM), non-volatile memory (Flash), and programmable input/output peripherals.',
    explanation='MCUs integrate everything needed for embedded control: CPU, Flash (program), RAM (data), GPIO, timers, ADC, UART, SPI, I2C. Popular families: AVR (Arduino), PIC, STM32 (ARM Cortex-M), ESP32. They run bare-metal firmware or an RTOS, executing a fixed program from power-on.',
    worked='STM32F103: ARM Cortex-M3, 72 MHz, 64 KB Flash, 20 KB RAM\nAVR ATmega328P: 20 MHz, 32 KB Flash, 2 KB RAM (Arduino Uno)',
    eng='STM32 and ESP32 dominate IoT; PIC and AVR serve cost-sensitive markets; automotive MCUs (RH850) meet safety standards.',
    mistakes=['Confusing MCUs with microprocessors; ignoring memory limits; not understanding clock sources.'],
    practice=['What is the difference between a microcontroller and a microprocessor?', 'Name three MCU families.'],
    quiz=[
        q('A microcontroller integrates:', ['CPU only', 'CPU, memory, and peripherals on one chip', 'Only memory', 'Only peripherals'], [1], 'Single-chip computer.'),
        q('Arduino Uno uses which MCU?', ['STM32', 'ATmega328P (AVR)', 'ESP32', 'PIC16'], [1], 'ATmega328P.'),
    ])

lesson(11, 3, 'Microprocessors',
    concept='A microprocessor is a CPU on a single chip, requiring external memory and peripherals, used in general-purpose computing.',
    definition='A microprocessor is an integrated circuit containing only the central processing unit, requiring external memory, I/O, and support chips.',
    explanation='Unlike MCUs, microprocessors lack onboard memory and peripherals — they need external RAM, storage, and chipsets. Examples: Intel Core, AMD Ryzen, ARM Cortex-A. They run full operating systems (Linux, Windows) and handle general-purpose workloads. Performance far exceeds MCUs but power and cost are higher.',
    worked='Microprocessor system: CPU + RAM chip + storage + chipset\nMCU system: one chip + minimal external components',
    eng='Servers and PCs use microprocessors; smartphones use SoCs (processor + GPU + modem on one chip).',
    mistakes=['Confusing microprocessor with microcontroller; assuming more MHz means better; ignoring power consumption.'],
    practice=['What external components does a microprocessor need?', 'What is the difference between a microprocessor and an SoC?'],
    quiz=[
        q('A microprocessor requires:', ['Nothing external', 'External memory and peripherals', 'Only power', 'Only a display'], [1], 'External components.'),
    ])

lesson(11, 4, 'GPIO',
    concept='GPIO (General Purpose Input/Output) pins are programmable pins that can be configured as digital inputs or outputs to interface with external hardware.',
    definition='GPIO is a generic pin on a microcontroller whose behavior (input or output, high or low) is controllable by software at runtime.',
    explanation='Each GPIO pin can be an input (read sensors, buttons) or output (drive LEDs, relays). Configurations: push-pull output, open-drain, pull-up/pull-down resistors, interrupt-on-change. Voltage levels are fixed by the MCU (3.3 V or 5 V logic). GPIO is the primary way embedded systems interact with the physical world.',
    worked='pinMode(LED_PIN, OUTPUT);\ndigitalWrite(LED_PIN, HIGH);  // turn on\nint button = digitalRead(BTN_PIN);  // read input',
    eng='GPIO controls motors, reads sensors, and bit-bangs protocols in countless devices; STM32 has 80+ GPIOs.',
    mistakes=['Exceeding pin current limits (typically 20 mA); not using pull-ups on inputs; voltage level mismatches (3.3 V vs 5 V).'],
    practice=['What does GPIO stand for?', 'How do you configure a pin as input vs output?'],
    quiz=[
        q('GPIO pins can be:', ['Output only', 'Input or output', 'Input only', 'Analog only'], [1], 'Both directions.'),
        q('A typical GPIO pin can source/sink about:', ['1 mA', '20 mA', '1 A', '10 A'], [1], '20 mA typical.'),
    ])

lesson(11, 5, 'Digital Input',
    concept='Digital input reads binary states (HIGH/LOW) from buttons, switches, and sensors, with debouncing and pull-up/down configuration.',
    definition='Digital input is the reading of a binary signal (1 or 0) on a GPIO pin configured as an input.',
    explanation='A digital input reads voltage as HIGH (1) or LOW (0). Floating inputs are unstable — use pull-up or pull-down resistors (internal or external). Buttons connect between pin and ground (with pull-up) or pin and VCC (with pull-down). Mechanical switches bounce, requiring debouncing (software delay or hardware filter).',
    worked='Button to ground + internal pull-up:\npinMode(BTN, INPUT_PULLUP);\nint state = digitalRead(BTN);  // LOW when pressed',
    eng='Keypads, limit switches, and encoders all use digital inputs; interrupt-driven inputs respond instantly.',
    mistakes=['Floating inputs without pull resistors; not debouncing buttons; exceeding voltage on pins.'],
    practice=['Why use a pull-up resistor?', 'What is switch bouncing?'],
    quiz=[
        q('A floating input reads:', ['Always HIGH', 'Unstable/random values', 'Always LOW', 'Zero volts'], [1], 'Unstable.'),
        q('Button debouncing is needed because:', ['Buttons are slow', 'Mechanical contacts bounce', 'GPIO is too fast', 'Voltage is too high'], [1], 'Bouncing.'),
    ])

lesson(11, 6, 'Digital Output',
    concept='Digital output drives external components HIGH or LOW, with current limiting for LEDs and drivers for high-current loads.',
    definition='Digital output is the driving of a GPIO pin to a HIGH or LOW voltage to control external circuits.',
    explanation='Output HIGH (3.3/5 V) or LOW (0 V) controls LEDs (with resistors), relays (with transistors), and logic inputs. Pin current is limited (typically 20 mA per pin, 100 mA total). For higher currents, use transistors or MOSFETs as switches. Open-drain outputs allow wired-AND configurations and level shifting.',
    worked='LED: GPIO → resistor → LED → GND\nR = (3.3 − 2)/0.01 = 130 Ω (use 150 Ω)\nHigh-current: GPIO → MOSFET gate → load',
    eng='LED matrices, relay boards, and motor drivers all start with digital outputs; PWM outputs (next lesson) add analog-like control.',
    mistakes=['Driving loads directly without current limiting; exceeding total port current; not using transistors for inductive loads.'],
    practice=['Calculate the resistor for a 3.3 V pin driving a red LED at 10 mA.', 'Why use a MOSFET for a motor?'],
    quiz=[
        q('Digital output drives:', ['Analog signals', 'HIGH or LOW voltages', 'Current only', 'AC power'], [1], 'Binary levels.'),
        q('High-current loads should be driven by:', ['GPIO directly', 'Transistors or MOSFETs', 'Resistors', 'Capacitors'], [1], 'Drivers.'),
    ])

lesson(11, 7, 'UART',
    concept='UART (Universal Asynchronous Receiver/Transmitter) serial communication transmits data bit-by-bit over two wires (TX, RX).',
    definition='UART is a hardware protocol for asynchronous serial communication using TX and RX lines with configurable baud rate, data bits, parity, and stop bits.',
    explanation='UART is point-to-point: TX of device A connects to RX of device B. Both sides must agree on baud rate (bits per second): 9600, 115200 common. Frame: start bit, 8 data bits, optional parity, 1–2 stop bits. No clock line — timing is agreed in advance. Used for GPS, Bluetooth modules, debug consoles.',
    worked='Configuration: 115200 baud, 8 data bits, no parity, 1 stop (8N1)\n"Hello" = 5 bytes × 10 bits = 50 bits\nAt 115200 baud: ~434 μs',
    eng='Debug consoles use UART over USB; GPS modules output NMEA sentences; Bluetooth HC-05 modules communicate via UART.',
    mistakes=['Connecting TX to TX (must cross: TX→RX); mismatched baud rates; not connecting grounds.'],
    practice=['What does UART stand for?', 'What baud rate is commonly used for debug output?'],
    quiz=[
        q('UART uses how many wires for basic communication?', ['1', '2', '4', '8'], [1], 'TX and RX.'),
        q('UART is:', ['Synchronous', 'Asynchronous', 'Parallel', 'Wireless'], [1], 'Asynchronous.'),
    ])

lesson(11, 8, 'SPI',
    concept='SPI (Serial Peripheral Interface) is a synchronous full-duplex protocol using four wires: MOSI, MISO, SCK, and CS.',
    definition='SPI is a synchronous serial communication protocol with separate clock and data lines, supporting full-duplex communication at high speeds.',
    explanation='SPI uses four signals: MOSI (Master Out Slave In), MISO (Master In Slave Out), SCK (clock), and CS/SS (chip select). One master controls the clock; multiple slaves each need a CS line. Full-duplex: data flows both directions simultaneously. No addressing — CS selects the device. Speeds up to 50+ MHz. Used for displays, SD cards, flash memory, sensors.',
    worked='Wiring: MCU MOSI → SD card DI\nMCU MISO → SD card DO\nMCU SCK → SD card CLK\nMCU CS → SD card CS',
    eng='TFT displays use SPI for fast frame updates; SD cards use SPI mode; IMUs (MPU6050) offer SPI for speed.',
    mistakes=['Forgetting chip select; mode mismatches (SPI modes 0–3); voltage level mismatches; long wires at high speed.'],
    practice=['What does SPI stand for?', 'How does SPI select among multiple slaves?'],
    quiz=[
        q('SPI uses how many basic wires?', ['2', '3', '4', '6'], [2], 'MOSI, MISO, SCK, CS.'),
        q('SPI is:', ['Asynchronous', 'Synchronous with a clock', 'Parallel', 'Packet-based'], [1], 'Synchronous.'),
    ])

lesson(11, 9, 'I2C',
    concept='I2C (Inter-Integrated Circuit) is a synchronous multi-master, multi-slave protocol using two wires: SDA (data) and SCL (clock).',
    definition='I2C is a two-wire serial protocol supporting multiple masters and slaves with addressing, commonly used for sensors and EEPROMs.',
    explanation='I2C uses open-drain lines with pull-ups: SDA (data) and SCL (clock). Each slave has a 7-bit (or 10-bit) address. Communication: START condition, address + R/W bit, data bytes, ACK/NACK, STOP. Multi-master uses arbitration. Speeds: standard (100 kHz), fast (400 kHz), fast+ (1 MHz), high-speed (3.4 MHz).',
    worked='Bus: MCU SDA → sensor SDA; MCU SCL → sensor SCL\nPull-ups: 4.7 kΩ to 3.3 V\nAddress: 0x68 (MPU6050)',
    eng='I2C connects dozens of sensors on two wires (phones, laptops); EEPROMs (24C256) store calibration data; RTCs (DS3231) keep time.',
    mistakes=['Missing pull-up resistors; address collisions; clock stretching misunderstandings; voltage mismatches.'],
    practice=['What does I2C stand for?', 'Why are pull-up resistors needed on I2C?'],
    quiz=[
        q('I2C uses how many wires?', ['1', '2', '4', '8'], [1], 'SDA and SCL.'),
        q('I2C slaves are selected by:', ['Chip select lines', '7-bit addresses', 'Baud rate', 'Voltage levels'], [1], 'Addresses.'),
    ])

lesson(11, 10, 'ADC in Embedded Systems',
    concept='Microcontroller ADCs convert analog sensor voltages to digital values for processing, with resolution, reference, and sampling considerations.',
    definition='An embedded ADC digitizes analog signals using the microcontroller\'s built-in peripheral, with configurable resolution and sampling rate.',
    explanation='MCUs include SAR ADCs (8–16 bits). Key parameters: resolution (bits), reference voltage (Vref), sampling rate, and input impedance. Read: configure pin as analog, start conversion, wait, read result. Oversampling improves resolution. External ADCs (via SPI/I2C) offer higher performance when needed.',
    worked='STM32 12-bit ADC, 3.3 V Vref:\nReading 1.65 V → 1.65/3.3 × 4095 = 2048\n10-bit (Arduino): 1.65/5 × 1023 = 338',
    eng='Data acquisition systems sample at kilohertz to megahertz rates; audio ADCs sample at 44.1 kHz+; oversampling achieves 16-bit from 12-bit.',
    mistakes=['Sampling above Nyquist; ignoring input impedance; noisy references; not waiting for conversion.'],
    practice=['What ADC resolution do Arduino and STM32 have?', 'What is oversampling?'],
    quiz=[
        q('Arduino Uno ADC resolution is:', ['8-bit', '10-bit', '12-bit', '16-bit'], [1], '10-bit.'),
        q('ADC resolution determines:', ['Speed only', 'Number of discrete levels', 'Voltage range only', 'Power'], [1], 'Levels.'),
    ])

lesson(11, 11, 'PWM',
    concept='PWM (Pulse Width Modulation) varies the duty cycle of a square wave to control average power, used for motor speed and LED dimming.',
    definition='PWM is a technique that controls average power delivery by varying the ON-time percentage (duty cycle) of a fixed-frequency square wave.',
    explanation='Duty cycle = ON time / period × 100%. Average voltage = duty cycle × peak voltage. A motor or LED responds to the average, not the individual pulses. MCUs generate PWM with hardware timers (no CPU load). Frequency depends on application: LEDs (100 Hz–1 kHz), motors (1–20 kHz), audio (much higher).',
    worked='50% duty at 5 V → average 2.5 V\nLED at 25% duty → quarter brightness\nMotor at 75% duty → 75% speed (approximately)',
    eng='Drones control motor speed with PWM; SMPS regulate voltage via PWM; servo motors position by pulse width (1–2 ms).',
    mistakes=['Frequencies too low for motors (audible noise); not filtering PWM for analog loads; ignoring flyback diodes for inductive loads.'],
    practice=['What duty cycle gives 3 V average from a 5 V signal?', 'Why is PWM efficient for motor control?'],
    quiz=[
        q('PWM controls:', ['Voltage directly', 'Average power via duty cycle', 'Frequency only', 'Resistance'], [1], 'Duty cycle.'),
        q('50% duty cycle at 5 V gives average:', ['5 V', '2.5 V', '0 V', '1.25 V'], [1], '2.5 V.'),
    ])

lesson(11, 12, 'Timers',
    concept='Timers are hardware counters that generate precise time intervals, PWM signals, and event triggers in embedded systems.',
    definition='A timer is a peripheral that counts clock pulses to measure time intervals, generate delays, and trigger events with hardware precision.',
    explanation='Timers count up (or down) from a clock source. Applications: precise delays (without busy-waiting), PWM generation, input capture (measuring pulse widths), output compare (toggling pins at set times), and watchdog timers (resetting on firmware hangs). Timer interrupts run code at precise intervals.',
    worked='Timer at 1 MHz → counts μs\nPeriod = 1000 → interrupt every 1 ms\nISR (interrupt service routine) runs periodically',
    eng='Motor control loops run at 10–20 kHz via timer interrupts; RTC timers keep time at 32.768 kHz; watchdogs recover from crashes.',
    mistakes=['Doing heavy work in ISRs; not clearing interrupt flags; ignoring timer overflow.'],
    practice=['What is a watchdog timer?', 'What is the difference between polling and timer interrupts?'],
    quiz=[
        q('A watchdog timer:', ['Tells time', 'Resets the system on firmware hangs', 'Generates PWM', 'Measures temperature'], [1], 'Resets on hang.'),
        q('Timer interrupts run:', ['Never', 'Automatically at set intervals', 'Only on power-on', 'Only in main loop'], [1], 'Periodically.'),
    ])

lesson(11, 13, 'Interrupts',
    concept='Interrupts are hardware signals that pause normal execution to run an interrupt service routine (ISR) for time-critical events.',
    definition='An interrupt is a signal to the processor emitted by hardware or software, indicating an event that needs immediate attention.',
    explanation='When an interrupt fires, the CPU saves its state, jumps to the ISR, executes it, then resumes. Sources: external pins (GPIO), timers, UART, ADC. Priorities determine which interrupt preempts others. ISRs should be short: set flags, defer work. Interrupts enable responsive, event-driven firmware without polling.',
    worked='Button press → external interrupt → ISR sets flag\nMain loop checks flag → debounce → act\nISR is short and fast',
    eng='RTOS kernels rely on tick interrupts for scheduling; motor control uses encoder interrupts; low-power modes wake on interrupts.',
    mistakes=['Long ISRs (missed events); shared variables without volatile; not disabling interrupts for critical sections.'],
    practice=['Why keep ISRs short?', 'What does volatile mean for ISR variables?'],
    quiz=[
        q('An interrupt:', ['Pauses execution to run a handler', 'Speeds up the CPU', 'Increases memory', 'Replaces the main loop'], [0], 'Event-driven handler.'),
        q('ISRs should be:', ['Long and complex', 'Short and fast', 'Avoided', 'Run in main loop'], [1], 'Short.'),
    ])

lesson(11, 14, 'AVR',
    concept='AVR is an 8-bit microcontroller family by Atmel (now Microchip), popularized by Arduino, with RISC architecture and rich peripherals.',
    definition='AVR is a family of 8-bit RISC microcontrollers known for their simplicity, low cost, and Arduino ecosystem support.',
    explanation='AVR (Alf-Egil Bogen and Vegard Wollan) uses a modified Harvard architecture with 32 registers. Models: ATtiny (small), ATmega (mid, ATmega328P in Arduino Uno), ATmega2560 (Arduino Mega). Peripherals: GPIO, timers, ADC, UART, SPI, I2C. Programmed in C/C++ via AVR-GCC or Arduino IDE. Clock: 1–20 MHz.',
    worked='ATmega328P: 20 MHz, 32 KB Flash, 2 KB SRAM, 1 KB EEPROM\n23 GPIO, 6 PWM, 6 ADC channels, UART/SPI/I2C',
    eng='Arduino made AVR ubiquitous in education and prototyping; AVRs run in 3D printers, drones, and countless hobby projects.',
    mistakes=['Exceeding current limits; not using brown-out detection; ignoring EEPROM write endurance.'],
    practice=['What does AVR stand for?', 'Which AVR is in the Arduino Uno?'],
    quiz=[
        q('AVR microcontrollers are:', ['32-bit', '8-bit RISC', '16-bit CISC', '64-bit'], [1], '8-bit RISC.'),
        q('Arduino Uno uses:', ['STM32', 'ATmega328P', 'ESP32', 'PIC18'], [1], 'ATmega328P.'),
    ])

lesson(11, 15, 'Arduino',
    concept='Arduino is an open-source electronics platform combining easy-to-use hardware (AVR boards) and a simplified IDE for rapid prototyping.',
    definition='Arduino is an open-source platform of microcontroller boards and software designed to make embedded programming accessible to everyone.',
    explanation='Arduino abstracts AVR programming: setup() runs once, loop() runs forever. The IDE provides digitalWrite, analogRead, Serial, and a vast library ecosystem. Shields add functionality (motor, Ethernet, LCD). Arduino is ideal for learning, prototyping, and art installations — but production often moves to bare-metal or STM32.',
    worked='void setup() {\n  pinMode(LED_BUILTIN, OUTPUT);\n}\nvoid loop() {\n  digitalWrite(LED_BUILTIN, HIGH);\n  delay(500);\n  digitalWrite(LED_BUILTIN, LOW);\n  delay(500);\n}',
    eng='Arduino prototypes become products: 3D printers (Marlin), drones (flight controllers), and IoT devices start as Arduino sketches.',
    mistakes=['Using delay() in complex projects (blocks); not understanding what Arduino abstracts away; powering from USB in production.'],
    practice=['What are the two main Arduino functions?', 'What is the Arduino IDE?'],
    quiz=[
        q('The two main Arduino functions are:', ['main() and loop()', 'setup() and loop()', 'init() and run()', 'start() and cycle()'], [1], 'setup() and loop().'),
        q('Arduino is built around which MCU family?', ['PIC', 'AVR', 'STM32', 'ESP32'], [1], 'AVR.'),
    ])

lesson(11, 16, 'ESP32',
    concept='ESP32 is a low-cost, low-power SoC with Wi-Fi and Bluetooth, widely used for IoT and wireless applications.',
    definition='ESP32 is a series of Espressif microcontrollers integrating dual-core processors, Wi-Fi, and Bluetooth at low cost.',
    explanation='ESP32 features: dual-core Xtensa LX6 (240 MHz), 520 KB SRAM, Wi-Fi 802.11 b/g/n, Bluetooth/BLE, rich peripherals (GPIO, ADC, DAC, touch, PWM, UART, SPI, I2C). Programmed with ESP-IDF (FreeRTOS-based), Arduino IDE, or MicroPython. Ultra-low-power modes enable battery-powered IoT. ESP32-S3/C3 add USB and RISC-V cores.',
    worked='ESP32-DevKit: 38 GPIO, 2.4 GHz Wi-Fi, BLE\nDeep sleep: μA current for battery life\nReads sensors → Wi-Fi → cloud dashboard',
    eng='ESP32 dominates IoT: smart home sensors, wearables, and industrial monitoring; its Wi-Fi + BLE combo is unmatched at its price.',
    mistakes=['Not handling Wi-Fi reconnects; deep wake current too high; ignoring RF regulations.'],
    practice=['What wireless capabilities does ESP32 have?', 'What framework is commonly used with ESP32?'],
    quiz=[
        q('ESP32 integrates:', ['No wireless', 'Wi-Fi and Bluetooth', 'Only Wi-Fi', 'Only Ethernet'], [1], 'Wi-Fi + BLE.'),
        q('ESP32 is popular in:', ['Supercomputers', 'IoT and wireless devices', 'Desktop PCs', 'Servers'], [1], 'IoT.'),
    ])

lesson(11, 17, 'Sensors in Embedded Systems',
    concept='Embedded systems read sensors via analog voltages, digital protocols (I2C/SPI), or bit-banged interfaces, converting to meaningful data.',
    definition='Sensors in embedded systems are read through ADC, digital protocols, or GPIO, with signal conditioning and calibration for accuracy.',
    explanation='Sensor interfaces: analog (voltage divider → ADC), I2C (addressed, 2-wire), SPI (fast, 4-wire), UART (serial data), and 1-Wire. Steps: read raw value, convert to engineering units (calibration), filter (moving average, Kalman), and apply. Common sensors: temperature (DS18B20, TMP36), motion (MPU6050), distance (HC-SR04).',
    worked='TMP36: 10 mV/°C, 500 mV offset\nADC 500 mV → 0°C; 750 mV → 25°C\nTemp = (Vout − 0.5) × 100',
    eng='Sensor fusion combines accelerometer, gyro, and magnetometer for precise orientation in drones and phones.',
    mistakes=['Not calibrating sensors; noise without filtering; protocol mismatches; power supply noise.'],
    practice=['How do you read an I2C sensor?', 'What is sensor calibration?'],
    quiz=[
        q('TMP36 outputs:', ['Digital data', 'Analog voltage proportional to temperature', 'PWM', 'Serial data'], [1], 'Analog.'),
        q('Sensor fusion combines:', ['One sensor', 'Multiple sensors for better accuracy', 'Only cameras', 'Only GPS'], [1], 'Multiple sensors.'),
    ])

lesson(11, 18, 'Actuators',
    concept='Actuators convert electrical signals to physical action: motors, relays, solenoids, speakers, and displays, driven by embedded outputs.',
    definition='An actuator is a device that converts an electrical control signal into mechanical motion, sound, light, or other physical output.',
    explanation='Actuator types: DC motors (H-bridge drivers), stepper motors (step/dir signals), servos (PWM), relays (on/off), solenoids (linear motion), speakers (audio), and displays (SPI/I2C). Driving considerations: current requirements (use drivers), inductive kickback (flyback diodes), and power supply capacity.',
    worked='DC motor: H-bridge (L298N) controls direction and speed\nStepper: step + direction signals → precise positioning\nServo: 1–2 ms pulse → 0–180° position',
    eng='Robots use servo and stepper motors; smart homes use relays for appliances; 3D printers use stepper drivers.',
    mistakes=['Driving motors from GPIO directly; no flyback diodes on inductive loads; undersized power supplies.'],
    practice=['What is an H-bridge?', 'How do you control a servo motor?'],
    quiz=[
        q('An actuator converts:', ['Motion to electricity', 'Electrical signals to physical action', 'Heat to light', 'Digital to analog'], [1], 'Electrical to physical.'),
        q('A servo motor is controlled by:', ['Voltage level', 'PWM pulse width', 'I2C address', 'Resistance'], [1], 'Pulse width.'),
    ])

lesson(11, 19, 'Embedded C',
    concept='Embedded C is C programming tailored for microcontrollers: direct hardware access, resource awareness, and deterministic behavior.',
    definition='Embedded C is the practice of programming microcontrollers in C, manipulating registers and peripherals directly within tight resource constraints.',
    explanation='Embedded C uses volatile for hardware registers, bit manipulation for configuration, and direct memory-mapped I/O. Constraints: limited RAM/Flash, no dynamic allocation (often), deterministic timing. Development: cross-compilers (arm-none-eabi-gcc), debuggers (JTAG/SWD), and IDEs (STM32CubeIDE, PlatformIO).',
    worked='volatile uint32_t *gpio = (uint32_t*)0x40020000;\n*gpio |= (1 << 5);  // set bit 5\n*gpio &= ~(1 << 5); // clear bit 5',
    eng='Embedded C runs the firmware in your car, appliances, and medical devices; MISRA-C enforces safety-critical standards.',
    mistakes=['Ignoring volatile on hardware registers; dynamic allocation causing fragmentation; not initializing peripherals.'],
    practice=['Why use volatile for hardware registers?', 'What is a cross-compiler?'],
    quiz=[
        q('Embedded C programs run on:', ['PCs', 'Microcontrollers', 'Servers', 'Web browsers'], [1], 'MCUs.'),
        q('The volatile keyword tells the compiler:', ['To optimize aggressively', 'The variable may change outside program flow', 'To store in RAM', 'To make it constant'], [1], 'External changes possible.'),
    ])

lesson(11, 20, 'Real-Time Systems',
    concept='Real-time systems guarantee response within strict deadlines, classified as hard (miss = failure) or firm/soft (miss = degraded).',
    definition='A real-time system is one where correctness depends on both logical results and the time at which they are produced.',
    explanation='Hard real-time: missing a deadline is catastrophic (airbag, brake control). Firm: occasional misses tolerated (video). Soft: misses degrade quality (gaming). Key concepts: determinism, jitter (timing variation), latency, and scheduling (rate-monotonic, EDF). RTOS kernels provide deterministic task scheduling.',
    worked='Brake-by-wire: must respond within 1 ms (hard)\nVideo stream: occasional frame drop OK (soft)\nRTOS schedules tasks to meet deadlines',
    eng='Automotive (ISO 26262), aerospace (DO-178C), and medical devices demand hard real-time guarantees.',
    mistakes=['Assuming faster hardware solves timing; ignoring jitter; not analyzing worst-case execution time (WCET).'],
    practice=['What is the difference between hard and soft real-time?', 'What is WCET?'],
    quiz=[
        q('Hard real-time means:', ['Fast', 'Missing deadlines causes failure', 'Expensive', 'Optional'], [1], 'Deadline mandatory.'),
        q('Jitter refers to:', ['Speed', 'Variation in timing', 'Power', 'Memory'], [1], 'Timing variation.'),
    ])

lesson(11, 21, 'RTOS Basics',
    concept='An RTOS (Real-Time Operating System) provides deterministic task scheduling, inter-task communication, and resource management for embedded systems.',
    definition='An RTOS is an operating system designed for real-time applications, guaranteeing task execution within specified time constraints.',
    explanation='RTOS features: preemptive priority-based scheduling, tasks/threads, queues, semaphores, mutexes, and timers. Popular RTOSes: FreeRTOS, Zephyr, ThreadX, VxWorks. Tasks have priorities; the scheduler always runs the highest-priority ready task. Context switches are deterministic (μs). RTOS adds structure to complex firmware.',
    worked='FreeRTOS tasks:\n- Sensor task (priority 3): reads every 10 ms\n- Control task (priority 2): computes every 5 ms\n- Comm task (priority 1): sends every 100 ms',
    eng='FreeRTOS runs on most MCUs; Zephyr powers IoT devices; QNX (RTOS) runs in cars and medical equipment.',
    mistakes=['Too many priorities; not handling priority inversion; blocking in ISRs; stack overflow.'],
    practice=['What does an RTOS provide?', 'What is priority inversion?'],
    quiz=[
        q('RTOS scheduling is typically:', ['Round-robin only', 'Priority-based preemptive', 'Random', 'Cooperative only'], [1], 'Priority preemptive.'),
        q('A mutex provides:', ['Mutual exclusion', 'Memory allocation', 'Networking', 'Display control'], [0], 'Mutual exclusion.'),
    ])

lesson(11, 22, 'IoT Fundamentals',
    concept='IoT (Internet of Things) connects physical devices to the internet, collecting and acting on data from the physical world.',
    definition='IoT is a network of physical objects embedded with sensors, software, and connectivity that exchange data over the internet.',
    explanation='IoT architecture: sensors/actuators → edge devices (ESP32, Raspberry Pi) → gateways → cloud platforms → applications. Protocols: MQTT (lightweight pub/sub), HTTP/REST, CoAP. Concerns: security (device authentication, encryption), power (battery vs mains), connectivity (Wi-Fi, LoRa, cellular), and scalability.',
    worked='Smart sensor: ESP32 reads temperature → MQTT → broker → dashboard\nLoRa: km-range, low-power, low-data-rate for agriculture',
    eng='IoT connects billions of devices: smart homes, industrial monitoring (IIoT), agriculture, and wearables.',
    mistakes=['No security on devices; cloud dependency without offline fallback; ignoring power budgets.'],
    practice=['What is MQTT?', 'Name three IoT connectivity options.'],
    quiz=[
        q('IoT stands for:', ['Internet of Things', 'Interface of Technology', 'Integrated Online Terminal', 'Internal Optical Transceiver'], [0], 'Internet of Things.'),
        q('MQTT is a:', ['Programming language', 'Lightweight messaging protocol', 'Database', 'Operating system'], [1], 'Protocol.'),
    ])

formula('Embedded Systems', 'PWM Duty Cycle', 'D = t_on / T × 100%', 't_on: on-time; T: period', 'Motor and LED control')
formula('Embedded Systems', 'UART Bit Time', 't_bit = 1 / baud_rate', 't_bit: seconds per bit', 'Serial timing')
formula('Embedded Systems', 'ADC Resolution', 'Step = Vref / 2^n', 'Vref: reference; n: bits', 'ADC accuracy')
