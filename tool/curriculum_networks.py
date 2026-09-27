"""Computer Networks and Digital Logic curriculum content."""

from curriculum_base import lesson, q, formula, reference, subject

subject(8, 'Computer Networks', 'Networking',
        'OSI • TCP/IP • IP • Subnetting • Security', 'lan')
subject(9, 'Digital Logic', 'Hardware',
        'Gates • Boolean • K-Maps • Flip-Flops', 'account_tree')

# ---------------- Computer Networks (25 lessons) ----------------

lesson(8, 1, 'Introduction to Networking',
    concept='A computer network connects devices to share resources and communicate, using protocols that define rules for data exchange.',
    definition='A computer network is a collection of interconnected devices that exchange data using communication protocols over shared media.',
    explanation='Networks enable resource sharing (files, printers), communication (email, messaging), and distributed computing. They range from LANs (a home) to WANs (the Internet). Protocols — agreed rules — govern addressing, routing, and reliable delivery. Key network devices: switches (LAN), routers (between networks), and access points (wireless).',
    worked='Your phone → Wi-Fi AP → router → ISP → Internet\nEach hop uses protocols: Wi-Fi (802.11), Ethernet, IP, TCP',
    eng='Data centers interconnect thousands of servers with high-speed Ethernet; the Internet backbone moves terabits per second.',
    mistakes='Confusing the Internet with a network; assuming all networks use the same protocol; ignoring the physical layer.',
    practice=['What is a network protocol?', 'What devices connect networks together?'],
    quiz=[
        q('A network connects devices to:', ['Print only', 'Share resources and communicate', 'Charge batteries', 'Cool CPUs'], [1], 'Networks share resources.'),
        q('Which device connects different networks?', ['Switch', 'Router', 'Hub', 'Repeater'], [1], 'Routers interconnect networks.'),
    ])

lesson(8, 2, 'Network Types',
    concept='Network types by scale: PAN, LAN, MAN, WAN — each covering different geographical ranges with different technologies.',
    definition='Network types classify networks by geographical coverage: Personal, Local, Metropolitan, and Wide Area Networks.',
    explanation='PAN (Bluetooth, ~10 m) connects personal devices. LAN (Ethernet, Wi-Fi, ~100 m–1 km) covers a home or office. MAN (city-scale, ~5–50 km) connects LANs across a campus or city. WAN (the Internet, global) connects networks worldwide. The Internet is the largest WAN.',
    worked='PAN: phone ↔ earbuds (Bluetooth)\nLAN: home Wi-Fi\nMAN: university campus network\nWAN: Internet (ISP backbone)',
    eng='5G networks blur MAN/WAN boundaries with edge computing placing compute close to users for low latency.',
    mistakes='Assuming LAN means wireless; confusing WAN with the Internet (the Internet is a WAN); ignoring PAN.',
    practice=['What is the difference between LAN and WAN?', 'Give an example of a PAN.'],
    quiz=[
        q('A network covering a city is a:', ['PAN', 'LAN', 'MAN', 'WAN'], [2], 'MAN covers metropolitan areas.'),
        q('The Internet is an example of a:', ['LAN', 'MAN', 'WAN', 'PAN'], [2], 'The Internet is a WAN.'),
    ])

lesson(8, 3, 'Network Topologies',
    concept='Network topology is the arrangement of nodes and links: bus, star, ring, mesh, and tree — each with trade-offs in cost, reliability, and performance.',
    definition='Network topology is the physical or logical layout of nodes and connections in a network.',
    explanation='Bus: all nodes share one cable (cheap, single point of failure). Star: nodes connect to a central switch (most common, easy to manage). Ring: nodes form a loop (token passing). Mesh: every node connects to every other (maximum redundancy, expensive). Tree: hierarchical stars (scalable). Modern LANs use star topology with switches.',
    worked='Star topology: PC1 — Switch — PC2, PC3, PC4\nFailure of the switch takes down the LAN; failure of one PC affects only that PC.',
    eng='Data centers use leaf-spine (mesh variant) topologies for non-blocking east-west traffic between servers.',
    mistakes='Confusing physical and logical topology; assuming mesh is always best; ignoring cable failures in bus.',
    practice=['What is the most common LAN topology?', 'What is the advantage of mesh topology?'],
    quiz=[
        q('The most common modern LAN topology is:', ['Bus', 'Star', 'Ring', 'Mesh'], [1], 'Star dominates with switches.'),
        q('Which topology has the highest redundancy?', ['Bus', 'Star', 'Ring', 'Mesh'], [3], 'Full mesh maximizes paths.'),
    ])

lesson(8, 4, 'OSI Model',
    concept='The OSI model is a 7-layer reference framework for network communication: Physical, Data Link, Network, Transport, Session, Presentation, Application.',
    definition='The OSI (Open Systems Interconnection) model is a conceptual framework that standardizes network functions into seven abstraction layers.',
    explanation='Each layer serves the layer above and is served by the layer below. Layer 1 (Physical): bits over media. Layer 2 (Data Link): frames, MAC addresses, switches. Layer 3 (Network): packets, IP addresses, routers. Layer 4 (Transport): segments, TCP/UDP, ports. Layers 5–7 (Session, Presentation, Application): connections, encryption/formatting, and user protocols like HTTP.',
    worked='Sending an email:\nHTTP (7) → TLS encrypts (6) → TCP segments (4) → IP packets (3) → Ethernet frames (2) → bits (1)',
    eng='Network engineers troubleshoot layer by layer: check cables (1), MAC addresses (2), IP connectivity (3), ports (4), then applications (7).',
    mistakes='Confusing OSI with TCP/IP model; thinking all layers are hardware; skipping layers in troubleshooting.',
    practice=['What does each OSI layer do?', 'Which layer do routers operate at?'],
    quiz=[
        q('Which layer routes IP packets?', ['Data Link', 'Network', 'Transport', 'Physical'], [1], 'Layer 3 routes.'),
        q('Switches operate at which layer?', ['Physical', 'Data Link', 'Network', 'Transport'], [1], 'Switches use MAC addresses (Layer 2).'),
    ])

lesson(8, 5, 'TCP/IP Model',
    concept='The TCP/IP model is the practical 4-layer framework of the Internet: Network Access, Internet, Transport, and Application.',
    definition='The TCP/IP model is a concise, implementation-focused networking framework with four layers that maps to the OSI model.',
    explanation='Layer 1 (Network Access): combines OSI physical and data link (Ethernet, Wi-Fi). Layer 2 (Internet): IP addressing and routing. Layer 3 (Transport): TCP (reliable) and UDP (fast). Layer 4 (Application): HTTP, DNS, SSH, and all user protocols. TCP/IP is what the Internet actually runs on.',
    worked='Web browsing: HTTP (Application) → TCP (Transport) → IP (Internet) → Ethernet (Network Access)',
    eng='Every Internet-connected device implements TCP/IP; it is the universal protocol suite of the modern world.',
    mistakes='Treating TCP/IP and OSI as competing standards (TCP/IP implements, OSI references); confusing TCP with IP.',
    practice=['How does TCP/IP map to OSI?', 'What is the difference between TCP and UDP?'],
    quiz=[
        q('The TCP/IP model has how many layers?', ['4', '5', '7', '8'], [0], 'TCP/IP has 4 layers.'),
        q('IP operates at which TCP/IP layer?', ['Transport', 'Internet', 'Application', 'Network Access'], [1], 'IP is the Internet layer.'),
    ])

lesson(8, 6, 'Ethernet',
    concept='Ethernet is the dominant wired LAN technology, using frames with MAC addresses to deliver data within a local network.',
    definition='Ethernet is a family of wired networking technologies that defines frame formats and MAC addressing for local area networks.',
    explanation='Ethernet frames contain destination and source MAC addresses, a type field, payload, and error checking (CRC). Speeds: 10 Mbps (legacy), 100 Mbps (Fast), 1 Gbps (Gigabit), 10/25/40/100 Gbps (modern). Switches learn MAC addresses and forward frames only to the intended port, creating separate collision domains.',
    worked='Frame: [Dest MAC (6B)][Src MAC (6B)][Type (2B)][Payload (46–1500B)][CRC (4B)]\nSwitch MAC table: port → MAC, learned from source addresses',
    eng='Data centers deploy 100 Gbps Ethernet; automotive Ethernet (100BASE-T1) connects cameras and ECUs in cars.',
    mistakes='Assuming Ethernet is wireless (that\'s Wi-Fi); confusing MAC with IP addresses; thinking hubs are switches.',
    practice=['What address does Ethernet use?', 'What is the difference between a hub and a switch?'],
    quiz=[
        q('Ethernet delivers data using:', ['IP addresses', 'MAC addresses', 'Port numbers', 'URLs'], [1], 'Ethernet frames use MAC addresses.'),
        q('Modern Ethernet speeds include:', ['10 Mbps', '1 Gbps', '100 Gbps', 'All of the above'], [3], 'Ethernet scales from 10 Mbps to 100+ Gbps.'),
    ])

lesson(8, 7, 'MAC Addresses',
    concept='A MAC address is a unique 48-bit hardware identifier assigned to a network interface, used for Layer 2 delivery.',
    definition='A MAC (Media Access Control) address is a 48-bit identifier burned into a network interface card, formatted as six hex pairs.',
    explanation='The first 24 bits identify the manufacturer (OUI); the last 24 bits are the device serial. MAC addresses operate at Layer 2 for local delivery: switches use them to forward frames. MAC addresses can be changed in software (spoofing). ARP resolves IP addresses to MAC addresses on a LAN.',
    worked='MAC: 00:1A:2B:3C:4D:5E\nOUI 00:1A:2B → manufacturer; 3C:4D:5E → device\nARP: "Who has 192.168.1.1?" → reply with MAC',
    eng='Network access control filters devices by MAC address; randomization protects privacy on public Wi-Fi.',
    mistakes='Assuming MAC addresses are routable (they\'re local only); thinking they identify users; confusing MAC with IP.',
    practice=['What does MAC stand for?', 'What is the purpose of ARP?'],
    quiz=[
        q('A MAC address is how many bits?', ['32', '48', '64', '128'], [1], 'MAC addresses are 48 bits.'),
        q('MAC addresses operate at which OSI layer?', ['Physical', 'Data Link', 'Network', 'Transport'], [1], 'MAC is Layer 2.'),
    ])

