" For editing multiple lines in vim, use 1. `V:! sd` 2. macros 3. `V:norm`.
" Vim motion options: f/F for horizontal, C-j/C-k for vertical, /n*, search/goto hotkeys
" Paste text vertically using visual block mode https://stackoverflow.com/a/27542895

" Options
let mapleader = " "
set nowrap " Turn off line wrap
set nohlsearch " Turn off search highlighting
set clipboard=unnamedplus " Use system clipboard for copy and paste
set ignorecase " Search with smart case
set smartcase " Search with smart case
set timeoutlen=0 " Immediately show which-key
set noshowmode " Hide mode prompt (insert, etc) since we are using lightline
let $BASH_ENV = "~/.bash-aliases"
set sessionoptions=buffers " Session = buffers only (to avoid bugs with abduco)
set hidden " Allow buffers to be hidden without saving
set number " Enable line numbers by default
set expandtab " Spaces-only indenation https://gist.github.com/LunarLambda/4c444238fb364509b72cfb891979f1dd
set softtabstop=-1 " Spaces-only indenation
syntax off " Rely on treesitter only for syntax highlighting

" Don't touch unnamed register when pasting over visual selection
xnoremap <expr> p 'pgv"' . v:register . 'y'

"" Set colorscheme to NeoSolarized
lua << EOF
  require('neosolarized').setup({
    comment_italics = false,
    background_set = true,
  })
EOF
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

"" impatient.nvim
lua << EOF
vim.loader.enable()
EOF

"" symbols-outline.nvim
lua << EOF
require("symbols-outline").setup()
EOF

"" coc-snippets
" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

"" packer.nvim
""" Bootstrap
lua << EOF
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
end)
EOF
""" Enable packer
lua require('plugins')

"" refactoring.nvim
lua << EOF
require('refactoring').setup({})
EOF

"" sessions.nvim
lua << EOF
require("sessions").setup()
EOF

"" vim-sandwich
let g:sandwich_no_default_key_mappings = 1
let g:operator_sandwich_no_default_key_mappings = 1

"" hop.nvim
lua << EOF
require'hop'.setup()
EOF

