"""Computer Architecture and Operating Systems curriculum content."""

from curriculum_base import lesson, q, formula, reference, subject

subject(6, 'Computer Architecture', 'Hardware',
        'CPU • Memory • Pipelining • Parallelism', 'memory')
subject(7, 'Operating Systems', 'Systems',
        'Processes • Scheduling • Memory • Filesystems', 'dns')

# ---------------- Computer Architecture (23 lessons) ----------------

lesson(6, 1, 'Introduction to Computer Architecture',
    concept='Computer architecture is the structure and organization of a computer system: the CPU, memory, and I/O, and how they interact.',
    definition='Computer architecture defines the functional behavior and physical organization of a computer system as seen by the programmer and hardware designer.',
    explanation='Computer architecture spans the instruction set (what the CPU can do), microarchitecture (how the CPU implements it), and system architecture (memory, buses, I/O). It determines performance, power, and cost. Key metrics: instructions per cycle (IPC), clock speed, and memory bandwidth.',
    worked='A CPU executes instructions: fetch from memory, decode the operation, execute in the ALU, write back the result. Architecture determines how efficiently this cycle runs.',
    eng='Processor designers at Intel, ARM, and Apple balance performance, power efficiency, and area when designing architectures for servers, mobile, and embedded markets.',
    mistakes='Confusing architecture (ISA) with microarchitecture (implementation); ignoring memory hierarchy effects; assuming clock speed alone determines performance.',
    practice=['What is the difference between architecture and microarchitecture?', 'What are the main components of a computer system?'],
    quiz=[
        q('What does ISA stand for?', ['Instruction Set Architecture', 'Internal System Arrangement', 'Integrated Signal Algorithm', 'International Standards Association'], [0], 'ISA is the Instruction Set Architecture.'),
        q('Which is NOT a main computer component?', ['CPU', 'Memory', 'Power supply unit', 'I/O system'], [2], 'The PSU is supporting infrastructure, not a core architectural component.'),
    ])

lesson(6, 2, 'Von Neumann Architecture',
    concept='The Von Neumann architecture stores both instructions and data in the same memory, with a single bus connecting CPU and memory.',
    definition='Von Neumann architecture is the stored-program design where instructions and data share one memory space, processed sequentially by a central processing unit.',
    explanation='Described by John von Neumann in 1945, this design uses a single memory for code and data, a CPU with an ALU and control unit, and sequential instruction processing. The "Von Neumann bottleneck" arises because instructions and data compete for the same bus. Harvard architecture separates instruction and data memory to avoid this.',
    worked='Memory: [instruction][instruction][data][data]\nCPU fetches instruction → decodes → executes → fetches next. The shared bus limits throughput to one transfer at a time.',
    eng='Most general-purpose computers (x86, ARM in unified mode) use Von Neumann design; microcontrollers often use Harvard architecture for simultaneous instruction and data access.',
    mistakes='Assuming Von Neumann and Harvard are the same; ignoring the bottleneck; thinking stored-program means code cannot change.',
    practice=['What is the Von Neumann bottleneck?', 'How does Harvard architecture differ?'],
    quiz=[
        q('In Von Neumann architecture, instructions and data are stored:', ['Separately', 'In the same memory', 'On disk', 'In registers only'], [1], 'Shared memory is the defining feature.'),
        q('What is the Von Neumann bottleneck?', ['CPU speed', 'Shared bus limiting data/instruction flow', 'Memory size', 'Power consumption'], [1], 'The shared bus limits throughput.'),
    ])

lesson(6, 3, 'CPU Components',
    concept='The CPU comprises the Arithmetic Logic Unit (ALU), Control Unit (CU), registers, and cache, coordinated by the clock.',
    definition='CPU components are the functional units that fetch, decode, and execute instructions: ALU for computation, CU for control, registers for fast storage.',
    explanation='The ALU performs arithmetic and logic operations. The CU directs operation by decoding instructions and generating control signals. Registers provide the fastest storage (1-cycle access). The clock synchronizes all operations. Modern CPUs add branch predictors, multiple execution units, and cache hierarchies.',
    worked='Registers: 32 × 64-bit general purpose (x86-64)\nALU: performs ADD, SUB, AND, OR in one clock cycle\nCU: sequences operations, manages the instruction pipeline',
    eng='CPU designers add execution units (FPUs, vector units, AI accelerators) to speed up specific workloads like graphics and machine learning.',
    mistakes='Thinking registers are part of main memory; ignoring the role of the clock; confusing ALU with CU.',
    practice=['What does the ALU do?', 'What is the role of the Control Unit?'],
    quiz=[
        q('Which unit performs arithmetic operations?', ['CU', 'ALU', 'Cache', 'RAM'], [1], 'The ALU computes.'),
        q('What do registers provide?', ['Permanent storage', 'Fastest storage', 'Network access', 'Display output'], [1], 'Registers are the fastest storage.'),
    ])

lesson(6, 4, 'ALU — Arithmetic Logic Unit',
    concept='The ALU performs arithmetic (add, subtract, multiply) and logic (AND, OR, XOR, shift) operations on binary data.',
    definition='The ALU is a digital circuit that computes arithmetic and logical operations on integer and, in modern CPUs, floating-point and vector data.',
    explanation='The ALU takes operands from registers, performs the selected operation, and outputs the result with status flags (zero, carry, overflow, negative). Modern ALUs are pipelined and duplicated for superscalar execution. SIMD units extend the ALU to process vectors in parallel.',
    worked='ADD R1, R2, R3  →  R1 = R2 + R3\nFlags set: Zero (result=0), Carry (overflow), Negative (sign bit)\nThe ALU executes this in one clock cycle (simple ops).',
    eng='GPUs contain thousands of ALUs optimized for parallel arithmetic, enabling the matrix operations that power machine learning.',
    mistakes='Assuming the ALU handles memory addresses (it doesn\'t — address calculation is separate); ignoring status flags; thinking ALU speed is the only performance factor.',
    practice=['What status flags does an ALU set?', 'What is SIMD?'],
    quiz=[
        q('Which operation does the ALU perform?', ['Branching', 'Arithmetic and logic', 'Memory allocation', 'Interrupt handling'], [1], 'The ALU computes arithmetic and logic.'),
        q('What does the Zero flag indicate?', ['Carry occurred', 'Result is zero', 'Overflow', 'Negative result'], [1], 'Zero flag means the result is zero.'),
    ])

lesson(6, 5, 'Control Unit',
    concept='The Control Unit directs CPU operation by decoding instructions and generating control signals that coordinate the ALU, registers, and memory.',
    definition='The Control Unit is the component that fetches instructions, decodes them, and generates the timing and control signals that execute them.',
    explanation='The CU implements the fetch-decode-execute cycle. Hardwired control uses fixed logic circuits (fast, inflexible); microcoded control stores control sequences in a control store (flexible, easier to modify). Modern CPUs use a hybrid approach with micro-op translation.',
    worked='Fetch: PC → memory → instruction register\nDecode: instruction → control signals\nExecute: signals drive ALU, registers, buses\nThe CU repeats this cycle for every instruction.',
    eng='Complex instruction sets (CISC) rely on microcoding to translate instructions into micro-ops; RISC designs use hardwired control for speed.',
    mistakes='Confusing the CU with the ALU; thinking the CU executes instructions (it directs them); ignoring microcode.',
    practice=['What is the difference between hardwired and microcoded control?', 'What does the PC stand for?'],
    quiz=[
        q('What does the Control Unit do?', ['Computes results', 'Directs and coordinates execution', 'Stores data', 'Manages power'], [1], 'The CU coordinates.'),
        q('What does PC stand for?', ['Program Counter', 'Processor Core', 'Personal Computer', 'Primary Cache'], [0], 'PC is the Program Counter.'),
    ])