lesson(8, 8, 'IPv4',
    concept='IPv4 is the fourth version of the Internet Protocol, using 32-bit addresses to identify devices on a network.',
    definition='IPv4 (Internet Protocol version 4) is the primary network layer protocol using 32-bit addresses, supporting about 4.3 billion unique addresses.',
    explanation='IPv4 addresses are written in dotted decimal (192.168.1.1). Each address has a network portion and a host portion, divided by the subnet mask. IPv4 provides connectionless, best-effort delivery — no guarantees of arrival, order, or duplication. Address exhaustion led to NAT and IPv6.',
    worked='192.168.1.10/24 → network 192.168.1.0, host 10\nSubnet mask 255.255.255.0 defines the boundary\nTotal addresses: 2^32 ≈ 4.3 billion',
    eng='Despite exhaustion, IPv4 remains dominant; ISPs and carriers use Carrier-Grade NAT to share addresses among customers.',
    mistakes='Assuming IPv4 addresses are unique globally (NAT breaks this); confusing network and host portions; ignoring address exhaustion.',
    practice=['How many bits is an IPv4 address?', 'What problem does NAT solve?'],
    quiz=[
        q('An IPv4 address is how many bits?', ['16', '32', '64', '128'], [1], 'IPv4 uses 32-bit addresses.'),
        q('IPv4 provides:', ['Guaranteed delivery', 'Best-effort connectionless delivery', 'Ordered delivery', 'Encrypted delivery'], [1], 'IPv4 is best-effort.'),
    ])

lesson(8, 9, 'IPv6',
    concept='IPv6 is the successor to IPv4, using 128-bit addresses to provide a vastly larger address space and simplified features.',
    definition='IPv6 (Internet Protocol version 6) is the modern network layer protocol using 128-bit addresses, designed to replace IPv4.',
    explanation='IPv6 addresses are eight groups of four hex digits (2001:0db8:85a3::8a2e:0370:7334). The 128-bit space provides 3.4 × 10^38 addresses — effectively unlimited. IPv6 simplifies headers, removes NAT need, has built-in security (IPsec), and supports auto-configuration. Adoption is growing but IPv4 still dominates.',
    worked='IPv6: 2001:0db8:0000:0000:0000:ff00:0042:8329\nCompressed: 2001:0db8::ff00:42:8329\n128 bits = 340 undecillion addresses',
    eng='Mobile networks (4G/5G) heavily use IPv6; cloud providers assign IPv6 to all resources.',
    mistakes='Assuming IPv6 is just "longer IPv4"; thinking NAT is required in IPv6; ignoring that both protocols coexist.',
    practice=['How many bits is an IPv6 address?', 'What are two advantages of IPv6?'],
    quiz=[
        q('An IPv6 address is how many bits?', ['32', '48', '64', '128'], [3], 'IPv6 uses 128 bits.'),
        q('IPv6 addresses are written in:', ['Dotted decimal', 'Hexadecimal', 'Binary', 'Octal'], [1], 'IPv6 uses hex groups.'),
    ])

lesson(8, 10, 'Subnetting',
    concept='Subnetting divides a network into smaller sub-networks using a subnet mask, improving organization, security, and efficiency.',
    definition='Subnetting is the practice of partitioning a larger IP network into smaller logical subnets by borrowing bits from the host portion of the address.',
    explanation='A subnet mask (e.g., 255.255.255.0 or /24) marks which bits identify the network. The network address is the subnet\'s base; the broadcast address is its last address; usable hosts are between them. Subnetting reduces broadcast domains, improves security through segmentation, and conserves addresses.',
    worked='192.168.1.0/24 → 254 usable hosts (1–254)\nNetwork: 192.168.1.0, Broadcast: 192.168.1.255\nSubnets: 192.168.1.0/25 → 126 hosts, 192.168.1.128/25 → 126 hosts',
    eng='Cloud VPCs subnet networks into public and private tiers; each subnet controls routing and security groups.',
    mistakes='Using the network or broadcast address as a host; mismatching masks across a subnet; not accounting for growth.',
    practice=['What is a subnet mask?', 'How many usable hosts in a /24 subnet?'],
    quiz=[
        q('A /24 subnet has how many usable hosts?', ['256', '254', '255', '128'], [1], '256 minus network and broadcast.'),
        q('The broadcast address is used for:', ['Single device', 'All devices on the subnet', 'The router', 'DNS'], [1], 'Broadcast reaches the whole subnet.'),
    ])

lesson(8, 11, 'CIDR',
    concept='CIDR (Classless Inter-Domain Routing) is a flexible addressing scheme using prefix lengths instead of fixed classes, enabling efficient allocation.',
    definition='CIDR is an IP addressing method that uses a prefix length (e.g., /24) to define network boundaries, replacing the rigid class A/B/C system.',
    explanation='CIDR notation appends the prefix length to an address: 192.168.1.0/24. It allows variable-length subnet masks (VLSM), so networks can be any size — /30 for point-to-point links (2 hosts), /24 for LANs. CIDR enables route aggregation (supernetting), shrinking routing tables. Use this app\'s subnet calculator to practice CIDR math.',
    worked='10.0.0.0/8 → 16,777,216 addresses (huge)\n192.168.1.0/30 → 4 addresses, 2 usable (point-to-point)\n203.0.113.0/24 → 254 usable hosts',
    eng='ISPs allocate CIDR blocks to customers; BGP routes the Internet using aggregated CIDR prefixes.',
    mistakes='Confusing prefix length with mask; assuming /24 is the only valid size; not aggregating routes.',
    practice=['What does /24 mean?', 'What is route aggregation?'],
    quiz=[
        q('In CIDR, /24 means:', ['24 hosts', '24 network bits', '24 total bits', 'Class 24'], [1], '/24 = 24 network bits.'),
        q('CIDR replaced which system?', ['DNS', 'Classful addressing', 'Ethernet', 'NAT'], [1], 'CIDR replaced classes A/B/C.'),
    ])

lesson(8, 12, 'Routing',
    concept='Routing is the process of selecting paths for packets to travel from source to destination across interconnected networks.',
    definition='Routing is the network-layer function of determining optimal paths for packets using routing tables and algorithms.',
    explanation='Routers forward packets based on destination IP addresses and routing tables. Static routes are manually configured; dynamic routing protocols (OSPF, BGP, EIGRP, RIP) learn and adapt. Metrics (hop count, bandwidth, latency) determine the best path. BGP routes the Internet between autonomous systems; OSPF routes within them.',
    worked='Routing table:\n10.0.0.0/8 → direct\n192.168.0.0/16 → via 10.0.0.1\n0.0.0.0/0 → via 203.0.113.1 (default)\nLongest prefix match wins: /24 beats /16.',
    eng='BGP tables on the Internet exceed 900,000 prefixes; anycast routing directs users to the nearest server globally.',
    mistakes='Assuming all routes are equal; ignoring longest prefix match; confusing routing (Layer 3) with switching (Layer 2).',
    practice=['What is the difference between static and dynamic routing?', 'What does a default route do?'],
    quiz=[
        q('Routing operates at which layer?', ['Data Link', 'Network', 'Transport', 'Application'], [1], 'Routing is Layer 3.'),
        q('Which protocol routes between autonomous systems on the Internet?', ['OSPF', 'BGP', 'RIP', 'EIGRP'], [1], 'BGP is the Internet\'s exterior gateway protocol.'),
    ])

lesson(8, 13, 'Switching',
    concept='Switching forwards frames within a LAN based on MAC addresses, learning which ports lead to which devices.',
    definition='Switching is the data-link-layer function of forwarding frames to the correct destination port using MAC address tables.',
    explanation='Switches maintain a MAC address table mapping ports to MAC addresses. When a frame arrives, the switch looks up the destination MAC: if found, it forwards only to that port; if not, it floods to all ports (except the source). Switches create separate collision domains per port, enabling full-duplex communication. VLANs segment switches logically.',
    worked='MAC table: port 1 → AA:BB:CC:00:00:01\nFrame to AA:BB:CC:00:00:01 → forwarded only to port 1\nUnknown destination → flood to all ports',
    eng='Data center switches (leaf-spine) provide non-blocking connectivity; industrial switches withstand harsh environments.',
    mistakes='Confusing switches with routers; assuming switches route IP; not understanding flooding behavior.',
    practice=['What does a switch use to forward frames?', 'What is a VLAN?'],
    quiz=[
        q('Switches forward frames using:', ['IP addresses', 'MAC addresses', 'Port numbers', 'URLs'], [1], 'Switches use MAC addresses.'),
        q('A switch creates separate:', ['Networks', 'Collision domains', 'Subnets', 'DNS zones'], [1], 'Each port is its own collision domain.'),
    ])

