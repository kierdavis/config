PACKAGE_PATHS = nix_channel_proxy
PYTHON_PATHS = $(PACKAGE_PATHS) setup.py

all: format typecheck lint

format: black isort

black:
	black $(PYTHON_PATHS)

isort:
	isort -rc $(PYTHON_PATHS)

typecheck:
	mypy $(PACKAGE_PATHS)

lint:
	flake8 $(PYTHON_PATHS)
