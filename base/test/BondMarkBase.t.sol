// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/BondMarkBase.sol";

contract BondMarkBaseTest is Test {
    BondMarkBase bm;
    address owner = makeAddr("owner");
    address arbiter = makeAddr("arbiter");
    address seller = makeAddr("seller");
    address buyer = makeAddr("buyer");
    address stranger = makeAddr("stranger");
    uint256 constant U = 0.001 ether;
    uint256 constant H = 3600;

    function setUp() public {
        vm.prank(owner);
        bm = new BondMarkBase(arbiter, H);
        vm.deal(seller, 10 ether);
        vm.deal(buyer, 10 ether);
        vm.deal(stranger, 10 ether);
    }

    function _register(uint256 bond) internal {
        vm.prank(seller);
        bm.registerSeller{value: bond}("shop_one");
    }

    function _deal(uint256 protect) internal returns (uint256 id) {
        vm.prank(seller);
        id = bm.createDeal("Red handbag", "40 USD", "https://example.com/p/1", protect, 48);
    }

    function _bound(uint256 protect) internal returns (uint256 id) {
        _register(20 * U);
        id = _deal(protect);
        vm.prank(buyer);
        bm.claimPayment{value: U}(id, "bank ref 123456");
        vm.prank(seller);
        bm.respondPayment(id, true, "");
    }

    function _delivered(uint256 protect) internal returns (uint256 id) {
        id = _bound(protect);
        vm.prank(seller);
        bm.submitDelivery(id, "shipped with tracking", "https://example.com/t/1");
    }

    function _disputed(uint256 protect) internal returns (uint256 id) {
        id = _delivered(protect);
        vm.prank(buyer);
        bm.openDispute{value: U}(id, "parcel never arrived at all", "");
    }

    function _accounting() internal view {
        uint256 total = bm.totalBonds() + bm.totalClaimable() + bm.treasury() + bm.burned() + bm.depositsHeld();
        assertEq(address(bm).balance, total);
    }

    function test_register_and_level() public {
        _register(20 * U);
        BondMarkBase.SellerInfo memory i = bm.sellerInfo(seller);
        assertEq(uint256(i.level), 1);
        assertEq(i.handle, "shop_one");
        assertEq(bm.sellerByHandle("shop_one"), seller);
        _accounting();
    }

    function test_register_rejects_bad_input() public {
        vm.prank(seller);
        vm.expectRevert("bond below minimum");
        bm.registerSeller{value: U}("shop_one");
        vm.prank(seller);
        vm.expectRevert("invalid handle");
        bm.registerSeller{value: 6 * U}("Bad Handle");
        _register(6 * U);
        vm.prank(stranger);
        vm.expectRevert("handle taken");
        bm.registerSeller{value: 6 * U}("shop_one");
    }

    function test_create_locks_bond_and_caps() public {
        _register(20 * U);
        _deal(4 * U);
        assertEq(bm.sellerInfo(seller).locked, 6 * U);
        vm.prank(seller);
        vm.expectRevert("protect above level cap");
        bm.createDeal("Another item", "1", "", 11 * U, 5);
        vm.prank(seller);
        vm.expectRevert("bad url");
        bm.createDeal("Another item", "1", "http://x.com", 2 * U, 5);
        vm.prank(seller);
        vm.expectRevert("bad url");
        bm.createDeal("Another item", "1", "https://user:pw@x.com/a", 2 * U, 5);
    }

    function test_happy_path() public {
        uint256 id = _delivered(4 * U);
        vm.prank(buyer);
        bm.confirmDelivery(id);
        BondMarkBase.SellerInfo memory i = bm.sellerInfo(seller);
        assertEq(uint256(i.completedVerified), 1);
        assertEq(i.locked, 0);
        assertGt(i.score, 500);
        _accounting();
    }

    function test_reject_reopens_offer() public {
        _register(20 * U);
        uint256 id = _deal(4 * U);
        vm.prank(buyer);
        bm.claimPayment{value: U}(id, "bank ref 123456");
        vm.prank(seller);
        bm.respondPayment(id, false, "no money received");
        BondMarkBase.Deal memory d = bm.getDeal(id);
        assertEq(uint256(d.status), uint256(BondMarkBase.Status.OPEN));
        assertEq(d.buyer, address(0));
        assertEq(uint256(bm.sellerInfo(seller).rejectedClaims), 1);
    }

    function test_timeout_binding() public {
        _register(20 * U);
        uint256 id = _deal(4 * U);
        vm.prank(buyer);
        bm.claimPayment{value: U}(id, "bank ref 123456");
        vm.prank(stranger);
        vm.expectRevert("seller still has time");
        bm.bindByTimeout(id);
        vm.warp(block.timestamp + 24 * H);
        vm.prank(stranger);
        bm.bindByTimeout(id);
        assertEq(uint256(bm.getDeal(id).status), uint256(BondMarkBase.Status.ACTIVE));
    }

    function test_auto_finalize_and_lapse() public {
        uint256 id = _delivered(4 * U);
        vm.expectRevert("review window open");
        bm.finalizeDeal(id);
        vm.warp(block.timestamp + 72 * H + 1);
        bm.finalizeDeal(id);
        assertEq(uint256(bm.sellerInfo(seller).completedAuto), 1);
    }

    function test_lapsed_when_nobody_acts() public {
        uint256 id = _bound(4 * U);
        vm.warp(block.timestamp + 48 * H + 72 * H + 1);
        bm.finalizeDeal(id);
        BondMarkBase.SellerInfo memory i = bm.sellerInfo(seller);
        assertEq(uint256(i.lapsed), 1);
        assertEq(i.locked, 0);
    }

    function test_buyer_wins_pays_from_bond() public {
        uint256 id = _disputed(4 * U);
        vm.prank(seller);
        bm.submitEvidence(id, "I posted it yesterday", "https://example.com/t/1");
        vm.prank(arbiter);
        vm.expectRevert("evidence window open");
        bm.resolveDispute(id, BondMarkBase.Verdict.BUYER_WINS, bytes32("NO_DELIVERY_PROOF"), "none", true);
        vm.warp(block.timestamp + 48 * H + 1);
        vm.prank(stranger);
        vm.expectRevert("only arbiter");
        bm.resolveDispute(id, BondMarkBase.Verdict.BUYER_WINS, bytes32("X"), "x", true);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.BUYER_WINS, bytes32("NO_DELIVERY_PROOF"), "none", true);
        uint256 fee = (4 * U * 500) / 10000;
        assertEq(bm.claimable(buyer), 4 * U + U + U);
        assertEq(bm.treasury(), fee);
        assertEq(bm.sellerInfo(seller).bond, 20 * U - 4 * U - fee);
        assertEq(bm.sellerInfo(seller).locked, 0);
        _accounting();
        uint256 before = buyer.balance;
        vm.prank(buyer);
        bm.claim();
        assertEq(buyer.balance, before + 6 * U);
        vm.prank(owner);
        bm.collectFees();
        vm.prank(owner);
        bm.claim();
        _accounting();
    }

    function test_seller_wins_gets_deposit() public {
        uint256 id = _disputed(4 * U);
        vm.warp(block.timestamp + 48 * H + 1);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.SELLER_WINS, bytes32("DELIVERY_PROOF_CREDIBLE"), "ok", true);
        assertEq(bm.claimable(seller), 2 * U);
        assertEq(bm.claimable(buyer), 0);
        assertEq(uint256(bm.sellerInfo(seller).disputesWon), 1);
        _accounting();
    }

    function test_split() public {
        uint256 id = _disputed(4 * U);
        vm.warp(block.timestamp + 48 * H + 1);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.SPLIT, bytes32("PARTIAL_OR_MISMATCH"), "half", true);
        assertEq(bm.getDeal(id).compensation, 2 * U);
        assertEq(bm.claimable(buyer), 4 * U);
        _accounting();
    }

    function test_insufficient_reopens_then_inconclusive() public {
        uint256 id = _disputed(4 * U);
        vm.warp(block.timestamp + 48 * H + 1);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.INSUFFICIENT_EVIDENCE, bytes32("NO_SUBSTANTIVE_EVIDENCE"), "thin", true);
        assertEq(uint256(bm.getDeal(id).status), uint256(BondMarkBase.Status.REOPENED));
        vm.warp(block.timestamp + 24 * H + 1);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.INSUFFICIENT_EVIDENCE, bytes32("NO_SUBSTANTIVE_EVIDENCE"), "thin", true);
        assertEq(bm.getDeal(id).compensation, 0);
        assertEq(bm.claimable(buyer), 2 * U);
        assertEq(bm.sellerInfo(seller).locked, 0);
        _accounting();
    }

    function test_arbiter_timeout_is_inconclusive() public {
        uint256 id = _disputed(4 * U);
        vm.warp(block.timestamp + 48 * H + 1);
        vm.expectRevert("arbiter still has time");
        bm.resolveTimeout(id);
        vm.warp(block.timestamp + 168 * H + 1);
        bm.resolveTimeout(id);
        assertEq(bm.getDeal(id).compensation, 0);
        assertEq(bm.claimable(buyer), 2 * U);
        _accounting();
    }

    function test_dispute_guards() public {
        uint256 id = _bound(4 * U);
        vm.prank(buyer);
        vm.expectRevert("not disputable now");
        bm.openDispute{value: U}(id, "too early to complain", "");
        vm.warp(block.timestamp + 48 * H + 1);
        vm.prank(stranger);
        vm.expectRevert("only buyer");
        bm.openDispute{value: U}(id, "not my deal at all", "");
        vm.prank(buyer);
        vm.expectRevert("wrong deposit");
        bm.openDispute{value: U / 2}(id, "claim text long enough", "");
        vm.prank(buyer);
        vm.expectRevert("wrong deposit");
        bm.openDispute{value: 2 * U}(id, "claim text long enough", "");
        vm.prank(buyer);
        bm.openDispute{value: U}(id, "claim text long enough", "");
        _accounting();
    }

    function test_evidence_limit() public {
        uint256 id = _disputed(4 * U);
        vm.startPrank(buyer);
        bm.submitEvidence(id, "second piece of proof", "");
        bm.submitEvidence(id, "third piece of proof", "");
        vm.expectRevert("evidence limit");
        bm.submitEvidence(id, "fourth piece of proof", "");
        vm.stopPrank();
        assertEq(bm.getEvidence(id).length, 3);
        vm.prank(stranger);
        vm.expectRevert("only parties");
        bm.submitEvidence(id, "outsider text here", "");
    }

    function test_pair_credit_limit() public {
        _register(50 * U);
        for (uint256 k = 0; k < 5; k++) {
            vm.prank(seller);
            uint256 id = bm.createDeal("Red handbag", "40 USD", "", 2 * U, 5);
            vm.prank(buyer);
            bm.claimPayment{value: U}(id, "bank ref 123456");
            vm.prank(seller);
            bm.respondPayment(id, true, "");
            vm.prank(seller);
            bm.submitDelivery(id, "shipped ok", "");
            vm.prank(buyer);
            bm.confirmDelivery(id);
        }
        BondMarkBase.SellerInfo memory i = bm.sellerInfo(seller);
        assertEq(uint256(i.completedVerified), 3);
        assertFalse(i.trusted);
    }

    function test_withdraw_limited_by_lock() public {
        _register(20 * U);
        _deal(4 * U);
        vm.prank(seller);
        vm.expectRevert("exceeds free bond");
        bm.withdrawBond(15 * U);
        vm.prank(seller);
        bm.withdrawBond(14 * U);
        vm.prank(seller);
        bm.claim();
        _accounting();
    }

    function test_only_owner_can_propose_arbiter() public {
        vm.prank(stranger);
        vm.expectRevert("only owner");
        bm.proposeArbiter(stranger);
        vm.prank(owner);
        bm.proposeArbiter(stranger);
        assertEq(bm.arbiter(), arbiter);
        assertEq(bm.pendingArbiter(), stranger);
    }

    function test_arbiter_change_is_timelocked() public {
        address other = makeAddr("other_arbiter");
        vm.prank(owner);
        bm.proposeArbiter(other);
        vm.expectRevert("change is still locked");
        bm.applyArbiterChange();
        vm.warp(block.timestamp + 168 * H);
        bm.applyArbiterChange();
        assertEq(bm.arbiter(), other);
        assertEq(bm.pendingArbiter(), address(0));
    }

    function test_arbiter_proposal_can_be_cancelled() public {
        vm.prank(owner);
        bm.proposeArbiter(stranger);
        vm.prank(owner);
        bm.cancelArbiterChange();
        vm.warp(block.timestamp + 168 * H);
        vm.expectRevert("nothing proposed");
        bm.applyArbiterChange();
    }

    function test_arbiter_change_does_not_affect_open_dispute() public {
        uint256 id = _disputed(4 * U);
        address other = makeAddr("other_arbiter");
        vm.prank(owner);
        bm.proposeArbiter(other);
        vm.warp(block.timestamp + 168 * H);
        bm.applyArbiterChange();
        assertEq(bm.arbiter(), other);
        vm.prank(other);
        vm.expectRevert("only arbiter");
        bm.resolveDispute(id, BondMarkBase.Verdict.BUYER_WINS, bytes32("X"), "x", true);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.SELLER_WINS, bytes32("DELIVERY_PROOF_CREDIBLE"), "ok", true);
        _accounting();
    }

    function test_rejected_buyer_cannot_reclaim() public {
        _register(20 * U);
        uint256 id = _deal(4 * U);
        vm.prank(buyer);
        bm.claimPayment{value: U}(id, "bank ref 123456");
        vm.prank(seller);
        bm.respondPayment(id, false, "no money received");
        vm.prank(buyer);
        vm.expectRevert("claim was rejected");
        bm.claimPayment{value: U}(id, "bank ref 654321");
        vm.prank(stranger);
        bm.claimPayment{value: U}(id, "bank ref 777777");
    }

    function test_reopen_allows_more_evidence() public {
        uint256 id = _disputed(4 * U);
        vm.startPrank(buyer);
        bm.submitEvidence(id, "second piece of proof", "");
        bm.submitEvidence(id, "third piece of proof", "");
        vm.stopPrank();
        vm.warp(block.timestamp + 48 * H + 1);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.INSUFFICIENT_EVIDENCE, bytes32("NO_SUBSTANTIVE_EVIDENCE"), "thin", true);
        vm.startPrank(buyer);
        bm.submitEvidence(id, "fourth piece of proof", "");
        bm.submitEvidence(id, "fifth piece of proof", "");
        vm.expectRevert("evidence limit");
        bm.submitEvidence(id, "sixth piece of proof", "");
        vm.stopPrank();
    }

    function test_trusted_needs_buyer_confirmed_deals() public {
        _register(50 * U);
        for (uint256 k = 0; k < 5; k++) {
            address b = makeAddr(string(abi.encodePacked("buyer", vm.toString(k))));
            vm.deal(b, 10 ether);
            vm.prank(seller);
            uint256 id = bm.createDeal("Red handbag", "40 USD", "", 2 * U, 5);
            vm.prank(b);
            bm.claimPayment{value: U}(id, "bank ref 123456");
            vm.prank(seller);
            bm.respondPayment(id, true, "");
            vm.prank(seller);
            bm.submitDelivery(id, "shipped ok", "");
            vm.warp(block.timestamp + 72 * H + 1);
            bm.finalizeDeal(id);
        }
        BondMarkBase.SellerInfo memory i = bm.sellerInfo(seller);
        assertEq(uint256(i.completedAuto), 5);
        assertFalse(i.trusted);
    }

    function test_rejection_does_not_lower_score() public {
        _register(20 * U);
        uint256 before = bm.sellerScore(seller);
        uint256 id = _deal(4 * U);
        vm.prank(buyer);
        bm.claimPayment{value: U}(id, "bank ref 123456");
        vm.prank(seller);
        bm.respondPayment(id, false, "no money received");
        assertEq(bm.sellerScore(seller), before);
    }

    function test_bad_unit_rejected() public {
        vm.expectRevert("bad unit");
        new BondMarkBase(arbiter, 86401);
    }

    function _timeoutDisputed(uint256 protect) internal returns (uint256 id) {
        _register(20 * U);
        id = _deal(protect);
        vm.prank(buyer);
        bm.claimPayment{value: U}(id, "bank ref 123456");
        vm.warp(block.timestamp + 24 * H);
        bm.bindByTimeout(id);
        vm.warp(block.timestamp + 48 * H + 1);
        vm.prank(buyer);
        bm.openDispute{value: U}(id, "nothing was ever sent", "");
        vm.warp(block.timestamp + 48 * H + 1);
    }

    function test_timeout_deal_buyer_win_is_capped_at_25_percent() public {
        uint256 id = _timeoutDisputed(4 * U);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.BUYER_WINS, bytes32("NO_DELIVERY_PROOF"), "x", true);
        assertEq(uint256(bm.getDeal(id).status), uint256(BondMarkBase.Status.PAYOUT_PENDING));
        vm.expectRevert("payout is still locked");
        bm.finalizePayout(id);
        vm.warp(block.timestamp + 168 * H);
        bm.finalizePayout(id);
        BondMarkBase.Deal memory d = bm.getDeal(id);
        assertEq(d.compensation, U);
        assertTrue(d.paymentEvidenceReviewed);
        assertEq(bm.claimable(buyer), 3 * U);
        _accounting();
    }

    function test_timeout_deal_split_is_capped_at_25_percent() public {
        uint256 id = _timeoutDisputed(4 * U);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.SPLIT, bytes32("PARTIAL_OR_MISMATCH"), "x", true);
        vm.warp(block.timestamp + 168 * H);
        bm.finalizePayout(id);
        assertEq(bm.getDeal(id).compensation, U);
        _accounting();
    }

    function test_timeout_deal_needs_review_flag_for_compensation() public {
        uint256 id = _timeoutDisputed(4 * U);
        vm.prank(arbiter);
        vm.expectRevert("payment evidence not reviewed");
        bm.resolveDispute(id, BondMarkBase.Verdict.BUYER_WINS, bytes32("NO_DELIVERY_PROOF"), "x", false);
        vm.prank(arbiter);
        vm.expectRevert("payment evidence not reviewed");
        bm.resolveDispute(id, BondMarkBase.Verdict.SPLIT, bytes32("PARTIAL_OR_MISMATCH"), "x", false);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.SELLER_WINS, bytes32("BUYER_CLAIM_UNSUPPORTED"), "x", false);
        assertEq(bm.getDeal(id).compensation, 0);
        _accounting();
    }

    function test_timeout_deal_arbiter_cannot_exceed_cap_even_if_flagged() public {
        uint256 id = _timeoutDisputed(10 * U);
        uint256 bondBefore = bm.sellerInfo(seller).bond;
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.BUYER_WINS, bytes32("NO_DELIVERY_PROOF"), "x", true);
        vm.warp(block.timestamp + 168 * H);
        bm.finalizePayout(id);
        uint256 comp = (10 * U * 2500) / 10000;
        uint256 fee = (comp * 500) / 10000;
        assertEq(bondBefore - bm.sellerInfo(seller).bond, comp + fee);
    }

    function test_timeout_deal_inconclusive_needs_no_flag() public {
        uint256 id = _timeoutDisputed(4 * U);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.INSUFFICIENT_EVIDENCE, bytes32("NO_SUBSTANTIVE_EVIDENCE"), "x", false);
        assertEq(uint256(bm.getDeal(id).status), uint256(BondMarkBase.Status.REOPENED));
    }

    function test_claim_deposit_must_be_exact() public {
        _register(20 * U);
        uint256 id = _deal(4 * U);
        vm.prank(buyer);
        vm.expectRevert("wrong deposit");
        bm.claimPayment{value: U / 2}(id, "bank ref 123456");
        vm.prank(buyer);
        vm.expectRevert("wrong deposit");
        bm.claimPayment{value: 2 * U}(id, "bank ref 123456");
    }

    function test_rejected_claim_deposit_is_burned() public {
        _register(20 * U);
        uint256 id = _deal(4 * U);
        vm.prank(buyer);
        bm.claimPayment{value: U}(id, "bank ref 123456");
        vm.prank(seller);
        bm.respondPayment(id, false, "no money received");
        assertEq(bm.burned(), U);
        assertEq(bm.treasury(), 0);
        assertEq(bm.claimable(seller), 0);
        assertEq(bm.getDeal(id).claimDeposit, 0);
        _accounting();
    }

    function test_claim_deposit_returned_on_completion() public {
        uint256 id = _delivered(4 * U);
        vm.prank(buyer);
        bm.confirmDelivery(id);
        assertEq(bm.claimable(buyer), U);
        _accounting();
    }

    function test_seller_can_challenge_pending_payout() public {
        uint256 id = _timeoutDisputed(4 * U);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.BUYER_WINS, bytes32("NO_DELIVERY_PROOF"), "x", true);
        vm.prank(stranger);
        vm.expectRevert("only seller");
        bm.challengePayout(id, "I never saw this payment", "");
        vm.prank(seller);
        bm.challengePayout(id, "My bank shows no incoming transfer", "https://example.com/stmt");
        assertEq(uint256(bm.getDeal(id).status), uint256(BondMarkBase.Status.CHALLENGED));
        vm.warp(block.timestamp + 24 * H + 1);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.SELLER_WINS, bytes32("BUYER_CLAIM_UNSUPPORTED"), "x", false);
        assertEq(bm.getDeal(id).compensation, 0);
        assertEq(bm.claimable(seller), 2 * U);
        assertEq(bm.claimable(buyer), 0);
        _accounting();
    }

    function test_challenge_window_closes() public {
        uint256 id = _timeoutDisputed(4 * U);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.BUYER_WINS, bytes32("NO_DELIVERY_PROOF"), "x", true);
        vm.warp(block.timestamp + 168 * H);
        vm.prank(seller);
        vm.expectRevert("challenge window closed");
        bm.challengePayout(id, "too late to object", "");
    }

    function test_challenged_ruling_pays_immediately_and_stays_capped() public {
        uint256 id = _timeoutDisputed(4 * U);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.BUYER_WINS, bytes32("NO_DELIVERY_PROOF"), "x", true);
        vm.prank(seller);
        bm.challengePayout(id, "My bank shows no incoming transfer", "");
        vm.warp(block.timestamp + 24 * H + 1);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.BUYER_WINS, bytes32("NO_DELIVERY_PROOF"), "x", true);
        assertEq(uint256(bm.getDeal(id).status), uint256(BondMarkBase.Status.RESOLVED));
        assertEq(bm.getDeal(id).compensation, U);
        _accounting();
    }

    function test_trusted_needs_age_and_unique_buyers() public {
        _register(50 * U);
        for (uint256 k = 0; k < 6; k++) {
            address b = makeAddr(string(abi.encodePacked("rep", vm.toString(k % 2))));
            vm.deal(b, 100 ether);
            vm.prank(seller);
            uint256 id = bm.createDeal("Red handbag", "40 USD", "", 2 * U, 5);
            vm.prank(b);
            bm.claimPayment{value: U}(id, "bank ref 123456");
            vm.prank(seller);
            bm.respondPayment(id, true, "");
            vm.prank(seller);
            bm.submitDelivery(id, "shipped ok", "");
            vm.prank(b);
            bm.confirmDelivery(id);
        }
        vm.warp(block.timestamp + 340 * H);
        BondMarkBase.SellerInfo memory i = bm.sellerInfo(seller);
        assertEq(uint256(i.completedVerified), 6);
        assertEq(uint256(i.uniqueBuyers), 2);
        assertFalse(i.trusted);
    }

    function test_seller_can_challenge_after_using_all_evidence_slots() public {
        uint256 id = _timeoutDisputed(4 * U);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.INSUFFICIENT_EVIDENCE, bytes32("NO_SUBSTANTIVE_EVIDENCE"), "x", false);
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(seller);
            bm.submitEvidence(id, "seller evidence text", "");
        }
        vm.warp(block.timestamp + 24 * H + 1);
        vm.prank(arbiter);
        bm.resolveDispute(id, BondMarkBase.Verdict.BUYER_WINS, bytes32("NO_DELIVERY_PROOF"), "x", true);
        vm.prank(seller);
        bm.challengePayout(id, "My bank shows no incoming transfer", "");
        assertEq(uint256(bm.getDeal(id).status), uint256(BondMarkBase.Status.CHALLENGED));
        vm.prank(buyer);
        bm.submitEvidence(id, "buyer reply to the challenge", "");
        vm.prank(seller);
        bm.submitEvidence(id, "seller follow-up after challenge", "");
        _accounting();
    }
}
