"""Physics and Engineering Mathematics curriculum content."""

from curriculum_base import lesson, q, formula, reference, subject

subject(14, 'Physics', 'Science',
        'Mechanics • Electricity • Magnetism • Waves', 'science')
subject(15, 'Engineering Mathematics', 'Mathematics',
        'Algebra • Trig • Matrices • Probability', 'functions')

# ---------------- Physics (37 lessons) ----------------

lesson(14, 1, 'Units and Measurements',
    concept='Physics uses SI units (meters, kilograms, seconds) and measurements with uncertainty to describe the physical world.',
    definition='Units and measurements are the standardized quantities and processes used to express physical properties accurately.',
    explanation='SI base units: meter (length), kilogram (mass), second (time), ampere (current), kelvin (temperature), mole (amount), candela (luminous intensity). Derived units: newton, joule, watt, volt. Measurement has uncertainty; significant figures express precision. Dimensional analysis checks equations.',
    worked='Speed: 100 km/h = 100 × 1000/3600 = 27.8 m/s\nForce: F = ma = 2 kg × 3 m/s² = 6 N',
    eng='Engineering drawings specify units explicitly; unit mismatches caused the Mars Climate Orbiter loss ($327M).',
    mistakes=['Ignoring units in calculations; confusing mass and weight; not converting units.'],
    practice=['Convert 60 km/h to m/s.', 'What is the SI unit of force?'],
    quiz=[
        q('The SI unit of mass is:', ['Gram', 'Kilogram', 'Pound', 'Newton'], [1], 'Kilogram.'),
        q('Dimensional analysis checks:', ['Numbers', 'Unit consistency', 'Significant figures', 'Precision'], [1], 'Units.'),
    ])

lesson(14, 2, 'Vectors',
    concept='Vectors are quantities with magnitude and direction, represented by arrows and manipulated with vector algebra.',
    definition='A vector is a mathematical object with both magnitude and direction, used to represent physical quantities like force and velocity.',
    explanation='Vectors add tip-to-tail (graphically) or component-wise (algebraically). Subtraction adds the negative. Scalar multiplication scales magnitude. Dot product: A·B = |A||B|cos(θ) (scalar). Cross product: A×B = |A||B|sin(θ) (vector, perpendicular). Unit vectors (i, j, k) decompose vectors.',
    worked='A = 3i + 4j, |A| = √(9+16) = 5\nA·B = (3)(2) + (4)(1) = 10\nA×B = (3i+4j)×(2i+j) = 3·1−4·2 = −5k',
    eng='Forces, fields, and motion are vectors; structural analysis resolves forces into components.',
    mistakes=['Adding magnitudes instead of vectors; confusing dot and cross products; ignoring direction.'],
    practice=['Add vectors A = 2i + 3j and B = 4i − j.', 'What is the dot product of perpendicular vectors?'],
    quiz=[
        q('A vector has:', ['Magnitude only', 'Magnitude and direction', 'Direction only', 'Neither'], [1], 'Both.'),
        q('The dot product of perpendicular vectors is:', ['1', '0', 'Maximum', 'Negative'], [1], '0.'),
    ])

lesson(14, 3, 'Motion',
    concept='Motion describes position change over time, characterized by displacement, velocity, and acceleration.',
    definition='Motion is the change in position of an object over time, described by kinematic quantities: displacement, velocity, and acceleration.',
    explanation='Displacement: change in position (vector). Velocity: rate of change of displacement (v = Δx/Δt). Acceleration: rate of change of velocity (a = Δv/Δt). Kinematic equations for constant acceleration: v = u + at, s = ut + ½at², v² = u² + 2as.',
    worked='Car accelerates from 0 to 20 m/s in 5 s:\na = (20−0)/5 = 4 m/s²\nDistance: s = 0 + ½(4)(25) = 50 m',
    eng='Vehicle crash analysis uses kinematics; robotics plans motion trajectories with these equations.',
    mistakes=['Confusing distance and displacement; assuming constant acceleration; sign errors.'],
    practice=['A ball is thrown up at 10 m/s. How high does it go? (g = 10 m/s²)', 'What are the kinematic equations?'],
    quiz=[
        q('Velocity is the rate of change of:', ['Acceleration', 'Position (displacement)', 'Time', 'Force'], [1], 'Position.'),
        q('An object in free fall has constant:', ['Velocity', 'Acceleration', 'Position', 'Mass'], [1], 'Acceleration.'),
    ])

lesson(14, 4, 'Velocity',
    concept='Velocity is the rate of change of position with direction — a vector; speed is its magnitude.',
    definition='Velocity is the time rate of change of displacement, a vector quantity with magnitude (speed) and direction.',
    explanation='Average velocity = displacement/time. Instantaneous velocity is the derivative of position. Velocity differs from speed: 60 km/h north is velocity; 60 km/h is speed. Relative velocity accounts for moving reference frames.',
    worked='v = Δx/Δt = (100 m − 20 m)/(10 s − 2 s) = 10 m/s\nInstantaneous: v = dx/dt',
    eng='GPS measures velocity; airspeed indicators show aircraft velocity relative to air.',
    mistakes=['Confusing speed with velocity; ignoring direction; averaging speeds incorrectly.'],
    practice=['A runner completes 400 m in 50 s. What is the average velocity?', 'What is the difference between speed and velocity?'],
    quiz=[
        q('Velocity is a:', ['Scalar', 'Vector', 'Unit', 'Dimension'], [1], 'Vector.'),
        q('Average velocity equals:', ['Speed', 'Displacement / time', 'Distance / time', 'Acceleration'], [1], 'Displacement/time.'),
    ])

lesson(14, 5, 'Acceleration',
    concept='Acceleration is the rate of change of velocity, measured in m/s², caused by net force.',
    definition='Acceleration is the time rate of change of velocity, a vector quantity measured in meters per second squared.',
    explanation='Acceleration occurs when velocity changes — in magnitude or direction. Positive acceleration speeds up; negative (deceleration) slows down. Centripetal acceleration (v²/r) changes direction in circular motion. Newton\'s second law: a = F/m.',
    worked='a = Δv/Δt = (30 − 10)/5 = 4 m/s²\nCentripetal: a = v²/r = 100/25 = 4 m/s²',
    eng='Roller coasters and centrifuges exploit acceleration; crash tests measure deceleration to design safety systems.',
    mistakes=['Assuming acceleration means speeding up (it can be direction change); confusing with velocity; ignoring units.'],
    practice=['A car goes from 0 to 30 m/s in 6 s. What is the acceleration?', 'What causes centripetal acceleration?'],
    quiz=[
        q('Acceleration is measured in:', ['m/s', 'm/s²', 'N', 'J'], [1], 'm/s².'),
        q('Acceleration occurs when:', ['Speed changes only', 'Velocity changes (speed or direction)', 'Position changes', 'Mass changes'], [1], 'Velocity changes.'),
    ])

lesson(14, 6, 'Newton\'s Laws',
    concept='Newton\'s three laws describe motion: inertia, F = ma, and action-reaction pairs.',
    definition='Newton\'s laws of motion are three principles: (1) inertia, (2) F = ma, (3) every action has an equal and opposite reaction.',
    explanation='First law: objects maintain velocity unless acted on by net force (inertia). Second law: net force equals mass times acceleration. Third law: forces come in pairs — if A exerts force on B, B exerts equal opposite force on A. These laws govern all classical mechanics.',
    worked='F = ma: 10 N on 2 kg → a = 5 m/s²\nRocket: exhaust down (action), rocket up (reaction)',
    eng='Structural engineering applies Newton\'s laws to static equilibrium; propulsion systems rely on the third law.',
    mistakes=['Thinking force is needed to maintain velocity (inertia); confusing mass and weight; ignoring force pairs.'],
    practice=['State Newton\'s three laws.', 'A 5 kg object accelerates at 3 m/s². What is the net force?'],
    quiz=[
        q('Newton\'s second law is:', ['F = ma', 'E = mc²', 'a = F/m²', 'F = m/a'], [0], 'F = ma.'),
        q('Newton\'s first law describes:', ['Acceleration', 'Inertia', 'Action-reaction', 'Gravity'], [1], 'Inertia.'),
    ])

