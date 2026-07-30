<div align="center">

<img src="https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsarbanner.png" alt="Pulsar Framework" width="100%" />

<br/>

# PULSAR-LAPTOP

### In-game laptop — business management (BizWiz), LS Underground, team management, and settings, as an app-based NUI

<br/>

![Lua](https://img.shields.io/badge/Lua_5.4-2C2D72?style=flat-square&logo=lua&logoColor=white)
![FiveM](https://img.shields.io/badge/FiveM-F40552?style=flat-square)
![Svelte](https://img.shields.io/badge/Svelte_5-FF3E00?style=flat-square&logo=svelte&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=flat-square&logo=typescript&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-646CFF?style=flat-square&logo=vite&logoColor=white)
![Bun](https://img.shields.io/badge/Bun-000000?style=flat-square&logo=bun&logoColor=white)

<br/>

<sub>Enjoy the framework? A coffee helps keep active development, hardening, and support going.</sub>

<a href="https://buymeacoffee.com/pulsarframework"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 50px !important;width: 180px !important;" /></a>

<br/>

[Overview](#overview) · [Apps](#apps) · [Theming](#theming) · [Dependencies](#dependencies)

</div>

---

## Overview

Registers `plsr.Laptop`. A desktop shell — Home grid, taskbar clock/notifications, draggable app windows — with four real apps living under `apps/`, each with its own client/server Lua pair and Svelte NUI screen. `internet` and `files` are decorative-only entries in the app catalog (`fake = true` in `server/data.lua`); clicking them does nothing, matching old's behavior where those apps were never actually built.

---

## Apps

- **BizWiz** — business management for any job/business with a `config.bizwiz.businesses` entry (`config/server.lua`): dashboard + notice board, PDM/Dynasty-style vehicle and property sales (stock, credit checks, sales history, dealer config), Casino big-wins ticker, an internal documents/receipts system with a per-employee receipt leaderboard, and a business "Spammer" (Twitter-style broadcast) with a profile picture setting.
- **LS Underground** — restricted app (`ACCESS_LSUNDERGROUND` state / `PHONE_VPN` / `RACE_DONGLE`): a 5-tab shell for Boosting (contract queue, accept/transfer/decline, admin contract creation + ban management), a Boosting Market tab (not yet wired server-side — same as old), a Chop List viewer, a black-market Market/shop with a cart + checkout, and Reputation progress bars.
- **Teams** — create/join/manage a team, invites, and member management.
- **Settings** — wallpaper, accent color, zoom, volume, and notification toggles.

---

## Theming

Edit `ui/src/theme.css` for colors and fonts, and `ui/src/config.ts` for the app registry. Then rebuild:

```
cd ui
bun install
bun run build
```

Commit the rebuilt `ui/dist/` — that's what actually ships.

---

## Dependencies

- `pulsar_core` — framework core
- `pulsar_pwnzor` — anti-cheat check loaded alongside every resource

---

## License

This resource is free to use and modify under the [Pulsar Framework License](LICENSE.md). Redistribution is welcome as long as it stays free — selling this resource or any derivative of it requires written permission from the Pulsar Framework team.

---

<div align="center">

![Pulsar Framework](https://img.shields.io/badge/Pulsar-Framework-7c3aed?style=flat-square)
![Built for FiveM](https://img.shields.io/badge/Built_for-FiveM-F40552?style=flat-square)

</div>
