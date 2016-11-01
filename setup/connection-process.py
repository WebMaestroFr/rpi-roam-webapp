import argparse

from webapp.app import _auto_connect

parser = argparse.ArgumentParser()
parser.add_argument(
    "--adapter", nargs="?", default="wlan1", help="Adapter Interface.")
args = parser.parse_args()

_auto_connect(args.adapter)