lesson(6, 6, 'Registers',
    concept='Registers are the fastest storage locations in the CPU, holding operands, addresses, and status during instruction execution.',
    definition='Registers are small, high-speed storage locations within the CPU used to hold instructions, data, and addresses during processing.',
    explanation='Register types: general-purpose (operands), program counter (next instruction address), instruction register (current instruction), stack pointer, base pointer, and status/flags register. Register access is ~0.3 ns vs ~100 ns for RAM. CPUs rename registers dynamically to avoid hazards (register renaming).',
    worked='x86-64 registers: RAX, RBX, RCX, RDX (general)\nRSP (stack pointer), RBP (base pointer)\nRIP (instruction register), RFLAGS (status)\n16 general-purpose 64-bit registers.',
    eng='Register allocation is critical in compiler design — keeping frequently used variables in registers can double program speed.',
    mistakes='Assuming registers are unlimited; confusing registers with cache; ignoring register pressure in performance code.',
    practice=['Why are registers faster than RAM?', 'What is register renaming?'],
    quiz=[
        q('How many general-purpose registers does x86-64 have?', ['4', '8', '16', '32'], [2], 'x86-64 has 16 general-purpose registers.'),
        q('Which register holds the next instruction address?', ['RSP', 'RIP', 'RAX', 'RFLAGS'], [1], 'RIP is the instruction pointer.'),
    ])

lesson(6, 7, 'Instruction Cycle',
    concept='The instruction cycle (fetch-decode-execute) is the fundamental process the CPU repeats to run programs.',
    definition='The instruction cycle is the sequence of steps the CPU performs to execute one instruction: fetch from memory, decode, execute, and optionally write back.',
    explanation='Fetch: the PC address is placed on the address bus, memory returns the instruction, and the PC increments. Decode: the control unit interprets the instruction and sets control signals. Execute: the ALU performs the operation, data moves between registers and memory. Write back: results are stored to registers or memory.',
    worked='1. Fetch:  MAR ← PC; IR ← M[MAR]; PC ← PC + 4\n2. Decode: CU interprets IR\n3. Execute: ALU computes\n4. Write back: Register ← result',
    eng='Superscalar CPUs execute multiple instruction cycles in parallel per clock, and out-of-order execution reorders them for efficiency.',
    mistakes='Thinking instructions execute instantly; ignoring memory latency in the fetch step; confusing the instruction cycle with the clock cycle.',
    practice=['What are the steps of the instruction cycle?', 'What is the role of the PC?'],
    quiz=[
        q('What is the first step of the instruction cycle?', ['Decode', 'Fetch', 'Execute', 'Write back'], [1], 'Fetch comes first.'),
        q('What does the PC do during fetch?', ['Executes', 'Holds the next instruction address', 'Decodes', 'Stores results'], [1], 'The PC points to the next instruction.'),
    ])

lesson(6, 8, 'Machine Instructions',
    concept='Machine instructions are binary-encoded commands the CPU executes directly, each specifying an operation, operands, and addressing modes.',
    definition='A machine instruction is a binary pattern recognized by the CPU control unit that directs a specific operation on data.',
    explanation='An instruction has an opcode (operation: ADD, LOAD, JUMP) and operands (registers, memory addresses, immediate values). Addressing modes define how operands are interpreted: immediate (literal value), direct (memory address), indirect (address of address), register, and indexed. Instruction length varies (fixed in RISC, variable in CISC).',
    worked='ADD R1, R2, R3\nOpcode: ADD | Dest: R1 | Src1: R2 | Src2: R3\nBinary: 0001 0001 0010 0011 (simplified encoding)',
    eng='Compilers generate machine instructions from high-level code; understanding them helps optimize performance-critical routines.',
    mistakes='Confusing assembly (mnemonics) with machine code (binary); ignoring addressing modes; assuming all instructions take one cycle.',
    practice=['What is an opcode?', 'What is the difference between immediate and register addressing?'],
    quiz=[
        q('What does the opcode specify?', ['The operation', 'The memory address', 'The register number', 'The clock speed'], [0], 'The opcode names the operation.'),
        q('In immediate addressing, the operand is:', ['A register', 'A literal value', 'A memory address', 'An offset'], [1], 'Immediate means the value is in the instruction.'),
    ])

lesson(6, 9, 'Instruction Set Architecture',
    concept='The ISA is the interface between software and hardware: the set of instructions, registers, and data types a processor supports.',
    definition='Instruction Set Architecture is the programmer-visible interface of a processor: instructions, registers, addressing modes, and data types.',
    explanation='ISA defines what software can ask the hardware to do. Two major families: CISC (Complex Instruction Set Computing — x86, many instructions, variable length) and RISC (Reduced Instruction Set Computing — ARM, MIPS, fewer instructions, fixed length, load-store). The ISA is the contract: binaries compiled for one ISA do not run on another.',
    worked='RISC (ARM): ADD, SUB, LDR, STR — fixed 32-bit, load-store\nCISC (x86): thousands of instructions, variable length, memory operands\nSame program, different ISA → different machine code.',
    eng='Apple\'s M-series chips use ARM ISA for power efficiency; servers use x86 for software compatibility; RISC-V is the open-source ISA.',
    mistakes='Confusing ISA with microarchitecture; assuming RISC is always faster; thinking ISA changes break all software.',
    practice=['What is the difference between CISC and RISC?', 'Why does the ISA matter for software compatibility?'],
    quiz=[
        q('Which is a RISC architecture?', ['x86', 'ARM', '68000', 'Pentium'], [1], 'ARM is RISC.'),
        q('The ISA defines:', ['Physical layout', 'Programmer-visible interface', 'Clock speed', 'Cache size'], [1], 'ISA is the software-hardware contract.'),
    ])

lesson(6, 10, 'RISC vs CISC',
    concept='RISC uses simple, fixed-length instructions executed in one cycle; CISC uses complex, variable-length instructions that can perform multi-step operations.',
    definition='RISC (Reduced Instruction Set Computing) and CISC (Complex Instruction Set Computing) are two ISA philosophies trading instruction simplicity against code density.',
    explanation='RISC: small instruction set, fixed length, load-store architecture, most instructions complete in one cycle, relying on compilers for optimization. CISC: large instruction set, variable length, instructions can operate directly on memory, microcoded. Modern CPUs blur the line: x86 (CISC) translates to RISC-like micro-ops internally.',
    worked='RISC (ARM): 32-bit fixed instructions, 16 registers, load-store\nCISC (x86): 1–15 byte instructions, complex addressing\nARM dominates mobile (power); x86 dominates desktops (compatibility).',
    eng='RISC-V is gaining traction in embedded and research as an open, royalty-free ISA; Apple\'s ARM chips prove RISC can lead in performance too.',
    mistakes='Assuming RISC always beats CISC; ignoring the micro-op translation in modern x86; thinking CISC is obsolete.',
    practice=['What is a load-store architecture?', 'How do modern x86 CPUs blur the RISC/CISC line?'],
    quiz=[
        q('RISC instructions are typically:', ['Variable length', 'Fixed length', 'Always multi-cycle', 'Microcoded only'], [1], 'RISC uses fixed-length instructions.'),
        q('Which market does ARM (RISC) dominate?', ['Desktop', 'Mobile/embedded', 'Mainframes', 'Supercomputers only'], [1], 'ARM powers most mobile devices.'),
    ])

lesson(6, 11, 'Memory Hierarchy',
    concept='The memory hierarchy orders storage by speed and cost: registers, cache (L1/L2/L3), RAM, and disk, each level slower and larger than the last.',
    definition='The memory hierarchy is a structure of storage levels from fast, small, expensive registers and caches to slow, large, cheap disks, exploiting locality of reference.',
    explanation='Programs exhibit temporal locality (recently used data is reused) and spatial locality (nearby data is used soon). The hierarchy serves each access from the fastest level that contains the data. Cache hit rates of 95%+ make the hierarchy effective. Each level is a cache for the one below.',
    worked='Registers: 1 cycle, KB\nL1 cache: ~4 cycles, 32–64 KB\nL2: ~12 cycles, 256 KB–1 MB\nL3: ~40 cycles, 8–64 MB\nRAM: ~100 cycles, GB\nSSD: ~100,000 cycles, TB',
    eng='Game engines and databases are designed around the hierarchy: data-oriented design keeps hot data in cache lines for maximum speed.',
    mistakes='Ignoring cache effects in performance code; assuming RAM speed is uniform; not understanding locality.',
    practice=['What is temporal locality?', 'Why is cache faster than RAM?'],
    quiz=[
        q('Which is fastest?', ['RAM', 'L1 cache', 'SSD', 'Registers'], [3], 'Registers are fastest.'),
        q('Spatial locality means:', ['Recent reuse', 'Nearby data used soon', 'Predictable access', 'Random access'], [1], 'Spatial locality is about nearby addresses.'),
    ])

