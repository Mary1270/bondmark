import json
import pathlib

root = pathlib.Path(__file__).resolve().parent.parent
MICRO = 10 ** 6
BW, SW, SPLIT, INS = "BUYER_WINS", "SELLER_WINS", "SPLIT", "INSUFFICIENT_EVIDENCE"
CAP_BPS = 2500
FEE_BPS = 500
LOCK_BPS = 15000
BOND_UNITS = 50
DEP = MICRO
CLAIM_DEP = MICRO


class Divergence(Exception):
    pass


def initial(protect_units, status):
    p = protect_units * MICRO
    return {
        "status": status,
        "verdict": "",
        "compensation": 0,
        "fee": 0,
        "buyer_claimable": 0,
        "seller_claimable": 0,
        "treasury": 0,
        "seller_bond": BOND_UNITS * MICRO,
        "seller_locked": p * LOCK_BPS // 10000,
        "lost": 0,
        "split": 0,
        "won": 0,
        "inconclusive": 0,
    }


def settle(o, p, silent, v):
    comp = p if v == BW else p // 2 if v == SPLIT else 0
    if silent and comp > 0:
        comp = min(comp, p * CAP_BPS // 10000)
    fee = comp * FEE_BPS // 10000
    o["status"] = "RESOLVED"
    o["verdict"] = v
    o["compensation"] = comp
    o["fee"] = fee
    o["treasury"] = fee
    o["seller_bond"] = BOND_UNITS * MICRO - comp - fee
    o["seller_locked"] = 0
    o["buyer_claimable"] = comp
    if v == SW:
        o["seller_claimable"] = DEP + CLAIM_DEP
        o["won"] = 1
    else:
        o["buyer_claimable"] += DEP + CLAIM_DEP
        o["lost"] = 1 if v == BW else 0
        o["split"] = 1 if v == SPLIT else 0
        o["inconclusive"] = 1 if v == INS else 0


def model(protect_units, silent, steps):
    p = protect_units * MICRO
    o = initial(protect_units, "DISPUTED")
    reopened = False
    pending = None
    for n, st in enumerate(steps):
        kind = st[0]
        if kind == "r":
            _, v, reviewed = st
            if silent and v in (BW, SPLIT) and not reviewed:
                if n != 0:
                    raise AssertionError("divergent step must be first")
                raise Divergence()
            challenged = o["status"] == "CHALLENGED"
            if v == INS and not reopened and not challenged:
                reopened = True
                o["status"] = "REOPENED"
                o["verdict"] = INS
                continue
            if silent and not challenged and v in (BW, SPLIT):
                o["status"] = "PAYOUT_PENDING"
                o["verdict"] = v
                pending = v
                continue
            settle(o, p, silent, v)
        elif kind == "c":
            assert o["status"] == "PAYOUT_PENDING"
            o["status"] = "CHALLENGED"
            reopened = True
            pending = None
        elif kind == "f":
            assert o["status"] == "PAYOUT_PENDING"
            settle(o, p, silent, pending)
            pending = None
    return o


def scenarios():
    out = []
    singles = [(BW, True), (BW, False), (SPLIT, True), (SPLIT, False), (SW, True), (SW, False), (INS, False), (INS, True)]
    doubles = [[(INS, False), (BW, True)], [(INS, False), (SPLIT, True)], [(INS, False), (SW, False)], [(INS, False), (INS, False)]]
    seqs = []
    for a in singles:
        seqs.append([("r",) + a])
    for d in doubles:
        seqs.append([("r",) + x for x in d])
    for protect in (1, 10):
        for silent in (False, True):
            for seq in seqs:
                out.append(make(protect, silent, seq))
        for v in (BW, SPLIT):
            r = ("r", v, True)
            out.append(make(protect, True, [r, ("f",)]))
            out.append(make(protect, True, [r, ("c",), ("r", SW, False)]))
            out.append(make(protect, True, [r, ("c",), ("r", v, True)]))
            out.append(make(protect, True, [r, ("c",), ("r", INS, False)]))
            out.append(make(protect, True, [("r", INS, False), r, ("f",)]))
            out.append(make(protect, True, [("r", INS, False), r, ("c",), ("r", v, True)]))
    return out


def label(st):
    if st[0] == "r":
        return "%s_%s" % (st[1].lower(), "rev" if st[2] else "norev")
    return "challenge" if st[0] == "c" else "finalize"


def make(protect, silent, seq):
    name = "p%d_%s_%s" % (protect, "silent" if silent else "confirmed", "_then_".join(label(s) for s in seq))
    sc = {"id": name, "protect": protect, "silent": silent, "steps": [list(s) for s in seq]}
    try:
        sc["expect"] = model(protect, silent, seq)
    except Divergence:
        sc["divergent"] = True
        sc["expect_genlayer"] = initial(protect, "REOPENED")
        sc["expect_genlayer"]["verdict"] = INS
        sc["expect_base"] = initial(protect, "DISPUTED")
        sc["base_reverts"] = True
    return sc


def render_json():
    return json.dumps({"micro_units_per_unit": MICRO, "scenarios": scenarios()}, indent=1) + "\n"


STATUS_NUM = {"DISPUTED": 5, "REOPENED": 6, "RESOLVED": 7, "PAYOUT_PENDING": 10, "CHALLENGED": 11}
KIND_NUM = {"r": 0, "c": 1, "f": 2}
VERDICT_NUM = {"": 0, BW: 1, SW: 2, SPLIT: 3, INS: 4}


def sol_checks(exp, reverted):
    wei = 10 ** 9
    lines = [
        "        assertEq(o.reverted, %s);" % ("true" if reverted else "false"),
        "        assertEq(o.status, %d);" % STATUS_NUM[exp["status"]],
        "        assertEq(o.verdict, %d);" % VERDICT_NUM[exp["verdict"]],
    ]
    for key, field in (("compensation", "compensation"), ("fee", "fee"), ("buyer_claimable", "buyerClaimable"), ("seller_claimable", "sellerClaimable"), ("treasury", "treasury"), ("seller_bond", "sellerBond"), ("seller_locked", "sellerLocked")):
        lines.append("        assertEq(o.%s, %d);" % (field, exp[key] * wei))
    for key, field in (("lost", "lost"), ("split", "split"), ("won", "won"), ("inconclusive", "inconclusive")):
        lines.append("        assertEq(o.%s, %d);" % (field, exp[key]))
    return lines


def render_sol():
    lines = [
        "// SPDX-License-Identifier: MIT",
        "pragma solidity ^0.8.24;",
        "",
        'import "./ParityBase.sol";',
        "",
        "contract ParityScenariosTest is ParityBase {",
    ]
    for sc in scenarios():
        lines.append("")
        lines.append("    function test_parity_%s() public {" % sc["id"])
        lines.append("        uint8[] memory k = new uint8[](%d);" % len(sc["steps"]))
        lines.append("        uint8[] memory v = new uint8[](%d);" % len(sc["steps"]))
        lines.append("        bool[] memory r = new bool[](%d);" % len(sc["steps"]))
        for i, st in enumerate(sc["steps"]):
            lines.append("        k[%d] = %d;" % (i, KIND_NUM[st[0]]))
            if st[0] == "r":
                lines.append("        v[%d] = %d;" % (i, VERDICT_NUM[st[1]]))
                lines.append("        r[%d] = %s;" % (i, "true" if st[2] else "false"))
        lines.append("        Obs memory o = _run(%d, %s, k, v, r);" % (sc["protect"], "true" if sc["silent"] else "false"))
        if sc.get("divergent"):
            lines += sol_checks(sc["expect_base"], True)
        else:
            lines += sol_checks(sc["expect"], False)
        lines.append("    }")
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


if __name__ == "__main__":
    (root / "tests" / "parity_scenarios.json").write_text(render_json())
    (root / "base" / "test" / "ParityScenarios.t.sol").write_text(render_sol())
    print("wrote parity files:", len(scenarios()), "scenarios")
