.PHONY: all build format edit demo clean

src?=0
dst?=9
graph?=graph7

all: build

build1:
	@echo "\n   🚨  COMPILING DEMO  🚨 \n"
	dune build src/fdemo.exe
	ls src/*.exe > /dev/null && ln -fs src/*.exe .

build2:
	@echo "\n   🚨  COMPILING TEST  🚨 \n"
	dune build src/ftest.exe
	ls src/*.exe > /dev/null && ln -fs src/*.exe .

format:
	ocp-indent --inplace src/*

edit:
	code . -n

clean:
	find -L . -name "*~" -delete
	rm -f *.exe
	rm new.svg
	rm graphs/new.dot
	dune clean

demoFF: build1
	@echo "\n   ⚡  EXECUTING DEMO ON FF  ⚡\n"
	./fdemo.exe graphs/ressources/${graph}.txt $(src) $(dst) graphs/new.dot
	dot -Tsvg graphs/new.dot > graphs/svg_output/${graph}.svg
	
testFF: build2
	@echo "\n   ⚡  EXECUTING TEST ON FF  ⚡\n"
	./ftest.exe 

demoGB: build1
	@echo "\n   ⚡  EXECUTING DEMO ON GB  ⚡\n"
	./fdemo.exe graphs-bipartite/ressources/${graph}b.txt $(src) $(dst) graphs-bipartite/new.dot
	dot -Tsvg graphs-bipartite/new.dot > graphs/svg_output/${graph}b.svg

testGB: build2
	@echo "\n   ⚡  EXECUTING TEST ON GB  ⚡\n"
	./ftest.exe 