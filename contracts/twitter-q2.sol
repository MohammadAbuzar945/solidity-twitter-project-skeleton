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

    struct Message {
        uint256 messageId;
        string content;
        address from;
        address to;
    }

    struct User {
        address wallet;
        string name;
        uint256[] userTweets;
        address[] following;
        address[] followers;
        mapping(address => Message[]) conversations;
    }

    mapping(address => User) public users;
    mapping(uint256 => Tweet) public tweets;

    uint256 public nextTweetId;
    uint256 public nextMessageId;

    // ----- END OF DO-NOT-EDIT ----- //

    // ----- START OF QUEST 1 ----- //
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

    // ----- END OF QUEST 1 ----- //

    // ----- START OF QUEST 2 ----- //

    function followUser(address _user) external {
        User storage user = users[msg.sender];
        user.following.push(_user);
        User storage userToFollow = users[_user];
        userToFollow.followers.push(msg.sender);
    }

    function getFollowing() external view returns (address[] memory) {
        User storage user = users[msg.sender];
        return user.following;
    }

    function getFollowers() external view returns (address[] memory) {
        User storage user = users[msg.sender];
        return user.followers;
    }

    function getTweetFeed() external view returns (Tweet[] memory) {
        users[msg.sender];
        Tweet[] memory userTweets = new Tweet[](nextTweetId);
        for (uint256 i = 0; i < nextTweetId; i++) {
            userTweets[i] = tweets[i];
        }
        return userTweets;
    }

    function sendMessage(address _to, string calldata _content)
        external
        accountExists(_to)
    {
        User storage user = users[msg.sender];
        User storage recipent = users[_to];
        Message memory message;
        message.messageId = nextMessageId;
        message.content = _content;
        message.from = msg.sender;
        message.to = _to;
        user.conversations[_to].push(message);
        recipent.conversations[msg.sender].push(message);

        nextMessageId++;
    }

    function getConversationWithUser(address _user)
        external
        view
        accountExists(_user)
        returns (Message[] memory)
    {
        User storage user = users[msg.sender];
        return user.conversations[_user];
    }
}
