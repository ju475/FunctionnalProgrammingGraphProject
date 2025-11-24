.PHONY: all build format edit demo clean

src?=0
dst?=5
graph?=graph.txt

all: build

build:
	@echo "\n   🚨  COMPILING  🚨 \n"
	dune build src/ftest.exe
	ls src/*.exe > /dev/null && ln -fs src/*.exe .

format:
	ocp-indent --inplace src/*

edit:
	code . -n

demo: build
	@echo "\n   ⚡  EXECUTING  ⚡\n"
	./ftest.exe graphs/${graph} $(src) $(dst) outfile
	@echo "\n   🥁  RESULT (content of outfile)  🥁\n"
	@cat outfile

clean:
	find -L . -name "*~" -delete
	rm -f *.exe
	rm new.svg
	rm graphs/new.dot
	dune clean

demoDot: build
	@echo "\n   ⚡  EXECUTING  ⚡\n"
	./ftest.exe graphs/${graph} $(src) $(dst) graphs/new.dot
	dot -Tsvg graphs/new.dot > new.svg
	@echo "\n   🥁  RESULT (content of new.dot)  🥁\n"
	@cat new.dot