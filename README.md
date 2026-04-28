# MAT4200A

**MAT4200A** is a MATLAB toolbox for controlling the Keithley 4200A-SCS Semiconductor Characterization System. It wraps the [py4200A](https://github.com/Cava3/py4200A) Python library, providing a fully native MATLAB interface — no `py.` prefixes or manual type conversions required.

Developed collaboratively with the University of Salamanca.

---

## Architecture

MAT4200A is a thin MATLAB wrapper that delegates all instrument communication to **py4200A** via MATLAB's built-in Python interface. Every class in the `+MAT4200A` package holds a private `pyobj` handle to the corresponding Python object and translates MATLAB types automatically on every call.

```
MATLAB code
  └─ MAT4200A.KI4200A / MAT4200A.RT_KI4200A
       └─ py4200A  (Python package)
            └─ pyvisa / NI-VISA / linux-gpib
                 └─ Keithley 4200A-SCS  (KXCI over GPIB or TCP/IP)
```

---

## Requirements

| Requirement | Version |
|---|---|
| MATLAB | R2021b or newer |
| Python | 3.10 – 3.12 (3.13 not yet supported by MATLAB) |
| py4200A | ≥ 0.2.2 |

`py4200A` is installed automatically by `setup.m` if it is not found. It brings in `pyvisa`, `numpy`, and `gpib-ctypes` as dependencies.

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

> Python 3.10–3.12 is required. On Windows, install 3.11 with:
> `winget install Python.Python.3.11`

### 3. Run `setup.m` once per MATLAB session

```matlab
run('setup.m')
```

`setup.m` adds the toolbox to the MATLAB path, checks the Python version, and verifies that `py4200A` is importable. If `py4200A` is not installed it offers to install it via pip.

> **Tip:** add `run('/path/to/mat4200A/setup.m')` to your `startup.m` so the toolbox is always ready.

### Linux: GPIB permissions

On Linux, GPIB access requires `linux-gpib`. Grant your user the necessary permissions without `sudo` by running the helper script bundled with py4200A:

```bash
bash /path/to/py4200A/AddUserPermissions.sh
```

---

## Instrument setup

Before connecting from MATLAB:

1. **Power on** the Keithley 4200A-SCS.
2. **Close Clarius** (or any other software using the KXCI interface).
3. **Open KCon** on the 4200A and select the correct communication mode (GPIB or TCP/IP).
4. Ensure every board has a **unique channel number** in KCon.

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
I = smu.measure_current();
V = smu.measure_voltage();
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
| `MAT4200A.RT_SMU` | Real-time SMU in User Mode — `setVoltageOutput`, `measure_current`, etc. |
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
| `measure_voltage()` | `TV` — trigger and return voltage in volts. |
| `measure_current()` | `TI` — trigger and return current in amperes. |
| `set_current_range(range, compliance)` | `RI` — explicit current range. |
| `set_voltage_range(range, compliance)` | `RV` — explicit voltage range. |

---

### Result and display classes

| Class | Key methods |
|---|---|
| `MAT4200A.Measurement` | `getAllResults()`, `getResultSerie()`, `getResultAt(index)` |
| `MAT4200A.Display` | `displayGraph(x, y1)`, `displayList(names)` |

---

### Constants

All constants live in the `MAT4200A.consts` sub-package.

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

- [x] Connection management (GPIB / TCP/IP)
- [x] SMU programmed sweep, step, list-sweep, and constant modes
- [x] PMU/RPM pulse sweep and step modes
- [x] Real-time SMU (User Mode)
- [x] Result fetching and `Dependent` integration
- [x] Display control (graph and list)
- [ ] CVU (C-V measurements)
- [ ] Full KXCI instruction dictionary

---

## Contributing

Contributions are welcome. Please:

- Follow the existing code style: properties first, then public methods, private helpers last.
- Document every public method with a short comment block explaining arguments and return values.
- Keep MATLAB–Python type conversions explicit (`char()`, `double()`, `logical()`, `int32()`).
- Test against a real 4200A when possible, or at minimum verify the bridge conversions manually.

---

## License

MIT — see [LICENSE](LICENSE).