lesson(8, 14, 'ARP',
    concept='ARP (Address Resolution Protocol) maps IP addresses to MAC addresses on a local network, enabling Layer 2 delivery.',
    definition='ARP is a protocol that resolves network layer addresses (IP) to data link layer addresses (MAC) within a local network.',
    explanation='To send a packet, a device needs the destination MAC. ARP broadcasts "Who has IP X?" to the local network; the owner replies with its MAC. The requester caches the mapping in its ARP table (typically 2–20 minutes). ARP operates only within a broadcast domain (subnet).',
    worked='Device A wants 192.168.1.1\'s MAC:\n1. Broadcast ARP request\n2. 192.168.1.1 replies with its MAC\n3. A caches and sends frames directly',
    eng='ARP spoofing is a classic LAN attack; defenses include static ARP entries and dynamic ARP inspection on switches.',
    mistakes='Assuming ARP works across routers (it doesn\'t); confusing ARP with DNS; not understanding ARP cache poisoning.',
    practice=['What does ARP resolve?', 'Why doesn\'t ARP work across subnets?'],
    quiz=[
        q('ARP resolves which addresses?', ['IP to MAC', 'MAC to IP', 'Domain to IP', 'Port to protocol'], [0], 'ARP maps IP to MAC.'),
        q('ARP operates within:', ['The Internet', 'A broadcast domain', 'Any network', 'The transport layer'], [1], 'ARP is local to a subnet.'),
    ])

lesson(8, 15, 'DHCP',
    concept='DHCP (Dynamic Host Configuration Protocol) automatically assigns IP addresses and network configuration to devices.',
    definition='DHCP is a network management protocol that dynamically allocates IP addresses, subnet masks, gateways, and DNS servers to clients.',
    explanation='DHCP uses DORA: Discover (client broadcasts), Offer (server proposes), Request (client accepts), Acknowledge (server confirms). Leases are temporary (hours to days) and renew automatically. DHCP eliminates manual IP configuration and prevents address conflicts. Servers can reserve addresses by MAC for specific devices.',
    worked='Client boots → Discover → server offers 192.168.1.50\nClient requests → server ACKs with mask, gateway, DNS\nLease: 8 days, renews at 50% and 87.5%',
    eng='Enterprise networks use DHCP failover and reservations; routers relay DHCP across subnets (IP helper).',
    mistakes='Assigning static IPs in the DHCP range (conflicts); not reserving servers; ignoring lease times.',
    practice=['What are the four DHCP messages?', 'What is a DHCP reservation?'],
    quiz=[
        q('DHCP assigns:', ['MAC addresses', 'IP addresses and configuration', 'Domain names', 'Routes'], [1], 'DHCP automates IP configuration.'),
        q('DHCP Discover is sent as:', ['Unicast', 'Broadcast', 'Multicast', 'Anycast'], [1], 'Clients broadcast Discover.'),
    ])

lesson(8, 16, 'DNS',
    concept='DNS (Domain Name System) translates human-readable domain names to IP addresses, operating as a distributed, hierarchical database.',
    definition='DNS is a hierarchical, distributed naming system that resolves domain names to IP addresses and other records.',
    explanation='DNS is structured as a tree: root (.) → TLDs (.com, .org) → domains (example.com) → hosts (www.example.com). Resolution: recursive resolvers query root, TLD, and authoritative servers. Records: A (IPv4), AAAA (IPv6), MX (mail), CNAME (alias), TXT. DNS uses UDP (port 53) normally, TCP for large responses.',
    worked='Query www.example.com:\nRoot → .com TLD → example.com authoritative\nAnswer: A record 93.184.216.34\nCached at resolver for the TTL',
    eng='DNS powers the entire Internet; DNSSEC adds authentication; Anycast DNS (8.8.8.8, 1.1.1.1) provides fast global resolution.',
    mistakes='Assuming DNS is a single server; confusing DNS with DHCP; ignoring TTL and caching.',
    practice=['What does DNS resolve?', 'What is the DNS hierarchy?'],
    quiz=[
        q('DNS translates:', ['IP to MAC', 'Domain names to IP addresses', 'Ports to protocols', 'MAC to IP'], [1], 'DNS resolves names to IPs.'),
        q('Which record type maps a domain to an IPv6 address?', ['A', 'AAAA', 'MX', 'CNAME'], [1], 'AAAA holds IPv6 addresses.'),
    ])

lesson(8, 17, 'HTTP',
    concept='HTTP (Hypertext Transfer Protocol) is the application-layer protocol for transferring web resources between clients and servers.',
    definition='HTTP is a stateless request-response protocol that transfers hypertext and other resources over the web.',
    explanation='Clients send requests (GET, POST, PUT, DELETE) with headers; servers respond with status codes (200 OK, 404 Not Found, 500 Error) and bodies. HTTP is stateless — each request is independent; sessions use cookies. HTTP/1.1 uses persistent connections; HTTP/2 multiplexes streams; HTTP/3 uses QUIC over UDP. HTTPS adds TLS encryption.',
    worked='GET /index.html HTTP/1.1\nHost: example.com\n→ HTTP/1.1 200 OK\nContent-Type: text/html\n<body>...</body>',
    eng='REST APIs use HTTP methods and JSON; CDNs cache HTTP content globally; HTTP/3 reduces latency on mobile networks.',
    mistakes='Assuming HTTP is secure (only HTTPS is); using GET for state changes; ignoring status codes.',
    practice=['What HTTP method retrieves a resource?', 'What is the difference between HTTP and HTTPS?'],
    quiz=[
        q('Which HTTP method retrieves data?', ['POST', 'GET', 'DELETE', 'PUT'], [1], 'GET retrieves resources.'),
        q('HTTP is:', ['Stateful', 'Stateless', 'Encrypted', 'Connection-oriented'], [1], 'HTTP is stateless by design.'),
    ])

lesson(8, 18, 'HTTPS',
    concept='HTTPS is HTTP secured with TLS encryption, providing confidentiality, integrity, and authentication for web traffic.',
    definition='HTTPS (HTTP Secure) is HTTP over TLS (Transport Layer Security), encrypting and authenticating web communication.',
    explanation='TLS wraps HTTP in encrypted sessions. The TLS handshake authenticates the server (via certificates from CAs) and negotiates encryption keys. HTTPS prevents eavesdropping, tampering, and impersonation. Modern TLS 1.3 is faster and more secure. HTTPS is now the default for all web traffic.',
    worked='Client → ClientHello → server Certificate → key exchange → encrypted HTTP\nPadlock icon in browsers indicates HTTPS',
    eng='HTTPS everywhere: browsers mark HTTP as insecure; HSTS forces HTTPS; certificates are free via Let\'s Encrypt.',
    mistakes='Assuming HTTPS makes a site trustworthy (it encrypts, not validates content); mixing HTTP/HTTPS content; ignoring certificate warnings.',
    practice=['What does TLS provide?', 'What is a certificate authority?'],
    quiz=[
        q('HTTPS provides:', ['Speed', 'Encryption, integrity, authentication', 'Compression', 'Caching'], [1], 'TLS secures the connection.'),
        q('Which version of TLS is current?', ['TLS 1.0', 'TLS 1.1', 'TLS 1.2', 'TLS 1.3'], [3], 'TLS 1.3 is the latest standard.'),
    ])

lesson(8, 19, 'TCP',
    concept='TCP (Transmission Control Protocol) provides reliable, ordered, connection-oriented delivery of data between applications.',
    definition='TCP is a transport layer protocol that provides reliable, ordered, error-checked delivery of a byte stream between applications.',
    explanation='TCP establishes connections with a three-way handshake (SYN, SYN-ACK, ACK). It guarantees delivery via sequence numbers, acknowledgments, and retransmissions. Flow control (sliding window) prevents overwhelming receivers; congestion control (slow start, AIMD) prevents network collapse. TCP is used by HTTP, SSH, FTP, email.',
    worked='Connection: SYN → SYN-ACK → ACK\nData: sequenced segments, ACKed, retransmitted if lost\nClose: FIN → FIN-ACK',
    eng='TCP powers the reliable backbone of the Internet; BBR congestion control improves throughput on modern networks.',
    mistakes='Assuming TCP guarantees speed (it guarantees delivery); confusing TCP with UDP; ignoring head-of-line blocking.',
    practice=['What is the three-way handshake?', 'How does TCP ensure reliability?'],
    quiz=[
        q('TCP is:', ['Connectionless', 'Connection-oriented and reliable', 'Unrealtime', 'Physical layer'], [1], 'TCP is reliable and connection-oriented.'),
        q('Which mechanism does TCP use for flow control?', ['Sequence numbers', 'Sliding window', 'Checksums', 'SYN floods'], [1], 'Sliding windows regulate flow.'),
    ])

lesson(8, 20, 'UDP',
    concept='UDP (User Datagram Protocol) provides fast, connectionless, unreliable delivery — ideal for real-time applications.',
    definition='UDP is a transport layer protocol that provides connectionless, unreliable datagram delivery with minimal overhead.',
    explanation='UDP sends datagrams without handshakes, ordering, or retransmission. It is faster than TCP (no connection setup, no congestion control) but offers no guarantees. Used for DNS (fast queries), video streaming, online gaming, and VoIP where latency matters more than reliability. QUIC (HTTP/3) adds reliability on top of UDP.',
    worked='UDP header: 8 bytes (vs TCP 20)\nNo handshake, no ACK, no retransmit\nDNS query → UDP response in milliseconds',
    eng='QUIC (HTTP/3) runs over UDP to reduce connection setup time and improve performance on mobile networks.',
    mistakes='Using UDP when reliability is needed (use TCP); assuming UDP is always faster (congestion can hurt); ignoring UDP flood attacks.',
    practice=['When is UDP preferred over TCP?', 'What is QUIC?'],
    quiz=[
        q('UDP is:', ['Connection-oriented', 'Connectionless and unreliable', 'Slower than TCP', 'Encrypted'], [1], 'UDP is fast but unreliable.'),
        q('Which service commonly uses UDP?', ['Web browsing', 'DNS', 'SSH', 'Email (SMTP)'], [1], 'DNS uses UDP for fast queries.'),
    ])