lesson(14, 7, 'Force',
    concept='Force is a push or pull that causes acceleration, measured in newtons (N), with net force determining motion.',
    definition='Force is an interaction that changes the motion of an object, measured in newtons (1 N = 1 kg·m/s²).',
    explanation='Forces are vectors: they add as vectors. Net force (vector sum) determines acceleration via F = ma. Types: contact (friction, tension, normal) and field (gravity, electric, magnetic). Free-body diagrams visualize forces for analysis.',
    worked='Two forces: 3 N east + 4 N north\nNet: √(9+16) = 5 N at 53° north of east',
    eng='Structural engineers calculate forces in bridges; mechanical engineers design mechanisms to transmit force.',
    mistakes=['Adding forces as scalars; ignoring direction; confusing force with energy.'],
    practice=['Find the net force of 5 N east and 12 N north.', 'What is a free-body diagram?'],
    quiz=[
        q('Force is measured in:', ['Joules', 'Newtons', 'Watts', 'Pascals'], [1], 'Newtons.'),
    ])

lesson(14, 8, 'Work',
    concept='Work is energy transferred by force acting over distance: W = Fd cos(θ), measured in joules.',
    definition='Work is the energy transferred to or from an object via force acting over a displacement, W = F·d·cos(θ).',
    explanation='Work requires force and displacement in the force\'s direction. θ = angle between force and displacement. Positive work adds energy; negative work removes it. No displacement = no work (holding a weight still does no work). Work-energy theorem: net work = change in kinetic energy.',
    worked='W = Fd = 10 N × 5 m = 50 J\nLifting 2 kg 1 m: W = mgh = 2 × 9.8 × 1 = 19.6 J',
    eng='Work calculations size engines and motors; regenerative braking recovers work in electric vehicles.',
    mistakes=['Confusing work with force; ignoring the angle; thinking holding still does work.'],
    practice=['Calculate the work done pushing a box 10 m with 20 N.', 'What is the work-energy theorem?'],
    quiz=[
        q('Work is measured in:', ['Newtons', 'Joules', 'Watts', 'Pascals'], [1], 'Joules.'),
        q('Work requires:', ['Force only', 'Force and displacement', 'Mass only', 'Time only'], [1], 'Force + displacement.'),
    ])

lesson(14, 9, 'Energy',
    concept='Energy is the capacity to do work, existing as kinetic (motion), potential (position), and other forms, conserved in closed systems.',
    definition='Energy is the capacity of a system to do work, measured in joules, existing in forms like kinetic, potential, thermal, and chemical.',
    explanation='Kinetic energy: KE = ½mv². Gravitational potential: PE = mgh. Conservation of energy: energy transforms but total remains constant. Power is the rate of doing work (P = W/t). Energy efficiency = useful output / total input.',
    worked='KE = ½(2 kg)(3 m/s)² = 9 J\nPE = (2 kg)(9.8)(5 m) = 98 J\nTotal mechanical energy conserved (ignoring friction)',
    eng='Energy analysis drives power plant design, battery sizing, and renewable energy systems.',
    mistakes=['Confusing energy with power; ignoring energy losses (friction); assuming energy is created.'],
    practice=['Calculate the kinetic energy of a 1000 kg car at 20 m/s.', 'What is the difference between energy and power?'],
    quiz=[
        q('Energy is measured in:', ['Watts', 'Joules', 'Newtons', 'Volts'], [1], 'Joules.'),
    ])

lesson(14, 10, 'Power',
    concept='Power is the rate of doing work or transferring energy, measured in watts (W = J/s).',
    definition='Power is the rate at which work is done or energy is transferred, P = W/t = F·v, measured in watts.',
    explanation='Power quantifies how fast energy is used or produced. 1 watt = 1 joule per second. Mechanical power: P = F·v. Electrical power: P = VI. Horsepower (hp) is a non-SI unit (1 hp ≈ 746 W). Power ratings specify device capabilities.',
    worked='P = W/t = 100 J / 5 s = 20 W\nClimbing stairs: P = mgh/t = (70)(9.8)(3)/6 = 343 W',
    eng='Engine power determines vehicle performance; power grid capacity is measured in gigawatts.',
    mistakes=['Confusing power with energy; ignoring time; unit errors (kW vs W).'],
    practice=['A motor does 500 J of work in 10 s. What is its power?', 'What is the difference between power and energy?'],
    quiz=[
        q('Power is measured in:', ['Joules', 'Watts', 'Newtons', 'Volts'], [1], 'Watts.'),
        q('Power is the rate of:', ['Force', 'Work/Energy transfer', 'Mass', 'Velocity'], [1], 'Work.'),
    ])

lesson(14, 11, 'Momentum',
    concept='Momentum is the product of mass and velocity (p = mv), conserved in collisions, with impulse changing it.',
    definition='Momentum is the quantity of motion of an object, p = mv, a vector conserved in isolated systems.',
    explanation='Momentum measures how hard it is to stop an object. Conservation: total momentum before = total momentum after (collisions). Impulse: J = FΔt = Δp (force over time changes momentum). Elastic collisions conserve kinetic energy; inelastic do not.',
    worked='p = mv = 2 kg × 3 m/s = 6 kg·m/s\nImpulse: J = 10 N × 2 s = 20 N·s = Δp',
    eng='Crash safety uses impulse (airbags extend Δt to reduce F); rocket propulsion conserves momentum.',
    mistakes=['Confusing momentum with kinetic energy; assuming momentum is always conserved (only in isolated systems); ignoring vector nature.'],
    practice=['Calculate the momentum of a 1500 kg car at 25 m/s.', 'What is impulse?'],
    quiz=[
        q('Momentum equals:', ['mv', '½mv²', 'ma', 'Fd'], [0], 'p = mv.'),
        q('Momentum is conserved in:', ['All collisions (isolated systems)', 'Only elastic', 'Only inelastic', 'Never'], [0], 'Isolated systems.'),
    ])

lesson(14, 12, 'Impulse',
    concept='Impulse is the change in momentum caused by force over time: J = FΔt = Δp.',
    definition='Impulse is the product of force and the time interval over which it acts, equal to the change in momentum.',
    explanation='Impulse explains why airbags work: extending collision time (Δt) reduces peak force (F) for the same momentum change. Applications: catching eggs (bend knees), crumple zones, and sports (follow-through).',
    worked='Δp = 100 kg·m/s over 0.1 s → F = 1000 N\nSame Δp over 1 s → F = 100 N (10× less!)',
    eng='Crash test analysis uses impulse; packaging design protects products by extending impact time.',
    mistakes=['Confusing impulse with work; assuming force is constant; ignoring time.'],
    practice=['A 0.5 kg ball hits a wall at 10 m/s and rebounds at 8 m/s. What is the impulse?', 'Why do airbags reduce injury?'],
    quiz=[
        q('Impulse equals:', ['FΔt = Δp', 'Fd', 'mv²', 'ma'], [0], 'FΔt.'),
        q('Extending collision time ______ peak force.', ['Increases', 'Decreases', 'No change', 'Doubles'], [1], 'Decreases.'),
    ])

lesson(14, 13, 'Circular Motion',
    concept='Circular motion moves along a circular path, requiring centripetal force and producing centripetal acceleration.',
    definition='Circular motion is movement along a circular path, characterized by centripetal acceleration (v²/r) directed toward the center.',
    explanation='Even at constant speed, circular motion accelerates (direction changes). Centripetal force (mv²/r) causes this: tension (swinging a ball), gravity (orbits), friction (car turning). Angular velocity (ω) relates to linear: v = ωr. Centrifugal force is a fictitious force in rotating frames.',
    worked='a = v²/r = (10)²/5 = 20 m/s²\nF = mv²/r = 2 × 20 = 40 N',
    eng='Centrifuges separate materials by density; banked curves use normal force for turning; satellites orbit via gravity.',
    mistakes=['Thinking centrifugal force is real (in inertial frames); confusing angular and linear velocity; ignoring that constant speed ≠ constant velocity.'],
    practice=['Calculate the centripetal force on a 1 kg object moving at 5 m/s in a 2 m radius circle.', 'What provides centripetal force for a satellite?'],
    quiz=[
        q('Centripetal acceleration is directed:', ['Outward', 'Toward the center', 'Tangent', 'Up'], [1], 'Center.'),
        q('Centripetal force is provided by gravity in:', ['Car turns', 'Satellite orbits', 'Swinging balls', 'All circular motion'], [1], 'Orbits.'),
    ])

