//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "./KingKongUtils.sol";

contract KingKong is KingKongUtils {
	using SafeMath for uint256;

	constructor(address firstMember) {
		address[2] memory noChildrenYet;
		members[firstMember] = Member(
			firstMember, 0, address(0), noChildrenYet);	
		rowB.push(firstMember);
		height = 1;
		usingRowB = true;
	}

	function join() payable external {
		require(msg.value == membershipFee, "insufficient payment.");
		require(members[msg.sender].memberAddress == address(0), "already a member!");
		// have not analyzed what can happen if member have multiple entries
		// so we restrict it so as not to allow pathologies
		address parent = getParentFromRow();
		// new member
		addMember(msg.sender, parent);
		payMembershipAndUpdateStorage(parent);
	}
	
	function getBalance(address member) external view returns(uint256) {
		return members[member].balance;
	}

	function withdraw(uint amount, address payable recipient) external {
		require(members[msg.sender].memberAddress != address(0), "not a member!");
		members[msg.sender].balance = 
			members[msg.sender].balance.sub(amount);
		(bool success,) = recipient.call{value: amount}("");
		require(success, "withdraw failed!");
	}
}
