import types
import typing
from collections import defaultdict

__all__ = ["gl", "u256", "TreeMap", "DynArray", "allow_storage", "Address"]

MAX = 2 ** 256 - 1


class u256(int):
    def __new__(cls, v=0):
        v = int(v)
        if v < 0 or v > MAX:
            raise OverflowError("u256 out of range: " + str(v))
        return int.__new__(cls, v)


class Address(str):
    @property
    def as_hex(self):
        return str(self).lower()


class TreeMap(dict):
    pass


class DynArray(list):
    pass


def allow_storage(cls):
    hints = typing.get_type_hints(cls)
    orig = cls.__setattr__

    def __setattr__(self, name, value):
        t = hints.get(name)
        if t is u256 and not isinstance(value, u256):
            raise TypeError("storage field " + name + " needs u256, got " + type(value).__name__)
        if t is str and not isinstance(value, str):
            raise TypeError("storage field " + name + " needs str")
        if t is bool and not isinstance(value, bool):
            raise TypeError("storage field " + name + " needs bool")
        orig(self, name, value)

    cls.__setattr__ = __setattr__
    return cls


class _Message:
    sender_address = None
    value = 0


class _Return:
    def __init__(self, calldata):
        self.calldata = calldata


class _Vm:
    Return = _Return

    @staticmethod
    def run_nondet_unsafe(leader, validator, /):
        out = leader()
        if not validator(_Return(out)):
            raise Exception("validators disagreed")
        return out


class _Web:
    render = staticmethod(lambda url, mode="text": "page for " + url)


class _Nondet:
    web = _Web()
    exec_prompt = staticmethod(lambda prompt, response_format="text": {})


class _Transfer:
    def __init__(self, target):
        self.target = target

    def emit_transfer(self, *, value):
        chain = gl.chain
        value = int(value)
        if chain.balances[chain.addr] < value:
            raise Exception("contract balance too low")
        chain.balances[chain.addr] -= value
        chain.balances[str(self.target).lower()] += value


class _Public:
    @staticmethod
    def view(f):
        f._kind = "view"
        return f

    class _Write:
        def __call__(self, f):
            f._kind = "write"
            return f

        @staticmethod
        def payable(f):
            f._kind = "payable"
            return f

    write = _Write()


class Contract:
    def __new__(cls, *a, **k):
        obj = object.__new__(cls)
        hints = typing.get_type_hints(cls)
        for name, t in hints.items():
            origin = typing.get_origin(t)
            if origin is TreeMap:
                object.__setattr__(obj, name, TreeMap())
            elif origin is DynArray:
                object.__setattr__(obj, name, DynArray())
        return obj

    def __setattr__(self, name, value):
        hints = typing.get_type_hints(type(self))
        t = hints.get(name)
        if t is not None:
            origin = typing.get_origin(t)
            if origin in (TreeMap, DynArray):
                raise AssertionError("cannot assign collection field " + name)
            if t is u256 and not isinstance(value, u256):
                raise TypeError("storage field " + name + " needs u256")
            if t is str and not isinstance(value, str):
                raise TypeError("storage field " + name + " needs str")
        object.__setattr__(self, name, value)


class _GL:
    Contract = Contract
    message = _Message()
    public = _Public()
    vm = _Vm()
    nondet = _Nondet()
    chain = None

    @staticmethod
    def get_contract_at(addr):
        return _Transfer(addr)


gl = _GL()