lesson(14, 14, 'Electric Charge',
    concept='Electric charge is a fundamental property of matter, measured in coulombs, existing as positive or negative.',
    definition='Electric charge is a fundamental property of matter that causes electromagnetic force, measured in coulombs (C).',
    explanation='Charge is quantized (multiples of e = 1.6 × 10⁻¹⁹ C). Like charges repel; opposite charges attract. Charge is conserved. Conductors allow charge flow; insulators resist it. Coulomb\'s law: F = kq₁q₂/r².',
    worked='F = kq₁q₂/r² = 9×10⁹ × (1×10⁻⁶)²/(0.1)² = 0.9 N\nElectron charge: −1.6 × 10⁻¹⁹ C',
    eng='Electrostatic discharge (ESD) damages electronics; Van de Graaff generators demonstrate charge accumulation.',
    mistakes=['Confusing charge with current; assuming charge is continuous; ignoring conservation.'],
    practice=['What is the charge of an electron?', 'State Coulomb\'s law.'],
    quiz=[
        q('Charge is measured in:', ['Amperes', 'Coulombs', 'Volts', 'Ohms'], [1], 'Coulombs.'),
        q('Like charges:', ['Attract', 'Repel', 'Neutralize', 'Merge'], [1], 'Repel.'),
    ])

lesson(14, 15, 'Electric Field',
    concept='An electric field is the region around a charge where other charges experience force, measured in N/C or V/m.',
    definition='An electric field is a vector field surrounding a charged particle, representing the force per unit charge exerted on other charges.',
    explanation='E = F/q (force per unit charge). Field lines point away from positive, toward negative charges. Field strength decreases with distance (E ∝ 1/r² for point charges). Fields superpose (vector sum). Conductors shield internal fields.',
    worked='E = F/q = 10 N / 2 C = 5 N/C\nE = kQ/r² = 9×10⁹ × 1×10⁻⁶/4 = 2.25×10³ N/C',
    eng='Capacitors store energy in electric fields; field strength determines insulation requirements in high-voltage equipment.',
    mistakes=['Confusing field with force; assuming fields are scalar; ignoring superposition.'],
    practice=['Calculate the field 1 m from a 1 μC charge.', 'What is an electric field?'],
    quiz=[
        q('Electric field is measured in:', ['N/C', 'C/N', 'V', 'A'], [0], 'N/C.'),
        q('Field lines point ______ positive charges.', ['Toward', 'Away from', 'Parallel to', 'Randomly'], [1], 'Away.'),
    ])

lesson(14, 16, 'Electric Potential',
    concept='Electric potential (voltage) is the potential energy per unit charge, measured in volts, driving current in circuits.',
    definition='Electric potential is the electric potential energy per unit charge at a point in a field, measured in volts (V = J/C).',
    explanation='Voltage is the "electrical pressure" that drives charge. Potential difference (ΔV) between two points determines work done moving charge: W = qΔV. Equipotential surfaces are perpendicular to field lines. Batteries provide potential difference.',
    worked='V = W/q = 10 J / 2 C = 5 V\n1 V = 1 J/C',
    eng='High-voltage transmission reduces current for the same power; potential differences drive all electronic circuits.',
    mistakes=['Confusing potential with current; assuming voltage is absolute (it\'s a difference); ignoring reference points.'],
    practice=['What is the potential difference when 20 J moves 4 C?', 'What is a volt?'],
    quiz=[
        q('Voltage is measured in:', ['Amperes', 'Volts', 'Ohms', 'Watts'], [1], 'Volts.'),
        q('1 volt = 1 joule per:', ['Second', 'Coulomb', 'Meter', 'Kilogram'], [1], 'Coulomb.'),
    ])

lesson(14, 17, 'Current',
    concept='Electric current is the flow of charge, measured in amperes (A = C/s), driven by potential difference.',
    definition='Electric current is the rate of flow of electric charge through a conductor, measured in amperes.',
    explanation='I = ΔQ/Δt. Conventional current flows positive to negative (historical). Current requires a complete circuit and potential difference. Current density: J = I/A. AC alternates direction; DC flows one way.',
    worked='I = Q/t = 10 C / 2 s = 5 A\n1 A = 1 C/s',
    eng='Current ratings determine wire gauge; circuit breakers protect against overcurrent; ammeters measure current.',
    mistakes=['Confusing current with voltage; assuming current is used up in a circuit; ignoring direction conventions.'],
    practice=['Calculate the current when 15 C flows in 3 s.', 'What is the difference between AC and DC?'],
    quiz=[
        q('Current is measured in:', ['Volts', 'Amperes', 'Ohms', 'Watts'], [1], 'Amperes.'),
        q('Current is the flow of:', ['Voltage', 'Charge', 'Energy', 'Resistance'], [1], 'Charge.'),
    ])

lesson(14, 18, 'Resistance',
    concept='Resistance opposes current flow, measured in ohms (Ω), determined by material, length, and temperature.',
    definition='Electrical resistance is the opposition to current flow, R = V/I, measured in ohms (Ω).',
    explanation='Resistance depends on resistivity (ρ), length (L), and area (A): R = ρL/A. Temperature affects resistance (positive for metals, negative for semiconductors). Resistors control current and divide voltage in circuits. Superconductors have zero resistance.',
    worked='R = V/I = 12 V / 3 A = 4 Ω\nR = ρL/A for conductors',
    eng='Resistance heating (toasters, heaters); precision resistors in measurement; thermistors for temperature sensing.',
    mistakes=['Confusing resistance with resistivity; assuming resistance is constant (temperature); ignoring power ratings.'],
    practice=['Calculate the resistance of a 6 V, 2 A device.', 'What factors affect resistance?'],
    quiz=[
        q('Resistance is measured in:', ['Volts', 'Amperes', 'Ohms', 'Watts'], [2], 'Ohms.'),
        q('R =', ['V/I', 'VI', 'I/V', 'V+I'], [0], 'V/I.'),
    ])

lesson(14, 19, 'Ohm\'s Law',
    concept='Ohm\'s law states V = IR: voltage equals current times resistance, the fundamental circuit relationship.',
    definition='Ohm\'s law is the principle that current through a conductor is directly proportional to voltage: V = IR.',
    explanation='Given any two of V, I, R, find the third. Ohm\'s law applies to ohmic materials (constant R). It is the first tool for circuit analysis. Use this app\'s Ohm\'s Law calculator to verify values instantly.',
    worked='V = 12 V, R = 6 Ω → I = 2 A\nI = 2 A, R = 6 Ω → V = 12 V',
    eng='Ohm\'s law is the foundation of all circuit analysis, from simple devices to complex electronics.',
    mistakes=['Applying to non-ohmic devices (diodes); confusing the three forms; ignoring units.'],
    practice=['A circuit has 9 V and 3 Ω. What is the current?', 'What voltage produces 0.5 A through 100 Ω?'],
    quiz=[
        q('V = 12 V, R = 6 Ω. I =', ['0.5 A', '2 A', '18 A', '72 A'], [1], '2 A.'),
        q('Ohm\'s law states:', ['V = I/R', 'V = IR', 'I = VR', 'R = VI'], [1], 'V = IR.'),
    ])

lesson(14, 20, 'Electrical Power',
    concept='Electrical power is the rate of energy transfer, P = VI = I²R = V²/R, measured in watts.',
    definition='Electrical power is the rate at which electrical energy is transferred, P = VI, measured in watts.',
    explanation='Power combines voltage and current. Using Ohm\'s law: P = I²R = V²/R. Power ratings specify device consumption and component limits. Energy = power × time (kWh on bills).',
    worked='P = VI = 12 × 2 = 24 W\nP = I²R = 4 × 6 = 24 W',
    eng='Power grid capacity, appliance ratings, and circuit design all depend on power calculations.',
    mistakes=['Confusing power with energy; exceeding ratings; ignoring efficiency.'],
    practice=['A device draws 2 A at 12 V. What is its power?', 'What is the difference between power and energy?'],
    quiz=[
        q('Power is measured in:', ['Volts', 'Amperes', 'Ohms', 'Watts'], [3], 'Watts.'),
        q('P = V × I. For V=12, I=2:', ['6 W', '14 W', '24 W', '48 W'], [2], '24 W.'),
    ])

