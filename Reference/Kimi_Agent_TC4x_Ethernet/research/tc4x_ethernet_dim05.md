# Dimension 5: AVB & IEEE 1722 AVTP Protocol on Infineon AURIX TC4x

## Table of Contents
1. [AVB Overview](#1-avb-overview)
2. [IEEE 1722 AVTP Protocol](#2-ieee-1722-avtp-protocol)
3. [Supported AVTP Subtypes](#3-supported-avtp-subtypes)
4. [CAN Encapsulation over AVTP (ACF)](#4-can-encapsulation-over-avtp-acf)
5. [DRE Integration](#5-dre-integration)
6. [Stream Reservation: IEEE 802.1Qat (SRP)](#6-stream-reservation-ieee-8021qat-srp)
7. [Hardware Features: AV-Specific DMA](#7-hardware-features-av-specific-dma)
8. [AUTOSAR IEEE1722Tp Module](#8-autosar-ieee1722tp-module)
9. [References](#9-references)

---

## 1. AVB Overview

### 1.1 What is AVB (Audio Video Bridging)

Audio Video Bridging (AVB) is a set of IEEE standards originally developed to support synchronized audio and video transmission across Ethernet networks. It introduced mechanisms for time synchronization and bandwidth reservation, enabling media streams to maintain consistent timing [^206^].

In automotive systems, AVB was commonly used for:
- In-vehicle infotainment (IVI)
- Rear-seat entertainment systems
- Audio distribution across speakers
- Camera streaming to displays
- ADAS sensor data streaming

### 1.2 AVB vs TSN: Key Differences

TSN (Time-Sensitive Networking) builds on the concepts introduced by AVB but expands them significantly. TSN provides more comprehensive mechanisms for traffic scheduling, priority control, and deterministic communication [^206^].

| Aspect | AVB | TSN |
|--------|-----|-----|
| **Primary Use Case** | Media streaming (audio/video) | Mixed-critical systems (control + media) |
| **Traffic Support** | Primarily media streams | Both media streams and control traffic |
| **Scheduling** | Credit-based shaper (802.1Qav) | Time-aware shaper (802.1Qbv), multiple shapers |
| **Standards** | 802.1BA, 802.1Qav, 802.1Qat, 802.1AS | Superset including 802.1Qbv, 802.1Qbu, 802.1CB, 802.1Qci |
| **Synchronization** | gPTP (802.1AS) | Enhanced gPTP (802.1AS-2020) |
| **Automotive Fit** | Early step toward deterministic Ethernet | Broader framework for SDV-era platforms |
| **Stream Setup** | SRP (dynamic reservation) | Static configuration or CNC/CUC (802.1Qcc) |

> "For this reason, automotive Ethernet architectures increasingly treat AVB as an early step toward deterministic Ethernet, while TSN represents the broader framework needed for SDV-era vehicle platforms." [^206^]

### 1.3 AVB Protocol Stack

The AVB protocol suite consists of:

- **IEEE 802.1AS**: Timing and Synchronization (gPTP) - provides sub-microsecond time synchronization
- **IEEE 802.1Qav**: Forwarding and Queuing Enhancements for Time-Sensitive Streams (credit-based shaper)
- **IEEE 802.1Qat**: Stream Reservation Protocol (SRP) - reserves bandwidth along the path
- **IEEE 802.1BA**: Audio Video Bridging (AVB) Systems - defines profiles and requirements
- **IEEE 1722**: Audio Video Transport Protocol (AVTP) - the actual data transport protocol
- **IEEE 1722.1**: Device Discovery, Connection Management and Control (AVDECC)

### 1.4 Relevance in Automotive

In modern zonal E/E architectures, AVB/TSN protocols serve critical roles:

- **High-bandwidth streaming**: Camera, lidar, radar sensor data to central compute
- **Audio distribution**: Multi-channel audio with phase synchronization (< 1 us accuracy)
- **Legacy tunneling**: CAN/LIN frames over Ethernet backbone via IEEE 1722 ACF
- **Deterministic control**: Time-sensitive control commands with guaranteed latency

As stated by Excelfore: "TSN builds on this foundation, adding precise scheduling, time synchronization, and traffic shaping so that Ethernet can support both high-bandwidth sensor data and real-time control traffic within the same network infrastructure." [^207^]

---

## 2. IEEE 1722 AVTP Protocol

### 2.1 AVTP Overview

IEEE 1722 defines the Audio Video Transport Protocol (AVTP), which operates at Layer 2 directly over Ethernet with EtherType **0x22F0**. It does not require IP/UDP and avoids the unpredictable delays of the TCP/IP protocol stack [^208^][^37^].

> "IEEE 1722 enables interoperable streaming by defining: Media formats and encapsulations, Media synchronization mechanisms, Multicast address assignment" [^37^]

### 2.2 AVTP Packet Format

An AVTP packet (AVTPDU) is encapsulated within an Ethernet frame as follows [^208^][^37^]:

```
+--------------------------------------------------+
| Ethernet Header (14 bytes)                       |
|   - Destination MAC Address (6 bytes)            |
|   - Source MAC Address (6 bytes)                 |
|   - EtherType = 0x22F0 (2 bytes)                 |
+--------------------------------------------------+
| 802.1Q VLAN Tag (4 bytes, optional)              |
|   - TCI (PCP + CFI + VID)                        |
+--------------------------------------------------+
| AVTP Common Header (4 bytes)                     |
|   - subtype (1 byte)                             |
|   - sv, version, mr/tv/tu/etc. flags             |
|   - sequence_num                                 |
+--------------------------------------------------+
| AVTP Stream-Specific Header                      |
|   (format depends on subtype)                    |
+--------------------------------------------------+
| AVTP Payload                                     |
|   (media data, ACF messages, etc.)               |
+--------------------------------------------------+
| CRC/FCS (4 bytes)                                |
+--------------------------------------------------+
```

### 2.3 AVTP Common Header Format

The AVTPDU common header is shared by all AVTP formats [^37^][^214^]:

```
Byte 0:
  [7]   - h (header specific, used in 1722-2016 for compatibility)
  [6:0] - subtype (7 bits): defines the payload format

Byte 1:
  [7]   - cd (control/data, removed in 1722-2016, MSB of subtype)
  [6:0] - subtype-specific fields

Byte 2:
  [7]   - sv (stream_id valid)
  [6:4] - version (typically 0)
  [3:0] - type_specific_data (media clock restart, timestamp valid, etc.)

Bytes 3-11: stream_id (64 bits)
  - MAC address part (48 bits) + unique_id (16 bits)
```

### 2.4 AVTPDU Common Stream Header

For streaming subtypes (AAF, RVF, 61883_IIDC, CRF, TSCF), the common stream header includes [^37^][^252^]:

| Field | Size | Description |
|-------|------|-------------|
| mr | 1 bit | Media clock restart - indicates change in media clock source |
| r | 1 bit | Reserved |
| gv | 1 bit | Gateway info valid |
| tv | 1 bit | AVTP timestamp valid |
| sequence_num | 8 bits | Sequence number for packet loss detection |
| tu | 1 bit | Timestamp uncertain - set when gPTP sync has problems |
| avtp_timestamp | 32 bits | AVTP presentation time (nanoseconds, gPTP time base) |
| gateway_info | 64 bits | Gateway-specific information |
| stream_data_length | 16 bits | Length of payload following protocol-specific header |
| protocol_specific_header | variable | Format-specific header |
| stream_payload_data | variable | Actual media/control data |

### 2.5 Stream ID and Multicast Addressing

**Stream ID Format** (64 bits) [^209^]:
- Upper 48 bits: Talker's EUI-48 MAC address
- Lower 16 bits: Unique stream identifier (per device)

The Stream ID provides globally unique identification for each AVTP stream within a network. It is used by listeners to filter and identify streams.

**Multicast Address Assignment** [^209^]:
- AVTP streams typically use Ethernet multicast destination addresses
- Reserved MAC address range: **91-E0-F0-00-00-00** to **91-E0-F0-00-FF-FF**
- **91-E0-F0-00-00-00** to **91-E0-F0-00-FD-FF**: MAAP dynamic allocation pool
- **91-E0-F0-00-FE-00** to **91-E0-F0-00-FE-FF**: Locally administered pool (static config)

The MAAP (Media Address Allocation Protocol, IEEE 1722 Clause 9/Annex B) allows talkers to dynamically acquire multicast addresses from the reserved pool without manual configuration [^37^].

### 2.6 Presentation Time Mechanism

The AVTP presentation time is the core mechanism for synchronizing media playback across multiple listeners [^38^][^275^].

**Key formula**:
```
T_avtpPresentationTime = T_currentGlobalTime + T_maxTransitTime
```

Where:
- **T_currentGlobalTime**: The gPTP time when the media sample/event was generated
- **T_maxTransitTime**: The worst-case transit time from talker to listener(s)
- **T_avtpPresentationTime**: The gPTP time when the data should be presented

**Default Max Transit Times** [^275^][^280^]:

| SR Class | Max Transit Time |
|----------|-----------------|
| Class A | 2.0 ms (rounded to media clock period multiple) |
| Class B | 50.0 ms (automotive: reduced to 10 ms) |

The AUTOSAR IEEE1722Tp module defines:
> "The AVTP presentation time represents the gPTP time at which designated data within an AVTPDU payload is transferred to a time-sensitive application of an stream data consumer." [^38^]

**Presentation Time Workflow**:
1. Talker generates media sample and captures gPTP time (tG)
2. Talker calculates presentation time: tP = tG + tMT
3. tP is placed in the avtp_timestamp field (tv=1 when valid)
4. Listener buffers received data until gPTP time reaches tP
5. Data is then passed to the time-sensitive application

This mechanism compensates for variable network transit times and ensures all listeners render media simultaneously [^37^][^275^].

### 2.7 Media Clock Reconstruction

Media clock reconstruction is essential for long-term playback stability [^37^][^217^].

**The Problem**:
- Each AVB device has its own local clock
- Even with gPTP time synchronization, media clocks (e.g., 48kHz audio sample clock) can drift relative to each other
- Over time, this causes buffer overflow or underflow

**CRF-Based Clock Recovery**:
The Clock Reference Format (CRF) provides dedicated clock reference streams:

1. A **Media Clock Provider** (talker) sends CRF packets containing timestamps correlated to the media clock rate
2. **Media Clock Consumers** (listeners) receive the CRF stream and recover their local media clock using a PLL (Phase-Locked Loop)
3. The CRF stream itself is small and typically uses the same SR class priority as the associated media stream [^209^]

> "CRF is useful in synchronizing events within different systems by distributing a common clock. This is useful in a scenario where there are multiple talkers who are sending data to a single listener which is processing that data." [^217^]

**Media Clock Recovery without PLL** (patented approach):
> "Calculating a plurality of differences between timestamps of adjacent CRF packets, calculating an average difference of timestamps, and establishing a recovered frequency of a master clock based on the calculated average difference." [^222^]

---

## 3. Supported AVTP Subtypes

IEEE 1722-2016 defines multiple AVTPDU subtypes (Table 6 of the standard). The following subtypes are relevant to automotive applications on TC4x [^214^][^220^]:

| Subtype Value | Name | Description | AUTOSAR Support |
|---------------|------|-------------|-----------------|
| 0x00 | 61883_IIDC | IEC 61883/IIDC over AVTP | Yes (CP R24-11) |
| 0x02 | AAF | AVTP Audio Format | Yes (CP R24-11) |
| 0x03 | CRF | Clock Reference Format | Yes (CP R24-11) |
| 0x04 | CVF | Compressed Video Format | Partial |
| 0x05 | TSCF | Time-Synchronous Control Format | Yes (CP R24-11) |
| 0x07 | RVF | Raw Video Format | Yes (CP R24-11) |
| 0x7E | MAAP | MAC Address Acquisition Protocol | N/A |
| 0x82 | NTSCF | Non-Time-Synchronous Control Format | Yes (CP R24-11) |

### 3.1 AAF - AVTP Audio Format

AAF (Clause 7 of IEEE 1722-2016) is designed for uncompressed digital audio streaming [^239^][^240^].

**Supported Formats**:
- **PCM**: Pulse Code Modulation (raw audio)
- **AES3**: AES/EBU digital audio interface

**AAF PCM Header Fields**:
- `format`: Indicates PCM encapsulation
- `nsr` (nominal sample rate): 8kHz to 192kHz
- `sp` (sparse timestamp): Normal or sparse timestamp mode
- `channels_per_frame`: Number of audio channels
- `bit_depth`: 16, 24, or 32 bits
- `pcm_data_payload`: The actual audio samples

**AAF PCM Configurations** (Milan specification) [^239^][^240^]:

| Sample Rate | Channels | Bit Depth | Samples/PDU | Frame Period |
|-------------|----------|-----------|-------------|--------------|
| 48 kHz | 1-8 | 32-bit | 6 | 125 us (Class A) |
| 96 kHz | 1-8 | 32-bit | 12 | 125 us (Class A) |
| 192 kHz | 1-8 | 32-bit | 24 | 125 us (Class A) |

> "AAF through AVTP presentation time achieves cross-speaker phase synchronization, meeting <1us synchronization accuracy requirements." [^209^]

**AUTOSAR AAF Configuration** [^214^]:
```
IEEE1722TpStreamAAF:
  - IEEE1722TpStreamAafFormat (PCM or AES3)
  - IEEE1722TpStreamAafPcmNominalSampleRate
  - IEEE1722TpStreamAafPcmChannelsPerFrame
  - IEEE1722TpStreamAafPcmBitDepth
  - IEEE1722TpStreamAafSparseTimestamp
```

### 3.2 RVF - Raw Video Format

RVF (Clause 12 of IEEE 1722-2016) is designed for raw (uncompressed) video streaming [^214^][^234^].

**RVF Header Fields** [^214^][^283^]:
- `active_pixels`: Number of active pixels per line (16 bits)
- `total_lines`: Total number of lines in the frame (16 bits)
- `ap` (active pixels): Flag indicating active pixel data
- `f` (field): Field indicator for interlaced video
- `ef` (end frame): End of frame marker
- `evt`: Event field (4 bits)
- `pd` (pull-down): Pull-down flag
- `i` (interlaced): Interlaced/progressive indicator
- `pixel_depth`: Bit depth per pixel (4 bits)
- `pixel_format`: Pixel format code (4 bits)
- `frame_rate`: Frame rate (8 bits)
- `colorspace`: Color space (4 bits: RGB, YUV, etc.)
- `num_lines`: Number of lines in this PDU (4 bits)
- `i_seq_num`: Interlace sequence number (8 bits)
- `line_number`: Starting line number in this PDU (16 bits)

RVF allows a video frame to be split across multiple AVTPDUs, enabling transport of large video frames over standard Ethernet MTU.

### 3.3 61883_IDC - IEC 61883 over AVTP

IEC 61883/IIDC over AVTP (Clause 5 of IEEE 1722-2016) is the original format from IEEE 1722-2011, retained for backward compatibility [^214^].

**Encapsulation Modes**:
- **61883-6**: Uncompressed audio (AM824/MBLA format)
- **61883-4**: MPEG2-TS container for compressed video
- **61883-8**: BT.601/656 video
- **IIDC**: Industrial camera (IEEE 1394) uncompressed video

**61883 CIP Header Fields** (within AVTP payload):
- `tag` (2 bits): Quadlet indicator
- `channel` (6 bits): Isochronous channel
- `tcode` (4 bits): Transaction code
- `sy` (4 bits): Synchronization timing
- `SID` (6 bits): Source identifier
- `DBS` (8 bits): Data block size
- `FN` (2 bits): Fraction number
- `QPC` (3 bits): Quadlet padding count
- `SPH` (1 bit): Source packet header present
- `DBC` (8 bits): Data block count
- `FMT` (6 bits): Stream format
- `FDF` (8 bits): Format dependent field

### 3.4 CRF - Clock Reference Format

CRF (Clause 10 of IEEE 1722-2016) provides a dedicated mechanism for distributing media clock references [^214^][^278^].

**CRF Header Fields**:
- `mr` (media clock reset): 1 bit
- `fs` (frame sync): 1 bit
- `type`: CRF type (8 bits)
  - AUDIO_SAMPLE (0x00)
  - VIDEO_FRAME_SYNC (0x02)
  - VIDEO_LINE_SYNC (0x03)
- `pull`: Pull factor (3 bits)
  - PULL_1_0 (0x00): Multiply by 1.0
  - PULL_1_001 (0x01): Multiply by 1.001
  - PULL_1_1_001 (0x02): Multiply by 1/1.001
  - PULL_24_25 (0x03): Multiply by 24/25
  - PULL_25_24 (0x04): Multiply by 25/24
  - PULL_1_8 (0x05): Multiply by 1/8
- `base_frequency`: Base frequency in Hz (29 bits)
- `timestamp_interval`: Interval between timestamps (16 bits)
- `crf_data`: Variable-length timestamp data

**Example CRF Configurations** [^278^]:

| Media Clock | base_frequency | timestamp_interval | Timestamp Freq |
|-------------|---------------|-------------------|----------------|
| 48 kHz | 48000 | 96 | 500 Hz (2 ms) |
| 96 kHz | 96000 | 192 | 500 Hz (2 ms) |
| 192 kHz | 192000 | 384 | 500 Hz (2 ms) |

> "An AVB Class A Stream Reservation shall be used to transmit an Avnu Pro Audio CRF Media Clock Stream." [^278^]

### 3.5 ACF - AVTP Control Format (TSCF/NTSCF)

ACF (Clause 9 of IEEE 1722-2016) defines a format for tunneling control messages over AVTP [^214^][^229^]. This is the most important format for automotive gateway applications.

ACF provides two header variants:

#### 3.5.1 NTSCF - Non-Time-Synchronous Control Format (subtype 0x82)

NTSCF is used for time-insensitive, lightweight control commands [^229^][^232^].

**NTSCF Header Fields**:
- `sv` (stream_id_valid): Always set to 1
- `version`: Protocol version
- `ntscf_data_length`: Length of ACF payload in octets (16 bits)
- `sequence_num`: Sequence number (8 bits)
- `stream_id`: 64-bit stream identifier
- `acf_payload`: Contains one or more ACF messages

**Use case**: CAN frame tunneling where strict timing synchronization is not required. Messages are processed in arrival order.

#### 3.5.2 TSCF - Time-Synchronous Control Format (subtype 0x05)

TSCF carries a presentation timestamp and is used for time-sensitive control requiring multi-actuator coordination [^229^][^232^].

**TSCF Header Fields**:
- All common stream header fields (including avtp_timestamp)
- `stream_data_length`: Length of ACF payload in octets (16 bits)
- `acf_payload`: Contains one or more ACF messages

**Use case**: Chassis control (steering, braking) where multiple ECUs must execute commands simultaneously based on the global time base.

> "For TSCF streams, the 1722Tp module retrieves synchronized time for each frame and fills the timestamp in the frame header. These timestamps enable the receiving end to align control commands from different ECUs to a unified time base." [^209^]

#### 3.5.3 ACF Message Format

Each ACF message within the payload consists of [^214^]:

```
+------------------+------------------+
| ACF Message Type | Payload Length   |
| (7 bits)         | (9 bits)         |
+------------------+------------------+
| ACF Message Payload (variable)       |
+--------------------------------------+
```

**ACF Message Types**:

| Value | Name | Description |
|-------|------|-------------|
| 0x00 | ACF_MSG_GPC | Generic Precision Control |
| 0x01 | ACF_CAN | CAN/CAN FD message |
| 0x02 | ACF_CAN_BRIEF | Abbreviated CAN/CAN FD message |
| 0x03 | ACF_LIN | LIN message |
| 0x04 | ACF_FLEXRAY | FlexRay message |
| 0x05 | ACF_MOST | MOST message |
| 0x06 | ACF_SENSOR | Sensor message |
| 0x07 | ACF_SENSOR_BRIEF | Abbreviated sensor message |

Multiple ACF messages of different types can be concatenated in a single ACF payload [^214^].

---

## 4. CAN Encapsulation over AVTP (ACF)

### 4.1 ACF_CAN Message Format

ACF_CAN encapsulates full CAN 2.0 and CAN FD frames [^38^][^214^].

**ACF_CAN Header Fields**:
- `pad`: Padding length (to align payload to 32-bit boundary)
- `mtv`: Message timestamp valid (1 bit)
- `rtr`: Remote transmission request (1 bit)
- `eff`: Extended frame format (1 bit, 0=11-bit CAN ID, 1=29-bit CAN ID)
- `brs`: Bit rate switch (1 bit, CAN FD)
- `fdf`: CAN FD format (1 bit, 0=CAN 2.0, 1=CAN FD)
- `esi`: Error state indicator (1 bit)
- `can_bus_id`: CAN bus identifier (5 bits)
- `message_timestamp`: Current synchronized gPTP time (64 bits)
- `can_identifier`: CAN ID (29 bits)
- `can_msg_payload`: CAN data (up to 8 bytes for CAN 2.0, up to 64 bytes for CAN FD)

**Message Size**: 16-24 octets payload for Classic CAN [^237^]

### 4.2 ACF_CAN_BRIEF Message Format

ACF_CAN_BRIEF is an abbreviated format that omits the message timestamp [^38^][^214^].

**ACF_CAN_BRIEF Header Fields**:
- Same as ACF_CAN but **without** `message_timestamp` field
- `pad`, `mtv` (always 0), `rtr`, `eff`, `brs`, `fdf`, `esi`
- `can_bus_id`, `can_identifier`, `can_msg_payload`

**Message Size**: 8-16 octets payload for Classic CAN [^237^]

> "ACF_CAN_BRIEF has no timestamp field defined" [^38^]

### 4.3 CAN over AVTP Workflow

**Transmit Direction** (CAN -> Ethernet):
1. CAN controller receives a CAN frame
2. CanIf forwards the L-SDU to IEEE1722Tp via LSduR
3. IEEE1722Tp encapsulates the CAN frame into ACF_CAN or ACF_CAN_BRIEF
4. Multiple ACF messages may be collected into one ACF payload
5. The ACF payload is transmitted as an NTSCF or TSCF stream
6. Trigger conditions (frame count, timeout, buffer fill level) determine when to send

**Receive Direction** (Ethernet -> CAN):
1. Ethernet MAC receives AVTP frame with ACF subtype
2. IEEE1722Tp inspects ACF payload and unpacks ACF messages
3. Each ACF_CAN message is forwarded via LSduR to CanIf
4. CanIf transmits the CAN frame on the appropriate CAN bus

**Collection Parameters** [^209^]:
- `AcfCollectionThreshold`: Maximum accumulated payload size before transmission
- `AcfCollectionTimeout`: Maximum time to wait before sending collected messages
- Example: threshold=1500 bytes, timeout=1ms

---

## 5. DRE Integration

### 5.1 DRE Overview

The Data Routing Engine (DRE) is a hardware accelerator on the AURIX TC4x that routes CAN frames to/from Ethernet and between CAN interfaces without CPU intervention [^216^][^219^].

**Key Features** [^216^]:
- Routing of CAN frames to or from Ethernet IEEE 1722 ACF frames
- Routing of CAN frames between different MCMCAN modules
- Routing of CAN frames to configurable memory address locations
- Protocol translation between different message formats

> "The Data Routing Engine is aligned to the AVTP Control frame format defined by IEEE 1722-2016" [^216^]

**DRE Capabilities for IEEE 1722**:
- Supports Non-Time-Synchronous Control Format header (NTSCF)
- Supports Abbreviated CAN/CAN FD message type (ACF_CAN_BRIEF)
- Multiple Ethernet transmit trigger modes
- Optional user configuration for Ethernet 802.3 MAC header and 802.1Q Tag field
- CAN frame filtering (classical ID filter mode)

### 5.2 DRE Ethernet Transmit Trigger Modes

The DRE supports four trigger modes for Ethernet transmission [^216^]:

| Trigger Mode | Description |
|--------------|-------------|
| **Frame count** | Transmit after collecting a configured number of CAN frames |
| **Buffer fill level** | Transmit when buffer reaches configured fill level |
| **Time-triggered** | Transmit at configured time intervals |
| **Software-triggered** | CPU-initiated transmission |

These modes allow flexible latency/bandwidth trade-offs for different automotive use cases.

### 5.3 DRE System Integration

**Bus Interfaces** [^216^]:
- **SPB master**: Fetches/routes CAN frames from/to MCMCAN modules
- **SRI master**: Fetches/routes CAN/Ethernet frames from/to internal memory
- **SRI slave**: Application software can monitor Message RAM
- **CRE interface**: Direct trigger signals from CAN Routing Engine
- **Interrupt Router**: Service requests for various DRE events

### 5.4 DRE Application Example: CAN-to-Ethernet Gateway

A typical gateway use case [^216^]:
1. CAN frame arrives at source CAN interface
2. CRE detects frame and triggers DRE
3. DRE reads CAN frame from Rx Host Buffer
4. DRE encapsulates frame into ACF_CAN_BRIEF format
5. DRE adds Ethernet header (MAC + 802.1Q if configured)
6. DRE places frame in Ethernet Tx buffer
7. GETH MAC transmits the Ethernet frame

**Advantages** [^216^]:
- Accelerated data routing and protocol translation
- CPU offloading - zero CPU intervention for routing
- Supports protocol translation to other Ethernet-based protocols (SOME/IP) with CAN-to-memory routing

### 5.5 DRE Frame Filtering

The DRE supports classical CAN ID filtering for tunneled frames [^216^]:
- ID-based filtering: Only specific CAN IDs are forwarded
- Mask-based filtering: Range-based filtering with ID mask
- This allows selective forwarding of critical CAN frames over Ethernet

---

## 6. Stream Reservation: IEEE 802.1Qat (SRP)

### 6.1 SRP Overview

IEEE 802.1Qat Stream Reservation Protocol (SRP) was originally defined for AVB networks to dynamically reserve bandwidth along the path from talker to listener(s) [^218^][^227^].

**SRP Functions** [^218^]:
- Automatically creates a path with guaranteed bandwidth from Talker to Listener(s)
- Assures non-compliant devices cannot corrupt reserved streams
- Supports up to 7 SR classes (A, B, ..., G)
- Error reporting for failed reservations
- Emergency stream support (override non-emergency streams)
- Calculates latency along the path

**SRP Protocol Suite**:
- Multiple Registration Protocol (MRP)
- Multiple Stream Registration Protocol (MSRP)
- Multiple VLAN Registration Protocol (MVRP)
- Multiple MAC Registration Protocol (MMRP)

### 6.2 SRP in Automotive: Status

**SRP is NOT used in automotive applications**. The industry has moved to alternative approaches:

> "AUTOSAR do not support stream reservation protocol (SRP)" [^214^]

**Reasons SRP is not used in automotive**:
1. **Complexity**: SRP requires dynamic signaling across the network, adding protocol overhead
2. **Startup time**: SRP negotiation takes time, which is unacceptable for automotive boot requirements
3. **Static networks**: Automotive E/E networks are largely static - stream configurations are known at design time
4. **TSN alternatives**: Newer TSN standards provide better mechanisms:
   - **IEEE 802.1Qcc**: Centralized Network Configuration (CNC) for static configuration
   - **IEEE 802.1Qbv**: Time-aware scheduling provides deterministic transmission without reservation
   - **IEEE 802.1Qbu**: Frame preemption for mixed-critical traffic

**Automotive Alternative**:
- Static stream configuration at design time
- Stream parameters (bandwidth, priority, VLAN) configured in ECU flash
- TSN features (802.1Qbv gate schedules) provide deterministic behavior without dynamic reservation
- SOME/IP Service Discovery handles service-level discovery, not stream reservation

### 6.3 SR Classes

Despite SRP not being used, the SR (Stream Reservation) class concept remains relevant:

| SR Class | Observation Interval | Max Transit Time | PCP (VLAN Priority) | Use Case |
|----------|---------------------|------------------|---------------------|----------|
| Class A | 125 us | 2 ms | 3 | Critical real-time audio/control |
| Class B | 250 us | 10-50 ms | 2 | Non-critical media streaming |

The PCP values identify SR traffic in the VLAN tag for priority queuing [^227^].

---

## 7. Hardware Features: AV-Specific DMA

### 7.1 GETH AV Mode Features

The TC4x GETH (Gigabit Ethernet MAC) includes dedicated Audio/Video (AV) features inherited from the Synopsys DWC_ether_qos IP, which provides hardware support for AVB/TSN traffic [^133^]:

**AV Features**:
- Separate channels or queues for AV data transfer in 100 Mbps and 1000 Mbps modes
- IEEE 802.1Qav specified credit-based shaper (CBS) algorithm for Transmit channels
- Single Tx FIFO and Rx FIFO (MTL) for all selected queues
- **Programmable Slot Interval** with range from 1us to 4096us and granularity of 1us

> "DWC_ether_qos supports the following Audio Video (AV) features: Separate channels or queues for AV data transfer... Programmable Slot Interval with range from 1us to 4096us and granularity of 1us" [^133^]

### 7.2 Programmable Slot Interval (SLOTNUM)

The **Slot Interval** feature is a key AV-specific hardware capability:

- **Purpose**: Defines the time slot interval for AV traffic scheduling
- **Range**: 1us to 4096us (programmable with 1us granularity)
- **Usage**: Corresponds to the AVB observation interval (125us for Class A, 250us for Class B)
- **Location**: Configured via GETH MAC registers

This slot interval mechanism allows the DMA to align transmit operations with the AVB timing grid, ensuring frames are prepared and transmitted at the correct times within the credit-based shaping algorithm.

### 7.3 Generic Queuing Support

The GETH provides programmable queuing for AV streams [^133^]:
- Routing of multicast/broadcast packets to programmable receive queues
- Routing of VLAN-tagged and untagged IEEE 1588 PTP packets to programmable queues
- Routing of unicast/multicast packets that fail DA filtering to separate queues
- Statistical counters to calculate bandwidth served by each transmit channel when AV/DCB support is enabled

### 7.4 Credit-Based Shaper (CBS)

The hardware implements IEEE 802.1Qav CBS for transmit channels:
- Each AV queue has a credit counter
- Credit accumulates at `idleSlope` when queue is empty
- Credit depletes at `sendSlope` when frames are transmitted
- Frames can only be sent when credit is non-negative
- This ensures SR classes get their reserved bandwidth

### 7.5 DMA Channel Architecture

The GETH DMA supports multiple channels with AV-specific capabilities:
- **Tx DMA Channels**: Separate channels can be mapped to different traffic classes (SR Class A, SR Class B, Best Effort)
- **Rx DMA Channels**: Separate queues for AV traffic, PTP frames, and general traffic
- **Descriptor Rings**: Each channel has its own descriptor ring for buffer management

---

## 8. AUTOSAR IEEE1722Tp Module

### 8.1 Module Overview

The IEEE1722Tp module is the AUTOSAR Basic Software module that implements the IEEE 1722 transport protocol for time-sensitive applications [^214^].

**Module Purpose**:
> "The task of the IEEE1722Tp module is to process transmit requests and receive indications of IEEE1722Tp-related streams and forward particular AVTPDU-header information and payload via the LSduR to the according destination module(s)." [^214^]

**Position in AUTOSAR Stack**:
```
+--------------------------------------------------+
| Application / CDD (Stream Producer/Consumer)       |
+--------------------------------------------------+
| LSduR (Link Layer SDU Router)                      |
+--------------------------------------------------+
| IEEE1722Tp (Transport Layer)     <- THIS MODULE   |
+--------------------------------------------------+
| EthIf (Ethernet Interface)                         |
+--------------------------------------------------+
| Eth (Ethernet Driver/GETH MAC)                     |
+--------------------------------------------------+
```

### 8.2 Supported Scenarios (R24-11)

The IEEE1722Tp module supports the following scenarios [^214^]:

1. **Audio/Video Streaming**:
   - Transmission requests for AAF, 61883_IIDC, RVF streams (stream data producer)
   - Reception indication for AAF, 61883_IIDC, RVF streams (stream data consumer)

2. **Media Clock Distribution**:
   - Transmission requests for CRF streams (media clock provider)
   - Reception indication for CRF streams (media clock consumer)

3. **CAN/LIN Tunneling over ACF**:
   - Encapsulation of CAN/LIN frames to ACF_CAN/ACF_CAN_BRIEF/ACF_LIN
   - Collection and transmission of ACF messages
   - Reception, unpacking, and forwarding of ACF messages to CanIf/LinIf

### 8.3 Stream Configuration

Each IEEE 1722 stream is configured via the `IEEE1722TpStream` container [^214^]:

**Key Configuration Parameters**:
```
IEEE1722TpStream:
  - StreamIdMacAddress (48-bit MAC part of Stream ID)
  - StreamIdUniquePart (16-bit unique part)
  - StreamIndex (stream index)
  - StreamMaxTransitTime (max transit time for presentation time)
  - StreamVersion (AVTP version)
  - EthIfClkUnitRef (reference to clock unit for timestamps)
  - StbMSynchronizedTimeBaseRef (reference to synchronized time base)
  - StreamLowerLayerPduPoolRef (lower layer PDU pool)
  + StreamDirection (Tx or Rx)
  + StreamSubtype (AAF, RVF, IIDC, CRF, ACF)
```

### 8.4 ACF Stream Configuration

**ACF-Specific Configuration** [^214^][^209^]:

```
IEEE1722TpStreamACF:
  - HeaderType: TIME_SYNCHRONOUS (TSCF) or NON_TIME_SYNCHRONOUS (NTSCF)
  - AcfCollectionTimeout: Maximum collection time
  - AcfCollectionThreshold: Maximum accumulated payload size
  - MixedBusTypeCollection: TRUE/FALSE (mixed CAN/LIN in one stream)
  + StreamAcfCan (CAN encapsulation configuration)
  + StreamAcfLin (LIN encapsulation configuration)
```

**ACF_CAN Configuration**:
```
IEEE1722TpStreamAcfCan:
  - AcfBusId: Bus identifier (0-31)
  - AcfCanMessageType: CAN or CAN_BRIEF
  + StreamAcfCanPdu:
    - CanId: CAN identifier (if not from meta-data)
    - CanFDBitRateSwitch: CAN FD BRS
    - CanFDDataRateFormat: CAN FD FDF
    - TriggerMode: TRIGGER_ALWAYS or TRIGGER_NEVER
    + CanIdFilter (optional): Filter for specific CAN IDs
```

### 8.5 PDU Pool Management

The IEEE1722Tp uses a PDU pool mechanism for buffer management [^214^]:

**PDU States**:
- `PDU_AVAILABLE`: PDU is free and can be used
- `PDU_IN_USE`: PDU is currently being used for transmission/reception

**Pool Types**:
- **Lower Layer PDU Pool**: PDUs for communication with EthIf
- **Upper Layer Tx PDU Pool**: PDUs for transmission from upper layers (stream producers)
- **Upper Layer Rx PDU Pool**: PDUs for reception to upper layers (stream consumers)

### 8.6 MetaData Items

The IEEE1722Tp uses MetaData to pass additional information with PDUs [^214^]:

**For ACF CAN (Tx)**:
- `CAN_ID_32`: CAN identifier
- `CAN_ID_PROPS_8`: CAN properties (IDE, BRS, FDF, ESI)

**For ACF CAN (Rx)**:
- `IEEE1722TP_COMMON_STREAM_HEADER_PTR`: Presentation time (for TSCF)
- `MESSAGE_TIMESTAMP_64`: Message timestamp
- `MESSAGE_TIMESTAMP_VALID_8`: Timestamp validity
- `CAN_ID_32`: CAN identifier
- `CAN_ID_PROPS_8`: CAN properties

**For Streaming Subtypes**:
- `IEEE1722TP_COMMON_STREAM_HEADER_PTR`: Common stream header info
- `IEEE1722TP_TX/RX_<SUBTYPE>_PTR`: Subtype-specific header fields

### 8.7 AUTOSAR R24-11 Deterministic Communication with TSN

AUTOSAR R24-11 introduced the concept "Deterministic Communication with TSN" focused on completing IEEE 1722 tunneling support [^274^]:

> "This concept focuses on 'completion of IEEE1722 specified tunneling process within the AUTOSAR communication stack for legacy communication (CAN and LIN)'. Specifically, the goal is to fully support TSCF and NTSCF subtype IEEE 1722 streams on AUTOSAR Classic Platform." [^273^]

**Key Changes in R24-11**:
- Complete support for IEEE 1722 encapsulated CAN and LIN frames as ACF messages
- Tunneling of legacy communication via AVTP streams across the network
- Note: Other bus types (e.g., FlexRay) may be added in future releases

### 8.8 Limitations and Notes

**Known Limitations** (R23-11) [^38^]:
> "IEEE1722Tp streams used for audio, video streaming and interaction with a media clock (clock reference format) interact only with CDDs which act as stream data producer or stream data consumer. Exchange of data with AUTOSAR standardized BSW software modules (e.g. COM, LdCom) and Rte is not supported."

**SRP Note** [^214^]:
> "AUTOSAR do not support stream reservation protocol (SRP), but due to [1, IEEE1722] chapter '4.4.4.2 sv (stream_id valid) field' the sv field is always set to 1."

---

## 9. References

### Standards Documents

| Reference | Title | Status |
|-----------|-------|--------|
| [^258^] | IEEE 1722-2016 - IEEE Standard for a Transport Protocol for Time-Sensitive Applications in Bridged Local Area Networks | Active |
| [^272^] | IEEE 1722-2025 - Updated AVTP Standard | Active (2025) |
| [^214^] | AUTOSAR CP R24-11 - Specification of IEEE1722 Transport Protocol Module | Active |
| [^220^] | AUTOSAR FO R25-11 - Requirements on IEEE1722 | Active |
| [^38^] | AUTOSAR CP R23-11 - Specification of IEEE1722 Transport Protocol Module | Superseded |

### Infineon Documentation

| Reference | Title |
|-----------|-------|
| [^216^] | Infineon AURIX TC4x Data Routing Engine (DRE) v1.0 Training |
| [^219^] | Infineon AURIX TC4xx Documentation - DRE |
| [^133^] | Infineon AURIX TC3xx GETH Documentation |

### Industry Resources

| Reference | Title |
|-----------|-------|
| [^37^] | AVnu Alliance - Audio Video Transport Protocol (AVTP) Presentation |
| [^209^] | AVTP and CAN over AVTP in Automotive Ethernet - Engineering Practice |
| [^211^] | COVESA Open1722 - Open Source IEEE 1722 Implementation |
| [^237^] | Bosch - Short Ethernet Frames: Automotive Use Case |
| [^239^] | Avnu Pro Audio Functional and Interoperability Specification |
| [^278^] | Avnu Milan Media Clocking Specification |

---

*Research compiled from 20+ web searches covering official Infineon documentation, IEEE standards, AUTOSAR specifications, and industry technical resources.*

*Last updated: 2025*
