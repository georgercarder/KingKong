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
		address parent = getParentFromRow();
		Member[] memory lineage = fillLineage(parent);
		// pay membership
		payMembership(msg.value, lineage);
		// new member
		addMember(msg.sender, parent);

		// accounting of rows
		Member storage parentAsMember = members[parent];
		if (parentAsMember.children[0] == address(0)) {
			parentAsMember.children[0] = msg.sender;	
			putParentBackInRow(parent);
		} else {
			parentAsMember.children[1] = msg.sender;	
		}
		updateActiveRow();
		putNewMemberInRow(msg.sender);
	}

	function withdraw(uint amount, address payable recipient) external {
		require(members[msg.sender].memberAddress != address(0), "not a member!");
		members[msg.sender].balance = 
			members[msg.sender].balance.sub(amount);
		(bool success,) = recipient.call{value: amount}("");
		require(success, "withdraw failed!");
	}
}
