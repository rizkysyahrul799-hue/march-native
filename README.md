# march-native
A minimalist system control unit optimized for dynamic thread automation, background state control, and hardware performance scaling. Inspired by March 7th.

# March — Native Edition

March is a minimalist, lightweight system control center designed to optimize dynamic thread utilization, manage background processes, and calibrate hardware performance limits natively via a dedicated WebUI.

## Features

* **Flow State Mode**: Dynamically tunes CPU thread scheduling and utilizes uclamp configurations to ensure optimal UI responsiveness and low-latency task execution.
* **Smart Sleep & Cleanse**: Optimizes deep idle states and strictly manages background process lifecycles to minimize idle battery drain.
* **Smart Thermal Sync**: Adjusts system thermal configurations dynamically to balance peak device performance and temperature stability.
* **CPU Capacity Cap**: Provides a precise hardware frequency limit scaler (ranging from 40% to 100%) governed entirely by user preference.
* **Apply on Boot**: Restores all designated configurations seamlessly upon system initialization with safety boot protection delays.

## Repository Structure

```text
march/
├── assets/          # Static graphic assets & chibis
├── config/          # Internal configuration parameters
├── action.sh        # Core backend execution controller
├── service.sh       # Post-boot system restore routine
├── customize.sh     # Modular installer script & permission handler
├── uninstall.sh     # Clean-uninstallation script
├── index.html       # Native WebUI dashboard
├── theme.json       # Front-end manager metadata alignment
└── module.prop      # Core module properties

Installation
​Download the latest release .zip package.
​Flash the package via a modern root manager (KernelSU, APatch, or Magisk).
​Reboot your device to complete the system initialization.
​Open the module's WebUI from your manager dashboard to configure the parameters.
​Code of Conduct & Credits
​Built entirely with shell scripting and vanilla web technologies for a zero-overhead native footprint.
​Graphic assets and chibi illustrations belong to their respective original artists.
​Special thanks to the Android modding community for the inspiration.
​Inspired by March 7th.
