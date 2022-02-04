all: compile

.PHONY: clean
clean:
	rm -rf build

.PHONY: configure
configure:
	mkdir -p build
	cd build && cmake ..

.PHONY: compile
compile: configure
	cd build && cmake --build .

