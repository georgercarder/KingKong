//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

contract KingKongUtils {

	uint256 public testWall; // TODO DELETE
	
	uint256 public constant membershipFee = 1 ether;
	mapping (address => Member) internal members;
	uint256 internal height;
	address[] internal rowA;
	address[] internal rowB;
	bool internal usingRowB;

	struct Member {
		address memberAddress;
		uint256 balance;
		address parent;
		address[2] children;
	}


	function payMembershipAndUpdateStorage(address parent) internal {
		Member[] memory lineage = fillLineage(parent);
		// pay membership
		payMembership(msg.value, lineage);

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

	function payMembership(
		uint256 payment, Member[] memory lineage) internal {
		bool ok = true;
		for (uint256 i = lineage.length-1; ok; i--) {
			payment /= 2; // should not need safemath
			members[lineage[i].memberAddress].balance += payment;
			// should not need safemath because of scarcity of ether	
			if (i==0) {
				ok = !ok; //hack for reverse for-loop
			}
		}
	}

	function fillLineage(
		address parent
	) internal view returns(Member[] memory) {
		bool filling = true;
		Member memory member;
		Member[] memory lineage = new Member[](height);
		uint256 idx;
		while (filling) {
			member = members[parent];
			lineage[idx] = member;
			idx++;
			if (member.parent == address(0)) {
				filling = false;
			}
		}
		return lineage;
	}

	function getParentFromRow() internal returns(address) {
		address parent;
		if (usingRowB) {
			parent = rowB[rowB.length-1];	
			rowB.pop();
			return parent;
		}
		parent = rowA[rowB.length-1];	
		rowA.pop();
		return parent;
	}

	function putParentBackInRow(address parent) internal {
		if (usingRowB) {
			rowB.push(parent);
			return;
		}
		rowA.push(parent);	
	}

	function updateActiveRow() internal {
		if (usingRowB) {
			if (rowB.length == 0) {
				usingRowB = !usingRowB;
				height++;
			}
			return;
		}
		if (rowA.length == 0) {
			usingRowB = !usingRowB;
			height++;
		}
	}

	function putNewMemberInRow(address member) internal {
		// recall that the new member is put in the inactive row
		if (usingRowB) {
			rowA.push(member);
			return;
		}
		rowB.push(member);
	}

	function addMember(address member, address parent) internal {
		// this is checked in that 
		// member is msg.sender and parent is necessarily nontrivial
		address[2] memory noChildrenYet;
		members[member] = Member(
			member, 0, parent, noChildrenYet);	
	}
}
