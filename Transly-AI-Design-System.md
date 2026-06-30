# Transly AI — Design System / دليل التصميم

A multilingual AI translation mobile app (iOS/Android). Professional/corporate feel, coral accent, supports both **Arabic (RTL)** and **English (LTR)**. Light + Dark mode.

---

## 1. Color Palette · الألوان

### Brand (Coral)
| Token            | Hex       | Usage |
|------------------|-----------|-------|
| Primary          | `#FF5836` | Main brand color, active states, badges (light mode) |
| Deep             | `#F5421C` | Gradient end, pressed states |
| Accent (dark)    | `#FF6A45` | Primary accent on dark surfaces |
| Accent 2 (dark)  | `#FF8A66` | Secondary accent / RTL labels on dark |
| Gradient         | `linear-gradient(150deg, #FF7A4D, #F5421C)` | Buttons, mic, logo, avatars |

### Coral Tints (light)
| Hex       | Usage |
|-----------|-------|
| `#FFF4F0` | Output card bg, icon chip bg |
| `#FFEAE2` | Output card gradient end |
| `#FFD8C9` | Tint borders |
| `#C0461F` | RTL/Arabic label text on light |

### Light Neutrals
| Token         | Hex       | Usage |
|---------------|-----------|-------|
| Ink           | `#16181D` | Primary text |
| Secondary     | `#5A6072` | Secondary text |
| Muted         | `#9AA0AE` | Captions, placeholders, icons-muted |
| Border        | `#ECEDF1` | Card/divider borders |
| Divider       | `#F1F2F5` | Inner row dividers |
| Surface       | `#F6F7F9` | App background |
| Chip bg       | `#F2F3F6` | Neutral chips (e.g. EN tag) |
| White         | `#FFFFFF` | Cards, docks |

### Dark Neutrals
| Token         | Hex       | Usage |
|---------------|-----------|-------|
| Background    | `#0E0F12` | App background |
| Card          | `#1B1D22` | Cards, docks, inputs |
| Chip          | `#26282E` | Neutral chips |
| Border        | `#2A2D34` | Borders, dividers |
| Text Primary  | `#F3F4F6` | Primary text |
| Text Secondary| `#969CA8` | Secondary text |
| Text Muted    | `#7C828E` | Captions, placeholders |
| Icon line     | `#5A5F69` | Muted icon strokes |

---

## 2. Typography · الخطوط

**Font family:** `IBM Plex Sans Arabic` (supports Arabic + Latin) — fallback `IBM Plex Sans, system-ui, sans-serif`
**Weights:** 300 / 400 / 500 / 600 / 700

| Style    | Size | Weight | Usage |
|----------|------|--------|-------|
| Display  | 40px | 700    | Onboarding hero |
| Heading  | 25px | 700    | Screen titles |
| Body L   | 20px | 400    | Source/translation text |
| Body     | 16px | 400    | Default body text |
| Caption  | 13px | 600    | Labels, captions (often UPPERCASE, letter-spacing .04–.05em) |
| Micro    | 11–12px | 500–600 | Tags, hints, monospace codes |

RTL text: set `direction:rtl; text-align:right;` on Arabic content.

---

## 3. Iconography · الأيقونات

- **Style:** outline / line icons, `stroke-width: 1.8` (1.5 for filled stars), rounded line caps & joins, 24×24 viewBox.
- **Color:** inherit text color; accent (`#FF5836` / `#FF6A45`) for active/AI states.
- **Set used:** Translate (book+A), Swap (two arrows), Voice (mic), Camera, Speaker, Copy, Save (check-circle), Favorite (star), Search, Language (globe), Keyboard, AI Spark (filled 4-point star).

---

## 4. Components · المكوّنات

### Buttons
- **Primary:** height 52–56px, radius 16px, gradient bg, white text, weight 600, shadow `0 10px 22px rgba(245,66,28,.3)`.
- **Secondary:** same size, `#fff` bg + `1px #ECEDF1` border (light) / `#1B1D22` bg + `1px #2A2D34` (dark), ink/`#F3F4F6` text.

### Tone chips (النبرة)
- Pill, radius 999px, padding `9px 16px`, 13px/600.
- Active: solid accent + white text. Inactive: surface bg + border + secondary text.

### Badge (AI)
- Pill, accent bg, white text, 11px/600, spark icon. `padding 4px 9px`.

### Toggle
- Track 50×30px, radius 999px. Knob 24px circle, white, 3px inset.
- On: accent track, knob right. Off: `#E6E8ED` (light) / `#2A2D34` (dark) track, knob left.

### Cards & Radius scale
| Element | Radius |
|---------|--------|
| Card    | 20px |
| Input / search | 14px |
| Icon chip / small | 10–12px |
| Pill / toggle | 999px |

- Card: bg `#fff`/`#1B1D22`, border `#ECEDF1`/`#2A2D34`, padding 16–18px.

### Spacing
- Screen horizontal padding: 16–20px.
- Gap between stacked cards: 12px. Inner element gaps: 8px.

---

## 5. Layout & Behavior

- **Device target:** iPhone frame, screen ~402px wide.
- **Bilingual output cards:** show source + AI translation, with an `AI` badge on the translated side.
- **Tone selector:** Formal / Casual / Short (رسمية / عامية / مختصرة), AI-suggested.
- **Input dock:** Keyboard · Voice · Camera (3 modes).
- **Conversation mode:** chat bubbles, each showing both languages; mic button with pulse animation.
- **Camera mode:** live OCR overlay — original struck-through, translation below, in coral-outlined boxes.

### Animations
- Mic pulse: scale 1→1.18, opacity .5→0, 1.8s ease-out infinite.
- Voice waveform bars: height 18%→90%, 0.9s ease-in-out, staggered .15s delays.
