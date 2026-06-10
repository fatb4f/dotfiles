# Workspace IDE Manual Verification

- [ ] New workspace launch: select a configured project, run `term-ide-launch`, and confirm Neovim opens with Xplr split on the left.
- [ ] Repeated IDE launch: run `term-ide-launch` again and confirm the existing Neovim pane receives focus without spawning another editor.
- [ ] Stale socket recovery: leave a stale `TERM_NVIM_SOCKET`, run `term-ide-launch`, and confirm the socket is removed and Neovim starts.
- [ ] Live socket with cached pane: with Neovim running and its editor pane cached, run `term-ide-launch` and confirm that pane receives focus.
- [ ] Xplr enter: select a file in Xplr, press `Enter`, and confirm it opens in the socket-backed Neovim session.
- [ ] Smart-splits boundary: use `Ctrl+h/j/k/l` to move between Neovim splits and across the Neovim/Xplr WezTerm pane boundary.