lesson(14, 21, 'Kirchhoff\'s Laws',
    concept='Kirchhoff\'s Current Law (KCL) conserves charge at junctions; Kirchhoff\'s Voltage Law (KVL) conserves energy around loops.',
    definition='Kirchhoff\'s laws are two circuit analysis principles: KCL (sum of currents at a junction is zero) and KVL (sum of voltages around a loop is zero).',
    explanation='KCL: current entering equals current leaving (charge conservation). KVL: voltage rises equal drops around any loop (energy conservation). Together with Ohm\'s law, they analyze any DC circuit.',
    worked='KCL: I1 = I2 + I3\nKVL: 12 = V1 + V2 + V3',
    eng='SPICE circuit simulators solve Kirchhoff\'s laws for complex circuits; every circuit analysis starts here.',
    mistakes=['Sign errors in KVL; missing branches; confusing KCL with KVL.'],
    practice=['State KCL and KVL.', 'Analyze a simple series circuit using KVL.'],
    quiz=[
        q('KCL conserves:', ['Voltage', 'Current', 'Power', 'Energy'], [1], 'Current.'),
        q('KVL applies to:', ['Junctions', 'Closed loops', 'Open circuits', 'Single components'], [1], 'Loops.'),
    ])

lesson(14, 22, 'Magnetic Fields',
    concept='A magnetic field is the region around a magnet or current where magnetic forces act, measured in tesla (T).',
    definition='A magnetic field is a vector field that describes the magnetic influence on moving charges, currents, and magnetic materials.',
    explanation='Magnetic fields are produced by moving charges (currents) and magnetic dipoles. Field lines form closed loops from north to south poles. Earth\'s field guides compasses. Field strength: B (tesla). Lorentz force: F = qvB sin(θ).',
    worked='F = qvB = 1.6×10⁻¹⁹ × 10⁶ × 0.5 = 8×10⁻¹⁴ N\nEarth\'s field: ~25–65 μT',
    eng='MRI uses strong magnetic fields (1.5–3 T); particle accelerators steer beams with magnets; magnetic levitation trains.',
    mistakes=['Confusing magnetic with electric fields; assuming field lines start/end (they loop); ignoring the right-hand rule.'],
    practice=['What produces magnetic fields?', 'What is the unit of magnetic field?'],
    quiz=[
        q('Magnetic field is measured in:', ['Tesla', 'Gauss only', 'Amperes', 'Volts'], [0], 'Tesla.'),
        q('Magnetic fields are produced by:', ['Static charges', 'Moving charges (currents)', 'Heat', 'Light'], [1], 'Currents.'),
    ])

lesson(14, 23, 'Electromagnetic Induction',
    concept='Electromagnetic induction generates voltage when magnetic flux through a circuit changes, the basis of generators and transformers.',
    definition='Electromagnetic induction is the production of an electromotive force (voltage) across a conductor in a changing magnetic field.',
    explanation='Faraday\'s law: induced EMF = −N dΦ/dt (rate of change of magnetic flux). Lenz\'s law: the induced current opposes the change. Applications: generators (mechanical → electrical), transformers (voltage conversion), induction cooktops, and wireless charging.',
    worked='EMF = −dΦ/dt\nMoving a magnet through a coil induces voltage\nGenerator: rotating coil in magnetic field → AC',
    eng='Power plants generate electricity via induction; transformers enable efficient long-distance transmission.',
    mistakes=['Confusing induction with static magnetism; ignoring Lenz\'s law; assuming constant flux induces voltage.'],
    practice=['State Faraday\'s law.', 'How does a generator work?'],
    quiz=[
        q('Induction requires:', ['Constant field', 'Changing magnetic flux', 'Static charge', 'High voltage'], [1], 'Changing flux.'),
        q('Generators convert:', ['Electrical to mechanical', 'Mechanical to electrical', 'Heat to light', 'AC to DC'], [1], 'Mechanical → electrical.'),
    ])

lesson(14, 24, 'Faraday\'s Law',
    concept='Faraday\'s law states that induced EMF equals the negative rate of change of magnetic flux: EMF = −N dΦ/dt.',
    definition='Faraday\'s law of induction states that the induced electromotive force in a circuit equals the negative rate of change of magnetic flux through the circuit.',
    explanation='Magnetic flux Φ = BA cos(θ) (field × area × orientation). Changing B, A, or θ induces EMF. The negative sign is Lenz\'s law (opposition). More turns (N) increase EMF. This law is the foundation of electrical power generation.',
    worked='Φ = BA = 0.5 T × 0.1 m² = 0.05 Wb\nIf Φ changes in 0.1 s: EMF = 0.05/0.1 = 0.5 V',
    eng='Faraday\'s law enables all electric generators, transformers, and induction motors — the backbone of the power grid.',
    mistakes=['Ignoring the negative sign (Lenz); confusing flux with field; assuming static flux induces EMF.'],
    practice=['Calculate the EMF when flux changes from 0.1 Wb to 0 in 0.2 s.', 'What is magnetic flux?'],
    quiz=[
        q('Faraday\'s law: EMF =', ['dΦ/dt', '−N dΦ/dt', 'Φ/t', 'NΦ'], [1], '−N dΦ/dt.'),
        q('Induced EMF increases with:', ['Slower change', 'Faster flux change', 'Constant flux', 'No field'], [1], 'Faster change.'),
    ])

lesson(14, 25, 'Lenz\'s Law',
    concept='Lenz\'s law states that induced current opposes the change in magnetic flux that produced it, ensuring energy conservation.',
    definition='Lenz\'s law states that the direction of induced current is such that it opposes the change in magnetic flux that produced it.',
    explanation='The negative sign in Faraday\'s law is Lenz\'s law. When a magnet approaches a coil, the induced current creates a field repelling the magnet (opposing the approach). This opposition requires work, conserving energy — you can\'t get free energy.',
    worked='Magnet north pole approaches coil → coil\'s near end becomes north (repels)\nWork done against repulsion = electrical energy generated',
    eng='Lenz\'s law explains eddy current braking (trains, roller coasters) and why generators resist turning.',
    mistakes=['Thinking induced current aids the change; ignoring energy conservation; confusing with attraction.'],
    practice=['A magnet\'s south pole moves away from a coil. What is the induced current direction?', 'Why does Lenz\'s law conserve energy?'],
    quiz=[
        q('Lenz\'s law states induced current ______ the change.', ['Aids', 'Opposes', 'Ignores', 'Doubles'], [1], 'Opposes.'),
        q('Lenz\'s law is a consequence of:', ['Ohm\'s law', 'Energy conservation', 'Newton\'s first law', 'Coulomb\'s law'], [1], 'Conservation.'),
    ])

lesson(14, 26, 'Wave Properties',
    concept='Waves transfer energy without transferring matter, characterized by wavelength, frequency, amplitude, and speed.',
    definition='A wave is a disturbance that transfers energy through space and matter, characterized by wavelength (λ), frequency (f), amplitude (A), and speed (v).',
    explanation='Wave speed: v = fλ. Amplitude: maximum displacement (energy). Frequency: cycles per second (Hz). Wavelength: distance between crests. Types: transverse (light, water) and longitudinal (sound). Waves reflect, refract, diffract, and interfere.',
    worked='v = fλ: 340 m/s = f × 0.68 m → f = 500 Hz\nHigher frequency = shorter wavelength (same speed)',
    eng='Wireless communication, medical imaging (ultrasound), and seismology all exploit wave properties.',
    mistakes=['Confusing frequency with wavelength; assuming waves transfer matter; ignoring the medium for mechanical waves.'],
    practice=['Calculate the frequency of a 2 m wave at 10 m/s.', 'What is the relationship between frequency and wavelength?'],
    quiz=[
        q('Wave speed equals:', ['f/λ', 'fλ', 'λ/f', 'f + λ'], [1], 'v = fλ.'),
    ])

