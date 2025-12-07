# Shawna’s CMD Tools
A Windows diagnostics engine built with Batch as the orchestrator and PowerShell spun up on-the-fly to handle all the precision work.

<div align="center">

![Build](https://img.shields.io/badge/BUILD-PASSING-8A2BE2?style=for-the-badge)
![Platform](https://img.shields.io/badge/PLATFORM-WINDOWS-0078D6?style=for-the-badge&logo=windows)
![Batch](https://img.shields.io/badge/LANGUAGE-BATCH-blueviolet?style=for-the-badge)
![PowerShell](https://img.shields.io/badge/ENGINE-POWERSHELL-5391FE?style=for-the-badge&logo=powershell)
![Version](https://img.shields.io/badge/VERSION-V15-9370DB?style=for-the-badge)
![GPU](https://img.shields.io/badge/GPU-NVIDIA%2FAMD%2FINTEL-444444?style=for-the-badge)

</div>

---

## 👾 Demo

<div align="center">
  <img 
    src="https://github.com/Sapphica/ShawnasCmdTools/blob/main/assets/menu.jpg" 
    alt="Menu"
    style="width:50%; height:50%;">
</div>


---

## ⭐ Purpose

Shawna’s CMD Tools is a **full Windows diagnostics and maintenance suite** that bypasses CMD’s usual quoting bugs, timing issues, and general chaos by generating PowerShell modules dynamically at runtime.

Everything here is engineered for **repeatability, stability**, and **zero guesswork** — the same philosophy I use in firmware QA.

This tool handles:

- Disk checks and repairs  
- SFC + DISM system integrity fixes  
- Manual GPU vendor selection (NVIDIA / AMD / Intel)  
- GPU snapshots and driver restart logic  
- PCIe link speed detection (current + max)  
- CPU and RAM snapshots  
- Auto-recovery of failing services  
- Windows cleanup (Temp purge, component cleanup, etc.)  
- Icon cache rebuild  
- AppX / Windows Store reset  
- Search index rebuild  
- Explorer restart  
- Fun “BOOM” exit sequence  

All heavy logic is pushed into temp `.ps1` scripts for maximum stability.

---

## 📝 Notes

- This tool relies heavily on **runtime-generated PowerShell** to avoid CMD crashes.  
- NVIDIA logic is **frozen** — it works, so it stays untouched.  
- GPU selection is **manual** because autodetect lies on multi-GPU systems.  
- PCIe link speed detection is **timing-sensitive**, so the entire block remains locked to the V15 implementation.  
- The script runs on **Windows 10 and 11** with admin privileges.

This isn’t a toy script — it’s an engine.

---

## 🛠 Features

- Disk checks (C / D)  
- CHKDSK repair mode  
- SFC scan  
- DISM RestoreHealth  
- Multi-GPU vendor selection  
- GPU snapshot (nvidia-smi / WMI)  
- GPU driver restart sequences  
- PCIe Gen detection (current + max link speed)  
- Service health scan + auto restart  
- CPU load + core/thread snapshot  
- RAM usage snapshot  
- Windows cleanup tools  
- Explorer restart  
- Search index rebuild  
- Windows Store / AppX reset  
- Icon cache rebuild  
- Custom exit animation  

---

## 🧩 Technology Stack

- Windows 10 / 11  
- Batch (core flow engine)  
- PowerShell (runtime modules)  
- WMI / CIM queries  
- PnP device properties for PCIe detection  
- Native Windows tools (CHKDSK, DISM, SFC, CLEANMGR, WSRESET)

This stack is engineered to survive Windows quirks, timing issues, multi-GPU setups, and everything else CMD tends to break.

---

## 🔮 Future Additions

This tool is mostly working and stable, but I’m still building out some components:

- Logging system  
- Deeper GPU diagnostics  
- Optional “aggressive mode”  
- Extended PCIe detail  
- More polish on the BOOM animation  

---

## 📜 License

MIT License — use it, remix it, break it, improve it.  
Just don’t blame me when Windows does Windows things.

