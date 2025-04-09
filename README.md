# Adversity Framework

A framework for creating player hardship mods. 

## Building Requirements

- Any terminal of your choice (e.g., PowerShell)
- Any C++23 compiler (MSVCm Clang, ...)
	- [Visual Studio Community 2022](https://visualstudio.microsoft.com/) installs a compiler for you with the `Desktop development with C++` option
- [XMake](https://xmake.io/)
	- Edit the `PATH` environment variable and add the cmake.exe install path as a new value
  - Instructions for finding and editing the `PATH` environment variable can be found [here](https://www.java.com/en/download/help/path.html)  
- [Git](https://git-scm.com/downloads)
  - Edit the `PATH` environment variable and add the Git.exe install path as a new value

## End User Requirements

- [Address Library for SKSE](https://www.nexusmods.com/skyrimspecialedition/mods/32444)
  - Needed for SSE/AE
- [VR Address Library for SKSEVR](https://www.nexusmods.com/skyrimspecialedition/mods/58101)
  - Needed for VR


## Clone and Build
Open terminal (e.g., PowerShell) and run the following commands:

```bat
git clone https://github.com/Scrabx3/Adversity-Framework --recursive
xmake
```
