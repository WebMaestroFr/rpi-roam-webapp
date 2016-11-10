import os
from subprocess import call

path = os.path.dirname(os.path.realpath(__file__))


def iptables(ap, adapter, active=False):
    call(
        "/usr/bin/sudo bash %s/iptables.sh %s %s %s" %
        (path, 1 if active else 0, ap, adapter),
        shell=True)