lesson(14, 27, 'Frequency',
    concept='Frequency is the number of wave cycles per second, measured in hertz (Hz), determining pitch and color.',
    definition='Frequency is the number of complete oscillations per unit time, measured in hertz (Hz = cycles/second).',
    explanation='Frequency and period are reciprocals: f = 1/T. Higher frequency = higher pitch (sound) or bluer color (light). Human hearing: 20 Hz–20 kHz. Radio: kHz–GHz. Frequency is the fundamental property that distinguishes electromagnetic waves.',
    worked='f = 1/T = 1/0.02 s = 50 Hz\nv = fλ → f = v/λ = 340/0.34 = 1000 Hz',
    eng='5G uses higher frequencies (more bandwidth); musical pitch is frequency; medical ultrasound is MHz.',
    mistakes=['Confusing frequency with amplitude; assuming all waves have the same frequency; unit errors (kHz vs Hz).'],
    practice=['What is the frequency of a 0.01 s period wave?', 'What frequency range can humans hear?'],
    quiz=[
        q('Frequency is measured in:', ['Meters', 'Hertz', 'Seconds', 'Watts'], [1], 'Hz.'),
        q('Frequency and period are:', ['Equal', 'Reciprocals', 'Unrelated', 'Both constant'], [1], 'Reciprocals.'),
    ])

lesson(14, 28, 'Wavelength',
    concept='Wavelength is the distance between consecutive wave crests, inversely related to frequency at constant speed.',
    definition='Wavelength is the spatial period of a wave — the distance over which the wave\'s shape repeats, measured in meters.',
    explanation='λ = v/f. Longer wavelength = lower frequency (at constant speed). Wavelength determines wave behavior: diffraction (bending around obstacles) is significant when λ ≈ obstacle size. Radio waves (meters) diffract around buildings; light (nm) does not.',
    worked='λ = v/f = 340/1700 = 0.2 m\nAM radio: ~300 m; FM: ~3 m; Wi-Fi: ~0.12 m',
    eng='Antenna size is proportional to wavelength; fiber optics use specific wavelengths (850/1310/1550 nm) for low loss.',
    mistakes=['Confusing wavelength with amplitude; assuming wavelength is constant across media; ignoring diffraction.'],
    practice=['Calculate the wavelength of a 1000 Hz sound wave (v = 340 m/s).', 'Why do radio waves diffract around buildings but light doesn\'t?'],
    quiz=[
        q('Wavelength is measured in:', ['Hertz', 'Meters', 'Seconds', 'Watts'], [1], 'Meters.'),
        q('At constant speed, higher frequency means ______ wavelength.', ['Longer', 'Shorter', 'Same', 'Infinite'], [1], 'Shorter.'),
    ])

lesson(14, 29, 'Amplitude',
    concept='Amplitude is the maximum displacement of a wave from equilibrium, determining energy and intensity.',
    definition='Amplitude is the maximum extent of a wave\'s displacement from its rest position, related to the wave\'s energy.',
    explanation='Amplitude determines loudness (sound) and brightness (light). Wave energy ∝ amplitude². Amplitude decreases with distance (spreading and absorption). In EM waves, amplitude is the field strength.',
    worked='Energy ∝ A²: doubling amplitude quadruples energy\nSound: 2× amplitude = 6 dB louder (roughly)',
    eng='Amplitude modulation (AM radio) encodes audio in amplitude; earthquake magnitude relates to wave amplitude.',
    mistakes=['Confusing amplitude with frequency; assuming amplitude is constant over distance; ignoring energy relationship.'],
    practice=['What does amplitude determine in sound?', 'How does wave energy relate to amplitude?'],
    quiz=[
        q('Wave energy is proportional to:', ['Amplitude', 'Amplitude squared', 'Frequency only', 'Wavelength'], [1], 'A².'),
    ])

lesson(14, 30, 'Sound',
    concept='Sound is a longitudinal mechanical wave traveling through media, with frequency determining pitch and amplitude loudness.',
    definition='Sound is a mechanical wave of pressure variations propagating through a medium (air, water, solids), requiring a medium to travel.',
    explanation='Sound is longitudinal: particles oscillate parallel to propagation. Speed depends on medium: air ~343 m/s, water ~1480 m/s, steel ~5000 m/s. Frequency → pitch; amplitude → loudness. Ultrasound (>20 kHz) is used in imaging; infrasound (<20 Hz) in seismology.',
    worked='v = 343 m/s in air at 20°C\nEcho: distance = v × t/2 = 343 × 2/2 = 343 m',
    eng='Sonar, ultrasound imaging, noise cancellation, and concert hall acoustics all apply sound wave physics.',
    mistakes=['Assuming sound travels in a vacuum; confusing pitch with loudness; ignoring medium effects.'],
    practice=['Calculate the distance to a wall if an echo returns in 1 s (v = 343 m/s).', 'Why can\'t sound travel in space?'],
    quiz=[
        q('Sound is a ______ wave.', ['Transverse', 'Longitudinal', 'Electromagnetic', 'Standing'], [1], 'Longitudinal.'),
        q('Sound cannot travel through:', ['Water', 'Air', 'Steel', 'Vacuum'], [3], 'Vacuum.'),
    ])

lesson(14, 31, 'Electromagnetic Waves',
    concept='Electromagnetic waves are oscillating electric and magnetic fields propagating at light speed, spanning radio to gamma rays.',
    definition='Electromagnetic waves are waves of oscillating electric and magnetic fields that propagate through space at the speed of light.',
    explanation='EM waves need no medium. Spectrum: radio, microwave, infrared, visible, ultraviolet, X-ray, gamma. All travel at c = 3 × 10⁸ m/s in vacuum. Frequency determines type: radio (kHz) → gamma (EHz). Energy per photon: E = hf. Applications: communication, medicine, astronomy.',
    worked='c = fλ: 3×10⁸ = f × 0.1 → f = 3 GHz (Wi-Fi)\nE = hf: higher frequency = more energy per photon',
    eng='Wireless communication, medical X-rays, microwave ovens, and visible light are all electromagnetic waves.',
    mistakes=['Assuming EM waves need a medium; confusing frequency with energy per photon; ignoring the spectrum.'],
    practice=['Calculate the frequency of a 0.3 m wavelength wave.', 'What is the speed of light in vacuum?'],
    quiz=[
        q('EM waves travel at:', ['Sound speed', 'Light speed', 'Variable speed', 'Zero'], [1], 'c.'),
        q('EM waves require:', ['A medium', 'No medium', 'Air only', 'Water'], [1], 'No medium.'),
    ])

lesson(14, 32, 'Semiconductor Basics',
    concept='Semiconductors are materials with conductivity between conductors and insulators, controllable by doping and electric fields.',
    definition='A semiconductor is a material with electrical conductivity between that of a conductor and an insulator, modifiable by impurities (doping) and external fields.',
    explanation='Silicon is the dominant semiconductor. Pure (intrinsic) silicon has low conductivity. Doping adds impurities: N-type (extra electrons), P-type (extra holes). P-N junctions form diodes and transistors. Conductivity increases with temperature (opposite of metals).',
    worked='Si: 4 valence electrons, crystal lattice\nN-type: dopant with 5 electrons (phosphorus)\nP-type: dopant with 3 electrons (boron)',
    eng='Semiconductors enable all modern electronics: computers, phones, solar cells, LEDs.',
    mistakes=['Confusing semiconductors with conductors; assuming doping increases resistance; ignoring temperature effects.'],
    practice=['What is the most common semiconductor material?', 'What is doping?'],
    quiz=[
        q('The most common semiconductor is:', ['Germanium', 'Silicon', 'Gallium', 'Copper'], [1], 'Silicon.'),
    ])

lesson(14, 33, 'Diodes',
    concept='A diode is a semiconductor device allowing current in one direction, formed by a P-N junction.',
    definition='A diode is a two-terminal semiconductor device that conducts current primarily in one direction, formed by joining P-type and N-type materials.',
    explanation='The P-N junction creates a depletion region. Forward bias (P positive) reduces the barrier → current flows. Reverse bias widens it → blocks current. Forward voltage: ~0.7 V (Si). Applications: rectification, protection, LEDs, and solar cells.',
    worked='Forward: V > 0.7 V → conducts\nReverse: blocks until breakdown\nI-V curve: exponential forward, flat reverse',
    eng='Diodes are in every power supply; LEDs are efficient light sources; solar cells are large-area diodes.',
    mistakes=['Confusing diode direction; exceeding reverse voltage; ignoring forward voltage drop.'],
    practice=['What is the forward voltage of a silicon diode?', 'How does a P-N junction work?'],
    quiz=[
        q('A diode conducts in ______ direction(s).', ['Both', 'One', 'Neither', 'AC only'], [1], 'One.'),
        q('Silicon diode forward voltage is about:', ['0.3 V', '0.7 V', '1.5 V', '5 V'], [1], '0.7 V.'),
    ])

