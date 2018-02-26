# prevent-trailing-whitespace
Prevent trailing whitespace in edited region of current buffer.

## Installation
1. Put `prevent-trailing-whitespace.el` somewhere in your `load-path`.
2. Put `(require 'prevent-trailing-whitespace)` in your init file.
3. Put `(add-hook 'prog-mode #'prevent-trailing-whitespace-mode)` into your init file. Replace `prog-mode` with the major mode where you want to activate `prevent-trailing-whitespace-mode`.

## Usage
If you follow the installation guide trailing whitespace is removed automatically in buffers with active `prevent-trailing-whitespace-mode`. The mode is indicated by `-ws` in the modeline.
