
## All external scripts should reside and all output should be generated in 
## $(DOC:.raw=-files) directory

DOC  := $(wildcard *.raw)
RSRC := $(wildcard $(DOC:.raw=-files)/*.R)
ifndef PUB
	PUB := FALSE
endif

.PHONY: all

all: 
	make $(DOC:.raw=.html) 

pub: 
	PUB=TRUE make $(DOC:.raw=.Rmd)
	make all
	Rscript -e 'Rmd <- readLines("$(DOC:.raw=.Rmd)"); date <- gsub("date: ", "", Rmd[grep("^date:", Rmd)]); writeLines(gsub("![](", "![](/Blog/public/post/", Rmd, fixed=TRUE), paste0(date, "-$(DOC:.raw=.Rmd)"))'
	@echo "\n************************\n"
	@echo "Now copy .Rmd to Blog/content/post/ and -files/* to BOTH Blog/content/post/ (so that .Rmd will build) AND Blog/static/post/ (so that included images will work)\n"

%.Rmd: %.raw $(RSRC)
	Rscript -e 'writeLines(knitr::knit_expand("$<", EVAL=!$(PUB)), "$@")'

%.html: %.Rmd
	Rscript -e 'rmarkdown::render("$<")'

