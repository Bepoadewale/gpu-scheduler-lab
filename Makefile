PYTHON ?= .venv/bin/python
export PYTHONPATH := scheduler-lab/src
SHELL := /usr/bin/env bash

.PHONY: install bootstrap-local smoke dashboard dashboard-stop dashboard-status demo-kueue demo-gang demo-quota demo-borrow demo-fair-share demo-priority demo-preemption demo-starvation demo-topology demo-fragmentation demo-simulator test lint verify clean-local cleanroom-validate status

install:
	./scripts/install.sh

bootstrap-local:
	./scripts/bootstrap-local.sh

smoke:
	./scripts/smoke.sh

dashboard:
	./scripts/dashboard.sh start

dashboard-stop:
	./scripts/dashboard.sh stop

dashboard-status:
	./scripts/dashboard.sh status

demo-kueue:
	./scripts/demo-kueue.sh

demo-gang:
	./scripts/demo-gang.sh

demo-preemption:
	./scripts/demo-preemption.sh

demo-starvation:
	./scripts/demo-starvation.sh

demo-fair-share:
	./scripts/demo-fair-share.sh

status:
	./scripts/smoke.sh

verify: lint test

clean-local:
	./scripts/clean-local.sh

cleanroom-validate:
	./scripts/cleanroom-validate.sh

test:
	$(PYTHON) -m pytest -q
lint:
	$(PYTHON) -m ruff check scheduler-lab/src tests
demo-quota demo-borrow: demo-kueue

demo-priority: demo-preemption

demo-simulator demo-topology demo-fragmentation:
	$(PYTHON) -m pytest -q
