.PHONY: init

init:
	@rm -vrf extern/
	@mkdir -v extern/
	@wget -qc --show-progress -t 3 --waitretry=3 -P extern/ https://raw.githubusercontent.com/emacs-evil/goto-chg/master/goto-chg.el
	@wget -qc --show-progress -t 3 --waitretry=3 -P extern/ https://raw.githubusercontent.com/purcell/whole-line-or-region/master/whole-line-or-region.el
	@wget -qc --show-progress -t 3 --waitretry=3 -P extern/ https://raw.githubusercontent.com/emacsmirror/clang-format/master/clang-format.el
	@wget -qc --show-progress -t 3 --waitretry=3 -P extern/ https://raw.githubusercontent.com/yjwen/org-reveal/master/ox-reveal.el