lesson(6, 12, 'Cache Memory',
    concept='Cache is a small, fast memory that stores frequently accessed data from main memory, organized in lines with mapping strategies.',
    definition='Cache memory is a high-speed storage layer between the CPU and main memory that reduces average memory access time by serving repeated accesses locally.',
    explanation='Cache is organized in lines (typically 64 bytes). Mapping strategies: direct-mapped (each memory block maps to one line), set-associative (a set of lines), and fully associative (any line). Replacement policies (LRU, FIFO) evict lines when full. Write policies: write-through (update both) and write-back (update cache, write later).',
    worked='Hit: data found in cache (~4 cycles)\nMiss: fetch from RAM (~100 cycles), store in cache\nEffective access time = hit_time + miss_rate × miss_penalty\nWith 95% hit rate: 4 + 0.05 × 100 = 9 cycles average.',
    eng='CPU-bound applications optimize for cache: matrix multiplication is tiled to fit in L1, linked lists are replaced with arrays for spatial locality.',
    mistakes='Ignoring cache line size; poor data layout causing false sharing; assuming cache is transparent.',
    practice=['What is a cache hit vs miss?', 'What is the difference between write-through and write-back?'],
    quiz=[
        q('What is a cache miss?', ['Data found', 'Data not found, must fetch from RAM', 'Cache full', 'CPU idle'], [1], 'A miss requires fetching from main memory.'),
        q('Which replacement policy evicts the least recently used line?', ['FIFO', 'LRU', 'Random', 'MRU'], [1], 'LRU evicts least recently used.'),
    ])

lesson(6, 13, 'RAM — Random Access Memory',
    concept='RAM is the main volatile memory where running programs and data reside, organized as addressable cells with nanosecond access times.',
    definition='RAM (Random Access Memory) is volatile primary storage that provides fast, uniform access to any memory location for the CPU.',
    explanation='DRAM (Dynamic RAM) stores each bit in a capacitor that leaks charge, requiring periodic refresh. SRAM (Static RAM) uses flip-flops — faster, used in cache. RAM is volatile: contents lose on power-off. Memory is organized in a matrix of rows and columns; access involves row activation and column sensing.',
    worked='DRAM: 1 bit = 1 capacitor + 1 transistor, refreshed every ~64 ms\nSRAM: 1 bit = 6 transistors, no refresh, ~10× faster\nDDR4 RAM: ~25 GB/s bandwidth, ~100 ns latency',
    eng='Servers use ECC RAM to detect and correct bit flips; embedded systems use SRAM for deterministic, low-latency access.',
    mistakes='Confusing RAM with storage (SSD); assuming all RAM is the same (DRAM vs SRAM); ignoring memory bandwidth.',
    practice=['Why does DRAM need refreshing?', 'What is the difference between DRAM and SRAM?'],
    quiz=[
        q('Why does DRAM need refresh cycles?', ['Heat', 'Capacitors leak charge', 'Clock sync', 'Power saving'], [1], 'Charge leaks from capacitors.'),
        q('Which type of RAM is used in CPU cache?', ['DRAM', 'SRAM', 'Flash', 'ROM'], [1], 'SRAM is fast enough for cache.'),
    ])

lesson(6, 14, 'ROM — Read-Only Memory',
    concept='ROM is non-volatile memory storing firmware and boot code that persists without power, including PROM, EPROM, EEPROM, and flash.',
    definition='ROM (Read-Only Memory) is non-volatile storage that retains data without power, used for firmware, bootloaders, and embedded program storage.',
    explanation='ROM types: mask ROM (factory-programmed), PROM (one-time programmable), EPROM (UV-erasable), EEPROM (electrically erasable), and flash (block-erasable, the most common today). Flash dominates firmware storage in phones, SSDs, and microcontrollers. ROM provides the code that runs at power-on before the OS loads.',
    worked='Boot process: ROM/flash → bootloader → OS kernel → applications\nEEPROM: byte-wise erase, used for calibration data\nFlash: block erase, used for firmware and SSDs',
    eng='Microcontrollers store program code in internal flash; firmware updates rewrite flash in the field over the air (OTA).',
    mistakes='Confusing ROM with RAM; thinking ROM cannot be updated (flash can); ignoring write endurance limits of flash.',
    practice=['What is the difference between EEPROM and flash?', 'Where is ROM used in a computer?'],
    quiz=[
        q('Which ROM type is electrically erasable byte-wise?', ['PROM', 'EEPROM', 'Mask ROM', 'DRAM'], [1], 'EEPROM erases electrically per byte.'),
        q('ROM is:', ['Volatile', 'Non-volatile', 'Faster than RAM', 'Written constantly'], [1], 'ROM retains data without power.'),
    ])

lesson(6, 15, 'Virtual Memory',
    concept='Virtual memory gives each process a private address space, mapping virtual addresses to physical memory via pages, managed by the MMU and OS.',
    definition='Virtual memory is a memory management technique that provides each process with a contiguous virtual address space, backed by physical RAM and disk storage.',
    explanation='The CPU generates virtual addresses; the MMU (Memory Management Unit) translates them to physical addresses using page tables. Pages (typically 4 KB) map to frames in RAM. When RAM is full, pages swap to disk (swap file). Processes are isolated: one process cannot access another\'s memory. TLB caches translations for speed.',
    worked='Virtual address → page number + offset\nPage table lookup → frame number\nPhysical address = frame number + offset\nTLB hit: ~1 cycle; TLB miss: page table walk (~100 cycles)',
    eng='Operating systems use virtual memory to run more programs than RAM can hold and to isolate processes for security.',
    mistakes='Assuming virtual memory is only for "more RAM"; ignoring page faults; confusing virtual addresses with physical.',
    practice=['What is a page fault?', 'What does the TLB do?'],
    quiz=[
        q('What is a page fault?', ['A crash', 'Accessing a page not in RAM', 'A cache miss', 'A power failure'], [1], 'A page fault loads a page from disk.'),
        q('What does the TLB cache?', ['Data', 'Virtual-to-physical translations', 'Instructions', 'File handles'], [1], 'TLB caches address translations.'),
    ])

lesson(6, 16, 'Bus Architecture',
    concept='Buses are communication pathways connecting CPU, memory, and I/O: data bus (transfers data), address bus (selects location), and control bus (coordinates).',
    definition='A bus is a shared communication system that transfers data between computer components, consisting of data, address, and control lines.',
    explanation='The data bus width determines how many bits transfer at once (e.g., 64-bit). The address bus width determines addressable memory (32-bit = 4 GB, 64-bit = 16 EB). The control bus carries read/write signals, clock, and interrupts. Modern systems use point-to-point links (PCIe, USB) alongside traditional buses.',
    worked='32-bit address bus → 2^32 = 4 GB addressable\n64-bit data bus → 8 bytes per transfer\nBuses are shared: one transfer at a time per bus',
    eng='PCIe lanes scale bandwidth for GPUs and NVMe SSDs; embedded systems use I2C, SPI, and CAN buses for peripherals.',
    mistakes='Confusing bus width with speed; assuming buses are unlimited bandwidth; ignoring bus arbitration.',
    practice=['What does the address bus determine?', 'What is the difference between a bus and a point-to-point link?'],
    quiz=[
        q('The address bus width determines:', ['Speed', 'Addressable memory size', 'Data per transfer', 'Power'], [1], 'Address bus width sets address space.'),
        q('Which is a modern point-to-point interconnect?', ['PCI', 'PCIe', 'ISA', 'Front-side bus'], [1], 'PCIe uses point-to-point links.'),
    ])

