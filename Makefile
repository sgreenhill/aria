OBJS=TestAll OMake OEF

all: tools test

tools: OMake
	OMake OMake
	OMake OEF

clean:
	rm -f *.c *.sym *.oh
	rm -rf *.dSYM

clean-all: clean
	rm -f $(OBJS)

test: TestAll
	./TestAll

TestAll: OMake
	OMake TestAll

# boostrap OMake
OMake: script/build-omake.sh
	script/build-omake.sh

bootstrap:
	OMake -script OMake > script/build-omake.sh
