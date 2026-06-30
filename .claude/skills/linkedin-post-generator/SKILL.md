---
name: linkedin-post
description: Generate a polished, technical LinkedIn post (in both English and Arabic) from the user's recent code changes. Use this skill whenever the user asks to write a LinkedIn post, share their work on LinkedIn, summarize what they built/shipped for social media, or says things like "اعمل لي بوست لينكد ان", "post about my changes", "share this feature on LinkedIn", or "/linkedin-post". Also use it when the user finishes a feature and wants to announce it publicly.
---

# LinkedIn Post from Code Changes

Turn git changes into a professional, technically detailed LinkedIn post in **two versions: English and Arabic**.

## Step 1: Ask which changes to read

Always ask the user which source to read (unless they already specified it in their request). Offer these options:

1. **Uncommitted changes** → `git diff` + `git diff --staged`
2. **Last commit** → `git show HEAD --stat -p`
3. **Last N commits / since a date** → `git log --since="..." -p --stat` or `git diff HEAD~N..HEAD`
4. **Branch vs main** → `git diff main...HEAD --stat -p`

If the diff is very large (>2000 lines), read `--stat` first, then read full diffs only for the most significant files (skip generated files, lockfiles, `.g.dart`, `.freezed.dart`, build outputs, assets).

## Step 2: Analyze the changes like an engineer, not a changelog

Extract the *story* behind the diff:

- **What feature/fix is this?** (the user-facing or business value)
- **How was it built?** Architecture decisions, patterns, packages used (e.g., Clean Architecture layers touched, BLoC/Cubit, DI, middleware, EF Core migrations, React hooks...)
- **Interesting technical challenges** visible in the code: error handling strategies, edge cases, refactors, performance work
- **Numbers if available**: files changed, lines, new endpoints, screens, test coverage

If the diff alone doesn't reveal the "why" or a challenge worth mentioning, ask the user 1–2 short questions (e.g., "What problem pushed you to build this?" / "Any tricky part worth highlighting?"). A post with a real story performs far better than a generic feature list.

## Step 3: Privacy & confidentiality check (MANDATORY)

Before writing anything, scan what you plan to mention and **never include**:

- Client or employer names, internal project codenames, private repo names — unless the user explicitly confirms it's OK
- API keys, tokens, URLs of internal/staging environments, package names that reveal the client (e.g., `com.clientname.app`)
- Business-sensitive logic, pricing, or unreleased product details

When in doubt, generalize: "a logistics client app" instead of the real name. If the repo clearly belongs to an employer/client, remind the user briefly: "Heads up — I kept the client name out. Tell me if you want it included."

## Step 4: Write the post — both versions

Produce **two complete posts**: Arabic FIRST, then English. They should carry the same content but each must read natively, not as a translation.

**Arabic voice (important):** conversational professional Arabic — the way a developer actually talks, not formal MSA. Mix everyday phrasing ("كان عندي مشكلة", "الكود كان بيقرأ") with technical terms kept in English inline (main thread, data layer, Cubit, compute()). Avoid stiff constructions like "أنجزتُ" or "قمتُ بتطوير".

**The Arabic version always opens with the greeting merged into the hook on the same line** — never on its own line:

```
السلام عليكم — [جملة الـ hook]
```

Strong hook pattern: state the problem then subvert the expected cause — e.g. "...كانت بتتجمّد لثوانٍ، والسبب لم يكن الشبكة."

### LinkedIn formatting rules (apply to both)

- **No Markdown.** LinkedIn doesn't render it. No `**bold**`, no `#` headers, no backticks.
- Short paragraphs: 1–2 lines each, **with exactly one blank line between every paragraph and around every list** — no cramped blocks, no double blank lines. LinkedIn truncates after ~3 lines ("see more"), so the **first line must hook**.
- Use unicode bullets for lists: `•` or `→`, or numbered lists (`1.` `2.`) when the problem has multiple dimensions.
- Emojis: light and purposeful (2–5 total), not decorating every line.
- **Hashtags appear ONCE only — at the very end of the English version** (which is the end of the whole post). The Arabic version gets no hashtags. Use 3–6, mixing broad + specific, e.g.: `#Flutter #MobileDevelopment #CleanArchitecture #Performance`.
- Length: **100–170 words**. Tight beats thorough — keep the problem, its cause, and the strongest one or two fixes; cut secondary details (minor bonus fixes, inner-layer minutiae). Never exceed ~200 words.

### Post structure (technical-detail style)

```
[Hook — one line: the problem + a twist ("...and the cause wasn't X"). NOT "I'm excited to share...". Arabic version: السلام عليكم — merged into this line]

[Context — the concrete scenario, 1–2 lines]

[The problem — if it has more than one dimension, break it into a short numbered list
 (e.g. 1. performance: ... 2. architecture: ...)]

[The fix — what was done and where it lives, 2–4 short lines]

[Result — 1–2 short, punchy lines]

[Question — invite real feedback: ask if there's a better way to do it,
 not a generic engagement question]

[Hashtags]
```

### Tone

- Confident, specific, first-person. Show real engineering thinking.
- Concrete > vague: "handled 403 responses with a session-level navigation guard" beats "improved error handling".
- Never invent metrics, results, or challenges that aren't in the diff or confirmed by the user.
- Avoid LinkedIn clichés: "I'm thrilled/humbled/excited to announce", "game-changer", "🚀🚀🚀".

## Step 5: Deliver

Output ONE ready-to-paste block — Arabic first, then a dash separator line, then English, with the hashtags at the very end. **No headers or labels** like "النسخة العربية" or "English version" — the user pastes the whole thing into LinkedIn as-is:

```
[Arabic post — no hashtags]

------------------------------------------

[English post]

[hashtags]
```

Then offer quick adjustments: shorter / more casual / add a code-snippet image suggestion / different hook. Apply edits to both versions to keep them in sync.

**Before writing, read `references/example.md`** — it contains the gold-standard post (written and approved by the user). Match its voice, rhythm, and structure as closely as the new content allows.