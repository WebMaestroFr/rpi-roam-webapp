import argparse

from app import _auto_connect

parser = argparse.ArgumentParser()
parser.add_argument(
    "--ap", nargs="?", default="wlan0", help="Access Point Interface.")
parser.add_argument(
    "--adapter", nargs="?", default="wlan1", help="Adapter Interface.")
args = parser.parse_args()

_auto_connect(args.ap, args.adapter)
