(TeX-add-style-hook
 "unique"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("geometry" "	a4paper" "	left=0.8in" "	right=0.8in" "	top=0.70in" "	bottom=0.55in" "	nohead")))
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art10"
    "ctex"
    "titlesec"
    "color"
    "enumitem"
    "geometry")
   (TeX-add-symbols
    '("datedproject" 3)
    '("datedaward" 3)
    '("dateditem" 2)
    '("basicinfo" 1)
    '("name" 1)))
 :latex)