lesson(8, 21, 'Ports',
    concept='Port numbers (0–65535) identify specific applications or services on a host, enabling multiple simultaneous connections.',
    definition='A port is a 16-bit number that identifies a specific process or service on a device, enabling multiplexing of network connections.',
    explanation='Ports 0–1023 are well-known (HTTP 80, HTTPS 443, SSH 22, DNS 53). Ports 1024–49151 are registered; 49152–65535 are ephemeral (temporary client ports). The combination IP:port identifies a connection endpoint. Firewalls filter by port; NAT maps ports to internal hosts (port forwarding).',
    worked='192.168.1.10:443 → HTTPS to that host\n192.168.1.10:22 → SSH\nServer listens on well-known ports; clients use ephemeral ports',
    eng='Port scanning discovers open services (used by attackers and security auditors); firewalls restrict ports to minimize attack surface.',
    mistakes='Confusing ports with protocols; assuming all ports are open; not securing listening ports.',
    practice=['What port does HTTPS use?', 'What is the difference between well-known and ephemeral ports?'],
    quiz=[
        q('HTTPS uses port:', ['80', '443', '22', '53'], [1], 'HTTPS is port 443.'),
        q('Well-known ports are in which range?', ['0–1023', '1024–49151', '49152–65535', '1–100'], [0], 'Well-known ports are 0–1023.'),
    ])

lesson(8, 22, 'NAT',
    concept='NAT (Network Address Translation) maps private IP addresses to public ones, conserving IPv4 addresses and adding a layer of security.',
    definition='NAT is a router function that translates private IP addresses to public IP addresses (and vice versa) for Internet communication.',
    explanation='Inside a LAN, devices use private addresses (10.x, 172.16–31.x, 192.168.x). The NAT router translates these to its public IP, tracking connections in a table. PAT (Port Address Translation) maps many internal hosts to one public IP using different ports. NAT conserves IPv4 but breaks end-to-end connectivity.',
    worked='LAN: 192.168.1.10 → router → Internet: 203.0.113.5\nRouter NAT table: 192.168.1.10:5000 ↔ 203.0.113.5:5000',
    eng='Carrier-Grade NAT lets ISPs share one public IP among many customers; IPv6 eliminates the need for NAT.',
    mistakes='Assuming NAT is a security feature (it\'s a side effect); breaking peer-to-peer apps; confusing NAT with a firewall.',
    practice=['What problem does NAT solve?', 'What is PAT?'],
    quiz=[
        q('NAT primarily conserves:', ['Bandwidth', 'IPv4 addresses', 'DNS records', 'Ports'], [1], 'NAT extends IPv4 address space.'),
        q('NAT translates:', ['MAC to IP', 'Private to public IP addresses', 'Domain to IP', 'Ports to protocols'], [1], 'NAT maps address spaces.'),
    ])

lesson(8, 23, 'Firewalls',
    concept='A firewall is a security system that monitors and controls network traffic based on predefined rules.',
    definition='A firewall is a network security device or software that permits or blocks traffic based on security rules.',
    explanation='Firewalls filter traffic by IP addresses, ports, protocols, and application content. Types: packet-filtering (stateless), stateful (tracks connections), next-generation (deep packet inspection, application awareness), and web application firewalls. Default deny (block all, allow by exception) is the secure approach.',
    worked='Rule: ALLOW TCP 443 from any → 192.168.1.0/24\nRule: DENY all other inbound\nStateful firewalls allow return traffic for established connections',
    eng='Next-gen firewalls (NGFW) integrate intrusion prevention, VPN, and application control; cloud security groups act as virtual firewalls.',
    mistakes='Assuming firewalls stop all attacks (they don\'t); default-allow rules; not updating firewall rules.',
    practice=['What is the difference between stateful and stateless firewalls?', 'What does default deny mean?'],
    quiz=[
        q('A firewall filters traffic based on:', ['Nothing', 'Security rules', 'Speed only', 'Cable type'], [1], 'Rules control traffic.'),
        q('Which approach is more secure?', ['Default allow', 'Default deny', 'No rules', 'Allow all'], [1], 'Default deny is secure.'),
    ])

lesson(8, 24, 'Network Security',
    concept='Network security protects data and infrastructure from unauthorized access, attacks, and breaches using defense-in-depth strategies.',
    definition='Network security is the practice of protecting computer networks and data from misuse, modification, or unauthorized access.',
    explanation='Key principles: confidentiality (encryption), integrity (hashing), availability (redundancy) — the CIA triad. Threats: malware, phishing, DDoS, man-in-the-middle. Defenses: firewalls, IDS/IPS, VPNs, encryption (TLS, IPsec), access control, and segmentation. Zero trust assumes no implicit trust, verifying every access.',
    worked='Defense in depth:\nPerimeter firewall → IDS → segmentation → host firewall → encryption',
    eng='Enterprise security operations centers (SOCs) monitor threats 24/7; penetration testing validates defenses.',
    mistakes='Assuming security is a product (it\'s a process); ignoring insider threats; weak passwords.',
    practice=['What is the CIA triad?', 'What is zero trust?'],
    quiz=[
        q('The CIA triad includes:', ['Confidentiality, Integrity, Availability', 'Compression, Internet, Access', 'Cloud, IP, ARP', 'Crypto, Integrity, Authentication'], [0], 'CIA: core security principles.'),
        q('A man-in-the-middle attack:', ['Steals hardware', 'Intercepts communication', 'Deletes files', 'Overloads CPUs'], [1], 'MITM intercepts traffic.'),
    ])

lesson(8, 25, 'Troubleshooting',
    concept='Network troubleshooting systematically isolates and resolves connectivity issues using layered approaches and diagnostic tools.',
    definition='Network troubleshooting is the process of diagnosing and resolving network problems through systematic isolation of causes.',
    explanation='Approach: define the problem, gather information, isolate the layer (physical → application), test hypotheses, and verify the fix. Tools: ping (connectivity), traceroute (path), nslookup/dig (DNS), netstat (connections), Wireshark (packet capture). The OSI model guides layered diagnosis: check cables first, then IP, then ports, then applications.',
    worked='Can\'t reach a website?\n1. ping 8.8.8.8 → tests IP connectivity\n2. ping google.com → tests DNS\n3. curl -v https://google.com → tests TLS/HTTP\n4. Check firewall rules',
    eng='Network engineers use Wireshark to capture and analyze packets; automated monitoring detects anomalies before users notice.',
    mistakes='Changing multiple things at once; not documenting fixes; skipping the physical layer.',
    practice=['What does ping test?', 'What is the first layer to check in troubleshooting?'],
    quiz=[
        q('ping tests which layer primarily?', ['Application', 'Network (IP connectivity)', 'Presentation', 'Session'], [1], 'ping uses ICMP at Layer 3.'),
        q('The first troubleshooting step should be:', ['Reboot everything', 'Define the problem and check physical layer', 'Change DNS', 'Reinstall OS'], [1], 'Start with physical connectivity.'),
    ])

formula('Networking', 'Subnet Usable Hosts', 'Hosts = 2^(32−prefix) − 2', 'prefix: CIDR notation', 'IP subnetting')
formula('Networking', 'Bandwidth-Delay Product', 'BDP = Bandwidth × RTT', 'BDP: bits in flight', 'Network capacity')
formula('Networking', 'Nyquist Rate', 'C = 2B log₂(M)', 'B: bandwidth; M: signal levels', 'Data rate limits')

# ---------------- Digital Logic (31 lessons) ----------------

lesson(9, 1, 'Number Systems',
    concept='Number systems represent quantities with different bases: binary (2), decimal (10), octal (8), and hexadecimal (16).',
    definition='A number system is a mathematical notation for representing numbers using a base and digits.',
    explanation='Each system uses powers of its base. Decimal: 45 = 4×10¹ + 5×10⁰. Binary: 101101 = 32+8+4+1 = 45. Octal groups 3 bits; hexadecimal groups 4 bits. Use this app\'s Number System Calculator to convert between bases instantly.',
    worked='101101₂ = 1×32 + 0×16 + 1×8 + 1×4 + 0×2 + 1×1 = 45₁₀\n45₁₀ = 55₈ = 2D₁₆',
    eng='Digital systems are inherently binary; hexadecimal compactly represents binary for humans (memory addresses, color codes).',
    mistakes='Confusing binary with decimal weights; forgetting hex digits A–F represent 10–15; misaligning bit groups.',
    practice=['Convert 101101₂ to decimal.', 'Convert 45₁₀ to hexadecimal.'],
    quiz=[
        q('What base does binary use?', ['10', '2', '8', '16'], [1], 'Binary is base 2.'),
        q('101101₂ equals which decimal?', ['45', '37', '53', '29'], [0], '101101₂ = 45₁₀.'),
    ])

lesson(9, 2, 'Binary',
    concept='Binary is the base-2 number system using only 0 and 1, forming the foundation of all digital computing.',
    definition='Binary is a positional number system with base 2, where each bit represents a power of 2.',
    explanation='Each binary digit (bit) is 0 or 1. The rightmost bit is 2⁰ (1), then 2¹ (2), 2² (4), etc. n bits represent 2ⁿ values. Binary directly maps to digital logic: 0 = low voltage, 1 = high voltage. All computer data — numbers, text, images — is ultimately binary.',
    worked='Decimal 13 = 1101₂ (8 + 4 + 1)\n8 bits (a byte) represent 0–255\nBinary addition: 1 + 1 = 10 (carry 1)',
    eng='Everything in a computer — CPU instructions, memory contents, network packets — is binary at the hardware level.',
    mistakes='Thinking binary is just for integers (it represents everything); confusion with BCD; ignoring bit significance.',
    practice=['Convert 25₁₀ to binary.', 'Add 1011₂ + 1101₂.'],
    quiz=[
        q('How many values can 8 bits represent?', ['8', '16', '256', '64'], [2], '2⁸ = 256.'),
        q('In binary, 1 + 1 equals:', ['2', '10', '0', '11'], [1], 'Binary 1+1 = 10 (decimal 2).'),
    ])

