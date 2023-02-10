vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Colorscheme
  use 'joshdick/onedark.vim'

  -- LSP
  use 'neovim/nvim-lspconfig'

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
  use("nvim-lua/popup.nvim")
  use("nvim-lua/plenary.nvim")
  use("nvim-telescope/telescope.nvim")
end)

-- first, download the lua language binary and put it somewhere
-- then define the path to that binary
local lua_lsp_binary = "~/Downloads/lua-lsp/bin/lua-language-server"
require'lspconfig'.sumneko_lua.setup{
  cmd = {lua_lsp_binary}
}
-- rust setup
require('rust')
