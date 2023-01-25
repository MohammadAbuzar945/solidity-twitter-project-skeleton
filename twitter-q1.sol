// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Twitter {
    // ----- START OF DO-NOT-EDIT ----- //
    struct Tweet {
        uint256 tweetId;
        address author;
        string content;
        uint256 createdAt;
    }
    struct User {
        address wallet;
        string name;
        uint256[] userTweets;
    }
    mapping(address => User) public users;
    mapping(uint256 => Tweet) public tweets;
    uint256 public nextTweetId;

    // ----- END OF DO-NOT-EDIT ----- //
    function registerAccount(string calldata _name) external {
        require(bytes(_name).length != 0, "Name cannot be an empty string");
        User storage user = users[msg.sender];
        user.wallet = msg.sender;
        user.name = _name;
    }

    function postTweet(string calldata _content)
        external
        accountExists(msg.sender)
    {
        User storage user = users[msg.sender];
        Tweet storage tweet = tweets[nextTweetId];
        tweet.tweetId = nextTweetId;
        tweet.author = msg.sender;
        tweet.content = _content;
        tweet.createdAt = block.timestamp;
        user.userTweets.push(nextTweetId);
        nextTweetId++;
    }

    function readTweets(address _user) external view returns (Tweet[] memory) {
        User storage user = users[_user];
        uint256[] storage userTweetIds = user.userTweets;
        Tweet[] memory userTweets = new Tweet[](userTweetIds.length);
        for (uint256 i = 0; i < userTweetIds.length; i++) {
            userTweets[i] = tweets[userTweetIds[i]];
        }
        return userTweets;
    }

    modifier accountExists(address _user) {
        require(
            users[_user].wallet != address(0),
            "This wallet does not belong to any account."
        );
        _;
    }
}