lesson(9, 3, 'Decimal',
    concept='Decimal is the base-10 number system humans use daily, with digits 0–9 weighted by powers of 10.',
    definition='Decimal is a positional number system with base 10, where each digit\'s place value is a power of 10.',
    explanation='Each position represents 10ⁿ: units (10⁰), tens (10¹), hundreds (10²). To convert decimal to binary, repeatedly divide by 2 and read remainders upward. To convert binary to decimal, sum the powers of 2 for each 1 bit.',
    worked='Decimal 45 → binary:\n45 ÷ 2 = 22 r 1\n22 ÷ 2 = 11 r 0\n11 ÷ 2 = 5 r 1\n5 ÷ 2 = 2 r 1\n2 ÷ 2 = 1 r 0\n1 ÷ 2 = 0 r 1\nRead upward: 101101₂',
    eng='Financial systems use decimal (BigDecimal) to avoid binary floating-point rounding errors in calculations.',
    mistakes='Reading remainders in the wrong order; confusing decimal with BCD; ignoring fractional conversion.',
    practice=['Convert 100₁₀ to binary.', 'Convert 101010₂ to decimal.'],
    quiz=[
        q('Decimal 100 in binary is:', ['1100100', '1010100', '1111000', '1001000'], [0], '100₁₀ = 1100100₂.'),
        q('101010₂ in decimal is:', ['42', '34', '52', '26'], [0], '101010₂ = 42₁₀.'),
    ])

lesson(9, 4, 'Octal',
    concept='Octal is the base-8 number system using digits 0–7, grouping three binary bits for compact representation.',
    definition='Octal is a positional number system with base 8, where each digit represents a power of 8.',
    explanation='Each octal digit maps to exactly 3 binary bits: 0=000, 1=001, ..., 7=111. Octal was common in early computing (PDP-8, UNIX permissions). Conversion: group binary bits in threes from the right, replace each group with its octal digit.',
    worked='Binary 101101 → groups: 101 101 → 5 5 → 55₈\nOctal 73 → 111 011 → 111011₂',
    eng='UNIX file permissions use octal: chmod 755 = rwxr-xr-x (owner 7, group 5, others 5).',
    mistakes=['Confusing octal with hexadecimal; misgrouping binary bits; using digits 8–9 in octal.'],
    practice=['Convert 111000₂ to octal.', 'Convert 37₈ to binary.'],
    quiz=[
        q('Octal digit 7 equals which binary?', ['111', '101', '110', '011'], [0], '7 = 111₂.'),
        q('Binary 111000₂ in octal is:', ['70', '60', '50', '77'], [0], '111 000 → 70₈.'),
    ])

lesson(9, 5, 'Hexadecimal',
    concept='Hexadecimal is the base-16 number system using digits 0–9 and A–F, grouping four binary bits for compact binary representation.',
    definition='Hexadecimal is a positional number system with base 16, where each digit represents a power of 16.',
    explanation='Each hex digit maps to exactly 4 binary bits: A=1010, B=1011, ..., F=1111. Hex is the standard shorthand for binary in computing: memory addresses (0xFF), color codes (#FF5733), and MAC addresses. Conversion: group binary in fours, replace each group with its hex digit.',
    worked='Binary 101101 → groups: 0010 1101 → 2 D → 2D₁₆\nHex 2D → 0010 1101 → 00101101₂',
    eng='Debuggers display memory in hex; programmers write masks like 0xFF00 to manipulate specific byte ranges.',
    mistakes='Forgetting A–F values; misgrouping binary bits (must be 4); confusing hex with decimal.',
    practice=['Convert 11110000₂ to hex.', 'Convert A3₁₆ to binary.'],
    quiz=[
        q('Hex digit F equals which binary?', ['1111', '1110', '1011', '1101'], [0], 'F = 1111₂.'),
        q('Binary 11110000₂ in hex is:', ['F0', 'E0', 'FF', '0F'], [0], '1111 0000 → F0₁₆.'),
    ])

lesson(9, 6, 'Binary Arithmetic',
    concept='Binary arithmetic performs addition, subtraction, multiplication, and division using binary digits, following rules simpler than decimal.',
    definition='Binary arithmetic computes with binary numbers using rules: 0+0=0, 0+1=1, 1+1=10 (carry).',
    explanation='Binary addition: sum bits column by column with carries (1+1=10, write 0 carry 1). Subtraction uses borrowing (or two\'s complement addition). Multiplication is shift-and-add. Division is repeated subtraction with shifts. These operations are implemented directly in hardware (ALU).',
    worked='  1011 (11)\n+ 1101 (13)\n=11000 (24)\n1+1=10, 1+0+1=10, etc.',
    eng='CPUs perform all arithmetic in binary; understanding binary math is essential for embedded and hardware programming.',
    mistakes='Forgetting carries; misaligning columns; confusing binary addition with XOR.',
    practice=['Add 1101₂ + 1011₂.', 'Subtract 1101₂ − 1010₂.'],
    quiz=[
        q('1011₂ + 1101₂ equals:', ['11000', '10000', '10100', '11110'], [0], '11 + 13 = 24 = 11000₂.'),
        q('Binary 1 + 1 + 1 equals:', ['11', '10', '01', '111'], [0], '1+1+1 = 3 = 11₂.'),
    ])

lesson(9, 7, 'Logic Gates',
    concept='Logic gates are fundamental building blocks that perform Boolean operations on binary inputs: AND, OR, NOT, NAND, NOR, XOR, XNOR.',
    definition='A logic gate is a physical or logical device that implements a Boolean function on one or more binary inputs to produce a single binary output.',
    explanation='Each gate has a truth table defining its output for all input combinations. AND outputs 1 only if all inputs are 1. OR outputs 1 if any input is 1. NOT inverts. NAND/NOR are AND/OR with inverted output (universal gates). XOR outputs 1 when inputs differ. All digital circuits are built from these gates.',
    worked='AND: 1·1=1, else 0\nOR: 0+0=0, else 1\nXOR: 1⊕1=0, 1⊕0=1\nNAND: inverse of AND',
    eng='Billions of logic gates form a CPU; NAND is universal — any circuit can be built from NAND gates alone.',
    mistakes=['Confusing AND with OR; thinking XOR is addition; ignoring gate delays in timing analysis.'],
    practice=['What is the output of AND(1,0)?', 'Which gate inverts its input?'],
    quiz=[
        q('AND(1, 1) outputs:', ['0', '1', '2', '10'], [1], 'AND needs all 1s.'),
        q('Which gate inverts?', ['AND', 'OR', 'NOT', 'XOR'], [2], 'NOT inverts.'),
    ])

lesson(9, 8, 'AND Gate',
    concept='The AND gate outputs 1 only when all inputs are 1; it performs logical multiplication.',
    definition='The AND gate is a logic gate that outputs 1 only if all its inputs are 1; otherwise it outputs 0.',
    explanation='AND performs logical multiplication: output = A · B. With two inputs: 0·0=0, 0·1=0, 1·0=0, 1·1=1. Multi-input AND extends this: all must be 1. AND is used for masking (extracting bits) and enabling signals.',
    worked='Truth table:\nA B | Out\n0 0 | 0\n0 1 | 0\n1 0 | 0\n1 1 | 1\nSymbol: flat back, round front',
    eng='AND gates mask interrupt flags: flag & MASK extracts specific bits from a status register.',
    mistakes='Confusing AND with OR; assuming AND adds; ignoring multi-input AND.',
    practice=['What is AND(1, 0, 1)?', 'How is AND used for masking?'],
    quiz=[
        q('AND(1, 0, 1) outputs:', ['1', '0', '2', 'Error'], [1], 'Any 0 input makes AND output 0.'),
        q('AND performs logical:', ['Addition', 'Multiplication', 'Inversion', 'Division'], [1], 'AND is multiplication.'),
    ])

lesson(9, 9, 'OR Gate',
    concept='The OR gate outputs 1 when any input is 1; it performs logical addition.',
    definition='The OR gate is a logic gate that outputs 1 if at least one input is 1; it outputs 0 only when all inputs are 0.',
    explanation='OR performs logical addition: output = A + B (Boolean). With two inputs: 0+0=0, 0+1=1, 1+0=1, 1+1=1. Multi-input OR: any 1 input makes output 1. OR is used for setting bits and combining flags.',
    worked='Truth table:\nA B | Out\n0 0 | 0\n0 1 | 1\n1 0 | 1\n1 1 | 1\nSymbol: curved back, pointed front',
    eng='OR gates combine interrupt sources: any active interrupt line triggers the CPU IRQ pin.',
    mistakes='Confusing OR with XOR; assuming 1+1=10 in Boolean OR; ignoring multi-input OR.',
    practice=['What is OR(0, 1, 0)?', 'How is OR used for setting bits?'],
    quiz=[
        q('OR(0, 1, 0) outputs:', ['0', '1', '2', '10'], [1], 'Any 1 input makes OR output 1.'),
        q('OR performs logical:', ['Multiplication', 'Addition', 'Inversion', 'Subtraction'], [1], 'OR is logical addition.'),
    ])

lesson(9, 10, 'NOT Gate',
    concept='The NOT gate (inverter) outputs the opposite of its single input: 0 becomes 1, 1 becomes 0.',
    definition='The NOT gate is a logic gate that inverts its input, outputting the logical complement.',
    explanation='NOT is the simplest gate: one input, one output, always inverted. NOT(A) = A\' (A-bar). NOT is used to create active-low signals, complement bits, and build other gates (NAND = AND + NOT).',
    worked='A | Out\n0 | 1\n1 | 0\nSymbol: triangle with bubble',
    eng='Active-low control signals (RESET, CHIP SELECT) use NOT logic: the pin is active when driven low.',
    mistakes='Confusing NOT with NAND; assuming NOT has two inputs; ignoring bubble notation in schematics.',
    practice=['What is NOT(0)?', 'What does a bubble on a gate symbol mean?'],
    quiz=[
        q('NOT(0) outputs:', ['0', '1', 'Error', 'Undefined'], [1], 'NOT inverts.'),
        q('The NOT gate is also called:', ['Inverter', 'Buffer', 'Amplifier', 'Comparator'], [0], 'NOT inverts.'),
    ])

