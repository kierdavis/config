from setuptools import setup

setup(
    name="passchars",
    version="0.1",
    author="Kier Davis",
    author_email="kierdavis@gmail.com",
    platforms="ALL",
    python_requires=">=3",

    packages=["passchars"],
    entry_points={
        'console_scripts': [
            'passchars = passchars:main',
        ],
    },
)
