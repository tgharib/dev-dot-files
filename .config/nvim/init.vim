" set shell=C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe
set shell=C:\\Windows\\System32\\cmd.exe
" set shellcmdflag=-command
set shellquote="
set shellxquote=

" For editing multiple lines in vim, use 1. `V:! sd` 2. macros 3. `V:norm`.
" Vim motion options: f/F/t/T for horizontal, pounce.nvim for vertical, */#, search, goto definition
" Paste text vertically using visual block mode https://stackoverflow.com/a/27542895

" Options
let mapleader = " "
set nowrap " Turn off line wrap
set nohlsearch " Turn off search highlighting
set clipboard=unnamedplus " Use system clipboard for copy and paste
set ignorecase " Search with smart case
set smartcase " Search with smart case
set timeoutlen=0 " Immediately show which-key
let $BASH_ENV = "~/.bash-aliases"
set sessionoptions=buffers " Session = buffers only (to avoid bugs with abduco)
set hidden " Allow buffers to be hidden without saving
set number " Enable line numbers by default
set expandtab " Spaces-only indenation https://gist.github.com/LunarLambda/4c444238fb364509b72cfb891979f1dd
set softtabstop=-1 " Spaces-only indenation
syntax off " Rely on treesitter only for syntax highlighting
let g:suda_smart_edit = 1 " suda.nvim smart write

" Don't touch unnamed register when pasting over visual selection
xnoremap p P

" bootstrap lazy.nvim
lua << EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  defaults = {
    lazy = true, -- should plugins be lazy-loaded?
  },
})
EOF

"" Set colorscheme
lua << EOF
require("tokyonight").setup({
  styles = {
    comments = { italic = false },
    keywords = { italic = false },
  },
})
EOF
colorscheme tokyonight-night
set termguicolors " Force colorscheme colors with 24-bit support

"" Auto-reload file changes outside of vim
augroup autoreload
  autocmd!
  """ notification after file change
  autocmd FileChangedShellPost * echohl WarningMsg | echo "File changed on disk!!!" | echohl None
augroup end

"" Markdown macros
let @i ="o![](images/){width=60%}\<Esc>11hi"
let @e ="o$$\<Enter>$$\<Esc>O"

" Helper functions
augroup helper_funcs
  autocmd!
  "" Trim trailing whitespace function
  function! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
  endfunction
augroup end

" Plugins

"" gitsigns.nvim
lua << EOF
require('gitsigns').setup {
  attach_to_untracked = false,
}
EOF

"" mini.align
" gA to start
" s for split pattern
" t for trimming whitespace
" https://github.com/echasnovski/mini.nvim/blob/main/doc/mini-align.txt
lua << EOF
require('mini.align').setup()
EOF

"" mini.cursorword
lua << EOF
require('mini.cursorword').setup()
EOF

"" guess-indent.nvim
lua << EOF
require('guess-indent').setup()
EOF

"" symbols-outline.nvim
lua << EOF
local opts = {
  highlight_hovered_item = false,
  position = 'left',
}
require("symbols-outline").setup(opts)
EOF

"" coc-snippets
" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

"" refactoring.nvim
lua << EOF
require('refactoring').setup({})
EOF

"" sessions.nvim
lua << EOF
require("sessions").setup()
EOF

"" pounce.nvim
lua << EOF
require'pounce'.setup()
EOF

"" nvim-treesitter
""" Do NOT use treesitter for folding as it cannot be disabled for large files
lua << EOF
disable_for_large_files = function(lang, bufnr) -- Disable in large buffers
  return vim.api.nvim_buf_line_count(bufnr) > 50000
end

require'nvim-treesitter.configs'.setup {
  -- Install all languages for treesitter except for rnoweb, phpdoc
  ensure_installed = { "bash", "beancount", "c", "cmake", "comment", "cpp", "dockerfile", "glsl", "java", "lua", "make", "markdown", "ninja", "nix", "python", "rust", "verilog" },
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    disable = disable_for_large_files,
    additional_vim_regex_highlighting = false,
  },
  -- nvim-treesitter-cpp-tools
  nt_cpp_tools = {
      enable = true,
      preview = {
          quit = '<Esc>',
          accept = '<CR>'
      },
  }
}

-- nvim-treesitter-context
require'treesitter-context'.setup {
  enable = false, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
    -- For all filetypes
    default = { 'class', 'function', 'method', 'for', 'while', 'if', 'switch', 'case' },
    -- Example for a specific filetype.
    -- If a pattern is missing, *open a PR* so everyone can benefit.
    --   rust = {
    --       'impl_item',
    --   },
  },
  exact_patterns = {
    -- Example for a specific filetype with Lua patterns
    -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
    -- exactly match "impl_item" only)
    -- rust = true,
  },

  -- The options below are exposed but shouldn't require your attention, you can safely ignore them.
  zindex = 20, -- The Z-index of the context window
  mode = 'topline',  -- Line used to calculate context. Choices: 'cursor', 'topline'
}