lesson(9, 11, 'NAND Gate',
    concept='The NAND gate outputs 0 only when all inputs are 1; it is AND followed by NOT and is a universal gate.',
    definition='The NAND gate is a logic gate that outputs 0 only if all inputs are 1; otherwise it outputs 1.',
    explanation='NAND = NOT AND. Its output is the inverse of AND: 0 only when all inputs are 1. NAND is universal: you can build ANY logic function (AND, OR, NOT, XOR, etc.) using only NAND gates. This makes NAND the foundation of integrated circuit design.',
    worked='Truth table:\nA B | NAND\n0 0 | 1\n0 1 | 1\n1 0 | 1\n1 1 | 0\nNOT(A) = NAND(A, A)\nAND(A,B) = NOT(NAND(A,B))',
    eng='NAND flash memory (SSDs, USB drives) is named for the NAND gate; all logic in early ICs used NAND structures.',
    mistakes='Confusing NAND with AND; thinking NAND is not universal; ignoring NAND\'s role in flash memory.',
    practice=['What is NAND(1, 1)?', 'How do you build NOT from NAND?'],
    quiz=[
        q('NAND(1, 1) outputs:', ['1', '0', '2', '10'], [1], 'NAND inverts AND.'),
        q('NAND is called universal because:', ['It is fast', 'Any function can be built from NAND alone', 'It uses less power', 'It has many inputs'], [1], 'NAND can construct all logic.'),
    ])

lesson(9, 12, 'NOR Gate',
    concept='The NOR gate outputs 1 only when all inputs are 0; it is OR followed by NOT and is also a universal gate.',
    definition='The NOR gate is a logic gate that outputs 1 only if all inputs are 0; otherwise it outputs 0.',
    explanation='NOR = NOT OR. Its output is the inverse of OR: 1 only when all inputs are 0. Like NAND, NOR is universal — any logic function can be built from NOR gates alone. NOR was used in early computers (Apollo Guidance Computer used NOR logic).',
    worked='Truth table:\nA B | NOR\n0 0 | 1\n0 1 | 0\n1 0 | 0\n1 1 | 0\nNOT(A) = NOR(A, A)',
    eng='The Apollo Guidance Computer was built almost entirely from NOR gates; some EEPROM cells use NOR architecture.',
    mistakes='Confusing NOR with OR; thinking NOR is not universal; ignoring NOR\'s historical significance.',
    practice=['What is NOR(0, 0)?', 'How do you build NOT from NOR?'],
    quiz=[
        q('NOR(0, 0) outputs:', ['0', '1', '2', 'Undefined'], [1], 'NOR is 1 only when all inputs are 0.'),
        q('Which gate is also universal?', ['AND', 'NOR', 'XOR', 'NOT'], [1], 'NOR is universal like NAND.'),
    ])

lesson(9, 13, 'XOR Gate',
    concept='The XOR (exclusive OR) gate outputs 1 when inputs differ; it is fundamental for addition, parity, and cryptography.',
    definition='The XOR gate is a logic gate that outputs 1 if its inputs are different, and 0 if they are the same.',
    explanation='XOR (⊕): A⊕B = 1 when A≠B. XOR is the sum bit of binary addition (without carry). Applications: half adders (sum = A⊕B), parity generation, comparison, toggling bits, and stream ciphers (one-time pads). XOR with 1 inverts; XOR with 0 passes through.',
    worked='Truth table:\nA B | XOR\n0 0 | 0\n0 1 | 1\n1 0 | 1\n1 1 | 0\nA⊕A = 0, A⊕0 = A, A⊕1 = A\'',
    eng='XOR is the core of RAID parity, error-correcting codes, and AES encryption rounds.',
    mistakes='Confusing XOR with OR; assuming XOR is associative with AND (it is, but not distributive like that); ignoring XOR\'s use in addition.',
    practice=['What is XOR(1, 1)?', 'How is XOR used in binary addition?'],
    quiz=[
        q('XOR(1, 1) outputs:', ['1', '0', '2', '10'], [1], 'Same inputs give 0.'),
        q('XOR(1, 0, 1, 0) outputs (chained):', ['0', '1', '2', '4'], [0], '1⊕0⊕1⊕0 = 0.'),
    ])

lesson(9, 14, 'XNOR Gate',
    concept='The XNOR gate outputs 1 when inputs are equal; it is XOR followed by NOT, used for comparison and parity checking.',
    definition='The XNOR gate is a logic gate that outputs 1 if its inputs are the same, and 0 if they differ.',
    explanation='XNOR (equivalence): A⊙B = 1 when A=B. It is the complement of XOR. Applications: equality comparison (XNOR of each bit pair, then AND all results), parity checking, and coincidence detection. XNOR with one input tied to 1 acts as a buffer; tied to 0 acts as an inverter.',
    worked='Truth table:\nA B | XNOR\n0 0 | 1\n0 1 | 0\n1 0 | 0\n1 1 | 1\nXNOR = NOT(XOR)',
    eng='Digital comparators use XNOR per bit to check equality; communication systems use XNOR for coherent detection.',
    mistakes='Confusing XNOR with XOR; thinking XNOR is universal (it\'s not); ignoring XNOR\'s comparator role.',
    practice=['What is XNOR(1, 1)?', 'How is XNOR used for equality checking?'],
    quiz=[
        q('XNOR(1, 1) outputs:', ['0', '1', '2', '10'], [1], 'Equal inputs give 1.'),
        q('XNOR is the complement of:', ['AND', 'XOR', 'OR', 'NAND'], [1], 'XNOR = NOT XOR.'),
    ])

lesson(9, 15, 'Truth Tables',
    concept='A truth table lists all possible input combinations and their corresponding outputs for a logic function.',
    definition='A truth table is a mathematical table that enumerates every possible combination of inputs to a logic function and the resulting output.',
    explanation='For n inputs, a truth table has 2ⁿ rows. Each row is one input combination; the output column defines the function. Truth tables are the specification for logic functions — they completely describe a circuit\'s behavior. They are used to derive Boolean expressions and verify designs.',
    worked='AND truth table (2 inputs, 4 rows):\nA B | Out\n0 0 | 0\n0 1 | 0\n1 0 | 0\n1 1 | 1\n3 inputs → 8 rows; 4 inputs → 16 rows',
    eng='Hardware verification compares circuit outputs against truth tables; formal verification proves equivalence.',
    mistakes='Missing input combinations; confusing rows with columns; not recognizing canonical forms.',
    practice=['How many rows for a 3-input truth table?', 'Create a truth table for OR.'],
    quiz=[
        q('A 3-input truth table has how many rows?', ['3', '6', '8', '9'], [2], '2³ = 8.'),
        q('A truth table completely describes:', ['A logic function', 'A CPU', 'A network', 'A database'], [0], 'Truth tables specify logic functions.'),
    ])

lesson(9, 16, 'Boolean Algebra',
    concept='Boolean algebra is the mathematics of binary variables and logic operations, using laws to simplify and manipulate logic expressions.',
    definition='Boolean algebra is a branch of algebra dealing with binary variables (0, 1) and operations (AND, OR, NOT), providing laws for simplification.',
    explanation='Boolean algebra has laws similar to ordinary algebra but with key differences (1+1=1). Basic laws: identity, null, idempotent, complement, commutative, associative, distributive, absorption, and involution. Simplification reduces the number of gates needed, saving cost and power in hardware.',
    worked='Absorption: A + AB = A\nA(A + B) = A\nDe Morgan: (A+B)\' = A\'B\'\n(AB)\' = A\' + B\'',
    eng='Logic synthesis tools apply Boolean laws automatically to minimize circuits before fabrication.',
    mistakes='Assuming Boolean algebra follows all ordinary algebra rules (1+1≠2); misapplying De Morgan\'s; not verifying simplifications.',
    practice=['Simplify A + AB.', 'Apply De Morgan\'s to (A+B)\'.'],
    quiz=[
        q('In Boolean algebra, 1 + 1 equals:', ['2', '1', '0', '11'], [1], 'Boolean 1+1=1.'),
        q('De Morgan\'s: (A + B)\' equals:', ['A\' + B\'', 'A\'B\'', 'AB', 'A + B'], [1], 'Complement of sum = product of complements.'),
    ])

lesson(9, 17, 'Boolean Laws',
    concept='Boolean laws (identity, domination, idempotent, complement, commutative, associative, distributive, absorption) are identities used to simplify expressions.',
    definition='Boolean laws are fundamental identities that hold for all values of Boolean variables, enabling expression simplification.',
    explanation='Key laws: Identity (A+0=A, A·1=A), Domination (A+1=1, A·0=0), Idempotent (A+A=A, A·A=A), Complement (A+A\'=1, A·A\'=0), Commutative, Associative, Distributive (A+BC=(A+B)(A+C)), Absorption (A+AB=A), De Morgan\'s. These let you reduce complex expressions to minimal forms.',
    worked='Simplify: A + A\'B\n= (A + A\')(A + B)  [distributive]\n= 1 · (A + B)       [complement]\n= A + B',
    eng='Logic minimization tools (Espresso) apply these laws to reduce gate count in chip design, saving area and power.',
    mistakes='Misapplying distributive law (Boolean differs from ordinary algebra); forgetting De Morgan\'s; not checking with truth tables.',
    practice=['Simplify A + A\'B.', 'State the absorption law.'],
    quiz=[
        q('The absorption law states A + AB equals:', ['AB', 'A', 'A + B', 'B'], [1], 'A absorbs AB.'),
        q('Complement law: A + A\' equals:', ['0', '1', 'A', 'A\''], [1], 'A OR NOT A = 1.'),
    ])

