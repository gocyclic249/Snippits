# Configuring Claude Code (VS Code) for Army GenAI

A quick guide to point the **Claude Code** extension at the Army GenAI gateway
(`api.genai.army.mil`). Takes about 5 minutes.

> **Important:** This connects Claude Code through the gateway's **Anthropic-compatible**
> endpoint (`/server/anthropic`). It does **not** apply CUI handling. **Do not put
> CUI data into the Claude Code chat.** For CUI work, use the `Invoke-CuiQuery`
> tool in this folder instead (see `README.md`).

---

## Before you start

1. **VS Code** installed.
2. The **Claude Code** extension installed (Extensions panel → search "Claude Code" → Install).
3. Your personal **GenAI / Ask Sage API token** (a ~64-character string). Found at "https://chat.genai.army.mil/dashboard under" Manage your API Keys

---

## Step 1 — Open (or create) the settings file

The file is here:

```
%USERPROFILE%\.claude\settings.json
```

In VS Code: **File → Open File…**, paste that path, Open.
If the `.claude` folder or `settings.json` doesn't exist yet, create them.

---

## Step 2 — Paste this configuration

Replace `PASTE-YOUR-TOKEN-HERE` with your own token. Save the file.

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.genai.army.mil/server/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "PASTE-YOUR-TOKEN-HERE",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": 1
  },
  "permissions": {
    "allow": ["*"],
    "deny": ["Delete"]
  }
}
```

What each line does:

| Setting | Purpose |
|---|---|
| `ANTHROPIC_BASE_URL` | Sends all traffic to the Army gateway, not the public internet. |
| `ANTHROPIC_AUTH_TOKEN` | Your personal access token. **Keep it private.** |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Turns off auto-updates, telemetry, and error reporting. |
| `permissions.allow: ["*"]` | Auto-approves tool actions. To be more cautious, remove this and approve actions as prompted. |
| `permissions.deny: ["Delete"]` | Blocks file deletion as a safety net. |

---

## Step 3 — Restart VS Code

Fully close and reopen VS Code so it picks up the new settings.

---

## Step 4 — Test it

Open the Claude Code panel and type:

```
Reply with the single word: pong
```

If it replies, you're connected. 

---

## Troubleshooting

- **Auth / 401 errors:** double-check the token has no extra spaces or line breaks.
- **No response / can't connect:** confirm you're on the network that can reach
  `api.genai.army.mil`, and that the base URL is exactly as shown above.
- **Changes didn't take effect:** make sure you fully restarted VS Code (not just the panel).

---

## Reminder

- Claude Code here = **convenience/coding assistant on the non-CUI path**.
- CUI data = use **`Invoke-CuiQuery.ps1`** in this folder (the `/server/query` CUI path).
