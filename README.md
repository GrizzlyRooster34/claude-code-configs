# Claude Code Configuration Repository

This repository contains all Claude Code configuration files and settings from the seven-of-nine-core project.

## Contents

### Agents (39 total)
- **`agents/`** - YAML configuration files and documentation for 39 specialized Claude agents
- **`agents-ts/`** - TypeScript implementation files for core agents

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

1. **Clone this repository:**
   ```bash
   git clone <this-repo-url>
   cd claude-code-configs
   ```

2. **Install configurations:**
   ```bash
   ./install-configs.sh  # (if installation script is available)
   ```
   
   Or manually copy files to appropriate Claude Code directories.

---

Created from seven-of-nine-core Claude Code configuration on Termux platform.