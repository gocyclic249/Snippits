# 🚀 GenAI.mil Continue.dev Integration Guide

Welcome to the configuration and setup guide for integrating **GenAI.mil** models into your local **Visual Studio Code** environment using **Continue.dev**.

---

## 🛠️ Step 1: Install Continue.dev on VS Code

To get started, you will need to install the Continue extension in Visual Studio Code. Please follow the instructions below:

| Step | Action | Details |
|---|---|---|
| 1 | **Open Extensions** | Open Visual Studio Code and click on the Extensions icon on the Activity Bar on the left side (or press `Ctrl+Shift+X` on Windows/Linux or `Cmd+Shift+X` on macOS). |
| 2 | **Search for Continue** | In the search bar, type `Continue` and look for the extension by **Continue** (with the official Continue logo). |
| 3 | **Install Extension** | Click the **Install** button to add the extension to your VS Code environment. |
| 4 | **Verify Installation** | Once installed, you will see a new **Continue** icon (a stylized letter 'C' or play icon) on your left-hand activity bar. |

---

## ⚙️ Step 2: Configure config.yaml

Continue uses a configuration file to connect to your preferred AI models. Follow these steps to apply your specific model configuration:

| Step | Action | Details |
|---|---|---|
| 1 | **Open Configuration** | Click on the **Continue** icon in the activity bar to open the sidebar. Click the **gear icon** (Settings) in the bottom-right corner of the sidebar, or use the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and search for `Continue: Open config.yaml` (or `config.json` depending on your version). |
| 2 | **Locate Config Directory** | Alternatively, navigate directly to your home directory folder: `~/.continue/config.yaml` (on macOS/Linux) or `%USERPROFILE%\.continue\config.yaml` (on Windows). |
| 3 | **Paste Configuration** | Replace the contents of your `config.yaml` file with the configuration provided in the section below. |
| 4 | **Save and Reload** | Save the file. Continue will automatically detect the changes and reload the configured models in your VS Code sidebar. |

---

## 📝 Configuration File (`config.yaml`)

Paste the following configuration block into your local `config.yaml` file:

```yaml
name: GenAI.mil
version: 1.0.0
schema: v1
models:
  - name: Gemini 2.5 Pro (DoW)
    provider: openai
    model: gemini-2.5-pro
    roles:
      - chat
      - edit
      - apply
    apiBase: https://api.genai.mil/v1
    apiKey: ""
    defaultCompletionOptions:
      temperature: 0.7
    capabilities:
      - tool_use
  - name: Gemini 2.5 Flash (DoW)
    provider: openai
    model: gemini-2.5-flash
    apiBase: https://api.genai.mil/v1
    apiKey: ""
    roles:
      - chat
      - edit
      - apply
      - autocomplete
    defaultCompletionOptions:
      temperature: 0.7
    capabilities:
      - tool_use
    useLegacyCompletionsEndpoint: false
  - name: Gemini 3.5 Flash (DoW)
    provider: openai
    model: gemini-3.5-flash
    apiBase: https://api.genai.mil/v1
    apiKey: ""
    roles:
      - chat
      - edit
      - apply
    defaultCompletionOptions:
      temperature: 0.7
    capabilities:
      - tool_use
```
