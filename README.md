# vim-php-check

Tiny PHP code checking plugin for Vim.

## Installation

vim-plug:

```vim
Plug 'olshevskiy87/vim-php-check'
```

## Usage

- `<leader>ps`, `:call PhpStanCheck([<level>])` - check file with phpstan
- `<leader>pm`, `:call PhpMdCheck()` - check file with phpmd

## Global options

| Option name                | Description                                              | Default value |
| -------------------------- | -------------------------------------------------------- | ------------- |
| `g:phpcheck_phpstan_bin`   | PHPStan binary path                                      | `phpstan`     |
| `g:phpcheck_phpmd_bin`     | PHPMD binary path                                        | `phpmd`       |
| `g:phpcheck_phpmd_ruleset` | PHPMD comma-separated rulesets (https://phpmd.org/rules) | `unusedcode`  |

## License

MIT. See file LICENSE for details.
