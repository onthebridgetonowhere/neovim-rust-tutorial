# Neovim (0.9) & Rust LSP setup for total beginners

## Description

I always had issues in setting up Neovim and the Rust LSP. I finally managed to get it only a few steps, so this tutorial will demonstrate how to set it up for Linux.

## Repo contents

This repository contains the exact files I used in the description below. If you want to start fresh with a Neovim installation, just copy the two files `init.lua` and `lua/rust.lua`, and add them to your `~/.config/nvim` folder. From there you should be able to run `:PackerInstall`.

## Step-by-step guidelines

### Install Rust

- `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

### Install Rust Analyzer

- `git clone https://github.com/rust-lang/rust-analyzer.git && cd rust-analyzer && cargo xtask install --server`
- check that `rust-analyzer` works by typing the command `rust-analyzer --help` in a terminal. It should not complain that it cannot find the command.

### Install Neovim ( I used the X64 nightly version )

- `wget https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.deb && sudo dpkg -i nvim-linux64.deb`

### Start and configure Neovim

- to start Neovim, open a terminal and type `nvim`.
- to exit Neovim, type `:q` (: is for issuing a command, and q is the shortcut from quit)
- a lot of magic happens in the plugins that one can install for Neovim. To do so, we need to write a bit of code
- let's write the script to initialize neovim with the defaults we want to have
- this script needs to be in the default folder for Neovim (might be different depending on the OS). On Linux Mint & Ubuntu the file `init.lua` sits in the `~/.config/nvim/` folder.
- to open or create the file with `nvim` type `nvim ~/.config/nvim/init.lua`
- if you use nvim, then type `:wq` which will save the file (`w`) and then quit neovim (`q`).

- first we need to tell neovim that we want to install a package (plugin) manager. In this case, let's install [Packer](https://github.com/wbthomason/packer.nvim). You need to clone the repository as per the instructions: `git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim`
- open the file `~/.config/nvim/init.lua` and add the following
  ```
  require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
  end)
  ```
- This will add support for `Packer`. Open Neovim and type :PackerInstall. It will install any packages required.
- Next, we can add support for `lsp`. Open `~/.config/nvim/init.lua` and add the `use 'neovim/nvim-lspconfig'` to it as below.

  ```lua
  require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- LSP Config
  use 'neovim/nvim-lspconfig'
  end)
  ```

- Open Neovim and type `:PackerInstall`. It should now install `LSP Config`.
- if all worked OK, then opening a `.rs` file with Neovim should be error free.
- finally, to add all the goodies for LSP and Rust, add the following code (from https://sharksforarms.dev/posts/neovim-rust/) into the `init.lua` file

  ```lua
  use "hrsh7th/nvim-cmp"

  use({
  -- cmp LSP completion
  "hrsh7th/cmp-nvim-lsp",
  -- cmp Snippet completion
  "hrsh7th/cmp-vsnip",
  -- cmp Path completion
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-buffer",
  after = { "hrsh7th/nvim-cmp" },
  requires = { "hrsh7th/nvim-cmp" },
  })

  use("simrat39/rust-tools.nvim")
  ```

- then type `:PackerInstall` to install all the new plugins.
- finally, let's make sure that Rust LSP is set up properly. Open a file at `~/.config/nvim/lua/rust.lua` and copy the following code:

  ```lua
  -- Set completeopt to have a better completion experience
  -- :help completeopt
  -- menuone: popup even when there's only one match
  -- noinsert: Do not insert text until a selection is made
  -- noselect: Do not auto-select, nvim-cmp plugin will handle this for us.
  vim.o.completeopt = "menuone,noinsert,noselect"

  -- Avoid showing extra messages when using completion
  vim.opt.shortmess = vim.opt.shortmess + "c"

  local function on_attach(client, buffer)
    -- This callback is called when the LSP is atttached/enabled for this buffer
    -- we could set keymaps related to LSP, etc here.
  end

  -- Configure LSP through rust-tools.nvim plugin.
  -- rust-tools will configure and enable certain LSP features for us.
  -- See https://github.com/simrat39/rust-tools.nvim#configuration
  local opts = {
    tools = {
      runnables = {
        use_telescope = true,
      },
      inlay_hints = {
        auto = true,
        show_parameter_hints = false,
        parameter_hints_prefix = "",
        other_hints_prefix = "",
      },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
    server = {
      -- on_attach is a callback called when the language server attachs to the buffer
      on_attach = on_attach,
      settings = {
        -- to enable rust-analyzer settings visit:
        -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
        ["rust-analyzer"] = {
          -- enable clippy on save
          checkOnSave = {
            command = "clippy",
          },
        },
      },
    },
  }

  require("rust-tools").setup(opts)

  -- Setup Completion
  -- See https://github.com/hrsh7th/nvim-cmp#basic-configuration
  local cmp = require("cmp")
  cmp.setup({
    preselect = cmp.PreselectMode.None,
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = {
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      -- Add tab support
      ["<S-Tab>"] = cmp.mapping.select_prev_item(),
      ["<Tab>"] = cmp.mapping.select_next_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.close(),
      ["<CR>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      }),
    },

    -- Installed sources
    sources = {
      { name = "nvim_lsp" },
      { name = "vsnip" },
      { name = "path" },
      { name = "buffer" },
    },
  })

  ```

- then add `require('rust')` at the end of the `init.lua` file. Open Neovim and type `:PackerInstall` and everything should work.