lesson(6, 17, 'I/O Architecture',
    concept='I/O architecture manages data flow between the CPU and peripherals via interrupts, DMA, and device drivers.',
    definition='I/O architecture is the set of mechanisms — controllers, buses, interrupts, and DMA — that connect the CPU to input/output devices.',
    explanation='Programmed I/O has the CPU poll device status (wasteful). Interrupt-driven I/O lets devices signal readiness. DMA (Direct Memory Access) lets peripherals transfer data directly to memory without CPU involvement, freeing the CPU. Device drivers abstract hardware specifics for the OS.',
    worked='Interrupt: device → CPU → save context → ISR → restore\nDMA: device ↔ memory directly, CPU only starts and is notified on completion',
    eng='High-performance networking and storage rely on DMA and interrupt coalescing to sustain millions of operations per second.',
    mistakes='Polling when interrupts fit; not using DMA for large transfers; ignoring interrupt latency.',
    practice='What is DMA and why is it important?',
    quiz=[
        q('What does DMA allow?', ['CPU polling', 'Direct device-to-memory transfer', 'Wireless networking', 'Display rendering'], [1], 'DMA bypasses the CPU for transfers.'),
        q('An interrupt signals:', ['Power on', 'Device needs attention', 'Program end', 'Error only'], [1], 'Interrupts notify the CPU.'),
    ])

lesson(6, 18, 'Pipelining',
    concept='Pipelining overlaps instruction execution stages (fetch, decode, execute, memory, write-back) so multiple instructions are in flight simultaneously, increasing throughput.',
    definition='Pipelining is a technique that divides instruction execution into stages, allowing concurrent processing of multiple instructions to improve CPU throughput.',
    explanation='Like an assembly line: while instruction 1 executes, instruction 2 decodes and instruction 3 fetches. Ideal speedup equals the number of stages (5-stage pipeline → up to 5×). Hazards (data, control, structural) stall the pipeline. Modern CPUs use 10–20+ stage pipelines with out-of-order execution.',
    worked='Without pipeline: 5 instructions × 5 cycles = 25 cycles\nWith 5-stage pipeline: 5 + 4 = 9 cycles (theoretical)\nSpeedup = 25/9 ≈ 2.8× (limited by hazards)',
    eng='Deep pipelines (Intel NetBurst) traded clock speed for branch misprediction penalties; modern designs balance depth and efficiency.',
    mistakes='Assuming pipelining reduces latency (it increases throughput, not single-instruction latency); ignoring hazards; thinking more stages always help.',
    practice=['What is a pipeline hazard?', 'Does pipelining reduce single-instruction latency?'],
    quiz=[
        q('Pipelining primarily improves:', ['Single-instruction speed', 'Throughput', 'Memory capacity', 'Power efficiency'], [1], 'Pipelining increases throughput.'),
        q('How many stages does a classic RISC pipeline have?', ['3', '5', '10', '20'], [1], 'Classic RISC: 5 stages.'),
    ])

lesson(6, 19, 'Hazards',
    concept='Pipeline hazards are conflicts that prevent the next instruction from executing: data hazards (dependencies), control hazards (branches), and structural hazards (resource conflicts).',
    definition='A pipeline hazard is any condition that causes a stall or incorrect execution in an instruction pipeline.',
    explanation='Data hazard: an instruction needs a result not yet computed (solved by forwarding/bypassing or stalling). Control hazard: branch outcome unknown (solved by prediction, speculation, or delay slots). Structural hazard: two instructions need the same resource (solved by duplicating resources or stalling).',
    worked='ADD R1, R2, R3\nSUB R4, R1, R5   ← needs R1 (data hazard)\nForward R1 from ADD\'s execute stage to SUB\'s execute stage → no stall',
    eng='Branch predictors in modern CPUs achieve >95% accuracy, making deep pipelines viable; mispredictions flush 10–20 instructions.',
    mistakes='Assuming hazards only affect performance slightly; ignoring control hazards in branchy code; not understanding forwarding.',
    practice=['What is the difference between a data and control hazard?', 'How does forwarding work?'],
    quiz=[
        q('A data hazard occurs when:', ['Two instructions need the same hardware', 'An instruction depends on an incomplete result', 'A branch is taken', 'Cache misses'], [1], 'Dependencies cause data hazards.'),
        q('Branch prediction addresses which hazard?', ['Data', 'Control', 'Structural', 'None'], [1], 'Branches cause control hazards.'),
    ])

lesson(6, 20, 'CPU Performance',
    concept='CPU performance is governed by the performance equation: execution time = instructions × CPI × clock cycle time, improved by parallelism and better ISAs.',
    definition='CPU performance is measured by execution time, determined by instruction count, cycles per instruction (CPI), and clock cycle time.',
    explanation='The iron law: Time = Instructions × CPI × CycleTime. Reduce any factor to improve speed: fewer instructions (better compiler/ISA), lower CPI (pipelining, cache), or shorter cycles (higher clock, though power limits this). Amdahl\'s Law limits speedup from parallelism: speedup is bounded by the serial fraction.',
    worked='Program: 1 billion instructions, CPI = 1.5, 3 GHz\nTime = 1e9 × 1.5 / 3e9 = 0.5 seconds\nHalving CPI → 0.25 seconds (2× speedup)',
    eng='Performance engineering profiles to find bottlenecks: reducing instructions (algorithm), CPI (cache-friendly code), or clock (process technology).',
    mistakes='Focusing only on clock speed; ignoring Amdahl\'s Law; assuming more cores always help.',
    practice='What is Amdahl\'s Law?',
    quiz=[
        q('CPU performance depends on:', ['Clock speed only', 'Instructions × CPI × cycle time', 'Cache size only', 'Bus width only'], [1], 'The iron law of processor performance.'),
        q('Amdahl\'s Law states speedup is limited by:', ['Memory', 'The serial fraction', 'Clock speed', 'Core count'], [1], 'Serial portions bound parallel speedup.'),
    ])

lesson(6, 21, 'Parallel Processing',
    concept='Parallel processing executes multiple operations simultaneously using multiple cores, SIMD instructions, or distributed systems.',
    definition='Parallel processing is the simultaneous execution of computation across multiple processing units to solve problems faster.',
    explanation='Levels of parallelism: bit-level (wider words), instruction-level (pipelining, superscalar), data-level (SIMD/GPU), thread-level (multicore), and task-level (distributed). Challenges: Amdahl\'s Law limits, synchronization overhead, load balancing, and communication costs. Flynn\'s taxonomy classifies architectures: SISD, SIMD, MISD, MIMD.',
    worked='Dual-core: two instructions streams, two cores (MIMD)\nSIMD: one instruction, multiple data (GPU shader)\nSpeedup limited by serial fraction per Amdahl\'s Law',
    eng='Machine learning training uses thousands of GPU cores in parallel; supercomputers use MPI across nodes for distributed parallelism.',
    mistakes='Assuming linear speedup with cores; ignoring synchronization costs; not balancing load.',
    practice=['What is Flynn\'s taxonomy?', 'Why doesn\'t doubling cores double speed?'],
    quiz=[
        q('SIMD stands for:', ['Single Instruction Multiple Data', 'Sequential Instruction Multiple Data', 'Single Interface Memory Device', 'Synchronized Inter-Module Data'], [0], 'SIMD: one instruction, many data.'),
        q('What limits parallel speedup?', ['Power', 'Amdahl\'s Law serial fraction', 'Memory', 'All of the above'], [3], 'Multiple factors limit speedup.'),
    ])

lesson(6, 22, 'Multicore Processors',
    concept='Multicore processors integrate multiple CPU cores on one chip, sharing memory and cache, enabling thread-level parallelism.',
    definition='A multicore processor is a single chip containing two or more independent processing cores that execute instructions concurrently.',
    explanation='Cores share L3 cache, memory controllers, and the system bus. Advantages: better throughput per watt than higher clocks, natural parallelism. Challenges: cache coherence (keeping shared data consistent), thread scheduling, and software that can use multiple threads. Cache coherence protocols (MESI) track line states.',
    worked='MESI states: Modified (dirty, exclusive), Exclusive (clean, exclusive), Shared (clean, multiple), Invalid\nWhen core A writes a shared line, other cores\' copies invalidate.',
    eng='Phones use heterogeneous multicore (big.LITTLE): high-performance cores for demanding tasks, efficiency cores for background work.',
    mistakes='Assuming all code parallelizes; ignoring cache coherence costs; not pinning threads to cores.',
    practice=['What is cache coherence?', 'What is heterogeneous multicore?'],
    quiz=[
        q('What does cache coherence ensure?', ['Speed', 'Consistency of shared data across cores', 'Security', 'Power saving'], [1], 'Cores see consistent data.'),
        q('big.LITTLE architecture combines:', ['CPUs and GPUs', 'High-performance and efficiency cores', 'RAM and cache', 'Cores and FPGA'], [1], 'big.LITTLE mixes core types.'),
    ])