lesson(14, 34, 'Transistors',
    concept='A transistor is a semiconductor device that amplifies or switches signals, the building block of modern electronics.',
    definition='A transistor is a three-terminal semiconductor device used to amplify or switch electronic signals and electrical power.',
    explanation='BJT: current-controlled (base current → collector current). MOSFET: voltage-controlled (gate voltage → drain current). Transistors form logic gates, amplifiers, and memory. Billions fit on a single CPU chip. Moore\'s Law tracked transistor density doubling.',
    worked='BJT: IC = βIB\nMOSFET: VGS > Vth → conducts\nCMOS: complementary pairs for logic',
    eng='Transistors are the most manufactured artifact in history; they enable computers, phones, and the internet.',
    mistakes=['Confusing BJT with MOSFET control; assuming transistors are mechanical switches; ignoring power/heat.'],
    practice=['What are the two main transistor types?', 'What is a transistor used for?'],
    quiz=[
        q('A transistor can:', ['Only switch', 'Amplify and switch', 'Only amplify', 'Only store'], [1], 'Amplify + switch.'),
    ])

lesson(14, 35, 'Sensors',
    concept='Sensors convert physical quantities to electrical signals, enabling measurement and control in electronic systems.',
    definition='A sensor is a device that detects a physical stimulus and converts it into an electrical signal for measurement or control.',
    explanation='Sensors bridge physical and digital worlds. Types: temperature (thermistor, thermocouple), light (photodiode), pressure (piezoelectric), motion (accelerometer, gyro), proximity (IR, ultrasonic). Key specs: range, accuracy, resolution, response time, interface.',
    worked='Thermistor: R varies with T → voltage divider → ADC\nPhotodiode: current ∝ light → transimpedance amp → ADC',
    eng='Smartphones have 15+ sensors; cars have hundreds; IoT devices are built around sensors.',
    mistakes=['Ignoring accuracy specs; not calibrating; electrical noise without filtering.'],
    practice=['Name three sensor types and their quantities.', 'What is the difference between accuracy and resolution?'],
    quiz=[
        q('A sensor converts:', ['Electrical to physical', 'Physical to electrical', 'Digital to analog', 'AC to DC'], [1], 'Physical → electrical.'),
    ])

lesson(14, 36, 'Optics',
    concept='Optics studies light behavior: reflection, refraction, lenses, and fiber, enabling imaging, communication, and sensors.',
    definition='Optics is the branch of physics dealing with the properties and behavior of light, including its interactions with matter.',
    explanation='Reflection: angle of incidence = angle of reflection. Refraction: light bends between media (Snell\'s law: n₁sinθ₁ = n₂sinθ₂). Lenses focus light (cameras, eyes). Fiber optics guide light by total internal reflection. Diffraction and interference are wave phenomena.',
    worked='Snell\'s law: n₁sinθ₁ = n₂sinθ₂\nAir→glass: 1.0×sin(30°) = 1.5×sinθ₂ → θ₂ ≈ 19.5°',
    eng='Fiber optics carry the internet; cameras and microscopes use lenses; lasers use stimulated emission.',
    mistakes=['Confusing reflection with refraction; ignoring total internal reflection; assuming light always travels straight.'],
    practice=['State Snell\'s law.', 'What is total internal reflection?'],
    quiz=[
        q('Refraction is caused by:', ['Change in speed', 'Change in color', 'Change in intensity', 'Change in source'], [0], 'Speed change.'),
        q('Fiber optics guide light by:', ['Mirrors', 'Total internal reflection', 'Diffraction', 'Absorption'], [1], 'TIR.'),
    ])

lesson(14, 37, 'Thermal Physics',
    concept='Thermal physics studies heat, temperature, and energy transfer: conduction, convection, and radiation.',
    definition='Thermal physics is the study of heat, temperature, and the transfer of thermal energy through conduction, convection, and radiation.',
    explanation='Temperature measures average kinetic energy. Heat flows hot → cold. Conduction: through solids (k). Convection: through fluids (movement). Radiation: through EM waves (Stefan-Boltzmann: P = σAT⁴). Thermal expansion: materials expand when heated.',
    worked='P = σAT⁴: doubling T → 16× radiation\nConduction: Q/t = kAΔT/L',
    eng='Heat sinks cool electronics; insulation saves energy; thermal imaging detects radiation; engines convert heat to work.',
    mistakes=['Confusing temperature with heat; assuming radiation needs a medium; ignoring thermal expansion.'],
    practice=['What are the three heat transfer mechanisms?', 'What is the Stefan-Boltzmann law?'],
    quiz=[
        q('Heat transfer by radiation requires:', ['A medium', 'No medium', 'Water', 'Metal'], [1], 'No medium.'),
        q('Temperature measures:', ['Total energy', 'Average kinetic energy', 'Heat', 'Pressure'], [1], 'Average KE.'),
    ])

formula('Physics', 'Newton\'s Second Law', 'F = ma', 'F: force (N); m: mass (kg); a: acceleration (m/s²)', 'Dynamics')
formula('Physics', 'Kinetic Energy', 'KE = ½mv²', 'm: mass; v: velocity', 'Energy')
formula('Physics', 'Ohm\'s Law', 'V = IR', 'V: voltage; I: current; R: resistance', 'Circuits')
formula('Physics', 'Wave Speed', 'v = fλ', 'v: speed; f: frequency; λ: wavelength', 'Waves')

# ---------------- Engineering Mathematics (15 lessons) ----------------

lesson(15, 1, 'Algebra',
    concept='Algebra manipulates symbols and equations to solve for unknowns, the foundation of all engineering mathematics.',
    definition='Algebra is the branch of mathematics dealing with symbols and the rules for manipulating them to solve equations.',
    explanation='Algebra solves for unknowns using operations: addition, subtraction, multiplication, division, exponents, and roots. Linear equations (ax + b = c), quadratic equations (ax² + bx + c = 0), and systems of equations. Factoring, expanding, and simplifying expressions are core skills.',
    worked='2x + 6 = 14 → 2x = 8 → x = 4\nx² − 5x + 6 = 0 → (x−2)(x−3) = 0 → x = 2, 3',
    eng='Every engineering calculation — circuit analysis, structural loads, control systems — starts with algebra.',
    mistakes=['Sign errors; dividing by zero; not checking solutions; order of operations errors.'],
    practice=['Solve 3x − 7 = 11.', 'Factor x² − 9.'],
    quiz=[
        q('Solve 3x − 7 = 11:', ['x = 4', 'x = 6', 'x = 5', 'x = 7'], [1], 'x = 6.'),
        q('x² − 9 factors to:', ['(x−3)²', '(x−3)(x+3)', '(x−9)(x+1)', 'Prime'], [1], 'Difference of squares.'),
    ])

lesson(15, 2, 'Functions',
    concept='Functions map inputs to outputs, modeling relationships between engineering quantities.',
    definition='A function is a relation that assigns each input exactly one output, expressed as y = f(x).',
    explanation='Functions model engineering relationships: stress(strain), voltage(current), position(time). Types: linear, polynomial, exponential, logarithmic, trigonometric. Domain and range. Composition and inverses. Graphing reveals behavior.',
    worked='f(x) = 2x + 3: linear, slope 2, intercept 3\ng(x) = eˣ: exponential growth\nf(g(x)) = 2eˣ + 3 (composition)',
    eng='Transfer functions in control systems, response curves in dynamics, and characteristic curves in electronics are all functions.',
    mistakes=['Confusing functions with equations; ignoring domain restrictions; assuming all relations are functions.'],
    practice=['What is the domain of f(x) = √(x − 2)?', 'What is a function composition?'],
    quiz=[
        q('The domain of √(x − 2) is:', ['All reals', 'x ≥ 2', 'x ≤ 2', 'x = 2'], [1], 'x ≥ 2.'),
    ])

