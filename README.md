# Ready by Eight — Web

A minimalist web clock with a private, encouraging morning chatbot named **Eight**. Ported from the SwiftUI iOS app to the browser: same scheduling model, same coach, same dark mint-and-charcoal look.

> **Honest limitation, same as the iOS version:** a web page cannot ring like a real alarm when the browser is closed. Notifications only fire while the site is open (or via a service worker while it stays alive). **Keep your phone's Clock app alarm as the backup.** Eight reminds and encourages; it does not guarantee you wake up.

## Features

- Dark clock dashboard with a live time display and next-reminder summary.
- Create, edit, enable, disable, and delete up to eight reminders.
- Repeat once, daily, on weekdays, or on weekends.
- Browser notifications with sound while the app tab is open.
- A small morning challenge with a daily completion marker.
- Chat with quick prompts, selectable messages, and conversation clearing.
- Built-in offline coach replies that work with zero setup.
- Optional AI replies: bring your own provider key in Settings (never hard-coded).
- Local-first storage; no account, no server, no tracking.

Eight offers suggestions, not medical advice. Chat cannot create or change reminders; use the Clock tab.

## Suggested stack

Any of these work — the app is intentionally simple:

- **Simplest:** one `index.html` with vanilla HTML/CSS/JS. Hosts anywhere (GitHub Pages, Netlify) with zero build step.
- **If you prefer components:** Vite + React/TypeScript, or Svelte.

Everything below is stack-agnostic.

## Getting started

```sh
git clone <your-repo-url>
cd ready-by-eight-web

# Vanilla version: just open index.html, or serve it
npx serve .          # or: python3 -m http.server

# Vite version
npm install
npm run dev          # local dev server
npm run build        # production build to dist/
```

## Project structure

```text
index.html               # App shell
styles/theme.css         # Design tokens + effects (see Design system)
src/
├── main.js              # Boot, tab routing (Clock / Eight)
├── models.js            # Reminder, repeat rules, next-occurrence math
├── store.js             # localStorage persistence, state changes
├── notifications.js     # Permission, scheduling while open, delivery
├── coach.js             # Offline replies + optional AI provider call
└── views/
    ├── clock.js         # Dashboard, reminder editor, challenge
    └── chat.js          # Eight chat screen
tests/                   # Logic tests for scheduling + coach
```

## Design system

Ported from `GhostTheme.swift`. Colors are converted from the Swift RGB values.

### Tokens

| Token | Value | Use |
|---|---|---|
| `--mint-bright` | `#D9FAB8` | Highlights, glow |
| `--mint` | `#C2E89E` | Accent, buttons, links |
| `--teal` | `#59B8AD` | Gradient partner, secondary accent |
| `--ink-deep` | `#06080A` | Deepest background |
| `--ink` | `#0E1113` | Base background |
| `--ink-raised` | `#1A1D21` | Raised surfaces, inputs |
| `--text-primary` | `rgba(255,255,255,.92)` | Body text |
| `--text-secondary` | `rgba(255,255,255,.58)` | Captions, hints |
| `--hairline` | `rgba(255,255,255,.10)` | 1px borders |
| `--glass` | `rgba(255,255,255,.06)` | Card fill |
| `--glass-strong` | `rgba(255,255,255,.10)` | Hover/active fill |

Radii: card `24px`, chip `14px`, sheet `32px`.
Spacing scale: `6 / 10 / 16 / 24 / 32px`.

### Effects

- **Aurora background** — deep ink gradient with two large blurred mint/teal circles drifting on a sine phase, plus a soft vignette. Animate with `requestAnimationFrame`; target **60 fps**, and **pause when `document.hidden`**.
- **Glass cards** — one gradient fill + one hairline border + a soft cached shadow. Avoid animated box-shadows (they repaint every frame).
- **Press feedback** — `scale(0.97)` + `opacity(0.88)` on `:active` with a spring-like transition (`280ms`, slight overshoot).
- **Shimmer** (opt-in) — a translating light sweep using `transform` only, never `width`/`left`.
- **Ghost mascot** — Eight's mascot floats, blinks, and moves its mouth while `isSpeaking` is true (during AI/coach reply generation). Pure CSS keyframes or a small canvas; drive the mouth from the same state flag that shows the typing indicator.

### Accessibility & performance

- Honor `prefers-reduced-motion`: render the aurora static, disable shimmer and mascot bounce.
- Animate only `transform` and `opacity`; keep blurs on few, large elements.
- Pause all loops when the tab is hidden.
- Maintain WCAG AA contrast on dark surfaces (the tokens above are chosen for it).

## The Eight coach

Offline replies are keyword-matched, clearly labeled, and always available:

| User says | Eight does |
|---|---|
| "alarm", "wake" | States the next reminder and points to the Clock tab |
| "tired", "sleep" | Gentle wind-down steps for tonight |
| "late", "rush" | Essentials-only triage |
| "challenge", "motivat" | A two-minute physical challenge |
| anything else | One small, achievable suggestion |

Rules: at most ~90 words, one actionable step, no shame, no medical advice, never claims it changed a reminder.

### Optional AI replies

- User pastes their own provider key in Settings (OpenAI-compatible base URL + model ID). Store it in `localStorage` on their device only.
- Never commit keys, never ship a key in client code, never proxy someone else's key through your server.
- If no key is set, or the request fails, fall back to the offline reply and label it as such.

## Notifications on the web (read before building)

1. Request permission from a user gesture (a button), never on page load.
2. While the tab is open, check upcoming reminders on an interval (e.g. every 15–30 s) and fire a `Notification` when due; mark it delivered so it doesn't repeat.
3. A service worker + Push lets notifications arrive when the tab is closed, but that needs a push server — out of scope for v1.
4. The Notification Triggers API (scheduled future notifications) is experimental and not cross-browser. Do not rely on it.
5. Always show the next reminder in the UI itself, so the app is useful even with notifications denied.

## Data & privacy

- Reminders, chat history (last 60 messages), and today's challenge flag live in `localStorage`.
- No analytics, no accounts, no server calls except the user's own optional AI provider.
- Provide **Export** (download JSON) and **Erase all data** (clear storage) buttons.
- Clearing the chat clears the app's copy only; exported files are the user's responsibility.

## Testing

Port the iOS regression suite to your stack (Vitest, or plain Node asserts):

- Next occurrence across midnight, weekdays, weekends, DST gaps and overlaps.
- Eight-reminder cap; label trimming to 60 characters.
- Draft autosave and message cap at 60.
- Day-key challenge logic.
- Every offline coach branch, including empty and long input (2,000-character cap).

## Roadmap

- [ ] PWA install + service worker basics
- [ ] Push notifications for closed-tab delivery (needs a tiny push server)
- [ ] Snooze from the notification
- [ ] Streak history and weekly summary
- [ ] Themes beyond mint/charcoal

## Provenance

Ported from the iOS app **Ready by Eight** (SwiftUI, Swift 6) in [`GhostChatDev/Ai-Alarm-Clock`](https://github.com/GhostChatDev/Ai-Alarm-Clock). Scheduling rules, coach behavior, and the design tokens in this file mirror that codebase.

## License

Choose one before publishing (MIT is a common default for app demos).
