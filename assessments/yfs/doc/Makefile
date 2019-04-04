ifdef ComSpec
    RM=del /F /Q
else
    RM=rm -rf
endif

all: BSAIyfin 

R_OPTS=--no-save --no-restore --no-init-file --no-site-file
#PANDOC_OPTS=-V geometry:margin=1in --to latex --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash --output text.tex --template ms.tex --highlight-style tango --pdf-engine=xelatex
#PANDOC_OPTS=-V geometry:margin=1in --template ms.tex --highlight-style tango --latex-engine=xelatex
#PANDOC_OPTS=-V geometry:margin=1in --highlight-style tango --latex-engine=xelatex #--template ms.tex 
#PANDOC_OPTS=-V geometry:margin=1in --highlight-style tango  --latex-engine=xelatex --template my.tex 
PANDOC_OPTS=-V geometry:margin=1in --latex-engine=xelatex --template my.tex 

test: test.Rmd 
#	cp pm.R pm.Rmd
	R ${R_OPTS} -e 'library(knitr); knit("test.Rmd");'
	pandoc test.md -o test.pdf ${PANDOC_OPTS}
	open test.pdf

text: text.Rmd 
	R ${R_OPTS} -e 'library(knitr); knit("text.Rmd");'
	pandoc text.md -o text.pdf  ${PANDOC_OPTS}
# --natbib --bibliography /Users/jim/Dropbox/master.bib
#	--latex-engine=xelatex
	open text.pdf

tab: tab.Rmd 
	R ${R_OPTS} -e 'library(knitr); knit("tab.Rmd");'
	pandoc tab.md -o tab.pdf  ${PANDOC_OPTS}
	#open tab.pdf

figs: figs.Rmd 
	R ${R_OPTS} -e 'library(knitr); knit("figs.Rmd");'
	pandoc figs.md -o figs.pdf ${PANDOC_OPTS}
	#open figs.pdf

model: model.Rmd 
	R ${R_OPTS} -e 'library(knitr); knit("model.Rmd");'
	pandoc model.md -o model.pdf  ${PANDOC_OPTS}
	#open model.pdf

BSAIyfin: BSAIyfin.Rmd 
	R ${R_OPTS} -e 'library(knitr); knit("BSAIyfin.Rmd");'
	pandoc BSAIyfin.md -o BSAIyfin.pdf ${PANDOC_OPTS}
	open BSAIyfin.pdf

clean:
	$(RM) pm.md 
	$(RM) figs.md 
	$(RM) tab.md 
	$(RM) model.md 
	$(RM) text.md 
	$(RM) figs.pdf 
	$(RM) tab.pdf 
	$(RM) model.pdf 
	$(RM) text.pdf 
	$(RM) ref.pdf 
	$(RM) ref.md 
