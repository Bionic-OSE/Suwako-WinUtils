# Suwako Feeds
Enables **News and Interest** on unsupported editions or Edge-less installs of Windows 10 builds 1904x.962 and later. 

<p align=center><img src="https://github.com/user-attachments/assets/4963765d-3e12-4878-bbd4-a6b6f5e12d2c">

You can download this along with other tools in the suite in the [**Releases tab**](https://github.com/Bionic-OSE/Suwako-WinUtils/releases/tag/latest)

---
## Features 
- Does exactly what the description said.
- **Super tiny**, just under 200KB in size and <1MB memory usage on average.
- Built with just the built in .NET 4.8 compiler (`C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe`), so it **runs out of the box**.
- Easy-to-follow CLI based installer (and has an uninstall entry too).

## How does it work?
- The registry value `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds` **`IsFeedsAvailable`** determines if News and Interests (called Feeds for short) is available to the user. You can identify this by looking at the taskbar's right click menu:

<p align=center><img src="https://github.com/user-attachments/assets/97173a62-8718-4f26-bc9e-e210c02dc365" width="828"></p>

- From here you can guess what we're after. The problem here is: If your install is considered "ineligible" for the feature (whether that's LTSC edition or having Edge removed), if you set the value to 1 **as soon as Explorer restarts the value will revert back to 0.**
- Which brings me to the core mechanism of Suwako Feeds: It runs in the background and watches for when the Explorer shell restarts. When that happens, it **"brute-force" writes 1** to the value until the shell finishes loading, keeping Feeds always available. 

## Remarks 
### 1. Administrator privileges & The way it hooks to your startup sequence 
- This version of Suwako Feeds uses Task Scheduler to bypass UAC on startup, so you won't have to be nagged by it asking for elevation every time you sign in to your computer. But wait, **why elevated** when all you are doing is write a value to `HKCU`? 
- Turns out, in order to be able to "catch" Explorer's restart, it needs to query the WMI, and unfortunately Administrator permissions is required in order for the query to work. There were an old version of this same app, prior to its debut here, that was based on PowerShell and used `Wait-Process` which didn't require any elevation. Maybe some day I will upload it, as for now, this will have to do. 
### 2. Suwako Feeds and the User-Choice Protection Driver (UCPD)
- Yes, that one driver that you heard [countless times](https://kolbi.cz/blog/2024/04/03/userchoice-protection-driver-ucpd-sys/) [on the news](https://www.ghacks.net/2024/04/08/new-sneaky-windows-driver-ucdp-stops-non-microsoft-software-from-setting-defaults/) when it came out back in April 2024. 
- Starting with the August 2024 Cummulative update, besides from blocking default browser related registry values, it also write-protected `IsFeedsAvailable`, breaking the tool as the result. The only way to counter this issue is to **remove the service that loads the driver** from the system, which is an absolutely harmless process (Don't believe me? Install Windows Server 2025, which is Windows 11 version 24H2 at its core, and I dare you to find traces of that driver compared to the latter). 
- Upon launching, the installer will detect and tell you if UCPD is present on the system, and if so, gives you the option to remove it before continuing with the installation. After which, enjoy Feeds without restrictions.
### 3. Feeds not saving your settings when Edge is uninstalled 
- This is a known quirk and it applies to both Feeds and Widgets on Windows 11 (at least before it's able to detect the lack of Edge). You will need to have Edge installed and at least one profile present for the settings to successfully save.
- As a workaround, maybe you can call some help from [MSEdgeRedirect](https://github.com/rcmaehl/MSEdgeRedirect) to try and stay as far from Edge as possible.
