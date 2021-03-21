//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import "./KingKongUtils.sol";

contract KingKong is KingKongUtils {

	uint256 public constant membershipFee = 1 ether;

	constructor(address firstMember) KingKongUtils(firstMember) {
		addMember(firstMember, address(0)); // parent is address(0)
	}

	function join() payable external {
		require(msg.value == membershipFee, "insufficient payment.");
		require(isNotMember(), "already a member!");
		// multiple joins affect accounting so we guard against it 
		address parent = payMembershipAndUpdateStorage();
		// msg.sender is new member, points to parent
		addMember(msg.sender, parent); 
	}
	
	function getBalance(address member) external view returns(uint256) {
		return super._getBalance(member);
	}

	function withdraw(uint256 amount, address payable recipient) external {
		super._withdraw(amount, recipient);
	}
}
