PYTHON ?= python3
export PYTHONPATH := scheduler-lab/src
test:
	$(PYTHON) -m pytest -q
lint:
	$(PYTHON) -m ruff check scheduler-lab/src tests
demo-quota demo-borrow demo-fair-share demo-priority demo-preemption demo-gang demo-topology demo-fragmentation:
	$(PYTHON) -m pytest -q
