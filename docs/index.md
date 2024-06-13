---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "Telem"
  text: "Turn your items into insights"
  tagline: Trivial ETL Engine for Minecraft
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started

features:
  - title: Standardized data format
    details: No more standardization headaches across different peripherals
  - title: Intuitive API
    details: Utilize dozens of built-in inputs and outputs with a simple interface. Or write your own!
  - title: Deep integrations
    details: First-class support for Applied Energistics, and more
---

## Do you love data?

Are you tired of creating complex logic to monitor inventory or production? Want something more modern, modular, and scalable? Want something that can empower live dashboards, both in-game and out? You have come to the right place.

### Extract
* Connect to item and fluid storage, with specialized support for Storage Drawers and Applied Energistics.
* ~~Monitor Mekanism reactors, turbines, and multiblock energy systems.~~
* Write custom adapters to support any block, system, or event that you want to integrate.

### Transform
* Attach middleware to calculate deltas, rates, and averages of your resources over time.
* Use custom middleware to apply your own measures, on an input-by-input basis or across the entire data stream.

### Load
* Supports direct output to a Grafana dashboard for historical analysis and real-time monitoring.
* Use Modem to transmit to a central monitoring hub through wired or wireless.

## Quick Start

Run the installer:

```bash
pastebin run -f paUSHQQC bakaneko152 telem master src/telem
mkdir /home/lib
mv /telem /home/lib/telem

```

Then, read the [Getting Started](/getting-started) guide to learn how to use Telem.

## Requirements
- OpenComputers(I use the GTNH environment)
- Internet Card for installer/Grafana