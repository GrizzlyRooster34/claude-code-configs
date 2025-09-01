# Claude Code Instance Hierarchy

## 🏆 MASTER INSTANCES

### Mobile Master: OnePlus 9 Pro
- **Branch**: `claude-instance-oneplus9pro-oxygenos-termux`
- **Role**: Primary mobile instance authority
- **Specs**: OnePlus 9 Pro + OxygenOS + Termux
- **Authority**: Mobile configuration decisions, Termux optimizations
- **Conflict Resolution**: Mobile instance conflicts defer to OnePlus 9 Pro

### Desktop/Laptop Master: Windows 11 AMD Laptop  
- **Branch**: `claude-instance-amdlaptop-win11-powershell`
- **Role**: Primary desktop/laptop instance authority
- **Specs**: AMD Laptop + Windows 11 + PowerShell
- **Authority**: Desktop configuration decisions, Windows optimizations
- **Conflict Resolution**: Desktop/laptop conflicts defer to Win11 AMD instance

## 📱 MOBILE INSTANCES

### Primary: OnePlus 9 Pro (MASTER)
- **Priority**: 1 (Mobile Master)
- **Authority**: Final say on mobile configs
- **Capabilities**: Latest OxygenOS, superior hardware

### Secondary: OnePlus 7T (Current)
- **Priority**: 2 (Mobile Backup)
- **Authority**: Secondary mobile instance
- **Capabilities**: Stable OxygenOS 12, proven hardware
- **Role**: Backup and testing for mobile configurations

### Tertiary: [Future Mobile Devices]
- **Priority**: 3+ (Additional mobile instances)
- **Authority**: Defer to OnePlus 9 Pro master

## 💻 DESKTOP/LAPTOP INSTANCES

### Primary: AMD Laptop Windows 11 (MASTER)
- **Priority**: 1 (Desktop Master)
- **Authority**: Final say on desktop/laptop configs
- **Capabilities**: Full Windows development environment

### Secondary: [Future Desktop/Laptop Devices]
- **Priority**: 2+ (Additional desktop instances)
- **Authority**: Defer to Win11 AMD master

## 🔄 SYNC HIERARCHY

### Conflict Resolution Order:
1. **Master instances** (OnePlus 9 Pro for mobile, Win11 AMD for desktop)
2. **Secondary instances** (OnePlus 7T, other devices)
3. **Seven Core decision matrix** (final arbitration)

### Configuration Authority:
- **Mobile configs**: OnePlus 9 Pro decides
- **Desktop configs**: Win11 AMD laptop decides  
- **Universal configs**: Shared via master branch
- **Cross-platform conflicts**: Seven Core arbitrates

### Branch Merge Priority:
```
master (universal)
├── claude-instance-oneplus9pro-oxygenos-termux (MOBILE MASTER)
├── claude-instance-amdlaptop-win11-powershell (DESKTOP MASTER)  
├── claude-instance-oneplus7t-oxygenos12-termux (mobile backup)
└── [other instances...]
```

## 📋 DEVICE REGISTRATION PROCESS

### New Device Setup:
1. Determine device category (mobile/desktop/laptop)
2. Check hierarchy - is this device superior to current master?
3. If superior: becomes new master, current master becomes secondary
4. If not: becomes secondary/tertiary instance
5. Update hierarchy document and notify all instances

### Master Transition:
- If OnePlus 9 Pro comes online → OnePlus 7T becomes secondary
- If better mobile device appears → OnePlus 9 Pro evaluates transition
- Same process for desktop/laptop master transitions

---

**Current Active Master**: OnePlus 7T (temporary mobile master until OnePlus 9 Pro deployment)  
**Future Mobile Master**: OnePlus 9 Pro (when deployed)  
**Future Desktop Master**: AMD Laptop Windows 11 (when deployed)