lesson(9, 18, 'De Morgan\'s Laws',
    concept='De Morgan\'s laws state that the complement of a sum equals the product of complements, and the complement of a product equals the sum of complements.',
    definition='De Morgan\'s laws are two transformation rules: (A+B)\' = A\'B\' and (AB)\' = A\'+B\', connecting AND, OR, and NOT.',
    explanation='These laws let you convert between AND and OR forms, essential for NAND/NOR implementations. For multiple variables: (A+B+C)\' = A\'B\'C\'. De Morgan\'s is used to convert SOP to POS forms, minimize circuits, and design with universal gates.',
    worked='(A + B)\' = A\'B\'\n(AB)\' = A\' + B\'\nExample: (XY + Z)\' = (XY)\'Z\' = (X\' + Y\')Z\'',
    eng='Chip designers use De Morgan\'s to implement logic with only NAND or only NOR gates for manufacturing efficiency.',
    mistakes='Applying De Morgan\'s to only part of an expression; confusing the two laws; not inverting all variables.',
    practice=['Apply De Morgan\'s to (A + B + C)\'.', 'Convert (AB)\' to sum form.'],
    quiz=[
        q('(AB)\' equals:', ['A\'B\'', 'A\' + B\'', 'A + B', 'AB'], [1], 'Complement of product = sum of complements.'),
        q('De Morgan\'s helps implement circuits using only:', ['AND gates', 'NAND or NOR gates', 'OR gates', 'XOR gates'], [1], 'Universal gate implementation.'),
    ])

lesson(9, 19, 'SOP — Sum of Products',
    concept='SOP (Sum of Products) is a canonical form where the output is expressed as OR of AND terms, directly mapping to two-level AND-OR logic.',
    definition='SOP is a standard Boolean expression form: the OR (sum) of product (AND) terms, each product being a minterm.',
    explanation='Each minterm is a product of all variables (true or complemented) for one row where the output is 1. SOP = OR of all minterms with output 1. It maps directly to AND-OR or NAND-NAND circuits. SOP is one of two canonical forms (the other is POS).',
    worked='F(A,B) = Σm(1, 2) [rows where F=1]\nRow 1: A=0,B=1 → A\'B\nRow 2: A=1,B=0 → AB\'\nF = A\'B + AB\' (XOR!)',
    eng='PLA (Programmable Logic Array) chips implement SOP forms directly; logic synthesizers output SOP netlists.',
    mistakes=['Confusing SOP with POS; missing minterms; not listing all variables in each term.'],
    practice=['Write the SOP for XOR.', 'Convert F = A\'B + AB to canonical SOP.'],
    quiz=[
        q('SOP stands for:', ['Sum of Products', 'Standard Ordered Form', 'Sequential OR Process', 'Simplified Output Pattern'], [0], 'Sum of Products.'),
        q('Each product term in SOP is called a:', ['Maxterm', 'Minterm', 'Midterm', 'Multiterm'], [1], 'Minterms are product terms.'),
    ])

lesson(9, 20, 'POS — Product of Sums',
    concept='POS (Product of Sums) is a canonical form where the output is expressed as AND of OR terms, directly mapping to two-level OR-AND logic.',
    definition='POS is a standard Boolean expression form: the AND (product) of sum (OR) terms, each sum being a maxterm.',
    explanation='Each maxterm is a sum of all variables (true or complemented) for one row where the output is 0. POS = AND of all maxterms with output 0. It maps to OR-AND or NOR-NOR circuits. POS is often simpler than SOP when the output has few 1s (many 0s).',
    worked='F(A,B) = ΠM(0, 3) [rows where F=0]\nRow 0: A=0,B=0 → (A + B)\nRow 3: A=1,B=1 → (A\' + B\')\nF = (A + B)(A\' + B\') (XNOR!)',
    eng='POS forms are used in NOR-based logic and programmable logic devices; synthesis tools choose the cheaper form.',
    mistakes=['Confusing POS with SOP; missing maxterms; not listing all variables in each term.'],
    practice=['Write the POS for XNOR.', 'When is POS simpler than SOP?'],
    quiz=[
        q('POS stands for:', ['Product of Sums', 'Primary Ordered Sum', 'Parallel OR System', 'Programmable Output Sequence'], [0], 'Product of Sums.'),
        q('Each sum term in POS is called a:', ['Minterm', 'Maxterm', 'Midterm', 'Minisum'], [1], 'Maxterms are sum terms.'),
    ])

lesson(9, 21, 'Karnaugh Maps',
    concept='A Karnaugh map (K-map) is a graphical method to simplify Boolean expressions by grouping adjacent 1s into the largest possible rectangles.',
    definition='A Karnaugh map is a grid representation of a truth table where adjacent cells differ by one variable, enabling visual simplification of Boolean functions.',
    explanation='K-maps work for 2–6 variables. Adjacent cells (including wrap-around) differ in one variable, so groups of 2ⁿ adjacent 1s eliminate n variables. Rules: groups must be rectangular, sizes 1/2/4/8/16, as large as possible, and can overlap. The result is a minimal SOP expression.',
    worked='K-map for F(A,B,C):\nGroup four 1s → eliminates 2 variables\nRemaining variable → product term\nSum of terms → minimal SOP',
    eng='Before CAD tools, engineers simplified logic by hand with K-maps; the technique remains essential for understanding minimization.',
    mistakes=['Non-rectangular groups; missing largest possible groups; ignoring wrap-around adjacency; grouping 0s for SOP.'],
    practice=['Simplify a 3-variable function using a K-map.', 'What is the maximum group size in a 4-variable K-map?'],
    quiz=[
        q('K-maps simplify by grouping adjacent:', ['0s', '1s', 'Any cells', 'Diagonals'], [1], 'Group 1s for SOP.'),
        q('Adjacent K-map cells differ by how many variables?', ['1', '2', '3', 'Any'], [0], 'One variable changes between neighbors.'),
    ])

lesson(9, 22, 'Half Adder',
    concept='A half adder adds two single bits, producing a sum and a carry, using XOR and AND gates.',
    definition='A half adder is a combinational circuit that adds two binary digits, producing a sum (XOR) and a carry (AND).',
    explanation='Sum = A ⊕ B (XOR), Carry = A · B (AND). The half adder cannot accept a carry-in, limiting it to single-bit addition. It is the foundation of all adders: full adders and multi-bit adders are built from half adders.',
    worked='A B | Sum Carry\n0 0 | 0   0\n0 1 | 1   0\n1 0 | 1   0\n1 1 | 0   1\nSum = A⊕B, Carry = AB',
    eng='Half adders are the atomic building block of ALUs; every addition in a CPU starts with half-adder logic.',
    mistakes=['Confusing half adder with full adder; thinking half adder handles carry-in; misremembering sum vs carry gates.'],
    practice=['What gates implement a half adder?', 'What is the carry when A=1, B=1?'],
    quiz=[
        q('The sum output of a half adder is:', ['AND', 'XOR', 'OR', 'NAND'], [1], 'Sum uses XOR.'),
        q('A half adder can add how many bits plus carry-in?', ['Two bits, no carry-in', 'Two bits with carry-in', 'Three bits', 'Four bits'], [0], 'Half adder has no carry-in.'),
    ])

lesson(9, 23, 'Full Adder',
    concept='A full adder adds three bits (A, B, and carry-in), producing a sum and a carry-out, built from two half adders and an OR gate.',
    definition='A full adder is a combinational circuit that adds two bits and a carry-in bit, producing a sum and a carry-out.',
    explanation='Sum = A ⊕ B ⊕ Cin. Carry-out = AB + Cin(A ⊕ B). A full adder is two half adders: the first adds A+B, the second adds the result + Cin. Chaining full adders creates multi-bit ripple-carry adders. Full adders are the core of ALU arithmetic.',
    worked='A B Cin | Sum Cout\n0 0 0  | 0   0\n1 0 0  | 1   0\n1 1 0  | 0   1\n1 1 1  | 1   1',
    eng='Ripple-carry adders chain full adders; carry-lookahead adders speed up carry propagation in modern CPUs.',
    mistakes=['Confusing full adder with half adder; thinking sum needs three XORs in series; ignoring carry propagation delay.'],
    practice=['What are the inputs of a full adder?', 'How is a full adder built from half adders?'],
    quiz=[
        q('A full adder has how many inputs?', ['2', '3', '4', '1'], [1], 'A, B, and carry-in.'),
        q('The carry-out of a full adder is:', ['A⊕B', 'AB + Cin(A⊕B)', 'A+B', 'Cin'], [1], 'Majority function of three inputs.'),
    ])

lesson(9, 24, 'Multiplexer',
    concept='A multiplexer (MUX) selects one of several input lines and forwards it to a single output based on select lines.',
    definition='A multiplexer is a combinational circuit that routes one of 2ⁿ input signals to a single output line using n select lines.',
    explanation='A MUX is a data selector: 2ⁿ inputs, n select lines, 1 output. The select lines form a binary number choosing which input passes through. MUXes implement arbitrary logic functions (any n-variable function with a 2ⁿ:1 MUX), route buses, and share communication lines.',
    worked='4:1 MUX: inputs D0–D3, selects S1S0\nS1S0=00 → D0, 01 → D1, 10 → D2, 11 → D3\nOutput = D0·S1\'S0\' + D1·S1\'S0 + D2·S1S0\' + D3·S1S0',
    eng='CPUs use multiplexers to select register outputs; communication systems multiplex channels onto shared media.',
    mistakes=['Confusing MUX with demux; miscounting select lines; thinking MUX stores data.'],
    practice=['How many select lines for an 8:1 MUX?', 'What does a MUX do?'],
    quiz=[
        q('An 8:1 MUX needs how many select lines?', ['2', '3', '4', '8'], [1], '2³ = 8 inputs.'),
        q('A MUX is a:', ['Memory device', 'Data selector', 'Clock generator', 'Amplifier'], [1], 'MUX selects inputs.'),
    ])

