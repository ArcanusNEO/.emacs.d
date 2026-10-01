MAKEFLAGS += -r
.PHONY: install uninstall
WGET := wget -qc --show-progress -t 3 --waitretry=3 -T 5 --no-use-server-timestamps
EXT := $(shell grep -Po -- '^extern/[-a-zA-Z0-9_./%]+.el(?=\s*:)' $(lastword $(MAKEFILE_LIST)))

install: extern $(EXT)

extern/goto-chg.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/emacs-evil/goto-chg/master/goto-chg.el' || (rm -f -- $@ && false)
extern/whole-line-or-region.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/purcell/whole-line-or-region/master/whole-line-or-region.el' || (rm -f -- $@ && false)
extern/cape.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/minad/cape/main/cape.el' || (rm -f -- $@ && false)
extern/cape-keyword.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/minad/cape/main/cape-keyword.el' || (rm -f -- $@ && false)
extern/yaml-mode.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/yoshiki/yaml-mode/master/yaml-mode.el' || (rm -f -- $@ && false)
extern/csv-mode.el:
	@$(WGET) -O $@ -- 'https://git.savannah.gnu.org/cgit/emacs/elpa.git/plain/csv-mode.el?h=externals/csv-mode' || (rm -f -- $@ && false)
extern/clang-format.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/emacsmirror/clang-format/master/clang-format.el' || (rm -f -- $@ && false)
extern/ox-reveal.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/yjwen/org-reveal/master/ox-reveal.el' || (rm -f -- $@ && false)
extern/xclip.el:
	@$(WGET) -O $@ -- 'https://git.savannah.gnu.org/cgit/emacs/elpa.git/plain/xclip.el?h=externals/xclip' || (rm -f -- $@ && false)
extern/corfu.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/minad/corfu/main/corfu.el' || (rm -f -- $@ && false)
extern/corfu-terminal.el:
	@$(WGET) -O $@ -- 'https://codeberg.org/akib/emacs-corfu-terminal/raw/branch/master/corfu-terminal.el' || (rm -f -- $@ && false)
extern/popon.el:
	@$(WGET) -O $@ -- 'https://codeberg.org/akib/emacs-popon/raw/branch/master/popon.el' || (rm -f -- $@ && false)
extern/multiple-cursors.el:
	@$(WGET) -O multiple-cursors.tar.gz -- 'https://api.github.com/repos/magnars/multiple-cursors.el/tarball' || (rm -f -- multiple-cursors.tar.gz && false)
	@install -d multiple-cursors
	@tar -xf multiple-cursors.tar.gz -C multiple-cursors --strip-components=1
	@install -vm644 -- multiple-cursors/*.el extern
	@rm -rf -- multiple-cursors multiple-cursors.tar.gz
extern/web-mode.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/fxbois/web-mode/master/web-mode.el' || (rm -f -- $@ && false)
extern/android-mode.el:
	@$(WGET) -O $@ -- 'https://codeberg.org/rwv/android-mode/raw/branch/master/android-mode.el' || (rm -f -- $@ && false)
extern/markdown-mode.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/jrblevin/markdown-mode/master/markdown-mode.el' || (rm -f -- $@ && false)
extern/go-mode.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/dominikh/go-mode.el/master/go-mode.el' || (rm -f -- $@ && false)
extern/jdecomp.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/xiongtx/jdecomp/master/jdecomp.el' || (rm -f -- $@ && false)
extern/typescript-mode.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/emacs-typescript/typescript.el/master/typescript-mode.el' || (rm -f -- $@ && false)
extern/powershell.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/jschaf/powershell.el/master/powershell.el' || (rm -f -- $@ && false)
extern/plz.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/alphapapa/plz.el/master/plz.el' || (rm -f -- $@ && false)
extern/dash.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/magnars/dash.el/master/dash.el' || (rm -f -- $@ && false)
extern/minuet.el:
	@$(WGET) -O minuet.tar.gz -- 'https://api.github.com/repos/milanglacier/minuet-ai.el/tarball' || (rm -f -- minuet.tar.gz && false)
	@install -d minuet
	@tar -xf minuet.tar.gz -C minuet --strip-components=1
	@install -vm644 -- minuet/*.el extern
	@rm -rf -- minuet minuet.tar.gz
extern/s.el:
	@$(WGET) -O $@ -- 'https://raw.github.com/magnars/s.el/master/s.el' || (rm -f -- $@ && false)
extern/groovy-mode.el:
	@$(WGET) -O groovy-mode.tar.gz -- 'https://api.github.com/repos/Groovy-Emacs-Modes/groovy-emacs-modes/tarball' || (rm -f -- groovy-mode.tar.gz && false)
	@install -d groovy-mode
	@tar -xf groovy-mode.tar.gz -C groovy-mode --strip-components=1
	@install -vm644 -- groovy-mode/*.el extern
	@rm -rf -- groovy-mode groovy-mode.tar.gz
extern/cmake-mode.el:
	@$(WGET) -O $@ -- 'https://gitlab.kitware.com/cmake/cmake/-/raw/master/Auxiliary/cmake-mode.el' || (rm -f -- $@ && false)

extern:
	@install -vd -- extern
uninstall:
	@rm -vrf -- extern
