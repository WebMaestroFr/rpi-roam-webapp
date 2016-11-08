from subprocess import CalledProcessError, call, check_output

from flask.json import JSONEncoder

from wifi import Cell, Scheme
from wifi.exceptions import ConnectionError


def _active(interface):
    try:
        return check_output(["iwgetid", interface, "-r"]).strip()
    except CalledProcessError:
        return None


def _scheme(interface, ssid=None):
    if ssid is None:
        ssid = _active(interface)
    if ssid:
        return Scheme.find(interface, ssid)
    return None


def _networks(interface):
    return Cell.all(interface)


def _save(interface, ssid, passkey):
    match = Cell.where(interface, lambda c: c.ssid == ssid)
    if match:
        previous = Scheme.find(interface, ssid)
        if previous:
            print "Deleting previous \"%s\" duplicate." % (ssid)
            previous.delete()
        scheme = Scheme.for_cell(interface, ssid, match[0], passkey)
        try:
            print "Saving WiFi scheme \"%s\"." % (ssid), scheme
            scheme.save()
            return scheme
        except:
            print "Scheme could not be saved."
            pass
    return False


def _connect(scheme):
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


def _iptables_webapp(ap, adapter, active):
    # Connected : Local address only redirect to webapp
    # TO DO : config file to turn on/off
    tor = False
    call(
        "/usr/bin/sudo bash %s/shell/iptables.sh %s %s %s %s" %
        (path, ap, adapter, 1 if active else 0, 1 if tor else 0),
        shell=True)


def _auto_connect(ap, adapter):
    if _active(adapter):
        return True
    _iptables_webapp(ap, adapter, False)
    for cell in _networks(ap):
        scheme = _scheme(adapter, cell.ssid)
        if _connect(scheme):
            _iptables_webapp(ap, adapter, True)
            return True
    return False


class RoamJSONEncoder(JSONEncoder):
    def default(self, obj):
        try:
            if isinstance(obj, Scheme):
                return obj.__dict__
            iterable = iter(obj)
        except TypeError:
            pass
        else:
            return list(iterable)
        return JSONEncoder.default(self, obj)


if __name__ == "__main__":

    import argparse
    from flask import Flask, jsonify, render_template, request
    import os

    path = os.path.dirname(os.path.realpath(__file__))

    app = Flask(__name__)
    app.config.update(DEBUG=True)
    app.json_encoder = RoamJSONEncoder

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--port", type=int, nargs="?", default=80, help="Application Port.")
    parser.add_argument(
        "--name", nargs="?", default="Raspberry Pi", help="Application Name.")
    parser.add_argument(
        "--ap", nargs="?", default="wlan0", help="Access Point Interface.")
    parser.add_argument(
        "--adapter", nargs="?", default="wlan1", help="Adapter Interface.")

    args = parser.parse_args()

    _auto_connect(args.ap, args.adapter)

    @app.route("/active")
    def active():
        return jsonify(_active(args.adapter))

    @app.route("/scheme")
    def scheme():
        return jsonify(_scheme(args.adapter))

    @app.route("/networks")
    def networks():
        return jsonify(_networks(args.ap))

    @app.route("/save", methods=["POST"])
    def save():
        if "ssid" in request.form:
            ssid = request.form["ssid"]
            passkey = None if "passkey" not in request.form else request.form[
                "passkey"]
            return jsonify(_save(args.adapter, ssid, passkey))
        return jsonify(False)

    @app.route("/connect", methods=["POST"])
    def connect():
        if "ssid" in request.form:
            ssid = request.form["ssid"]
            if "passkey" in request.form and request.form["passkey"]:
                scheme = _save(args.adapter, ssid, request.form["passkey"])
            else:
                scheme = Scheme.find(args.adapter, ssid)
            return jsonify(_connect(scheme))
        return jsonify(False)

    @app.route("/")
    def index():
        return render_template(
            "index.html",
            networks=_networks(args.ap),
            active=_active(args.adapter),
            name=args.name)

    app.run(host="0.0.0.0", port=args.port)