"" nvim-treesitter
""" Do NOT use treesitter for folding as it cannot be disabled for large files
lua << EOF
disable_for_large_files = function(lang, bufnr) -- Disable in large buffers
  return vim.api.nvim_buf_line_count(bufnr) > 50000
end

require'nvim-treesitter.configs'.setup {
  -- Install all languages for treesitter except for rnoweb, phpdoc
  ensure_installed = { "bash", "beancount", "c", "cmake", "comment", "cpp", "dockerfile", "glsl", "java", "lua", "make", "ninja", "nix", "rust", "verilog" },
  sync_install = false,
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

-- nvim-treesitter-refactor (used for treesitter highlight)
require'nvim-treesitter.configs'.setup {
  refactor = {
    highlight_definitions = {
      enable = true,
      disable = disable_for_large_files,
      clear_on_cursor_move = true, -- Set to false if you have an `updatetime` of ~100.
    },
  },
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

"" symbols-outline.nvim
lua << EOF
vim.g.symbols_outline = {
    highlight_hovered_item = false,
    auto_preview = false,
    position = 'left',
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
    f = { ":Files!<CR>", "open file" },
    b = { ":Buffers!<CR>", "select buffer" },
    q = { ":bw<CR>", "quit current buffer :bw" },
    Q = { ":bufdo bw<CR>", "quit all buffers :bufdo bw" },
    t = { ":tabonly<CR>", "tabs -> buffers" },
    l = { ":SessionsLoad! ", "load session" },
    s = { ":SessionsSave! ", "save session" },
  },
  g = {
    name = "go to",
    d = { "<Plug>(coc-definition)", "go to definition (coc)" },
    D = { "<Plug>(coc-implementation)", "go to implementation (coc)" },
    r = { "<Plug>(coc-references)", "go to references (coc)" },
    t = { "<Plug>(coc-type-definition)", "go to type definition (coc)" },
    g = { ":CocCommand clangd.switchSourceHeader<CR>", "go to source/header (coc)" },
  },
  ["s"] = {
    name = "search",
    s = { ":<C-u>CocList outline<CR>", "search symbol in document outline (coc)" },
    S = { ":<C-u>CocList -I symbols<CR>", "search symbol in workspace (coc)" },
    t = { ":BLines!<CR>", "search text in current buffer" },
    T = { ":Lines!<CR>", "search text in all buffers" },
    r = { ":Rg! ", "rg text in current working directory" },
    d = { ":CocOutline<CR>", "open document outline in split window (coc)" },
    D = { ":SymbolsOutline<CR>", "open document outline in split window" },
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
    b = { "<Cmd>lua require('refactoring').refactor('Extract Block')<CR>", "extract block (refactoring.nvim)" },
    B = { "<Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>", "extract block to file (refactoring.nvim)" },
    v = { "<Cmd>lua require('refactoring').refactor('Inline Variable')<CR>", "inline variable (refactoring.nvim)" },
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
    s = {
      name = "surroundings",
      a = { "<Plug>(operator-sandwich-add)", "add surroundings" },
      d = { "<Plug>(operator-sandwich-delete)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-auto-a)", "delete surroundings (automatic)" },
      D = { "<Plug>(operator-sandwich-delete)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)", "delete surroundings" },
      r = { "<Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-auto-a)", "replace surroundings (automatic)" },
      R = { "<Plug>(operator-sandwich-replace)<Plug>(operator-sandwich-release-count)<Plug>(textobj-sandwich-query-a)", "replace surroundings" },
    },
    S = { ":CocList snippets<CR>", "snippets" },
  },
  t = {
    name = "toggles",
    w = { ":set wrap!<CR>", "toggle line wrap" },
    l = { ":set number!<CR>", "toggle line numbers" },
    ["?"] = { ":Commands<CR>", "vim commands" },
    k = { ":help index<CR>", "vim keybinds" },
    K = { ":map<CR>", "vim mapped keybinds" },
    v = { ":Colors!<CR>", "vim color schemes" },
    f = { ":echo expand('%:p')<CR>", "show file path" },
    h = { ":set hlsearch!<CR>", "toggle search highlight" },
    c = { ":TSContextToggle<CR>", "toggle context" },
    t = { ":CocCommand document.toggleInlayHint<CR>", "toggle inlay hints (coc)" },
    d = { ":windo :diffthis<CR>", "diff between two splits" },
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
    s = { "<Plug>(coc-codeaction-selected)", "code action on selected (coc)" },
    m = { ":TSCppDefineClassFunc<CR>", "implement class member functions (c++)" },
    p = { ":TSCppMakeConcreteClass<CR>", "implement pure virtual functions (c++)" },
    ["3"] = { ":TSCppRuleOf3<CR>", "modify class to obey Rule of 3 (c++)" },
    ["5"] = { ":TSCppRuleOf5<CR>", "modify class to obey Rule of 5 (c++)" },
    v = { "<Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>", "extract variable (refactoring.nvim)" },
    f = { "<Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>", "extract function (refactoring.nvim)" },
    F = { "<Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>", "extract function to file (refactoring.nvim)" },
  },
}, { prefix = "<leader>", mode = "x" })

wk.register({
  f = { "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<CR>", "jump in line (after cursor)" },
  F = { "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<CR>", "jump in line (before cursor)" },
  t = { "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<CR>", "jump in line (after cursor)" },
  T = { "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })<CR>", "jump in line (before cursor)" },
  ["<C-j>"] = { "2j", "move cursor down two lines" },
  ["<C-k>"] = { "2k", "move cursor up two lines" },
}, { prefix = "", mode = "n" })
wk.register({
  f = { "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<CR>", "jump in line (after cursor)" },
  F = { "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<CR>", "jump in line (before cursor)" },
  t = { "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<CR>", "jump in line (after cursor)" },
  T = { "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })<CR>", "jump in line (before cursor)" },
}, { prefix = "", mode = "o" })
wk.register({
  f = { "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<CR>", "jump in line (after cursor)" },
  F = { "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<CR>", "jump in line (before cursor)" },
  t = { "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, hint_offset = -1 })<CR>", "jump in line (after cursor)" },
  T = { "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, hint_offset = 1 })<CR>", "jump in line (before cursor)" },
}, { prefix = "", mode = "x" })
EOF

" :nmap - Display normal mode maps
" :imap - Display insert mode maps
" :vmap - Display visual and select mode maps
" :smap - Display select mode maps <-- select mode is never used
" :xmap - Display visual mode maps
" :cmap - Display command-line mode maps i.e. after pressing :
" :omap - Display operator pending mode maps e.g. deletion after pressing d

let g:coc_global_extensions = ['coc-snippets', 'coc-clangd', 'coc-jedi']
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

let g:lightline = {
\ 'colorscheme': 'solarized',
\ 'active': {
\   'left': [ [ 'mode', 'paste' ],
\             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
\ },
\ 'component_function': {
\   'cocstatus': 'coc#status'
\ },
\ }

"" COC END

" Highlight trailing whitespace (at the end after colorscheme is set)
highlight extrawhitespace ctermbg=red guibg=red
match extrawhitespace /\s\+$\| \+\ze\t/
