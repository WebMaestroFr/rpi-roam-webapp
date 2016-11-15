import os
from subprocess import call

path = os.path.dirname(os.path.realpath(__file__))


def iptables(ap, adapter, ip="10.0.0.1", port=80, active=False):
    call(
        "/usr/bin/sudo bash %s/iptables.sh %s %s %s %s %s" %
        (path, 1 if active else 0, ap, adapter, ip, port),
        shell=True)
