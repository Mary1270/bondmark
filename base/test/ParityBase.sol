// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/BondMarkBase.sol";

abstract contract ParityBase is Test {
    struct Obs {
        bool reverted;
        uint8 status;
        uint8 verdict;
        uint256 compensation;
        uint256 fee;
        uint256 buyerClaimable;
        uint256 sellerClaimable;
        uint256 treasury;
        uint256 sellerBond;
        uint256 sellerLocked;
        uint256 lost;
        uint256 split;
        uint256 won;
        uint256 inconclusive;
    }

    uint256 internal constant U = 0.001 ether;
    uint256 internal constant H = 3600;

    function _run(uint256 protectUnits, bool silent, uint8[] memory kinds, uint8[] memory verdicts, bool[] memory reviewed) internal returns (Obs memory o) {
        address arbiter = makeAddr("arbiter");
        address seller = makeAddr("seller");
        address buyer = makeAddr("buyer");
        BondMarkBase bm = new BondMarkBase(arbiter, H);
        vm.deal(seller, 100 ether);
        vm.deal(buyer, 100 ether);

        vm.prank(seller);
        bm.registerSeller{value: 50 * U}("parity_shop");
        vm.prank(seller);
        uint256 id = bm.createDeal("Parity item", "1 USD", "", protectUnits * U, 48);
        vm.prank(buyer);
        bm.claimPayment{value: U}(id, "bank ref 123456");
        if (silent) {
            vm.warp(block.timestamp + 24 * H);
            bm.bindByTimeout(id);
        } else {
            vm.prank(seller);
            bm.respondPayment(id, true, "");
        }
        vm.warp(block.timestamp + 48 * H + 1);
        vm.prank(buyer);
        bm.openDispute{value: U}(id, "nothing was ever sent", "");
        vm.warp(block.timestamp + 48 * H + 1);

        for (uint256 i = 0; i < kinds.length; i++) {
            if (kinds[i] == 1) {
                vm.prank(seller);
                bm.challengePayout(id, "I never saw this payment", "");
            } else if (kinds[i] == 2) {
                vm.warp(block.timestamp + 168 * H);
                bm.finalizePayout(id);
            } else {
                if (i > 0) vm.warp(block.timestamp + 24 * H + 1);
                vm.prank(arbiter);
                try bm.resolveDispute(id, BondMarkBase.Verdict(verdicts[i]), bytes32("PARITY"), "parity", reviewed[i]) {} catch {
                    o.reverted = true;
                    break;
                }
            }
        }

        BondMarkBase.Deal memory d = bm.getDeal(id);
        BondMarkBase.SellerInfo memory s = bm.sellerInfo(seller);
        o.status = uint8(d.status);
        o.verdict = uint8(d.verdict);
        o.compensation = d.compensation;
        o.fee = d.fee;
        o.buyerClaimable = bm.claimable(buyer);
        o.sellerClaimable = bm.claimable(seller);
        o.treasury = bm.treasury();
        o.sellerBond = s.bond;
        o.sellerLocked = s.locked;
        o.lost = s.disputesLost;
        o.split = s.disputesSplit;
        o.won = s.disputesWon;
        o.inconclusive = s.inconclusive;
    }
}
