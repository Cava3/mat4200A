# MAT4200A

**MAT4200A** is a MATLAB toolbox for controlling the Keithley 4200A-SCS Semiconductor Characterization System. It wraps the [py4200A](https://github.com/Cava3/py4200A) Python library, providing a fully native MATLAB interface — no `py.` prefixes or manual type conversions required.

Developed collaboratively with the University of Salamanca.

---

## Requirements

| Requirement | Version | Install |
|---|---|---|
| MATLAB | R2022b or newer | Official MATLAB website |
| Python | 3.10 + | `winget install Python.Python.3.10` |
| py4200A | ≥ 0.2.2 | Setup will prompt for install |

`py4200A` is installed automatically by `setup.m` if it is not found. It brings in `pyvisa`, `numpy`, `pyvisa-py` and `gpib-ctypes` as dependencies.  

You will also need a proper GPIB installation (NI-VISA + NI488.2) if you plan to use the GPIB communications.

---

## Installation

### 1. Clone or download the toolbox

```bash
git clone git@github.com:Cava3/mat4200A.git
```

Or download the zip from the GitHub releases page and unzip it.

### 2. Point MATLAB at the correct Python environment *(once)*

```matlab
% Check the current Python environment
pyenv

% Point to a specific interpreter if needed (do this before running setup)
pyenv('Version', 'C:\path\to\python3.11\python.exe')   % Windows
% pyenv('Version', '/usr/bin/python3.11')               % Linux / macOS
```

> Python 3.10+ is required. For example on Windows, install 3.11 with:
> `winget install Python.Python.3.11`

### 3. Run `setup.m` once per MATLAB session

```matlab
setup;
```

`setup.m` adds the toolbox to the MATLAB path, checks the Python version, and verifies that `py4200A` is importable. If `py4200A` is not installed it offers to install it via pip.

> **Tip:** add `run('/path/to/mat4200A/setup.m')` to your `startup.m` so the toolbox is always ready.

### Linux: GPIB permissions

On Linux, GPIB access requires `linux-gpib`. Grant your user the necessary permissions without `sudo` by running the helper script in the 
[py4200A github repository](https://github.com/Cava3/Py4200A) named [AddUserPermissions.sh](https://github.com/Cava3/Py4200A/blob/main/AddUserPermissions.sh)

---

## Instrument setup

Before connecting from MATLAB:

1. **Power on** the Keithley 4200A-SCS.
2. **Close Clarius** (or any other software using the KXCI interface).
3. **Open KCon** on the 4200A and select the correct communication mode (GPIB or TCP/IP).
4. Ensure every board has a **unique channel number** corresponding to their slot in KCon.
5. **Open KXCI** and wait for it to startup (~10 seconds)

---

## Connecting

### GPIB

```matlab
ki = MAT4200A.KI4200A('GPIB0::17::INSTR');
```

GPIB requires a National Instruments USB-GPIB cable. The address (default 17) must match the address configured in KCon.

### TCP/IP

```matlab
ki = MAT4200A.KI4200A('TCPIP0::192.168.1.10::1225::SOCKET');
```

Both the host PC and the 4200A must be on the same network. Set the Keithley's network profile to **Private** in Windows to accept incoming connections.

---

## Quick start

### Programmed mode — `KI4200A`

```matlab
setup;

ki = MAT4200A.KI4200A('GPIB0::17::INSTR');
ki.reset();
ki.test_mode = MAT4200A.consts.RPMMode.SMU;

% SMU1 sweeps 0 → 10 V while SMU2 holds a constant 5 V
smu1 = ki.getSMU(1);
smu2 = ki.getSMU(2);

smu1.setupSMU('V1', 'I1', MAT4200A.consts.SourceType.VOLT, MAT4200A.consts.SourceFunction.SWEEP);
smu1.setSweepFunction(MAT4200A.consts.SweepType.LINEAR, 0, 10, 0.1, 0.01);

smu2.setupSMU('V2', 'I2', MAT4200A.consts.SourceType.VOLT, MAT4200A.consts.SourceFunction.CONSTANT);
smu2.setConstantSourceValue(5.0, 0.01);

ki.runTest();
ki.waitForTestEnd();

result = ki.makeDependentFrom(smu1.current_measurement, smu1.voltage_measurement);
ki.disconnect();
```

### Real-time mode — `RT_KI4200A`

```matlab
setup;

rt = MAT4200A.RT_KI4200A('GPIB0::17::INSTR');
smu = rt.getSMU(1);

smu.setVoltageOutput(1.5, 0.01);    % 1.5 V, 10 mA compliance
I = smu.measureCurrent();
V = smu.measureVoltage();
fprintf('V = %.4f V,  I = %.2e A\n', V, I);

rt.disconnect();
```

---

## Performance

The pre-programmed mode uploads the full sweep configuration to the instrument and executes it in firmware — significantly faster than polling point-by-point in real time.

| Mode | Test | Time |
|---|---|---|
| Programmed (`KI4200A`) | MOSFET output — 6 gate steps × 151 source points | ~101 s |
| Real-time (`RT_KI4200A`) | Same test, point-by-point | ~409 s |

Use **programmed mode** whenever possible. Use **real-time mode** when you need live feedback or want to adapt the sweep to intermediate results.

---

## Examples

Three ready-to-run scripts are provided in [examples/](examples/):

| Script | Description |
|---|---|
| [Mosfet_gate_programmed_SMU.m](examples/Mosfet_gate_programmed_SMU.m) | MOSFET output characteristics — two SMUs, gate stepped, source swept |
| [Mosfet_gate_programmed_PMU.m](examples/Mosfet_gate_programmed_PMU.m) | Same measurement via two PMU-RPM channels in pulse mode |
| [Mosfet_gate_realtime_SMU.m](examples/Mosfet_gate_realtime_SMU.m) | Same measurement via `RT_KI4200A` — point-by-point real-time loop |

All three scripts produce identical MOSFET output characteristic plots (I_source vs V_source, one curve per gate voltage) and can be used to compare results between modes.

---

## API reference

### Instrument controllers

| Class | Description |
|---|---|
| `MAT4200A.KI4200A` | Full sweep-mode controller. Configures boards, runs tests, retrieves results. |
| `MAT4200A.RT_KI4200A` | Real-time User-Mode (`US`) controller for interactive measurements. |

**`KI4200A` key methods**

| Method | Description |
|---|---|
| `KI4200A(resource)` | Connect and scan modules. |
| `reset()` | Reset to default state. |
| `scan()` | Re-scan modules; refresh `l_smus`, `l_rpms`, `id`. |
| `runTest()` / `abortTest()` | Start or abort the configured test. |
| `waitForTestEnd()` | Block until the test finishes (SRQ on GPIB, polling on TCP/IP). |
| `initPMU()` | Initialise PMU in standard pulse mode. |
| `getSMU(slot)` | Returns `MAT4200A.SMU` for the given slot. |
| `getRPM(slot)` | Returns `MAT4200A.PMU_RPM` for the given slot. |
| `makeDependentFrom(data, params)` | Assemble N-D results into a `Dependent` object. |
| `write(cmd)` / `query(cmd)` | Send raw KXCI commands. |
| `disconnect()` / `reconnect()` | Connection management. |

**`RT_KI4200A` key methods**

| Method | Description |
|---|---|
| `RT_KI4200A(resource)` | Connect and enter User Mode. |
| `getSMU(slot)` | Returns `MAT4200A.RT_SMU`. |
| `userMode()` | Re-enter User Mode after a page command. |
| `reset()` / `disconnect()` | Reset or close the connection. |

---

### Board wrappers

| Class | Description |
|---|---|
| `MAT4200A.SMU` | Source Measure Unit — voltage/current sweep, step, list-sweep, and constant. |
| `MAT4200A.CVU` | Capacitance-Voltage Unit — detected automatically on scan. |
| `MAT4200A.PMU_RPM` | PMU / Remote Pulse Measure channel — pulse timing, sweep, and step. |
| `MAT4200A.RT_SMU` | Real-time SMU in User Mode — `setVoltageOutput`, `measureCurrent`, etc. |
| `MAT4200A.RT_PMU_RPM` | Real-time RPM in User Mode — controls switching mode. |

**`SMU` source configuration**

| Method | Description |
|---|---|
| `setupSMU(v_name, i_name, source_type, source_function)` | Full SMU mode. |
| `setupVoltageSource(name, source_function)` | VS mode (voltage only). |
| `setupVoltmeter(name)` | VM mode (measure only). |
| `deactivate()` | Power off this channel. |
| `setConstantSourceValue(value, compliance)` | Fixed output level. |
| `setSweepFunction(type, start, stop, step, compliance)` | Linear or log sweep (max 1024 pts). |
| `setStepFunction(start, stop, step, compliance)` | Step by start/stop/step (max 32 pts). |
| `setListSweep(values, compliance, master)` | Arbitrary list sweep (max 4096 pts). |

**`PMU_RPM` pulse configuration**

| Method | Description |
|---|---|
| `setPulseTimes(period, width, riset, fallt)` | Timing parameters (all in seconds). |
| `setPulseTrain(vbase, vamplitude)` | Base and amplitude voltage levels. |
| `setPulseStep(mode, start, stop, step)` | Stepped pulse pattern. |
| `setPulseSweep(mode, start, stop, step, dual_sweep)` | Swept pulse pattern. |
| `setMeasurePIV(acquire_high, acquire_low)` | Select which pulse levels to acquire. |

**`RT_SMU` real-time operations**

| Method | Description |
|---|---|
| `setVoltageOutput(V, compliance)` | `DV` — set voltage and compliance. |
| `setCurrentOutput(I, compliance)` | `DI` — set current and compliance. |
| `measureVoltage()` | `TV` — trigger and return voltage in volts. |
| `measureCurrent()` | `TI` — trigger and return current in amperes. |
| `setCurrentRange(range, compliance)` | `RI` — explicit current range. |
| `setVoltageRange(range, compliance)` | `RV` — explicit voltage range. |

---

### Result and display classes

| Class | Key methods |
|---|---|
| `MAT4200A.Measurement` | `getAllResults()`, `getResultSerie()`, `getResultAt(index)` |
| `MAT4200A.Display` | `displayGraph(x, y1)`, `displayList(names)` |

---

### Constants and enums

All constants ans enums live in the `MAT4200A.consts` sub-package.

| Enum | Values |
|---|---|
| `SMUMode` | `SMU` · `VS` · `VM` |
| `SourceType` | `VOLT` · `AMPERE` · `COMMON` |
| `SourceFunction` | `SWEEP` · `STEP` · `CONSTANT` |
| `SweepType` | `LINEAR` · `LOG10` · `LOG25` · `LOG50` |
| `BoardType` | `SMU` · `CVU` · `PMU_RPM` |
| `RPMMode` | `PMU` · `SMU` · `CV_2W` · `CV_4W` |
| `IntegrationTime` | `SHORT` · `NORMAL` · `LONG` |
| `PMUMeasureMode` | `SPOT_MEAN_DISCRETE` · `WAVEFORM_DISCRETE` · … |
| `PMUPulseMode` | `AMPLITUDE` · `BASE` · `DC` |
| `PMUSourceRange` | `V10` · `V40` |
| `CurrentSourceRange` | `AUTORANGE` · `R_100PA` · `R_1NA` · … |
| `VoltageSourceRange` | `AUTORANGE` · `R_20V` · `R_200V` |

---

## Roadmap

- [x] Connection to KI4200A-SCS through PCIB or TCPIP
- [x] Perform basic instruction to get Model and SN from KXCI
- [x] Listing of all the boards available
- [x] Correctly type the boards
- [x] Send basic setting instructions to SMUs
- [x] Allow test execution
- [x] Basic result retrieval
- [x] Analysis and plotting
- [x] Publish on PyPi
- [x] PMU RMP commands
- [x] Matlab wrapper
- [ ] Full instruction dictionnary capabilities

---

## Contributing

If you are not a developer, or do not wish to publish code, feel free to open an issue. I will review
and get to work on it as soon as possible. Please understand that it may take some time though, as I
am currently the only maintainer and have other things to do in life.  
Feel free to open pull request. I will review each one, making sure it is properly documented, properly
commented, and really brings something to the table. Check existing file for documentation example.
Typing and using PyLint in "strict" mode will also be required.  
Garbage AI-generated spaghetti code (also know as "*vibe coding*") will be rejected. I have nothing against
good and proper usage of AI tools though. Simply keep your code relevant and readable.

---

## See also

[py4200A](https://github.com/Cava3/Py4200A)
[linux-gpib](https://github.com/coolshou/linux-gpib) - GPIB driver I'm using on my Linux (Ubuntu) laptop.  
[PyVISA](https://pyvisa.readthedocs.io/en/latest/) - Python library to communicate with a device via most interfaces through VISA.  
[PyVISA-py](https://pypi.org/project/PyVISA-py/) - Replaces proprietary VISA libraries with a python implementation.  
[USAL](https://usal.es/) - The university that works on this project.  
