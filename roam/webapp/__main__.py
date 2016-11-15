import argparse

from flask import Flask, jsonify, render_template, request

from modules import configuration, connection

parser = argparse.ArgumentParser()

parser.add_argument(
    "--ip", nargs="?", default="10.0.0.1", help="Application IP")
parser.add_argument(
    "--port", type=int, nargs="?", default=80, help="Application Port")
parser.add_argument(
    "--name", nargs="?", default="Raspberry Pi", help="Application Name")
parser.add_argument(
    "--ap", nargs="?", default="wlan0", help="Access Point Interface")
parser.add_argument(
    "--adapter", nargs="?", default="wlan1", help="Adapter Interface")

args = parser.parse_args()

ssid = connection.auto_connect(args.ap, args.adapter)
configuration.iptables(args.ap, args.adapter, args.ip, args.port, ssid)

app = Flask(__name__)
app.config.update(DEBUG=True)
app.json_encoder = connection.JSONEncoder


@app.route("/ssid")
def active_ssid():
    return jsonify(connection.active_ssid(args.adapter))


@app.route("/networks")
def list_networks():
    return jsonify(connection.list_networks(args.ap))


@app.route("/save", methods=["POST"])
def create_scheme():
    if "ssid" in request.form:
        ssid = request.form["ssid"]
        passkey = None if "passkey" not in request.form else request.form[
            "passkey"]
        scheme = connection.create_scheme(args.adapter, ssid, passkey)
        return jsonify(scheme)
    return jsonify(False)


@app.route("/connect", methods=["POST"])
def activate_scheme():
    if "ssid" in request.form:
        ssid = request.form["ssid"]
        if "passkey" in request.form:
            scheme = connection.create_scheme(args.adapter, ssid,
                                              request.form["passkey"])
        else:
            scheme = connection.get_scheme(args.adapter, ssid)
        if scheme and connection.activate_scheme(scheme):
            # configuration.iptables(args.ap, args.adapter, args.ip, args.port, ssid)
            return jsonify(ssid)
    return jsonify(False)


@app.route("/")
def index():
    return render_template(
        "index.html",
        networks=connection.list_networks(args.ap),
        active=connection.active_ssid(args.adapter),
        name=args.name)

# app.run(host="0.0.0.0", port=args.port)
app.run(host=args.ip, port=args.port)