lesson(6, 23, 'GPU Architecture',
    concept='GPUs use thousands of simple cores optimized for parallel data processing, excelling at graphics, machine learning, and scientific computing.',
    definition='GPU (Graphics Processing Unit) architecture is a many-core design optimized for executing the same operation on many data elements simultaneously (SIMT).',
    explanation='GPUs contain thousands of smaller, simpler cores organized into streaming multiprocessors. They hide memory latency with massive parallelism (running many threads). SIMT (Single Instruction Multiple Threads) executes warps of 32 threads in lockstep. GPUs offer 10–100× throughput for parallel workloads but require data-parallel algorithms.',
    worked='CPU: 8 powerful cores, optimized for serial tasks\nGPU: 5000 simple cores, optimized for parallel tasks\nMatrix multiplication: GPU wins by 50× on large matrices',
    eng='AI training, scientific simulation, and cryptocurrency mining all exploit GPU parallelism; CUDA and OpenCL program GPUs as compute devices.',
    mistakes='Using GPUs for serial workloads; ignoring CPU-GPU transfer overhead; assuming all code parallelizes.',
    practice=['What is SIMT?', 'Why are GPUs faster than CPUs for matrix operations?'],
    quiz=[
        q('GPUs are optimized for:', ['Serial tasks', 'Parallel data processing', 'Single-thread speed', 'Low power'], [1], 'GPUs excel at parallelism.'),
        q('What is a warp in CUDA?', ['A CPU instruction', '32 threads executing in lockstep', 'A memory unit', 'A cache line'], [1], 'Warps are groups of 32 threads.'),
    ])

formula('Computer Architecture', 'CPU Performance', 'Time = Instructions × CPI × CycleTime', 'CPI: cycles per instruction', 'Performance analysis')
formula('Computer Architecture', 'Amdahl\'s Law', 'Speedup = 1 / ((1 - P) + P/S)', 'P: parallel fraction; S: parallel speedup', 'Parallel computing limits')
formula('Computer Architecture', 'Cache Effective Access', 'EAT = hit_time + miss_rate × miss_penalty', 'EAT: effective access time', 'Cache performance')

# ---------------- Operating Systems (22 lessons) ----------------

lesson(7, 1, 'Introduction to Operating Systems',
    concept='An operating system is system software that manages hardware resources and provides services for applications.',
    definition='An operating system (OS) is software that acts as an intermediary between computer hardware and user applications, managing resources and providing common services.',
    explanation='The OS manages the CPU (scheduling), memory (allocation), storage (file systems), and I/O (device drivers). It provides abstractions (processes, virtual memory, files) so applications need not handle hardware directly. Examples: Linux, Windows, macOS, Android, iOS, and real-time OSes (FreeRTOS).',
    worked='Without an OS: each program controls hardware directly\nWith the OS: programs request services (files, memory, CPU time) through system calls',
    eng='Embedded devices run real-time OSes (FreeRTOS, Zephyr) that guarantee deterministic timing for control systems.',
    mistakes='Confusing the OS with applications; thinking the OS is only for PCs; ignoring the kernel\'s role.',
    practice=['What services does an OS provide?', 'What is the difference between an OS and an application?'],
    quiz=[
        q('The OS acts as:', ['An application', 'An intermediary between hardware and apps', 'A programming language', 'A database'], [1], 'The OS manages resources for apps.'),
        q('Which is a real-time OS?', ['Windows', 'FreeRTOS', 'macOS', 'Ubuntu Desktop'], [1], 'FreeRTOS is real-time.'),
    ])

lesson(7, 2, 'OS Functions',
    concept='Core OS functions include process management, memory management, file systems, I/O management, and security.',
    definition='OS functions are the resource management and service responsibilities of an operating system.',
    explanation='Process management creates, schedules, and terminates processes. Memory management allocates and tracks RAM. File systems organize persistent storage. I/O management controls devices through drivers. Security enforces access control, authentication, and isolation. The OS also handles networking, interrupts, and power management.',
    worked='System call flow: app → OS kernel → hardware → result → app\nExample: read() → kernel → disk controller → data → app',
    eng='Automotive OSes (QNX) add safety certification and deterministic response times for brake and steering systems.',
    mistakes='Thinking apps access hardware directly; ignoring the kernel; assuming all OSes have the same functions.',
    practice=['What is a system call?', 'List five OS functions.'],
    quiz=[
        q('Applications access hardware through:', ['Directly', 'System calls to the OS kernel', 'The BIOS only', 'Cloud APIs'], [1], 'System calls mediate hardware access.'),
        q('Which is an OS function?', ['Web browsing', 'Memory management', 'Word processing', 'Gaming'], [1], 'Memory management is an OS function.'),
    ])

lesson(7, 3, 'Kernel',
    concept='The kernel is the core of the OS, running in privileged mode with direct hardware access, managing resources and system calls.',
    definition='The kernel is the central, privileged component of an operating system that controls all hardware and system resources.',
    explanation='The kernel runs in kernel mode (privileged, full hardware access) while applications run in user mode (restricted). Kernel types: monolithic (Linux — all services in kernel space), microkernel (Minix — minimal kernel, services as processes), hybrid (Windows), and exokernel (minimal, libraries handle more). The kernel handles scheduling, memory, drivers, and system calls.',
    worked='User app calls read() → trap to kernel mode → kernel serves → return to user mode\nMode bit in CPU enforces privilege separation',
    eng='Linux powers Android, servers, and embedded devices; its monolithic design with loadable modules balances performance and flexibility.',
    mistakes='Confusing the kernel with the whole OS; thinking user apps can access hardware; ignoring the user/kernel mode distinction.',
    practice=['What is the difference between kernel mode and user mode?', 'What is a microkernel?'],
    quiz=[
        q('The kernel runs in:', ['User mode', 'Kernel mode (privileged)', 'Safe mode', 'Virtual mode'], [1], 'The kernel has full privileges.'),
        q('Which kernel type does Linux use?', ['Microkernel', 'Monolithic', 'Exokernel', 'None'], [1], 'Linux is monolithic.'),
    ])

lesson(7, 4, 'Processes',
    concept='A process is a running program with its own memory space, resources, and execution state, managed by the OS.',
    definition='A process is an instance of a program in execution, with its own address space, registers, and system resources.',
    explanation='A process contains the program code, data, heap, and stack. The OS tracks each in a Process Control Block (PCB): PID, state, registers, memory limits, open files. Processes are isolated; communication requires IPC (pipes, sockets, shared memory). The OS schedules processes onto the CPU.',
    worked='PCB contents: PID, process state, PC, registers, memory info, open files\nContext switch: save current PCB, load next — costs ~1–10 μs',
    eng='Servers run thousands of processes; container technologies (Docker) isolate processes with namespaces and cgroups.',
    mistakes='Confusing a process with a program; ignoring process isolation; not understanding context switch costs.',
    practice=['What is the difference between a process and a program?', 'What is a PCB?'],
    quiz=[
        q('A process is:', ['A program on disk', 'A program in execution', 'A file', 'A thread'], [1], 'Process = running program.'),
        q('The PCB contains:', ['Source code', 'Process state and context', 'User data only', 'Network packets'], [1], 'PCB holds process metadata.'),
    ])