require'nvim-treesitter.configs'.setup {
  textobjects = {
    move = {
      enable = true,
      disable = disable_for_large_files,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = { query = "@class.outer", desc = "Next class start" },
        --
        -- You can use regex matching and/or pass a list in a "query" key to group multiple queires.
        ["]o"] = "@loop.*",
        -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
        --
        -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
        -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
        ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
      -- Below will go to either the start or the end, whichever is closer.
      -- Use if you want more granular movements
      -- Make it even more gradual by adding multiple queries and regex.
      goto_next = {
        ["]d"] = "@conditional.outer",
      },
      goto_previous = {
        ["[d"] = "@conditional.outer",
      }
    },
  },
}
EOF

"" which-key.nvim
" Some coc commands can be found in:
" https://github.com/neoclide/coc.nvim/blob/master/data/schema.json
" https://github.com/neoclide/coc.nvim/blob/master/doc/coc-config.txt
lua << EOF
require("which-key").setup {
}
local wk = require("which-key")
wk.register({
  k = { ":call ShowDocumentation()<CR>", "show documentation (coc)" },
  b = {
    name = "buffers",
    f = { ":Files<CR>", "open file" },
    b = { ":Buffers<CR>", "select buffer" },
    q = { ":bw<CR>", "quit current buffer :bw" },
    Q = { ":bufdo bw<CR>", "quit all buffers :bufdo bw" },
    t = { ":tabonly<CR>", "tabs -> buffers" },
    l = { ":SessionsLoad! ", "load session" },
    s = { ":SessionsSave! ", "save session" },
    d = { ":windo :diffthis<CR>", "diff between two splits" },
    u = { ":windo :diffoff<CR>", "undiff between two splits" },
    g = {
      name = "git",
      b = { ":Git blame<CR>", "git blame this buffer" },
      d = { ":Gitsigns diffthis<CR>", "git diff this buffer" },
    },
  },
  g = {
    name = "go to",
    d = { "<Plug>(coc-definition)", "go to definition (coc)" },
    D = { "<Plug>(coc-implementation)", "go to implementation (coc)" },
    r = { "<Plug>(coc-references)", "go to references (coc)" },
    t = { "<Plug>(coc-type-definition)", "go to type definition (coc)" },
    g = { ":CocCommand clangd.switchSourceHeader<CR>", "go to source/header (coc)" },
  },
  s = {
    name = "search",
    s = { ":<C-u>CocList outline<CR>", "search symbol in document outline (coc)" },
    S = { ":<C-u>CocList -I symbols<CR>", "search symbol in workspace (coc)" },
    t = { ":BLines!<CR>", "search text in current buffer" },
    T = { ":Lines!<CR>", "search text in all buffers" },
    r = { ":Rg! ", "rg text in current working directory" },
    d = { ":CocOutline<CR>", "open document outline in split window (coc)" },
    D = { ":SymbolsOutline<CR>", "open document outline in split window" },
  },
  p = {
    name = "paths",
    c = { ":cd %:h<CR>", "cd into current buffer working directory" },
    f = { ":echo expand('%:p')<CR>", "show file path" },
    o = { ":Oil<CR>", "oil (file manager)" },
  },
  f = {
    name = "fix error",
    e = { ":<C-u>CocList diagnostics<CR>", "list errors/diagnostics (coc)" },
    l = { "<Plug>(coc-fix-current)", "fix error on current line (coc)" },
    b = { "<Plug>(coc-codeaction)", "fix error on current buffer (coc)" },
  },
  r = {
    name = "refactor/transform",
    f = { ":call CocActionAsync('format')<CR>", "format buffer (coc)" },
    o = { ":call CocActionAsync('runCommand', 'editor.action.organizeImport')<CR>", "organize imports (coc)" },
    r = { "<Plug>(coc-rename)", "rename symbol (coc)" },
    b = { ":lua require('refactoring').refactor('Extract Block')<CR>", "extract block (refactoring.nvim)" },
    B = { ":lua require('refactoring').refactor('Extract Block To File')<CR>", "extract block to file (refactoring.nvim)" },
    v = { ":lua require('refactoring').refactor('Inline Variable')<CR>", "inline variable (refactoring.nvim)" },
    p = {
      name = "printf",
      l = { ":lua require('refactoring').debug.printf({below = true})<CR>", "printf line (refactoring.nvim)" },
      v = { ":lua require('refactoring').debug.print_var({ normal = true })<CR>", "printf variable (refactoring.nvim)" },
      c = { ":lua require('refactoring').debug.cleanup({})<CR>", "cleanup (refactoring.nvim)" },
    },
    w = {
      name = "whitespace",
      r = { ":retab<CR>", "replace tabs with spaces" },
      ["2"] = { ":set tabstop=2 shiftwidth=2 | set expandtab | set softtabstop=-1<CR>", "set tabs to 2 spaces" },
      ["4"] = { ":set tabstop=4 shiftwidth=4 | set expandtab | set softtabstop=-1<CR>", "set tabs to 4 spaces" },
      t = { ":call TrimWhitespace()<CR>", "trim whitespace" },
    },
    s = { ":CocList snippets<CR>", "snippets" },
  },
  t = {
    name = "toggles",
    d = { ":Gitsigns toggle_signs<CR>", "toggle git diff signs" },
    w = { ":set wrap!<CR>", "toggle line wrap" },
    l = { ":set number!<CR>", "toggle line numbers" },
    h = { ":set hlsearch!<CR>", "toggle search highlight" },
    n = { ":TSContextToggle<CR>", "toggle context (nested statements)" },
    t = { ":CocCommand document.toggleInlayHint<CR>", "toggle inlay hints (coc)" },
  },
}, { prefix = "<leader>", mode = "n" })
wk.register({
  d = {
    name = "debug",
    s = { ":lua require('refactoring').debug.print_var({})<CR>", "printf selection (refactoring.nvim)" },
  },
  r = {
    name = "refactor/transform",
    f = { ":call CocActionAsync('format')<CR>", "format buffer (coc)" },
    a = { "<Plug>(coc-codeaction-selected)", "code action on selected (coc)" },
    m = { ":TSCppDefineClassFunc<CR>", "implement class member functions (c++)" },
    p = { ":TSCppMakeConcreteClass<CR>", "implement pure virtual functions (c++)" },
    ["3"] = { ":TSCppRuleOf3<CR>", "modify class to obey Rule of 3 (c++)" },
    ["5"] = { ":TSCppRuleOf5<CR>", "modify class to obey Rule of 5 (c++)" },
    v = { ":lua require('refactoring').refactor('Extract Variable')<CR>", "extract variable (refactoring.nvim)" },
    f = { ":lua require('refactoring').refactor('Extract Function')<CR>", "extract function (refactoring.nvim)" },
    F = { ":lua require('refactoring').refactor('Extract Function To File')<CR>", "extract function to file (refactoring.nvim)" },
  },
}, { prefix = "<leader>", mode = "x" })