lesson(15, 3, 'Trigonometry',
    concept='Trigonometry relates angles and sides of triangles, essential for waves, rotations, and AC circuits.',
    definition='Trigonometry is the study of relationships between angles and sides of triangles, using functions sine, cosine, and tangent.',
    explanation='SOH-CAH-TOA: sin = opposite/hypotenuse, cos = adjacent/hypotenuse, tan = opposite/adjacent. Unit circle extends to all angles. Identities: sin² + cos² = 1. Applications: AC circuits (phasors), vibrations, navigation, and signal processing.',
    worked='sin(30°) = 0.5, cos(30°) = 0.866, tan(45°) = 1\nsin²(θ) + cos²(θ) = 1 for all θ',
    eng='AC circuit analysis uses phasors (rotating vectors); robotics uses trig for kinematics; FFT uses trig identities.',
    mistakes=['Confusing sin with cos; degree/radian mode errors; ignoring quadrant signs.'],
    practice=['What is sin(90°)?', 'State the Pythagorean identity.'],
    quiz=[
        q('sin(90°) =', ['0', '0.5', '1', 'Undefined'], [2], '1.'),
        q('sin²(θ) + cos²(θ) =', ['0', '1', 'θ', '2'], [1], '1.'),
    ])

lesson(15, 4, 'Complex Numbers',
    concept='Complex numbers extend real numbers with the imaginary unit i (√−1), essential for AC analysis and signal processing.',
    definition='A complex number is a number of the form a + bi, where a and b are real and i² = −1.',
    explanation='Complex numbers have real (a) and imaginary (b) parts. Operations: addition (component-wise), multiplication (using i² = −1), division (conjugate). Polar form: r∠θ or re^(iθ). Euler\'s formula: e^(iθ) = cos(θ) + i·sin(θ). Used in AC circuits, control theory, and Fourier analysis.',
    worked='(3 + 2i) + (1 + 4i) = 4 + 6i\n(3 + 2i)(1 + 4i) = 3 + 12i + 2i + 8i² = −5 + 14i',
    eng='AC impedance is complex (resistance + reactance); control systems analyze poles in the complex plane; FFT uses complex exponentials.',
    mistakes=['Forgetting i² = −1; confusing rectangular and polar forms; division without conjugate.'],
    practice=['Multiply (2 + 3i)(1 − i).', 'What is Euler\'s formula?'],
    quiz=[
        q('i² equals:', ['1', '−1', '0', 'i'], [1], '−1.'),
        q('Euler\'s formula: e^(iθ) =', ['cos(θ) + i·sin(θ)', 'sin(θ) + i·cos(θ)', 'cos(θ) − i·sin(θ)', 'e^θ'], [0], 'cos + i·sin.'),
    ])

lesson(15, 5, 'Matrices',
    concept='Matrices are rectangular arrays of numbers representing linear transformations and systems of equations.',
    definition='A matrix is a rectangular array of numbers arranged in rows and columns, used to represent and solve systems of linear equations.',
    explanation='Matrix operations: addition (element-wise), scalar multiplication, matrix multiplication (row × column), transpose, and inverse. Determinants test invertibility. Matrices solve Ax = b, represent transformations, and appear in structural analysis and machine learning.',
    worked='[1 2] × [5 6] = [1×5+2×7  1×6+2×8] = [19 22]\n       [3 4]   [7 8]   [3×5+4×7  3×6+4×8]   [43 50]',
    eng='Structural analysis uses stiffness matrices; computer graphics uses transformation matrices; neural networks are matrix operations.',
    mistakes=['Matrix multiplication is not commutative; dimension mismatches; assuming all matrices have inverses.'],
    practice=['Multiply [1 2; 3 4] × [5 6; 7 8].', 'What is a matrix determinant?'],
    quiz=[
        q('Matrix multiplication is:', ['Commutative', 'Not commutative', 'Always undefined', 'Element-wise'], [1], 'Not commutative.'),
    ])

lesson(15, 6, 'Determinants',
    concept='A determinant is a scalar computed from a square matrix, indicating invertibility and scaling factor of transformations.',
    definition='The determinant is a scalar value computed from a square matrix, zero if and only if the matrix is singular (non-invertible).',
    explanation='2×2: det = ad − bc. 3×3: cofactor expansion. Properties: det(AB) = det(A)det(B), det(A⁻¹) = 1/det(A). Determinants solve systems (Cramer\'s rule), find eigenvalues, and compute areas/volumes.',
    worked='det([a b; c d]) = ad − bc\ndet([1 2; 3 4]) = 4 − 6 = −2',
    eng='Determinants test structural stability; eigenvalues (from determinants) determine system behavior; Jacobian determinants in coordinate transforms.',
    mistakes=['Assuming all matrices have determinants (only square); sign errors in cofactor expansion; confusing determinant with trace.'],
    practice=['Calculate det([2 3; 1 4]).', 'What does det = 0 mean?'],
    quiz=[
        q('det([2 3; 1 4]) =', ['5', '11', '−5', '8'], [0], '8 − 3 = 5.'),
        q('det = 0 means the matrix is:', ['Invertible', 'Singular (non-invertible)', 'Identity', 'Symmetric'], [1], 'Singular.'),
    ])

lesson(15, 7, 'Vectors',
    concept='Vectors are quantities with magnitude and direction, represented as arrays, fundamental in physics and engineering.',
    definition='A vector is a mathematical object with magnitude and direction, represented as an ordered list of components.',
    explanation='Vectors add component-wise, scale by scalars, and combine via dot product (scalar) and cross product (vector). Magnitude: |v| = √(v·v). Unit vectors normalize. Vectors represent forces, velocities, fields, and positions in engineering.',
    worked='v = (3, 4), |v| = √(9+16) = 5\nu = v/|v| = (0.6, 0.8)\nDot: (3,4)·(1,2) = 3+8 = 11',
    eng='Force analysis, fluid flow, and electromagnetic fields are vector quantities; computer graphics transforms vertices as vectors.',
    mistakes=['Adding magnitudes instead of vectors; confusing dot and cross products; ignoring direction.'],
    practice=['Find the magnitude of (6, 8).', 'What is the dot product of (1, 2) and (3, 4)?'],
    quiz=[
        q('|(6, 8)| =', ['10', '14', '48', '100'], [0], '10.'),
        q('(1, 2)·(3, 4) =', ['11', '10', '7', '24'], [0], '11.'),
    ])

lesson(15, 8, 'Sequences',
    concept='A sequence is an ordered list of numbers following a pattern, with arithmetic and geometric types.',
    definition='A sequence is an ordered list of numbers where each term follows a specific rule or pattern.',
    explanation='Arithmetic: constant difference (aₙ = a₁ + (n−1)d). Geometric: constant ratio (aₙ = a₁·rⁿ⁻¹). Series: sum of sequence terms. Convergence: infinite series approaching a limit. Sequences model discrete processes and series approximate functions.',
    worked='Arithmetic: 2, 5, 8, 11... (d = 3)\naₙ = 2 + (n−1)·3 = 3n − 1\nGeometric: 3, 6, 12, 24... (r = 2)',
    eng='Geometric series model compound interest and signal decay; arithmetic sequences model linear growth; Taylor series approximate functions.',
    mistakes=['Confusing arithmetic with geometric; assuming all series converge; index errors.'],
    practice=['Find the 10th term of 3, 7, 11, 15...', 'What is the sum of 1 + 2 + 4 + 8 + 16?'],
    quiz=[
        q('The 10th term of 3, 7, 11, 15... is:', ['39', '40', '41', '43'], [0], '3 + 9×4 = 39.'),
        q('1 + 2 + 4 + 8 + 16 =', ['31', '32', '30', '63'], [0], '31.'),
    ])

lesson(15, 9, 'Series',
    concept='A series is the sum of sequence terms, with convergence tests and applications in approximation and analysis.',
    definition='A series is the sum of the terms of a sequence, finite or infinite, with convergence determining whether the sum is finite.',
    explanation='Arithmetic series: S = n(a₁ + aₙ)/2. Geometric: S = a₁(1 − rⁿ)/(1 − r). Infinite geometric converges if |r| < 1: S = a₁/(1 − r). Taylor series approximate functions: eˣ = 1 + x + x²/2! + ...',
    worked='1 + 2 + ... + 100 = 100(1+100)/2 = 5050\n1 + 1/2 + 1/4 + ... = 1/(1−1/2) = 2',
    eng='Taylor series approximate functions in computers; Fourier series decompose signals; geometric series model finance.',
    mistakes=['Assuming all series converge; misapplying formulas; index errors.'],
    practice=['What is the sum of 1 + 3 + 5 + ... + 99?', 'Does 1 + 2 + 4 + 8 + ... converge?'],
    quiz=[
        q('Sum of 1 + 3 + 5 + ... + 99 =', ['2500', '2550', '2450', '2600'], [0], '50² = 2500.'),
        q('1 + 2 + 4 + 8 + ...:', ['Converges to 2', 'Diverges', 'Converges to 1', 'Converges to 0'], [1], 'Diverges (r = 2 > 1).'),
    ])