lesson(7, 5, 'Threads',
    concept='A thread is the smallest unit of execution within a process, sharing the process\'s memory but running independently.',
    definition='A thread is a lightweight execution unit within a process that shares the process address space but has its own stack and registers.',
    explanation='Threads share code, data, and heap but have separate stacks and registers. Benefits: parallelism on multicore, responsiveness (UI thread vs worker). Challenges: race conditions, deadlocks, and synchronization (mutexes, semaphores). Green threads (user-level) vs kernel threads (OS-scheduled).',
    worked='Process: 1 address space\nThreads: N stacks, N register sets, shared heap\nRace condition: two threads update a counter without locking → lost updates',
    eng='Web servers handle requests with thread pools; games use threads for rendering, physics, and AI concurrently.',
    mistakes='Assuming threads are processes; ignoring race conditions; over-threading small tasks.',
    practice=['What do threads share?', 'What is a race condition?'],
    quiz=[
        q('Threads within a process share:', ['Nothing', 'Code and data (address space)', 'Only registers', 'Only the stack'], [1], 'Threads share the address space.'),
        q('A race condition occurs when:', ['Threads run too fast', 'Concurrent access causes incorrect results', 'Memory runs out', 'The OS crashes'], [1], 'Unsynchronized access causes races.'),
    ])

lesson(7, 6, 'Process States',
    concept='A process moves through states: new, ready, running, waiting, and terminated, as the OS scheduler allocates the CPU.',
    definition='Process states describe the lifecycle of a process as managed by the OS scheduler: new, ready, running, waiting (blocked), and terminated.',
    explanation='New: being created. Ready: waiting for CPU. Running: executing on CPU. Waiting: blocked for an event (I/O). Terminated: finished. The scheduler transitions processes: running → ready (time slice expired), running → waiting (I/O request), waiting → ready (event completed).',
    worked='new → ready → running → waiting → ready → running → terminated\nThe OS scheduler decides which ready process runs next.',
    eng='Real-time OSes add priority to states: a high-priority process preempts a running low-priority one immediately.',
    mistakes='Assuming a process is always running; ignoring waiting states; confusing ready with running.',
    practice=['What triggers a running → waiting transition?', 'What is the difference between ready and running?'],
    quiz=[
        q('A process waiting for I/O is in which state?', ['Ready', 'Running', 'Waiting', 'Terminated'], [2], 'Blocked processes are waiting.'),
        q('Which state waits for the CPU?', ['New', 'Ready', 'Waiting', 'Terminated'], [1], 'Ready processes await the CPU.'),
    ])

lesson(7, 7, 'Process Scheduling',
    concept='Process scheduling decides which ready process runs next, using algorithms like FCFS, SJF, Round Robin, and Priority to optimize throughput, latency, and fairness.',
    definition='Process scheduling is the OS activity of selecting the next ready process for CPU execution according to a scheduling algorithm.',
    explanation='Schedulers optimize: CPU utilization, throughput, turnaround time, waiting time, and response time. Preemptive scheduling can interrupt running processes (Round Robin); non-preemptive lets them finish. Multi-level queue and multi-level feedback queues combine strategies. This app includes a CPU scheduling simulator for hands-on learning.',
    worked='Metrics:\nTurnaround = completion − arrival\nWaiting = turnaround − burst\nResponse = first run − arrival',
    eng='Linux uses the Completely Fair Scheduler (CFS); real-time systems use rate-monotonic and EDF scheduling for deadline guarantees.',
    mistakes='Assuming one algorithm fits all; ignoring convoy effects; not measuring scheduling metrics.',
    practice=['What is the difference between preemptive and non-preemptive scheduling?', 'What is response time?'],
    quiz=[
        q('Which metric measures time from arrival to completion?', ['Waiting', 'Turnaround', 'Response', 'Burst'], [1], 'Turnaround includes execution.'),
        q('Preemptive scheduling:', ['Lets processes finish', 'Can interrupt running processes', 'Only runs one process', 'Is always fair'], [1], 'Preemption interrupts.'),
    ])

lesson(7, 8, 'FCFS — First Come First Served',
    concept='FCFS runs processes in arrival order, non-preemptively — simple but suffers the convoy effect where short jobs wait behind long ones.',
    definition='FCFS is a non-preemptive scheduling algorithm that executes processes in the order they arrive.',
    explanation='FCFS is the simplest scheduler: a FIFO queue. Average waiting time can be poor if a long job arrives first (convoy effect). It is starvation-free — every process eventually runs. Use the simulator in this app to compare FCFS waiting times against other algorithms.',
    worked='Processes: P1(0, 24), P2(1, 3), P3(2, 3)\nFCFS order: P1, P2, P3\nWaiting: P1=0, P2=23, P3=25 → avg = 16\nSJF would give avg = 3.33',
    eng='Batch processing systems use FCFS variants; interactive systems avoid it for its poor response time.',
    mistakes='Assuming FCFS is fair for all workloads; ignoring the convoy effect; confusing arrival order with priority.',
    practice=['What is the convoy effect?', 'Is FCFS preemptive?'],
    quiz=[
        q('FCFS is:', ['Preemptive', 'Non-preemptive', 'Priority-based', 'Random'], [1], 'FCFS never interrupts.'),
        q('The convoy effect describes:', ['Fast processes speeding up', 'Short jobs waiting behind long ones', 'CPU overheating', 'Memory leaks'], [1], 'Short jobs queue behind long ones.'),
    ])

lesson(7, 9, 'SJF — Shortest Job First',
    concept='SJF runs the shortest job next, giving the minimum average waiting time, but requires knowing burst times and can starve long jobs.',
    definition='SJF is a non-preemptive scheduling algorithm that selects the process with the shortest burst time from the ready queue.',
    explanation='SJF is provably optimal for average waiting time. Drawbacks: burst times must be known in advance (estimated via exponential averaging), and long jobs may starve if short jobs keep arriving. Its preemptive variant is SRTF (Shortest Remaining Time First).',
    worked='Processes: P1(0, 6), P2(2, 2), P3(4, 8)\nSJF order: P1 (only one at t=0), P2 (shorter than P3), P3\nWaiting: P1=0, P2=4, P3=6 → avg = 3.33',
    eng='Batch job schedulers use SJF principles to minimize average turnaround; Linux CFS approximates it with virtual runtime.',
    mistakes='Assuming SJF works without burst time estimates; ignoring starvation; confusing SJF with SRTF.',
    practice=['Why is SJF optimal?', 'What is SRTF?'],
    quiz=[
        q('SJF minimizes:', ['Response time', 'Average waiting time', 'CPU usage', 'Memory'], [1], 'SJF is optimal for average waiting time.'),
        q('A major drawback of SJF is:', ['Complexity', 'Starvation of long jobs', 'High overhead', 'Non-determinism'], [1], 'Long jobs may starve.'),
    ])

lesson(7, 10, 'SRTF — Shortest Remaining Time First',
    concept='SRTF is the preemptive version of SJF: the job with the least remaining time runs, and new short jobs preempt running ones.',
    definition='SRTF is a preemptive scheduling algorithm that always executes the process with the shortest remaining burst time.',
    explanation='SRTF improves on SJF by preempting when a shorter job arrives. It offers the best average waiting time among preemptive algorithms but causes more context switches. Starvation of long jobs remains possible. Simulate SRTF in this app to see preemption in the Gantt chart.',
    worked='P1(0, 8) starts; P2(1, 4) arrives → preempts P1\nP2 runs 1–5; P3(2, 1) arrives → runs 5–6\nP2 resumes 6–9; P1 resumes 9–13',
    eng='General-purpose OSes use SRTF-like behavior (CFS) to keep interactive response times low.',
    mistakes='Confusing SRTF with SJF; ignoring context switch overhead; assuming no starvation.',
    practice=['How does SRTF differ from SJF?', 'What is the cost of preemption?'],
    quiz=[
        q('SRTF is:', ['Non-preemptive', 'Preemptive', 'Priority-based', 'Round-based'], [1], 'SRTF preempts.'),
        q('SRTF selects the process with:', ['Earliest arrival', 'Shortest remaining time', 'Highest priority', 'Largest burst'], [1], 'Least remaining time wins.'),
    ])