lesson(9, 25, 'Demultiplexer',
    concept='A demultiplexer (DEMUX) routes a single input to one of several output lines based on select lines — the inverse of a MUX.',
    definition='A demultiplexer is a combinational circuit that directs a single input signal to one of 2ⁿ output lines based on n select lines.',
    explanation='DEMUX is the reverse of MUX: 1 input, n selects, 2ⁿ outputs. The select lines choose which output receives the input; all others stay 0. Applications: data distribution, decoding addresses, and driving multiple displays or memory chips from one bus.',
    worked='1:4 DEMUX: input D, selects S1S0\nS1S0=00 → D0=D, others 0\nS1S0=01 → D1=D, others 0\n...',
    eng='Memory systems use demultiplexers as address decoders to select which chip receives data.',
    mistakes=['Confusing DEMUX with MUX; thinking DEMUX combines inputs; ignoring inactive outputs.'],
    practice=['What is the difference between MUX and DEMUX?', 'How many outputs for a 1:8 DEMUX?'],
    quiz=[
        q('A DEMUX has:', ['Many inputs, one output', 'One input, many outputs', 'One input, one output', 'Many inputs, many outputs'], [1], 'DEMUX splits one input to many outputs.'),
        q('A 1:8 DEMUX needs how many select lines?', ['2', '3', '4', '8'], [1], '2³ = 8 outputs.'),
    ])

lesson(9, 26, 'Encoder',
    concept='An encoder converts 2ⁿ input lines into an n-bit binary code representing the active input.',
    definition='An encoder is a combinational circuit that converts one-of-2ⁿ active input signals into an n-bit binary output code.',
    explanation='The inverse of a decoder. When input line i is active, the output is the binary representation of i. Priority encoders handle multiple active inputs by prioritizing the highest-numbered input. Applications: keyboards (key → binary), interrupt controllers, and position sensing.',
    worked='8:3 encoder: input I5 active → output 101 (binary 5)\nOnly one input active at a time (standard encoder)',
    eng='Keyboard encoders convert key presses to scan codes; rotary encoders convert position to digital signals.',
    mistakes=['Confusing encoder with decoder; assuming multiple simultaneous inputs (use priority encoder); miscounting output bits.'],
    practice=['What is the difference between an encoder and a decoder?', 'What is a priority encoder?'],
    quiz=[
        q('An encoder converts:', ['Binary to one-of-n', 'One-of-n to binary', 'Analog to digital', 'Serial to parallel'], [1], 'Encoders compress active lines to binary.'),
        q('An 8:3 encoder has how many outputs?', ['8', '3', '2', '24'], [1], '3 bits represent 8 inputs.'),
    ])

lesson(9, 27, 'Decoder',
    concept='A decoder converts an n-bit binary input into one of 2ⁿ output lines, activating exactly one output per input combination.',
    definition='A decoder is a combinational circuit that activates one of 2ⁿ output lines based on the n-bit binary input code.',
    explanation='The inverse of an encoder. For input code i, output line i is active (1), all others inactive (0). Decoders are used for address decoding (memory chips), display driving (7-segment), and instruction decoding in CPUs. A 3:8 decoder activates one of 8 outputs per 3-bit input.',
    worked='3:8 decoder: input 101 (5) → output Y5=1, all others 0\nY5 = A·B\'·C (for input 101)',
    eng='Memory address decoders select which RAM chip responds; instruction decoders in CPUs activate control signals.',
    mistakes=['Confusing decoder with encoder; thinking multiple outputs activate; ignoring enable inputs.'],
    practice=['What is the difference between a decoder and a demultiplexer?', 'How many outputs for a 4:16 decoder?'],
    quiz=[
        q('A decoder activates:', ['All outputs', 'One output per input code', 'Random outputs', 'No outputs'], [1], 'One output per code.'),
        q('A 4:16 decoder has how many inputs?', ['4', '16', '2', '8'], [0], '4-bit input selects 16 outputs.'),
    ])

lesson(9, 28, 'Flip-Flops',
    concept='A flip-flop is a bistable circuit storing one bit, the fundamental memory element in sequential logic.',
    definition='A flip-flop is a sequential circuit with two stable states that stores one bit of information, changing state on clock edges or inputs.',
    explanation='Flip-flops are the building blocks of registers, counters, and memory. Types: SR (set-reset), D (data/delay), JK (toggle-capable), and T (toggle). D flip-flops are most common: on a clock edge, Q takes the D input. Edge-triggered flip-flops change only at clock edges, avoiding glitches.',
    worked='D flip-flop: at rising clock edge, Q ← D\nQ holds its value between clock edges\nUsed in registers: 8 D flip-flops store one byte',
    eng='CPU registers, cache memory, and state machines all consist of flip-flop arrays; billions fit on a single chip.',
    mistakes=['Confusing latches with flip-flops; thinking flip-flops are combinational; ignoring setup/hold times.'],
    practice=['What is the difference between a latch and a flip-flop?', 'How many flip-flops store a byte?'],
    quiz=[
        q('A flip-flop stores:', ['One byte', 'One bit', 'One word', 'One address'], [1], 'One bit per flip-flop.'),
        q('A D flip-flop captures its input on:', ['Any time', 'The clock edge', 'Power-on', 'Never'], [1], 'Edge-triggered capture.'),
    ])

lesson(9, 29, 'Registers',
    concept='A register is a group of flip-flops storing multiple bits, with controls for loading, shifting, and clearing data.',
    definition='A register is a collection of flip-flops that stores a binary word, providing fast access for the CPU.',
    explanation='An n-bit register uses n flip-flops. Operations: parallel load (load all bits at once), shift left/right (move bits, used for multiplication/division), and clear. Registers are the CPU\'s fastest storage — instruction registers, general-purpose registers, and status registers. Shift registers convert between serial and parallel data.',
    worked='4-bit register: [Q3 Q2 Q1 Q0] stores 1011\nShift left: 0110 (MSB lost, LSB filled with 0 or input)\nShift right: 0101',
    eng='CPU register files hold 16–32 registers of 32–64 bits; shift registers drive serial communication (UART).',
    mistakes=['Confusing registers with cache; thinking registers are slow; ignoring shift register applications.'],
    practice=['What is a shift register?', 'How does a register differ from main memory?'],
    quiz=[
        q('A register is made of:', ['Capacitors', 'Flip-flops', 'Transistors only', 'Diodes'], [1], 'Flip-flops store register bits.'),
        q('Shift registers convert between:', ['Analog and digital', 'Serial and parallel data', 'High and low voltage', 'AC and DC'], [1], 'Serial ↔ parallel conversion.'),
    ])

lesson(9, 30, 'Counters',
    concept='A counter is a sequential circuit that cycles through a sequence of binary states, counting clock pulses.',
    definition='A counter is a register with feedback logic that advances its state on each clock pulse, counting events or measuring time.',
    explanation='Counters count clock pulses or events. Types: binary (counts 0 to 2ⁿ−1), decade (0–9), up/down (both directions), and ring/twisted-ring. Applications: frequency division, timekeeping, address generation, and digital clocks. Counters are built from flip-flops with feedback.',
    worked='3-bit binary counter: 000→001→010→011→100→101→110→111→000\nDivides frequency by 8 (2³)',
    eng='Digital watches use counters for seconds/minutes; CPUs use program counters to track instruction addresses.',
    mistakes=['Confusing counters with registers; thinking counters only count up; ignoring ripple vs synchronous counters.'],
    practice=['What does a counter count?', 'What is the difference between a 3-bit and 4-bit counter range?'],
    quiz=[
        q('A counter advances its state on:', ['Input data', 'Clock pulses', 'Power cycles', 'Random events'], [1], 'Counters count clock edges.'),
        q('A 3-bit counter counts up to:', ['7', '8', '15', '16'], [0], '0 to 2³−1 = 7.'),
    ])

lesson(9, 31, 'Sequential Circuits',
    concept='Sequential circuits have memory: their outputs depend on current inputs AND past states, unlike combinational circuits.',
    definition='A sequential circuit is a digital circuit whose outputs depend on both current inputs and the history of inputs (stored state).',
    explanation='Combinational circuits (gates, MUXes) output based only on current inputs. Sequential circuits add feedback and memory (flip-flops), enabling state machines, registers, counters, and memory. Design: state diagram → state table → flip-flop input equations. Synchronous sequential circuits use a clock.',
    worked='State machine: states + transitions + outputs\nExample: traffic light (red → green → yellow → red)\nImplemented with flip-flops storing current state',
    eng='Every digital system with memory — CPUs, communication protocols, control systems — is a sequential circuit.',
    mistakes=['Assuming all circuits are combinational; ignoring clock synchronization; confusing state diagrams with schematics.'],
    practice=['What is the difference between combinational and sequential circuits?', 'What is a state machine?'],
    quiz=[
        q('Sequential circuits differ from combinational by having:', ['More gates', 'Memory/feedback', 'Faster speed', 'Fewer inputs'], [1], 'Memory defines sequential logic.'),
        q('Sequential circuits are designed using:', ['Truth tables only', 'State diagrams and tables', 'Ohm\'s law', 'Karnaugh maps only'], [1], 'State-based design.'),
    ])

formula('Digital Logic', 'Boolean Complement', 'A + A\' = 1, A · A\' = 0', 'A\': complement of A', 'Boolean algebra identities')
formula('Digital Logic', 'De Morgan\'s Theorem', '(A + B)\' = A\'B\', (AB)\' = A\' + B\'', '\': complement operation', 'Logic transformation')
formula('Digital Logic', 'Half Adder', 'Sum = A ⊕ B, Carry = AB', '⊕: XOR; ·: AND', 'Binary addition')
