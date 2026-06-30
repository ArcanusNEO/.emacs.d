MAKEFLAGS += -r
.PHONY: install uninstall
WGET := wget -qc --show-progress -t 3 --waitretry=3 -T 5 --no-use-server-timestamps
EXTERN := $(shell grep -Po -- '^extern/[-a-zA-Z0-9_./%]+.el(?=\s*:)' $(lastword $(MAKEFILE_LIST)))

install: extern $(EXTERN)
	@touch -- $(EXTERN)

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
	@$(WGET) -O multiple-cursors.el-master.tar.gz -- 'https://github.com/magnars/multiple-cursors.el/archive/refs/heads/master.tar.gz' || (rm -f -- $@ && false)
	@tar xf multiple-cursors.el-master.tar.gz
	@install -vm644 -- multiple-cursors.el-master/*.el extern
	@rm -rf -- multiple-cursors.el-master multiple-cursors.el-master.tar.gz
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
	@$(WGET) -O minuet-ai.el-main.tar.gz -- 'https://github.com/milanglacier/minuet-ai.el/archive/refs/heads/main.tar.gz' || (rm -f -- $@ && false)
	@tar xf minuet-ai.el-main.tar.gz
	@install -vm644 -- minuet-ai.el-main/*.el extern
	@rm -rf -- minuet-ai.el-main minuet-ai.el-main.tar.gz

extern:
	@install -vd -- extern
uninstall:
	@rm -vrf -- extern
