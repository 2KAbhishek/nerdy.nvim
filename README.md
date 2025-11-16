<div align = "center">

<h1><a href="https://github.com/2kabhishek/nerdy.nvim">nerdy.nvim</a></h1>

<a href="https://github.com/2KAbhishek/nerdy.nvim/blob/main/LICENSE">
<img alt="License" src="https://img.shields.io/github/license/2kabhishek/nerdy.nvim?style=flat&color=eee&label="> </a>

<a href="https://github.com/2KAbhishek/nerdy.nvim/graphs/contributors">
<img alt="People" src="https://img.shields.io/github/contributors/2kabhishek/nerdy.nvim?style=flat&color=ffaaf2&label=People"> </a>

<a href="https://github.com/2KAbhishek/nerdy.nvim/stargazers">
<img alt="Stars" src="https://img.shields.io/github/stars/2kabhishek/nerdy.nvim?style=flat&color=98c379&label=Stars"></a>

<a href="https://github.com/2KAbhishek/nerdy.nvim/network/members">
<img alt="Forks" src="https://img.shields.io/github/forks/2kabhishek/nerdy.nvim?style=flat&color=66a8e0&label=Forks"> </a>

<a href="https://github.com/2KAbhishek/nerdy.nvim/watchers">
<img alt="Watches" src="https://img.shields.io/github/watchers/2kabhishek/nerdy.nvim?style=flat&color=f5d08b&label=Watches"> </a>

<a href="https://github.com/2KAbhishek/nerdy.nvim/pulse">
<img alt="Last Updated" src="https://img.shields.io/github/last-commit/2kabhishek/nerdy.nvim?style=flat&color=e06c75&label="> </a>

<h3>Find Nerd Glyphs Easily 🤓🔭</h3>

<figure>
  <img src="doc/images/screenshot.jpg" alt="nerdy.nvim in action">
  <br/>
  <figcaption>nerdy.nvim in action</figcaption>
</figure>

</div>

Do you like [Nerd fonts](https://github.com/ryanoasis/nerd-fonts)? but don't like going over to [their site](https://www.nerdfonts.com/cheat-sheet) to fetch a glyph for your pretty terminal? Well, me too!

Introducing nerdy.nvim, a super handy plugin that lets you search, preview and insert all nerd font glyphs straight from Neovim!

## ✨ Features

- Fuzzy search and insert nerd glyphs, by name and unicode
- Find and insert icons you use frequently
- Programmatic access to nerd glyphs by name for use in your configs
- Auto fetch latest icons list from official sources

## Setup

### ⚡ Requirements

- You have installed the latest version of `neovim`
- [snacks.nvim picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md) — for prettier select UI and multi select (optional, recommended)

### 🚀 Installation

```lua
-- Lazy
{
    '2kabhishek/nerdy.nvim',
    dependencies = {
        'folke/snacks.nvim',
    },
    cmd = 'Nerdy',
    opts = {
        max_recents = 30, -- Configure recent icons limit
        add_default_keybindings = true, -- Add default keybindings
        copy_to_clipboard = false, -- Copy glyph to clipboard instead of inserting
        copy_register = '+', -- Register to use for copying (if `copy_to_clipboard` is true)
    }
},
```

### 💻 Usage

#### 🚀 Commands

**Available Commands:**

- `:Nerdy` - Browse all nerd font icons (default behavior)
- `:Nerdy list` - Browse all nerd font icons (explicit)
- `:Nerdy recents` - Browse recently used icons
- `:Nerdy get <icon_name>` - Insert specific icon by name

#### ✅ Multi Select

**Multi-select Support**: When using with [snacks.nvim picker](https://github.com/folke/snacks.nvim/blob/main/docs/picker.md), you can select multiple glyphs at once:

- Use `<Tab>` to select/deselect individual glyphs
- Use `<Ctrl-a>` to select all glyphs on a filtered list
- Use `<Enter>` to confirm your selection

#### ⌨️ Keybindings

By default, these are the configured keybindings.

| Keybinding   | Command                           | Description               |
| ------------ | --------------------------------- | ------------------------- |
| `<leader>in` | `:Nerdy list<CR>` or `:Nerdy<CR>` | Browser nerd icons        |
| `<leader>iN` | `:Nerdy recents<CR>`              | Browser recent nerd icons |

I recommend customizing these keybindings based on your preferences.

Use `:help nerdy` for more details.

#### 🔭 Telescope Extension

Nerdy also comes with a Telescope extension, to use it add the following to your telescope configs.

```lua
require('telescope').load_extension('nerdy')
```

And then call

```vim
:Telescope nerdy
:Telescope nerdy_recents
" or
:lua require('telescope').extensions.nerdy.nerdy()
:lua require('telescope').extensions.nerdy.nerdy_recents()
```

#### 📝 Get Icons by Name Programmatically

You can also get nerd font icons programmatically using the `nerdy.get()` function:

```lua
local nerdy = require('nerdy')

-- Get a specific icon by name
local lua = nerdy.get('seti-lua')              -- Returns ''

-- Handle cases where icon doesn't exist
local unknown_icon = nerdy.get('non-existent') -- Returns '' and shows warning

-- Use in your own functions
local function get_language_icon(language)
    local icon_name = 'md-language_' .. language
    return nerdy.get(icon_name)
end
```

Recent icons are not tracked when fetching icons programmatically.

**💡 This is useful when configuring Neovim status lines, file trees, or any plugin that needs consistent nerd font icons without hard coding unicode characters.**

#### 🔄 Fetch New Icons

Running the `python scripts/generator.py` command will automatically fetch new icons from [source](https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/glyphnames.json) and update the icons.

## Behind The Code

### 🌈 Inspiration

I love nerd font glyphs, and I use them anywhere I can! but I was wasting a lot of time going back and forth between nerd font site and neovim, also the copy feature was super buggy for me on the site, so I made nerdy!

### 💡 Challenges/Learnings

- Making the generated icon table with vim.ui.select was a bit tricky.

### 🧰 Tooling

- [dots2k](https://github.com/2kabhishek/dots2k) — Dev Environment
- [nvim2k](https://github.com/2kabhishek/nvim2k) — Personalized Editor

### 🔍 More Info

- [nerdicons.nvim](https://github.com/nvimdev/nerdicons.nvim) — thanks to the original authors for the groundwork.
- [co-author.nvim](https://github.com/2kabhishek/co-author.nvim) — Another one of my plugin that lets you add co authors.

<hr>

<div align="center">

<strong>⭐ hit the star button if you found this useful ⭐</strong><br>

<a href="https://github.com/2KAbhishek/nerdy.nvim">Source</a>
| <a href="https://2kabhishek.github.io/blog" target="_blank">Blog </a>
| <a href="https://twitter.com/2kabhishek" target="_blank">Twitter </a>
| <a href="https://linkedin.com/in/2kabhishek" target="_blank">LinkedIn </a>
| <a href="https://2kabhishek.github.io/links" target="_blank">More Links </a>
| <a href="https://2kabhishek.github.io/projects" target="_blank">Other Projects </a>

</div>
