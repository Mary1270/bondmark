import copy
import importlib.util
import pathlib
import sys
import types
from collections import defaultdict

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
sys.path.insert(0, str(HERE / "genlayer_stub"))

from genlayer import gl, u256, Address


class _FakeStamp:
    def __init__(self, t):
        self.t = t

    def timestamp(self):
        return float(self.t)


class _FakeDT:
    pass


def load_module(name="bondmark.py"):
    path = ROOT / "contracts" / name
    spec = importlib.util.spec_from_file_location("contract_" + name.replace(".", "_"), path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def A(n):
    return "0x" + format(n, "040x")


class Chain:
    def __init__(self, name="bondmark.py", deployer=None):
        self.mod = load_module(name)
        self.now = 1_700_000_000
        chain = self
        dt = _FakeDT()
        dt.datetime = types.SimpleNamespace(now=lambda: _FakeStamp(chain.now))
        self.mod.datetime = dt
        self.balances = defaultdict(int)
        self.addr = A(0xC0FFEE)
        gl.chain = self
        self.deployer = deployer or A(1)
        self._set_msg(self.deployer, 0)
        self.c = self.mod.BondMark()

    def _set_msg(self, sender, value):
        gl.message.sender_address = Address(sender)
        gl.message.value = u256(value)

    def fund(self, who, amount):
        self.balances[who] += amount

    def call(self, sender, method, *args, value=0):
        fn = getattr(self.c, method)
        kind = getattr(fn, "_kind", None)
        if kind is None:
            raise AssertionError(method + " is not public")
        if value and kind != "payable":
            raise AssertionError(method + " is not payable")
        if self.balances[sender] < value:
            raise AssertionError("sender cannot afford value")
        snap_state = copy.deepcopy(self.c.__dict__)
        snap_bal = dict(self.balances)
        self.balances[sender] -= value
        self.balances[self.addr] += value
        self._set_msg(sender, value)
        try:
            return fn(*args)
        except BaseException:
            self.c.__dict__.clear()
            self.c.__dict__.update(snap_state)
            self.balances = defaultdict(int, snap_bal)
            self.balances[sender] -= value
            self.balances[self.addr] += value
            raise

    def advance(self, secs):
        self.now += secs
