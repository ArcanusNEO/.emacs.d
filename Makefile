.PHONY: init

init:
	@rm -vrf extern
	@mkdir -v extern
	@wget -qc --show-progress -t 3 --waitretry=3 -O extern/goto-chg.el 'https://raw.githubusercontent.com/emacs-evil/goto-chg/master/goto-chg.el'
	@wget -qc --show-progress -t 3 --waitretry=3 -O extern/whole-line-or-region.el 'https://raw.githubusercontent.com/purcell/whole-line-or-region/master/whole-line-or-region.el'
	@wget -qc --show-progress -t 3 --waitretry=3 -O extern/clang-format.el 'https://raw.githubusercontent.com/emacsmirror/clang-format/master/clang-format.el'
	@wget -qc --show-progress -t 3 --waitretry=3 -O extern/ox-reveal.el 'https://raw.githubusercontent.com/yjwen/org-reveal/master/ox-reveal.el'
	@wget -qc --show-progress -t 3 --waitretry=3 -O extern/sql-indent.el 'https://raw.githubusercontent.com/alex-hhh/emacs-sql-indent/master/sql-indent.el'
	@wget -qc --show-progress -t 3 --waitretry=3 -O extern/xclip.el 'https://git.savannah.gnu.org/cgit/emacs/elpa.git/plain/xclip.el?h=externals/xclip'