wk.register({
  s = { ":Pounce<CR>", "pounce" },
  S = { ":PounceRepeat<CR>", "pounce repeat" },
}, { prefix = "", mode = "n" })
wk.register({
  s = { ":Pounce<CR>", "pounce" },
  S = { ":PounceRepeat<CR>", "pounce repeat" },
}, { prefix = "", mode = "o" })
wk.register({
  s = { ":Pounce<CR>", "pounce" },
  S = { ":PounceRepeat<CR>", "pounce repeat" },
}, { prefix = "", mode = "x" })
EOF

" :nmap - Display normal mode maps
" :imap - Display insert mode maps
" :vmap - Display visual and select mode maps
" :smap - Display select mode maps <-- select mode is never used
" :xmap - Display visual mode maps
" :cmap - Display command-line mode maps i.e. after pressing :
" :omap - Display operator pending mode maps e.g. deletion after pressing d

" For Rust, as per https://github.com/neoclide/coc.nvim/wiki/Language-servers#rust, rust-analyzer binary needs to be compiled from source
let g:coc_global_extensions = ['coc-snippets', 'coc-clangd', 'coc-pyright', 'coc-rust-analyzer']
"" COC START
set nobackup " Some servers have issues with backup files, see #649.
set nowritebackup
set updatetime=300 " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience.
set signcolumn=number " Always show the signcolumn, otherwise it would shift the text each time diagnostics appear/become resolved.

""" Use tab for trigger completion with characters ahead and navigate. NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

""" Make <CR> to accept selected completion item or notify coc.nvim to format. <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <c-space> coc#refresh() " Use <c-space> to trigger completion

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

augroup coc_signature
  autocmd!
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp') " Update signature help on jump placeholder
augroup end

" Remap <C-f> and <C-b> to scroll floating windows/popups (such as when
" showing a coc documentation popup)
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<CR>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<CR>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

lua << END
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'tokyonight',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
END

"" COC END

" Highlight trailing whitespace (at the end after colorscheme is set)
highlight extrawhitespace ctermbg=red guibg=red
match extrawhitespace /\s\+$\| \+\ze\t/
