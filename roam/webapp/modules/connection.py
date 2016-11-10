from subprocess import CalledProcessError, check_output

from flask.json import JSONEncoder as FlaskJSONEncoder

import configuration
from wifi import Cell, Scheme
from wifi.exceptions import ConnectionError


class JSONEncoder(FlaskJSONEncoder):
    # Custom JSON encoder
    def default(self, obj):
        try:
            if isinstance(obj, Cell) or isinstance(obj, Scheme):
                # Turn instances to dicts
                return obj.__dict__
            # Turn iterables...
            iterable = iter(obj)
        except TypeError:
            pass
        else:
            # ... to lists
            return list(iterable)
        # Fallback on default encoder
        return FlaskJSONEncoder.default(self, obj)


def active_ssid(interface):
    # Get SSID of active connection
    try:
        return check_output(["iwgetid", interface, "-r"]).strip()
    except CalledProcessError:
        return False


def get_scheme(interface, ssid):
    return Scheme.find(interface, ssid)


def list_networks(interface):
    # Get list of available Cell objects
    return Cell.all(interface)


def create_scheme(interface, ssid, passkey):
    # Save a couple SSID / passkey into Scheme object
    cell = Cell.where(interface, lambda c: c.ssid == ssid)
    # Get cell matching SSID
    if cell:
        # Delete previous duplicate
        previous = Scheme.find(interface, ssid)
        if previous:
            print "Deleting previous \"%s\" duplicate." % (ssid)
            previous.delete()
        # Instanciate Scheme for this Cell
        scheme = Scheme.for_cell(interface, ssid, cell[0], passkey)
        print "Saving WiFi scheme \"%s\"." % (ssid)
        try:
            scheme.save()
            return scheme
        except:
            print "Scheme could not be saved."
            pass
    return False


def activate_scheme(scheme):
    # Connect a Scheme object
    print "Attempt connection...", scheme
    if scheme:
        try:
            scheme.activate()
            print "Connected to WiFi !"
            return scheme
        except ConnectionError as error:
            print "Connection Error.", error
            pass
    return False


def auto_connect(ap, adapter):
    # Attempt connection on known available networks
    for cell in list_networks(ap):
        # List networks from AP interface (so our own network is excluded)
        scheme = Scheme.find(adapter, cell.ssid)
        if activate_scheme(scheme):
            # Connected
            return cell.ssid
    # Failed to connect
    return False


if __name__ == "__main__":

    import argparse

    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--ap", nargs="?", default="wlan0", help="Access Point Interface.")
    parser.add_argument(
        "--adapter", nargs="?", default="wlan1", help="Adapter Interface.")

    args = parser.parse_args()

    ssid = active_ssid(args.adapter)

    if not ssid:
        # Attempt connection
        ssid = auto_connect(args.ap, args.adapter)
        # Reset iptables rules
        configuration.iptables(args.ap, args.adapter, ssid)
