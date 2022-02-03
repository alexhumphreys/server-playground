.PHONY: build

export IDRALL_TEST=True

repl:
	rlwrap -n idris2 --find-ipkg Server.idr

clean:
	rm -f tests/*.idr~
	rm -f tests/*.ibc
	rm -f Idrall/*.idr~
	rm -f Idrall/*.ibc
	rm -rf build/
	rm -rf tests/build/
	rm -rf tests/*/*/build
	@${MAKE} -C tests clean

build:
	idris2 --build server.ipkg

install:
	idris2 --install server.ipkg

testbin:
	@${MAKE} -C tests testbin

test-only:
	${MAKE} -C tests only=$(only)

test: build install testbin test-setup test-only

time:
	time ${MAKE} test INTERACTIVE=''

loadtest:
	ab -r -n 15000 -c 6 localhost:8000/
