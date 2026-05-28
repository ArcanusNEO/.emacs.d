MAKEFLAGS += -r
.PHONY: install uninstall
WGET := wget -nc -qc --show-progress -t 3 --waitretry=3 -T 5 --no-use-server-timestamps

install: extern extern/goto-chg.el extern/whole-line-or-region.el extern/cape.el extern/cape-keyword.el extern/yaml-mode.el extern/csv-mode.el extern/clang-format.el extern/ox-reveal.el extern/xclip.el extern/corfu.el extern/corfu-terminal.el extern/popon.el extern/multiple-cursors.el extern/web-mode.el extern/android-mode.el extern/markdown-mode.el extern/go-mode.el extern/jdecomp.el extern/typescript-mode.el
	-@touch -- extern/*.el

extern/goto-chg.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/emacs-evil/goto-chg/master/goto-chg.el'
extern/whole-line-or-region.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/purcell/whole-line-or-region/master/whole-line-or-region.el'
extern/cape.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/minad/cape/main/cape.el'
extern/cape-keyword.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/minad/cape/main/cape-keyword.el'
extern/yaml-mode.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/yoshiki/yaml-mode/master/yaml-mode.el'
extern/csv-mode.el:
	-@$(WGET) -O $@ -- 'https://git.savannah.gnu.org/cgit/emacs/elpa.git/plain/csv-mode.el?h=externals/csv-mode'
extern/clang-format.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/emacsmirror/clang-format/master/clang-format.el'
extern/ox-reveal.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/yjwen/org-reveal/master/ox-reveal.el'
extern/xclip.el:
	-@$(WGET) -O $@ -- 'https://git.savannah.gnu.org/cgit/emacs/elpa.git/plain/xclip.el?h=externals/xclip'
extern/corfu.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/minad/corfu/main/corfu.el'
extern/corfu-terminal.el:
	-@$(WGET) -O $@ -- 'https://codeberg.org/akib/emacs-corfu-terminal/raw/branch/master/corfu-terminal.el'
extern/popon.el:
	-@$(WGET) -O $@ -- 'https://codeberg.org/akib/emacs-popon/raw/branch/master/popon.el'
extern/multiple-cursors.el:
	-@$(WGET) -O multiple-cursors.el-master.tar.gz -- 'https://github.com/magnars/multiple-cursors.el/archive/refs/heads/master.tar.gz'
	-@tar xf multiple-cursors.el-master.tar.gz
	-@install -vm644 -- multiple-cursors.el-master/*.el extern
	-@rm -rf -- multiple-cursors.el-master multiple-cursors.el-master.tar.gz
extern/web-mode.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/fxbois/web-mode/master/web-mode.el'
extern/android-mode.el:
	-@$(WGET) -O $@ -- 'https://codeberg.org/rwv/android-mode/raw/branch/master/android-mode.el'
extern/markdown-mode.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/jrblevin/markdown-mode/master/markdown-mode.el'
extern/go-mode.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/dominikh/go-mode.el/master/go-mode.el'
extern/jdecomp.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/xiongtx/jdecomp/master/jdecomp.el'
extern/typescript-mode.el:
	-@$(WGET) -O $@ -- 'https://raw.github.com/emacs-typescript/typescript.el/master/typescript-mode.el'
extern:
	-@mkdir -v -- extern
uninstall:
	-@rm -vrf -- extern
