//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

contract KingKongUtils {

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

	function payMembershipAndUpdateStorage() internal returns(address) {
		address parent = getParentFromRow();
		Member[] memory lineage = fillLineage(parent);
		payMembership(lineage);
		putNewMemberAsChild(parent);
		putNewMemberInRow();
		updateActiveRow();
		return parent;
	}

	function payMembership(Member[] memory lineage) private {
		bool ok = true;
		uint256 totalPayment = msg.value;
		uint256 payment = totalPayment;
		uint256 paid;
		for (uint256 i = lineage.length-1; ok; i--) {
			payment /= 2; // should not need safemath
			members[lineage[i].memberAddress].balance += payment;
			paid += payment;
			// should not need safemath because of scarcity of ether
			if (i==0) {
				ok = !ok; //hack for reverse for-loop
			}
		}
		uint256 remaining = totalPayment - paid; // won't underflow
		// parent gets a bonus
		members[lineage[0].memberAddress].balance += remaining;
		// unchecked but in KingKong will always be defined
	}

	function fillLineage(
		address parent
	) private view returns(Member[] memory) {
		bool filling = true;
		Member memory member;
		Member[] memory lineage = new Member[](height);
		uint256 idx;
		while (filling) {
			member = members[parent];
			lineage[idx] = member;
			// unchecked but as used in KingKong,
			// the height bounds the lineage
			idx++;
			if (member.parent == address(0)) {
				filling = false;
			} else {
				parent = member.parent;
			}
		}
		return lineage;
	}

	function getParentFromRow() private returns(address) {
		// unchecked but as used in KingKong, rows should
		// not have to be checked
		address parent;
		if (usingRowB) {
			parent = rowB[rowB.length-1];	
			rowB.pop();
			return parent;
		}
		parent = rowA[rowA.length-1];	
		rowA.pop();
		return parent;
	}

	function putParentBackInRow(address parent) private {
		if (usingRowB) {
			rowB.push(parent);
			return;
		}
		rowA.push(parent);	
	}

	function updateActiveRow() private {
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

	function putNewMemberAsChild(address parent) private {
		address newMember = msg.sender;
		Member storage parentAsMember = members[parent];
		if (parentAsMember.children[0] == address(0)) {
			parentAsMember.children[0] = newMember;	
			putParentBackInRow(parent);
		} else {
			parentAsMember.children[1] = newMember;	
		}
	}

	function putNewMemberInRow() private {
		// recall that the new member is put in the inactive row
		address member = msg.sender;
		if (usingRowB) {
			rowA.push(member);
			return;
		}
		rowB.push(member);
	}

	function addMember(address parent) internal {
		// this is checked in that 
		// parent is necessarily nontrivial in KingKong
		address member = msg.sender;
		address[2] memory noChildrenYet;
		members[member] = Member(
			member, 0, parent, noChildrenYet);	
	}
}
