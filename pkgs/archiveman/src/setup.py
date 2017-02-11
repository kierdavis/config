from setuptools import setup

setup(
  name = "archiveman",
  version = "0.1",
  author = "Kier Davis",
  author_email = "kierdavis@gmail.com",
  platforms = "ALL",

  packages = ["archiveman"],
  entry_points = {
    "console_scripts": [
      "archiveman = archiveman:main",
    ],
  },

  install_requires = [
    "docopt==0.6.2",
    "SQLAlchemy==1.0.15",
  ],
)
