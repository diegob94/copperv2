
PYTHON ?= $(if $(shell which python),python,python3)
SHELL = bash

.PHONY: all
all: work/sim/result.xml

.PHONY: clean
clean:
	rm -rf work/rtl work/sim work/logs

.venv: requirements.txt
	$(PYTHON) -m venv .venv
	source .venv/bin/activate; pip install wheel
	source .venv/bin/activate; pip install -r requirements.txt

work/rtl/copperv2_rtl.v: $(shell find ./src -name '*.scala' -o -name '*.v')
	./scripts/mill copperv2.run

work/sim/result.xml: work/rtl/copperv2_rtl.v .venv
	source .venv/bin/activate; pytest -n $(shell nproc) --junitxml="$@"
