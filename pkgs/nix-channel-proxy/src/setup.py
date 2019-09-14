from setuptools import setup

setup(
    name="nix-channel-proxy",
    version="0.1",
    author="Kier Davis",
    author_email="me@kierdavis.com",
    packages=["nix_channel_proxy"],
    entry_points={
        "console_scripts": [
            "nix-channel-proxy = nix_channel_proxy.nix_channel_proxy:main"
        ]
    },
)