lesson(15, 10, 'Differential Equations',
    concept='Differential equations relate functions to derivatives, modeling dynamic systems in engineering.',
    definition='A differential equation is an equation involving a function and its derivatives, describing how quantities change.',
    explanation='ODEs involve one independent variable; PDEs involve several. Order: highest derivative. First-order: dy/dx = f(x, y). Separation of variables, integrating factors. Second-order linear: ay\'\' + by\' + cy = 0 (characteristic equation).',
    worked='dy/dx = 2x → y = x² + C\ny\'\' + y = 0 → y = A·cos(x) + B·sin(x)',
    eng='Circuit analysis (RLC), control systems, vibrations, and heat transfer are all modeled with differential equations.',
    mistakes=['Confusing ODEs with PDEs; not applying initial conditions; integration errors.'],
    practice=['Solve dy/dx = 3x².', 'What is the order of y\'\' + 2y\' + y = 0?'],
    quiz=[
        q('dy/dx = 3x² has solution:', ['y = 3x + C', 'y = x³ + C', 'y = 6x + C', 'y = x² + C'], [1], 'x³ + C.'),
        q('The order of y\'\' + 2y\' + y = 0 is:', ['1', '2', '3', '0'], [1], '2.'),
    ])

lesson(15, 11, 'Probability',
    concept='Probability quantifies uncertainty, from 0 (impossible) to 1 (certain), with rules for combining events.',
    definition='Probability is the measure of the likelihood of an event, a number between 0 and 1.',
    explanation='P(event) = favorable outcomes / total outcomes. Rules: complement (P(not A) = 1 − P(A)), addition (P(A or B) = P(A) + P(B) − P(A and B)), multiplication (P(A and B) = P(A)·P(B) for independent). Conditional probability: P(A|B) = P(A and B)/P(B).',
    worked='Die: P(even) = 3/6 = 0.5\nTwo coins: P(both heads) = 0.5 × 0.5 = 0.25',
    eng='Reliability engineering uses probability for failure rates; communication uses it for error rates; machine learning is built on probability.',
    mistakes=['Assuming independence; confusing P(A and B) with P(A or B); ignoring sample space.'],
    practice=['What is the probability of rolling a 6 on a die?', 'Two coins: what is P(at least one head)?'],
    quiz=[
        q('P(rolling a 6) =', ['1/6', '1/2', '1/3', '6'], [0], '1/6.'),
        q('P(at least one head in two coins) =', ['0.25', '0.5', '0.75', '1'], [2], '1 − 0.25 = 0.75.'),
    ])

lesson(15, 12, 'Statistics',
    concept='Statistics collects, analyzes, and interprets data, using measures of central tendency and spread.',
    definition='Statistics is the science of collecting, organizing, analyzing, and interpreting data to make informed decisions.',
    explanation='Mean: average. Median: middle value. Mode: most frequent. Spread: variance (σ²), standard deviation (σ). Distributions: normal (bell curve). Sampling and hypothesis testing draw conclusions from data.',
    worked='Data: 2, 4, 4, 6, 8\nMean = 24/5 = 4.8\nMedian = 4, Mode = 4\nσ = √(Σ(x−μ)²/n)',
    eng='Quality control uses statistical process control; experimental design uses statistics; machine learning is statistical learning.',
    mistakes=['Confusing mean with median; ignoring outliers; assuming correlation implies causation.'],
    practice=['Find the mean of 3, 7, 8, 12.', 'What is the standard deviation?'],
    quiz=[
        q('Mean of 3, 7, 8, 12 =', ['7.5', '8', '7', '30'], [0], '30/4 = 7.5.'),
    ])

lesson(15, 13, 'Numerical Methods',
    concept='Numerical methods approximate solutions to mathematical problems that lack closed-form solutions.',
    definition='Numerical methods are algorithms for approximating solutions to mathematical problems using iterative and discrete techniques.',
    explanation='Root finding: bisection, Newton-Raphson. Integration: trapezoidal, Simpson\'s. ODEs: Euler, Runge-Kutta. Linear systems: Gaussian elimination. Errors: truncation (method) and roundoff (floating point). Computers make numerical methods practical.',
    worked='Newton-Raphson: xₙ₊₁ = xₙ − f(xₙ)/f\'(xₙ)\nFind √2: f(x) = x² − 2, x₀ = 1.5\nx₁ = 1.5 − 0.25/3 = 1.4167',
    eng='Engineering simulation (FEA, CFD) is numerical methods; circuit simulators (SPICE) solve nonlinear equations numerically.',
    mistakes=['Assuming numerical solutions are exact; not checking convergence; ignoring roundoff errors.'],
    practice=['What is the Newton-Raphson formula?', 'What is the difference between truncation and roundoff error?'],
    quiz=[
        q('Newton-Raphson finds:', ['Integrals', 'Roots of equations', 'Derivatives', 'Matrices'], [1], 'Roots.'),
    ])

lesson(15, 14, 'Linear Algebra',
    concept='Linear algebra studies vectors, matrices, and linear transformations, the mathematics of data and systems.',
    definition='Linear algebra is the branch of mathematics concerning linear equations, vector spaces, linear mappings, and matrices.',
    explanation='Core concepts: vector spaces, linear independence, basis, dimension, eigenvalues/eigenvectors, and orthogonality. Applications: solving systems, transformations, least squares, and diagonalization. Linear algebra underlies computer graphics, machine learning, and quantum mechanics.',
    worked='Eigenvalues: det(A − λI) = 0\nA = [2 1; 1 2]: λ² − 4λ + 3 = 0 → λ = 1, 3',
    eng='Machine learning (PCA, SVD), computer graphics (transformations), and control theory (state-space) are built on linear algebra.',
    mistakes=['Confusing eigenvalues with determinants; assuming all matrices diagonalize; dimension errors.'],
    practice=['What is an eigenvalue?', 'Find the eigenvalues of [2 1; 1 2].'],
    quiz=[
        q('Eigenvalues of [2 1; 1 2] are:', ['1 and 3', '2 and 2', '0 and 4', '−1 and 3'], [0], '1, 3.'),
    ])

lesson(15, 15, 'Engineering Applications',
    concept='Engineering mathematics integrates all topics — algebra, calculus, linear algebra, probability — to solve real engineering problems.',
    definition='Engineering mathematics applies mathematical methods to analyze, model, and solve engineering problems across all disciplines.',
    explanation='Integration: circuit analysis (differential equations), structural analysis (linear algebra), signal processing (Fourier), control systems (Laplace transforms), reliability (statistics), optimization (calculus). Mathematics is the universal language of engineering.',
    worked='RC circuit: RC·dV/dt + V = Vin (ODE)\nSolve: V(t) = Vin(1 − e^(−t/RC))',
    eng='Every engineering discipline is applied mathematics — the tools in this curriculum are used daily by practicing engineers.',
    mistakes=['Applying math without understanding the physics; ignoring units; not verifying results.'],
    practice=['Give three examples of engineering mathematics applications.', 'Why is mathematics called the language of engineering?'],
    quiz=[
        q('Differential equations model:', ['Static systems', 'Dynamic systems (circuits, vibrations)', 'Only geometry', 'Only statistics'], [1], 'Dynamic systems.'),
    ])

formula('Engineering Mathematics', 'Quadratic Formula', 'x = (−b ± √(b² − 4ac)) / 2a', 'a, b, c: coefficients', 'Solving quadratics')
formula('Engineering Mathematics', 'Euler\'s Formula', 'e^(iθ) = cos(θ) + i·sin(θ)', 'i: imaginary unit', 'Complex analysis')
formula('Engineering Mathematics', 'Dot Product', 'A·B = |A||B|cos(θ)', 'A, B: vectors', 'Vector analysis')
