MAKEFLAGS += -r
.PHONY: install uninstall

WGET := wget -qc --show-progress -t 3 --waitretry=3

install:
	@rm -vrf extern
	@mkdir -v extern
	@$(WGET) -O extern/goto-chg.el 'https://raw.githubusercontent.com/emacs-evil/goto-chg/master/goto-chg.el'
	@$(WGET) -O extern/whole-line-or-region.el 'https://raw.githubusercontent.com/purcell/whole-line-or-region/master/whole-line-or-region.el'
	@$(WGET) -O extern/clang-format.el 'https://raw.githubusercontent.com/emacsmirror/clang-format/master/clang-format.el'
	@$(WGET) -O extern/ox-reveal.el 'https://raw.githubusercontent.com/yjwen/org-reveal/master/ox-reveal.el'
	@$(WGET) -O extern/sql-indent.el 'https://raw.githubusercontent.com/alex-hhh/emacs-sql-indent/master/sql-indent.el'
	@$(WGET) -O extern/xclip.el 'https://git.savannah.gnu.org/cgit/emacs/elpa.git/plain/xclip.el?h=externals/xclip'
	@$(WGET) -O extern/cape.el 'https://raw.githubusercontent.com/minad/cape/main/cape.el'
	@$(WGET) -O extern/cape-keyword.el 'https://raw.githubusercontent.com/minad/cape/main/cape-keyword.el'

uninstall:
	@rm -vrf extern
