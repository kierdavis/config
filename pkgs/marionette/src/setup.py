from setuptools import setup, find_packages

setup(
  name="marionette",
  version="1",
  packages=find_packages(exclude=["stubs"]),
  python_requires=">= 3.7",
  install_requires=[
    "pyparsing",
    "requests-oauthlib",
    "typing-extensions",
  ],
  entry_points={
    "console_scripts": [
      "marionette=marionette.main:main",
    ],
  },
)
