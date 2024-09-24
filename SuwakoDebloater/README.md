# Suwako Debloater
A simple tool that **purges UWP apps** (and optionally along with Edge and OneDrive) from your system. Simple, easily configurable, does what's said, and aims towards being a tool that you can just set and forget having to deal with consequences later.  
This tool suits for newly installed Windows systems, where its goal is to give you the lightest fresh start possible. Running this on an already-set up system will **remove ALL UWP apps that you have installed!**

<p align=center><img src="https://github.com/user-attachments/assets/8bbf1bc7-a48f-40f3-94f7-44ac5d96b5d3"></p>

<p align=center><img src="https://github.com/user-attachments/assets/c152320f-a633-4b20-9012-ebbb38d7541f"></p>  
<sup>(There are some ad tiles which won't be removed, so I removed them and all other tiles myself, resulting in a truly LTSC-like look)</sup>

You can download this along with other tools in the suite in the [**Releases tab**](https://github.com/Bionic-OSE/Suwako-WinUtils/releases/latest)

---

## Features 
- Main interface is **splitted into tabs**, each with their respective options inside:
<p align=center><img src="https://github.com/user-attachments/assets/56f86d29-c7d6-494e-912e-1841f06fe1bc"></p> 

- Adjustable removal options that suits your requirements, each does exactly what's said, nothing extra. 
- Optionally supports **removing Microsoft Edge** using script adopted from [Aveyo's](https://github.com/AveYo/fox/blob/main/Edge_Removal.bat), and **Microsoft OneDrive** using script from my own [BioniDKU project](https://github.com/Bionic-OSE/BioniDKU/blob/main/modules/removal/removeonedrive.ps1). 
- **Click-to-Run** packed executable with a custom C# wrapper that runs the PowerShell script with the `-ExecutionPolicy Bypass` switch. No `Set-ExecutionPolicy` required, you can keep your desired execution policy. Just double click and use. 
- App is made up from modular sub-scripts (I call them modules), [one of which](https://github.com/Bionic-OSE/Suwako-WinUtils/blob/main/SuwakoDebloater/Modules/Debloater.ps1) is the core code that does the job, and **it works without needing to go through the interactive menu**. Thanks to this, you can easily set up automation in scenarios like network deployment by directly calling the module with the right parameters.

## Things to be added 
- **Exclude apps from the removal**: This is something that would help if you want to keep things like the Microsoft Store. I know that a lot of debloaters out there already have this functionality ages ago, but from my experience they seemed confusing.
- **Ability to reinstall certain core UWP apps**: This helps if you wanted to have the Store, or on newer version of Windows, things like Notepad or Windows Security app, back after the removal (or if your install just doesn't have it for whatever reason). Details on this will be disclosed later once the feature goes live.

## Remarks
### Non-elevated mode
- Most of you when running the app may end up with it looking like this instead of what you saw above:
<p align=center><img src="https://github.com/user-attachments/assets/58e30cc9-cda7-46f0-8377-55de971d621a" width="800"></p>

- This is **"non-elevated" mode**, a mode that allows you to use some functionalities like current-user debloating and component reintalling without requiring elevation to work. It's helpful in cases like you have your own user on a guest system, and wants to debloat just your space but don't have sufficient permissions granted. 
- To use all functionalities of the app, just right-click and **"Run as Administrator"**, and everything will work as described. 
