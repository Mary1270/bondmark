// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ParityBase.sol";

contract ParityScenariosTest is ParityBase {

    function test_parity_p1_confirmed_buyer_wins_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 1;
        r[0] = true;
        Obs memory o = _run(1, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 1000000000000000);
        assertEq(o.fee, 50000000000000);
        assertEq(o.buyerClaimable, 3000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 50000000000000);
        assertEq(o.sellerBond, 48950000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_confirmed_buyer_wins_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 1;
        r[0] = false;
        Obs memory o = _run(1, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 1000000000000000);
        assertEq(o.fee, 50000000000000);
        assertEq(o.buyerClaimable, 3000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 50000000000000);
        assertEq(o.sellerBond, 48950000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_confirmed_split_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 3;
        r[0] = true;
        Obs memory o = _run(1, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 500000000000000);
        assertEq(o.fee, 25000000000000);
        assertEq(o.buyerClaimable, 2500000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 25000000000000);
        assertEq(o.sellerBond, 49475000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_confirmed_split_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 3;
        r[0] = false;
        Obs memory o = _run(1, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 500000000000000);
        assertEq(o.fee, 25000000000000);
        assertEq(o.buyerClaimable, 2500000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 25000000000000);
        assertEq(o.sellerBond, 49475000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_confirmed_seller_wins_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 2;
        r[0] = true;
        Obs memory o = _run(1, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_confirmed_seller_wins_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 2;
        r[0] = false;
        Obs memory o = _run(1, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_confirmed_insufficient_evidence_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        Obs memory o = _run(1, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 6);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 1500000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_confirmed_insufficient_evidence_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 4;
        r[0] = true;
        Obs memory o = _run(1, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 6);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 1500000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_confirmed_insufficient_evidence_norev_then_buyer_wins_rev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 1;
        r[1] = true;
        Obs memory o = _run(1, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 1000000000000000);
        assertEq(o.fee, 50000000000000);
        assertEq(o.buyerClaimable, 3000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 50000000000000);
        assertEq(o.sellerBond, 48950000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_confirmed_insufficient_evidence_norev_then_split_rev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 3;
        r[1] = true;
        Obs memory o = _run(1, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 500000000000000);
        assertEq(o.fee, 25000000000000);
        assertEq(o.buyerClaimable, 2500000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 25000000000000);
        assertEq(o.sellerBond, 49475000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_confirmed_insufficient_evidence_norev_then_seller_wins_norev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 2;
        r[1] = false;
        Obs memory o = _run(1, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_confirmed_insufficient_evidence_norev_then_insufficient_evidence_norev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 4;
        r[1] = false;
        Obs memory o = _run(1, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 2000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 1);
    }

    function test_parity_p1_silent_buyer_wins_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 1;
        r[0] = true;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 10);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 1500000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_buyer_wins_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 1;
        r[0] = false;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, true);
        assertEq(o.status, 5);
        assertEq(o.verdict, 0);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 1500000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_split_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 3;
        r[0] = true;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 10);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 1500000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_split_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 3;
        r[0] = false;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, true);
        assertEq(o.status, 5);
        assertEq(o.verdict, 0);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 1500000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_seller_wins_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 2;
        r[0] = true;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_seller_wins_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 2;
        r[0] = false;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_insufficient_evidence_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 6);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 1500000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_insufficient_evidence_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 4;
        r[0] = true;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 6);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 1500000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_insufficient_evidence_norev_then_buyer_wins_rev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 1;
        r[1] = true;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 10);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 1500000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_insufficient_evidence_norev_then_split_rev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 3;
        r[1] = true;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 10);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 1500000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_insufficient_evidence_norev_then_seller_wins_norev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 2;
        r[1] = false;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_insufficient_evidence_norev_then_insufficient_evidence_norev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 4;
        r[1] = false;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 2000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 1);
    }

    function test_parity_p1_silent_buyer_wins_rev_then_finalize() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 1;
        r[0] = true;
        k[1] = 2;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 250000000000000);
        assertEq(o.fee, 12500000000000);
        assertEq(o.buyerClaimable, 2250000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 12500000000000);
        assertEq(o.sellerBond, 49737500000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_buyer_wins_rev_then_challenge_then_seller_wins_norev() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 1;
        r[0] = true;
        k[1] = 1;
        k[2] = 0;
        v[2] = 2;
        r[2] = false;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_buyer_wins_rev_then_challenge_then_buyer_wins_rev() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 1;
        r[0] = true;
        k[1] = 1;
        k[2] = 0;
        v[2] = 1;
        r[2] = true;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 250000000000000);
        assertEq(o.fee, 12500000000000);
        assertEq(o.buyerClaimable, 2250000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 12500000000000);
        assertEq(o.sellerBond, 49737500000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_buyer_wins_rev_then_challenge_then_insufficient_evidence_norev() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 1;
        r[0] = true;
        k[1] = 1;
        k[2] = 0;
        v[2] = 4;
        r[2] = false;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 2000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 1);
    }

    function test_parity_p1_silent_insufficient_evidence_norev_then_buyer_wins_rev_then_finalize() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 1;
        r[1] = true;
        k[2] = 2;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 250000000000000);
        assertEq(o.fee, 12500000000000);
        assertEq(o.buyerClaimable, 2250000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 12500000000000);
        assertEq(o.sellerBond, 49737500000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_insufficient_evidence_norev_then_buyer_wins_rev_then_challenge_then_buyer_wins_rev() public {
        uint8[] memory k = new uint8[](4);
        uint8[] memory v = new uint8[](4);
        bool[] memory r = new bool[](4);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 1;
        r[1] = true;
        k[2] = 1;
        k[3] = 0;
        v[3] = 1;
        r[3] = true;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 250000000000000);
        assertEq(o.fee, 12500000000000);
        assertEq(o.buyerClaimable, 2250000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 12500000000000);
        assertEq(o.sellerBond, 49737500000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_split_rev_then_finalize() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 3;
        r[0] = true;
        k[1] = 2;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 250000000000000);
        assertEq(o.fee, 12500000000000);
        assertEq(o.buyerClaimable, 2250000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 12500000000000);
        assertEq(o.sellerBond, 49737500000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_split_rev_then_challenge_then_seller_wins_norev() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 3;
        r[0] = true;
        k[1] = 1;
        k[2] = 0;
        v[2] = 2;
        r[2] = false;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_split_rev_then_challenge_then_split_rev() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 3;
        r[0] = true;
        k[1] = 1;
        k[2] = 0;
        v[2] = 3;
        r[2] = true;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 250000000000000);
        assertEq(o.fee, 12500000000000);
        assertEq(o.buyerClaimable, 2250000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 12500000000000);
        assertEq(o.sellerBond, 49737500000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_split_rev_then_challenge_then_insufficient_evidence_norev() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 3;
        r[0] = true;
        k[1] = 1;
        k[2] = 0;
        v[2] = 4;
        r[2] = false;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 2000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 1);
    }

    function test_parity_p1_silent_insufficient_evidence_norev_then_split_rev_then_finalize() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 3;
        r[1] = true;
        k[2] = 2;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 250000000000000);
        assertEq(o.fee, 12500000000000);
        assertEq(o.buyerClaimable, 2250000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 12500000000000);
        assertEq(o.sellerBond, 49737500000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p1_silent_insufficient_evidence_norev_then_split_rev_then_challenge_then_split_rev() public {
        uint8[] memory k = new uint8[](4);
        uint8[] memory v = new uint8[](4);
        bool[] memory r = new bool[](4);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 3;
        r[1] = true;
        k[2] = 1;
        k[3] = 0;
        v[3] = 3;
        r[3] = true;
        Obs memory o = _run(1, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 250000000000000);
        assertEq(o.fee, 12500000000000);
        assertEq(o.buyerClaimable, 2250000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 12500000000000);
        assertEq(o.sellerBond, 49737500000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_confirmed_buyer_wins_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 1;
        r[0] = true;
        Obs memory o = _run(10, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 10000000000000000);
        assertEq(o.fee, 500000000000000);
        assertEq(o.buyerClaimable, 12000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 500000000000000);
        assertEq(o.sellerBond, 39500000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_confirmed_buyer_wins_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 1;
        r[0] = false;
        Obs memory o = _run(10, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 10000000000000000);
        assertEq(o.fee, 500000000000000);
        assertEq(o.buyerClaimable, 12000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 500000000000000);
        assertEq(o.sellerBond, 39500000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_confirmed_split_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 3;
        r[0] = true;
        Obs memory o = _run(10, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 5000000000000000);
        assertEq(o.fee, 250000000000000);
        assertEq(o.buyerClaimable, 7000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 250000000000000);
        assertEq(o.sellerBond, 44750000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_confirmed_split_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 3;
        r[0] = false;
        Obs memory o = _run(10, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 5000000000000000);
        assertEq(o.fee, 250000000000000);
        assertEq(o.buyerClaimable, 7000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 250000000000000);
        assertEq(o.sellerBond, 44750000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_confirmed_seller_wins_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 2;
        r[0] = true;
        Obs memory o = _run(10, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_confirmed_seller_wins_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 2;
        r[0] = false;
        Obs memory o = _run(10, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_confirmed_insufficient_evidence_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        Obs memory o = _run(10, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 6);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 15000000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_confirmed_insufficient_evidence_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 4;
        r[0] = true;
        Obs memory o = _run(10, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 6);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 15000000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_confirmed_insufficient_evidence_norev_then_buyer_wins_rev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 1;
        r[1] = true;
        Obs memory o = _run(10, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 10000000000000000);
        assertEq(o.fee, 500000000000000);
        assertEq(o.buyerClaimable, 12000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 500000000000000);
        assertEq(o.sellerBond, 39500000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_confirmed_insufficient_evidence_norev_then_split_rev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 3;
        r[1] = true;
        Obs memory o = _run(10, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 5000000000000000);
        assertEq(o.fee, 250000000000000);
        assertEq(o.buyerClaimable, 7000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 250000000000000);
        assertEq(o.sellerBond, 44750000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_confirmed_insufficient_evidence_norev_then_seller_wins_norev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 2;
        r[1] = false;
        Obs memory o = _run(10, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_confirmed_insufficient_evidence_norev_then_insufficient_evidence_norev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 4;
        r[1] = false;
        Obs memory o = _run(10, false, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 2000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 1);
    }

    function test_parity_p10_silent_buyer_wins_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 1;
        r[0] = true;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 10);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 15000000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_buyer_wins_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 1;
        r[0] = false;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, true);
        assertEq(o.status, 5);
        assertEq(o.verdict, 0);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 15000000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_split_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 3;
        r[0] = true;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 10);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 15000000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_split_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 3;
        r[0] = false;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, true);
        assertEq(o.status, 5);
        assertEq(o.verdict, 0);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 15000000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_seller_wins_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 2;
        r[0] = true;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_seller_wins_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 2;
        r[0] = false;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_insufficient_evidence_norev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 6);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 15000000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_insufficient_evidence_rev() public {
        uint8[] memory k = new uint8[](1);
        uint8[] memory v = new uint8[](1);
        bool[] memory r = new bool[](1);
        k[0] = 0;
        v[0] = 4;
        r[0] = true;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 6);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 15000000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_insufficient_evidence_norev_then_buyer_wins_rev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 1;
        r[1] = true;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 10);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 15000000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_insufficient_evidence_norev_then_split_rev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 3;
        r[1] = true;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 10);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 15000000000000000);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_insufficient_evidence_norev_then_seller_wins_norev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 2;
        r[1] = false;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_insufficient_evidence_norev_then_insufficient_evidence_norev() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 4;
        r[1] = false;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 2000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 1);
    }

    function test_parity_p10_silent_buyer_wins_rev_then_finalize() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 1;
        r[0] = true;
        k[1] = 2;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 2500000000000000);
        assertEq(o.fee, 125000000000000);
        assertEq(o.buyerClaimable, 4500000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 125000000000000);
        assertEq(o.sellerBond, 47375000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_buyer_wins_rev_then_challenge_then_seller_wins_norev() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 1;
        r[0] = true;
        k[1] = 1;
        k[2] = 0;
        v[2] = 2;
        r[2] = false;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_buyer_wins_rev_then_challenge_then_buyer_wins_rev() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 1;
        r[0] = true;
        k[1] = 1;
        k[2] = 0;
        v[2] = 1;
        r[2] = true;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 2500000000000000);
        assertEq(o.fee, 125000000000000);
        assertEq(o.buyerClaimable, 4500000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 125000000000000);
        assertEq(o.sellerBond, 47375000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_buyer_wins_rev_then_challenge_then_insufficient_evidence_norev() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 1;
        r[0] = true;
        k[1] = 1;
        k[2] = 0;
        v[2] = 4;
        r[2] = false;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 2000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 1);
    }

    function test_parity_p10_silent_insufficient_evidence_norev_then_buyer_wins_rev_then_finalize() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 1;
        r[1] = true;
        k[2] = 2;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 2500000000000000);
        assertEq(o.fee, 125000000000000);
        assertEq(o.buyerClaimable, 4500000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 125000000000000);
        assertEq(o.sellerBond, 47375000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_insufficient_evidence_norev_then_buyer_wins_rev_then_challenge_then_buyer_wins_rev() public {
        uint8[] memory k = new uint8[](4);
        uint8[] memory v = new uint8[](4);
        bool[] memory r = new bool[](4);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 1;
        r[1] = true;
        k[2] = 1;
        k[3] = 0;
        v[3] = 1;
        r[3] = true;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 1);
        assertEq(o.compensation, 2500000000000000);
        assertEq(o.fee, 125000000000000);
        assertEq(o.buyerClaimable, 4500000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 125000000000000);
        assertEq(o.sellerBond, 47375000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 1);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_split_rev_then_finalize() public {
        uint8[] memory k = new uint8[](2);
        uint8[] memory v = new uint8[](2);
        bool[] memory r = new bool[](2);
        k[0] = 0;
        v[0] = 3;
        r[0] = true;
        k[1] = 2;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 2500000000000000);
        assertEq(o.fee, 125000000000000);
        assertEq(o.buyerClaimable, 4500000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 125000000000000);
        assertEq(o.sellerBond, 47375000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_split_rev_then_challenge_then_seller_wins_norev() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 3;
        r[0] = true;
        k[1] = 1;
        k[2] = 0;
        v[2] = 2;
        r[2] = false;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 2);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 0);
        assertEq(o.sellerClaimable, 2000000000000000);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 1);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_split_rev_then_challenge_then_split_rev() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 3;
        r[0] = true;
        k[1] = 1;
        k[2] = 0;
        v[2] = 3;
        r[2] = true;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 2500000000000000);
        assertEq(o.fee, 125000000000000);
        assertEq(o.buyerClaimable, 4500000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 125000000000000);
        assertEq(o.sellerBond, 47375000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_split_rev_then_challenge_then_insufficient_evidence_norev() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 3;
        r[0] = true;
        k[1] = 1;
        k[2] = 0;
        v[2] = 4;
        r[2] = false;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 4);
        assertEq(o.compensation, 0);
        assertEq(o.fee, 0);
        assertEq(o.buyerClaimable, 2000000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 0);
        assertEq(o.sellerBond, 50000000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 0);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 1);
    }

    function test_parity_p10_silent_insufficient_evidence_norev_then_split_rev_then_finalize() public {
        uint8[] memory k = new uint8[](3);
        uint8[] memory v = new uint8[](3);
        bool[] memory r = new bool[](3);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 3;
        r[1] = true;
        k[2] = 2;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 2500000000000000);
        assertEq(o.fee, 125000000000000);
        assertEq(o.buyerClaimable, 4500000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 125000000000000);
        assertEq(o.sellerBond, 47375000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }

    function test_parity_p10_silent_insufficient_evidence_norev_then_split_rev_then_challenge_then_split_rev() public {
        uint8[] memory k = new uint8[](4);
        uint8[] memory v = new uint8[](4);
        bool[] memory r = new bool[](4);
        k[0] = 0;
        v[0] = 4;
        r[0] = false;
        k[1] = 0;
        v[1] = 3;
        r[1] = true;
        k[2] = 1;
        k[3] = 0;
        v[3] = 3;
        r[3] = true;
        Obs memory o = _run(10, true, k, v, r);
        assertEq(o.reverted, false);
        assertEq(o.status, 7);
        assertEq(o.verdict, 3);
        assertEq(o.compensation, 2500000000000000);
        assertEq(o.fee, 125000000000000);
        assertEq(o.buyerClaimable, 4500000000000000);
        assertEq(o.sellerClaimable, 0);
        assertEq(o.treasury, 125000000000000);
        assertEq(o.sellerBond, 47375000000000000);
        assertEq(o.sellerLocked, 0);
        assertEq(o.lost, 0);
        assertEq(o.split, 1);
        assertEq(o.won, 0);
        assertEq(o.inconclusive, 0);
    }
}
