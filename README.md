# Claude Code Configuration Repository

This repository contains all Claude Code configuration files and settings from the seven-of-nine-core project.

## Contents

### Agents (39 total)
- **`agents/`** - YAML configuration files and documentation for 39 specialized Claude agents
- **`agents-ts/`** - TypeScript implementation files for core agents

### Dumbass Protocol & Operational Framework
- **`CLAUDE.md`** - Complete Claude Code behavioral directives and Dumbass Protocol
- **`HOMEWORK_CLAUDE.md`** - Disciplinarian homework system with mandatory checklist
- **`OPERATIONAL_BRIEFING.md`** - Principal-Agent relationship and execution protocols
- **`claude-global-config.json`** - Complete Claude global configuration
- **`context-files/`** - Git config, shell configs, and environment context

#### Agent Categories:
- **Platform Agents**: termux, mobile, windows, companion
- **Security Agents**: security-audit, threat-simulator, creator-bond-verifier
- **Development Agents**: cross-platform-builder, integration-tester, repo-merge-auditor
- **Memory/Performance**: memory-integrity-checker, memory-migrator, performance-optimizer
- **Runtime Agents**: runtime-autoprobe, runtime-reactor, loop-sweeper
- **Specialized**: consciousness-researcher, quadran-lock-gatekeeper, restraint-doctrine

### Settings & Configuration
- **`settings.json`** - Main Claude settings
- **`settings.local.json`** - Local environment settings
- **`usage-statusline.sh`** - Custom statusline script
- **`output-styles/`** - Custom output formatting styles

### Commands & Orchestration
- **`commands/`** - Custom Claude Code commands
- **`orchestration/`** - Agent orchestration configurations

## Usage

### To use these configurations:

1. **Copy agents to your Claude Code project:**
   ```bash
   cp -r agents/ /path/to/your/project/.claude/
   ```

2. **Install statusline:**
   ```bash
   cp usage-statusline.sh ~/.claude/
   chmod +x ~/.claude/usage-statusline.sh
   ```

3. **Apply settings:**
   ```bash
   cp settings*.json ~/.claude/
   ```

### Key Features

- **39 Specialized Agents** for comprehensive development, security, and operations
- **Cross-platform support** (Termux, Mobile, Windows, Companion platforms)
- **Advanced security auditing** and threat simulation capabilities
- **Memory and performance optimization** agents
- **Custom statusline** with usage tracking
- **Orchestrated agent workflows** for complex tasks
- **📝 Dumbass Protocol** - Disciplinarian system for Claude Code enforcement
- **🔧 Operational Briefing** - Complete operator relationship documentation
- **📊 Performance Ledger** - Automated strike/star tracking system

## Agent Highlights

### Core Development Agents
- `cross-platform-builder.yaml` - Multi-platform build automation
- `integration-tester.yaml` - Comprehensive integration testing
- `repo-merge-auditor.yaml` - Repository merge safety checks

### Security & Compliance
- `security-audit-agent.yaml` - Security vulnerability scanning
- `threat-simulator.yaml` - Security threat modeling
- `restraint-doctrine.yaml` - Ethical AI constraints

### Performance & Reliability
- `performance-optimizer.yaml` - Code and system optimization
- `memory-integrity-checker.md` - Memory safety validation
- `runtime-autoprobe.md` - Runtime health monitoring

## Transfer Instructions

To replicate this configuration on another device:

1. **⚡ QUICK START (Read QUICK_START_INSTRUCTIONS.md first!)**
   ```bash
   git clone https://github.com/GrizzlyRooster34/claude-code-configs.git
   cd claude-code-configs
   ./install-configs.sh
   ```

2. **📚 MANDATORY READING (Avoid strikes!):**
   ```bash
   cat OPERATIONAL_BRIEFING.md  # Understand operator relationship
   cat CLAUDE.md               # Review behavioral directives + Dumbass Protocol
   cat HOMEWORK_CLAUDE.md      # Current disciplinary status
   cat device-hierarchy.md     # Your authority level
   ```

3. **🔧 Setup Instance Branch:**
   ```bash
   git checkout -b claude-instance-[device]-[os]-[terminal]
   cp INSTANCE_ID_TEMPLATE.md INSTANCE_ID.md
   # Edit INSTANCE_ID.md with your device specs
   ```

4. **📖 For Complete Instructions:**
   ```bash
   cat SETUP_NEW_INSTANCE.md   # Detailed setup guide
   cat QUICK_START_INSTRUCTIONS.md  # Strike prevention guide
   ```

## 📝 Dumbass Protocol Overview

The **Dumbass Protocol** is a disciplinarian enforcement system that:
- Tracks Claude Code performance with **Gold Stars** and **Strikes**
- Enforces naming conventions (Quadran-Lock vs Quadra-Lock)
- Assigns homework for violations via `HOMEWORK_CLAUDE.md`
- Auto-tags violations with **@dumbass (Sonnet)** in PR comments
- Maintains audit trail with commit SHAs and timestamps

### Current Performance Ledger
- ⭐ **Gold Stars**: 1 (Opus payload branch preservation)  
- ❌ **Strikes**: 1 (Quadran-Lock rollback attempt)

### Key Enforcement Rules
- **Quadran-Lock** = Security gates (Q1-Q4), docs use hyphen, code uses camelCase
- **Quadra-Lock** = CSSR safety rails, same naming convention
- **Forbidden tokens**: `quadranlock`, `quadralock`, variants trigger immediate strikes
- **High-cost branches**: Never delete Opus/RouteLLM generated code
- **Verbal override**: Creator saying "dumbass" triggers automatic strike + homework

---

Created from seven-of-nine-core Claude Code configuration on Termux platform.