lesson(7, 11, 'Round Robin',
    concept='Round Robin gives each process a fixed time quantum in circular order, ensuring fairness and good response time at the cost of context switch overhead.',
    definition='Round Robin is a preemptive scheduling algorithm that assigns each process a fixed time slice (quantum) in cyclic order.',
    explanation='Each process runs for at most the quantum, then moves to the back of the ready queue. Small quanta give good response time but increase context switch overhead; large quanta approximate FCFS. A quantum of 10–100 ms is typical. RR is fair — no starvation — and works well for time-sharing systems.',
    worked='Quantum = 4: P1(0,5), P2(0,3), P3(0,1)\nOrder: P1(0-4), P2(4-7), P3(7-8), P1(8-9)\nAll complete; response times are small.',
    eng='Time-sharing OSes (early Unix) pioneered Round Robin; modern schedulers use slices with dynamic quanta.',
    mistakes='Choosing quanta without considering context switch cost; assuming RR minimizes waiting time; ignoring that RR is not deadline-aware.',
    practice=['What happens if the quantum is too large?', 'Why is RR fair?'],
    quiz=[
        q('Round Robin is:', ['Non-preemptive', 'Preemptive with fixed time slices', 'Priority-based', 'Deadlock-prone'], [1], 'RR uses time slices.'),
        q('A very large quantum makes RR behave like:', ['SJF', 'FCFS', 'Priority', 'SRTF'], [1], 'Large quantum ≈ FCFS.'),
    ])

lesson(7, 12, 'Priority Scheduling',
    concept='Priority Scheduling runs the highest-priority process first, with static or dynamic priorities, risking starvation without aging.',
    definition='Priority Scheduling is a scheduling algorithm that selects the process with the highest priority from the ready queue.',
    explanation='Each process has a priority (number or class). The scheduler picks the highest-priority ready process. Can be preemptive or non-preemptive. Starvation of low-priority processes is mitigated by aging: priorities increase the longer a process waits. Priority inversion (low-priority holds a lock needed by high-priority) is solved by priority inheritance.',
    worked='Priorities: P1=3, P2=1, P3=2 (1 = highest)\nOrder: P2, P3, P1\nAging: after 10 waits, P1\'s priority increases',
    eng='Real-time systems assign priorities by deadline (EDF) or rate (RMS); Linux uses nice values and real-time priorities (SCHED_FIFO).',
    mistakes='Ignoring starvation; static priorities that never adapt; priority inversion without inheritance.',
    practice=['What is aging?', 'What is priority inversion?'],
    quiz=[
        q('Priority Scheduling selects:', ['The oldest process', 'The highest-priority process', 'The shortest job', 'A random process'], [1], 'Highest priority runs.'),
        q('Aging prevents:', ['Deadlock', 'Starvation of low-priority processes', 'Memory leaks', 'Context switches'], [1], 'Aging boosts waiting processes.'),
    ])

lesson(7, 13, 'Synchronization',
    concept='Synchronization coordinates concurrent access to shared data using mutexes, semaphores, and monitors to prevent race conditions.',
    definition='Synchronization is the coordination of concurrent processes or threads to ensure correct, deterministic access to shared resources.',
    explanation='A critical section is code accessing shared data. Mutual exclusion ensures only one thread enters at a time. Mutexes provide locking (lock/unlock). Semaphores count resources (acquire/release). Monitors encapsulate shared data with built-in locking. Problems: deadlock, livelock, and starvation if used incorrectly.',
    worked='Mutex:\npthread_mutex_lock(&mutex);\n// critical section\npthread_mutex_unlock(&mutex);\nSemaphore: wait() decrements, signals when zero; signal() increments.',
    eng='Database engines use fine-grained locking and MVCC for concurrent access; embedded systems use mutexes in RTOS kernels.',
    mistakes='Forgetting to unlock; locking too much (serialization); lock ordering violations causing deadlock.',
    practice=['What is a critical section?', 'What is the difference between a mutex and a semaphore?'],
    quiz=[
        q('A mutex provides:', ['Counting', 'Mutual exclusion', 'Scheduling', 'Memory allocation'], [1], 'Mutexes lock critical sections.'),
        q('A semaphore differs from a mutex by:', ['Being faster', 'Counting available resources', 'Using less memory', 'Being kernel-only'], [1], 'Semaphores count resources.'),
    ])

lesson(7, 14, 'Deadlocks',
    concept='A deadlock occurs when processes each hold resources the others need, forming a circular wait that blocks all progress.',
    definition='A deadlock is a state where a set of processes is blocked, each waiting for a resource held by another in the set.',
    explanation='Four necessary conditions (Coffman): mutual exclusion, hold and wait, no preemption, and circular wait. Handling: prevention (eliminate a condition), avoidance (Banker\'s algorithm — safe states), detection (resource allocation graphs + recovery), or ignoring (ostrich algorithm, used by many OSes).',
    worked='P1 holds R1, wants R2\nP2 holds R2, wants R1\n→ circular wait → deadlock\nPrevention: require all resources upfront (no hold and wait)',
    eng='Databases detect deadlocks via wait-for graphs and abort the youngest transaction; distributed systems use timeouts.',
    mistakes='Assuming deadlocks are rare and ignoring them; not using timeouts on locks; acquiring locks in inconsistent orders.',
    practice='What are the four Coffman conditions?',
    quiz=[
        q('Deadlock requires how many conditions?', ['1', '2', '4', '8'], [2], 'Four Coffman conditions.'),
        q('The Banker\'s algorithm is used for:', ['Detection', 'Avoidance', 'Prevention', 'Ignoring'], [1], 'It avoids unsafe states.'),
    ])

lesson(7, 15, 'Memory Management',
    concept='OS memory management allocates and tracks RAM for processes, using paging or segmentation to provide isolation and virtual memory.',
    definition='Memory management is the OS function of allocating, tracking, and reclaiming main memory among competing processes.',
    explanation='Each process gets a logical address space. The OS maps logical to physical addresses. Contiguous allocation suffers external fragmentation. Paging divides memory into fixed pages, eliminating external fragmentation. Segmentation divides by logical units (code, data, stack) with variable sizes. Modern systems combine both (segmented paging).',
    worked='Physical memory: frames of 4 KB\nLogical memory: pages of 4 KB\nPage table maps pages → frames\nNo external fragmentation; small internal fragmentation',
    eng='Linux uses a 4-level page table on x86-64; embedded MMUs support simpler 2-level tables for deterministic lookup.',
    mistakes='Confusing logical and physical addresses; assuming memory is contiguous; ignoring fragmentation.',
    practice=['What is the difference between paging and segmentation?', 'What is external fragmentation?'],
    quiz=[
        q('Paging divides memory into:', ['Variable segments', 'Fixed-size pages', 'Logical units', 'Blocks of 1 MB'], [1], 'Pages are fixed-size.'),
        q('External fragmentation occurs in:', ['Paging', 'Contiguous allocation', 'Segmentation with paging', 'Virtual memory'], [1], 'Contiguous allocation fragments.'),
    ])

lesson(7, 16, 'Paging',
    concept='Paging maps fixed-size logical pages to physical frames via a page table, eliminating external fragmentation and enabling virtual memory.',
    definition='Paging is a memory management scheme that divides logical memory into pages and physical memory into frames, mapping between them via a page table.',
    explanation='Pages and frames are typically 4 KB. The MMU translates virtual addresses: page number indexes the page table, offset locates the byte within the frame. Page tables can be huge (64-bit systems use multi-level tables). The TLB caches translations. Page faults occur when a page is not in RAM and must be loaded from disk.',
    worked='Virtual address (32-bit): 20-bit page number + 12-bit offset\nPage table: page number → frame number\nPhysical address = frame number × 4096 + offset',
    eng='Operating systems use demand paging and page replacement (LRU, clock) to manage limited RAM across many processes.',
    mistakes='Ignoring TLB misses; assuming page tables are single-level; not understanding page fault handling.',
    practice=['What is a page table?', 'What happens on a page fault?'],
    quiz=[
        q('The MMU translates using:', ['Segment table', 'Page table', 'File table', 'Process table'], [1], 'Page tables map pages to frames.'),
        q('A page fault triggers:', ['Process termination', 'Loading the page from disk', 'CPU shutdown', 'Context switch'], [1], 'The OS loads the missing page.'),
    ])

