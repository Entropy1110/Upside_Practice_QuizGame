// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    mapping(address => uint256)[] public bets;
    Quiz_item[] private quizzes;
    uint public vault_balance;

    constructor () {
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }

    function addQuiz(Quiz_item memory q) public {
        if (msg.sender == address(1)) {
            revert("You can't add a quiz");
        }
        
        for (uint i = 0; i < quizzes.length; i++) {
            require(quizzes[i].id != q.id, "Quiz id already exists");
        }
        bets.push();
        quizzes.push(q);
    }

    function getAnswer(uint quizId) public view returns (string memory){
        Quiz_item memory q = Quiz_item(0, "", "", 0, 0);
        for (uint i = 0; i < quizzes.length; i++) {
            if (quizzes[i].id == quizId) {
                q = quizzes[i];
                break;
            }
        }
        return q.answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory q = Quiz_item(0, "", "", 0, 0);
        for (uint i = 0; i < quizzes.length; i++) {
            if (quizzes[i].id == quizId) {
                q = quizzes[i];
                q.answer = "";
                break;
            }
        }
        return q;
    }

    function getQuizNum() public view returns (uint){
        return quizzes.length;
    }
    
    function betToPlay(uint quizId) public payable{
        Quiz_item memory q = Quiz_item(0, "", "", 0, 0);
        
        for (uint i = 0; i < quizzes.length; i++) {
            if (quizzes[i].id == quizId) {
                q = quizzes[i];
                require(msg.value >= q.min_bet && msg.value <= q.max_bet, "Invalid bet amount");
                
                bets[i][msg.sender] += msg.value;
                break;
            }
        }
        require(q.id != 0, "Quiz not found");
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        

        Quiz_item memory q = Quiz_item(0, "", "", 0, 0);
        uint i;
        for (i = 0; i < quizzes.length; i++) {
            if (quizzes[i].id == quizId) {
                q = quizzes[i];
                break;
            }
        }
        
        if (keccak256(abi.encodePacked(ans)) == keccak256(abi.encodePacked(getAnswer(quizId)))) {
            return true;
        }
        vault_balance += bets[i][msg.sender];
        bets[i][msg.sender] = 0;
    
        return false;
    }

    function claim() public {
        uint total = 0;
        
        for (uint i = 0; i < quizzes.length; i++) {
            total += bets[i][msg.sender];
            bets[i][msg.sender] = 0;
        }
        
        payable(msg.sender).call{value: total * 2}("");
        vault_balance -= total * 2;
    }

    fallback () external payable {
        vault_balance += msg.value;
    }

}