lesson(7, 17, 'Segmentation',
    concept='Segmentation divides memory into variable-sized logical units (code, data, stack, heap) that match program structure, with segment tables for translation.',
    definition='Segmentation is a memory management scheme that divides a process\'s address space into variable-sized segments, each with a base and limit.',
    explanation='Segments reflect logical divisions: code, data, stack, heap. Each has a base address and length in the segment table. Translation: logical (segment, offset) → physical (base + offset), with bounds checking. Advantages: natural protection and sharing (share a code segment). Disadvantages: external fragmentation from variable sizes.',
    worked='Segment table:\n0: base=1400, limit=1000 (code)\n1: base=3400, limit=500  (data)\nLogical (1, 200) → physical 3600',
    eng='x86 architecture supports segmentation (largely historical); embedded systems use MPU regions similar to segments for protection.',
    mistakes='Confusing segments with pages; ignoring bounds checks; assuming segmentation eliminates fragmentation.',
    practice=['What is the difference between a segment and a page?', 'What problem does segmentation solve?'],
    quiz=[
        q('Segments are sized:', ['Fixed', 'Variable', 'Always 4 KB', 'Always 1 MB'], [1], 'Segments vary in size.'),
        q('Segmentation reflects:', ['Hardware', 'Program logical structure', 'Network layout', 'File system'], [1], 'Segments match code/data structure.'),
    ])

lesson(7, 18, 'Virtual Memory',
    concept='Virtual memory gives each process a large, private address space backed by RAM and disk, with demand paging and page replacement.',
    definition='Virtual memory is a memory management technique that provides an abstraction of large, contiguous memory by mapping virtual addresses to physical RAM and disk.',
    explanation='Processes use virtual addresses; the OS and MMU map them to physical frames. Demand paging loads pages only when accessed. When RAM is full, the OS selects victims (LRU, clock algorithm) and swaps them to disk. Thrashing occurs when paging dominates execution. Benefits: isolation, larger-than-RAM programs, and simplified allocation.',
    worked='Working set: pages a process actively uses\nIf working set > available frames → thrashing\nSolution: add RAM or reduce multiprogramming',
    eng='Modern OSes use virtual memory for copy-on-write (fork), memory-mapped files, and transparent huge pages.',
    mistakes='Assuming virtual memory is free (disk is 1000× slower); ignoring thrashing; not understanding working sets.',
    practice=['What is demand paging?', 'What is thrashing?'],
    quiz=[
        q('Virtual memory allows programs to use:', ['Less memory than installed', 'More memory than physically installed', 'Only RAM', 'No storage'], [1], 'Virtual memory exceeds physical RAM.'),
        q('Thrashing is caused by:', ['Too much CPU', 'Excessive paging', 'Too many threads', 'Network congestion'], [1], 'Paging overhead dominates.'),
    ])

lesson(7, 19, 'File Systems',
    concept='A file system organizes, names, and manages persistent storage, tracking files, directories, and free space on disk.',
    definition='A file system is the OS subsystem that controls how data is stored, organized, and retrieved on storage devices.',
    explanation='File systems provide files (named data) and directories (hierarchy). They track metadata (size, permissions, timestamps) and free space (bitmaps). Structures: inodes (Unix), FAT tables, NTFS master file tables. Operations: create, read, write, delete, rename. Journaling (ext4, NTFS) ensures consistency after crashes.',
    worked='File: name → inode → data blocks\ninode: permissions, size, timestamps, block pointers\nDirectory: map of names to inode numbers',
    eng='Flash file systems (F2FS, exFAT) optimize for SSD wear leveling; embedded systems use littlefs for wear resilience.',
    mistakes='Confusing files with file systems; assuming writes are atomic; ignoring fragmentation.',
    practice=['What is an inode?', 'What is journaling?'],
    quiz=[
        q('A file system manages:', ['CPU scheduling', 'Persistent storage organization', 'Network packets', 'Process creation'], [1], 'File systems organize storage.'),
        q('An inode contains:', ['File name only', 'File metadata and block pointers', 'Directory structure only', 'Free space map'], [1], 'Inodes hold metadata.'),
    ])

lesson(7, 20, 'I/O Systems',
    concept='The I/O system manages device communication through device drivers, interrupts, and buffering, abstracting hardware diversity.',
    definition='The I/O system is the OS subsystem that controls input/output devices via drivers, interrupt handlers, and buffering mechanisms.',
    explanation='Devices connect via buses (USB, PCIe, SATA). Device drivers translate OS requests into device-specific commands. Interrupts signal completion. Buffering smooths speed differences. DMA transfers data without CPU involvement. Block devices (disks) transfer blocks; character devices (keyboards) transfer bytes.',
    worked='Read request: app → OS → driver → device\nDevice interrupts → OS wakes waiting process\nDMA: device ↔ memory directly',
    eng='Storage drivers (NVMe) use deep queues and interrupts to sustain millions of IOPS; embedded drivers handle UART, SPI, I2C.',
    mistakes='Polling instead of interrupts; ignoring DMA; assuming all devices are the same type.',
    practice=['What is a device driver?', 'What is the difference between block and character devices?'],
    quiz=[
        q('A device driver:', ['Is the device', 'Translates OS requests to device commands', 'Is the bus', 'Is the application'], [1], 'Drivers abstract hardware.'),
        q('Which is a block device?', ['Keyboard', 'Mouse', 'SSD', 'Serial port'], [2], 'SSDs transfer blocks.'),
    ])

lesson(7, 21, 'System Calls',
    concept='system calls are the interface between user applications and the OS kernel, providing controlled access to hardware and services.',
    definition='A system call is a controlled entry point into the kernel that allows user-mode programs to request privileged operations.',
    explanation='User programs cannot access hardware directly. System calls (read, write, open, fork, exec, mmap) trap into kernel mode, where the OS validates and performs the request. The C library (glibc) wraps system calls in portable functions. System calls are expensive (~1 μs) due to mode switching and context save/restore.',
    worked='Application: read(fd, buf, count)\n→ glibc wrapper → syscall instruction → kernel\n→ kernel reads device → copies data → returns',
    eng='strace traces system calls for debugging; seccomp filters them for sandboxing (containers, browsers).',
    mistakes='Calling system calls directly from apps; ignoring their cost; not checking return values.',
    practice=['Why are system calls needed?', 'What happens during a system call?'],
    quiz=[
        q('System calls provide:', ['Direct hardware access', 'Controlled kernel services', 'Faster execution', 'Compilation'], [1], 'System calls mediate privileged ops.'),
        q('A system call switches the CPU to:', ['User mode', 'Kernel mode', 'Sleep mode', 'Virtual mode'], [1], 'System calls trap to kernel mode.'),
    ])

lesson(7, 22, 'Linux Basics',
    concept='Linux is a monolithic Unix-like OS kernel powering servers, Android, and embedded devices, with a rich command-line ecosystem.',
    definition='Linux is an open-source operating system kernel (with GNU tools forming a complete OS) that manages hardware and provides Unix APIs.',
    explanation='Linux manages processes (CFS scheduler), memory (paging, NUMA), filesystems (ext4, Btrfs, XFS), and devices. The shell (bash) provides command-line control. Package managers (apt, dnf) install software. Linux dominates servers (96%+ of cloud), Android, and embedded (routers, TVs). Permissions, processes, and everything-is-a-file are core concepts.',
    worked='Core commands:\nls — list files\ncd — change directory\ncat — view file\nps — list processes\nchmod — change permissions',
    eng='Android is Linux-based; routers run OpenWrt; supercomputers run Linux; embedded devices run Buildroot/Yocto Linux.',
    mistakes='Running as root unnecessarily; ignoring permissions; not updating systems.',
    practice=['What is the Linux kernel?', 'What does "everything is a file" mean?'],
    quiz=[
        q('Linux is:', ['An application', 'An OS kernel', 'A programming language', 'A database'], [1], 'Linux is a kernel.'),
        q('Which command lists running files?', ['ps', 'ls', 'cat', 'chmod'], [1], 'ls lists directory contents.'),
    ])

formula('Operating Systems', 'Turnaround Time', 'T_turn = T_completion − T_arrival', 'T: time in seconds', 'Scheduling metrics')
formula('Operating Systems', 'Waiting Time', 'T_wait = T_turnaround − T_burst', 'T: time in seconds', 'Scheduling metrics')
formula('Operating States', 'Little\'s Law', 'L = λ × W', 'L: average items; λ: arrival rate; W: average wait', 'Queueing theory')
