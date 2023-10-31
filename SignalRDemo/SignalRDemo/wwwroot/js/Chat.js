"use strict";

var connection = new signalR.HubConnectionBuilder().withUrl("/chatHub").build();

// Disable the send button until the connection is established.
document.getElementById("sendButton").disabled = true;




// Event listener for user typing
document.getElementById("messageInput").addEventListener("input", function (event) {
    var user = document.getElementById("userInput").value;
    var isTyping = event.target.value.trim() !== ""; // Check if the input field is not empty
    connection.invoke("SendTypingStatus", user, isTyping).catch(function (err) {
        return console.error(err.toString());
    });
});

connection.on("ReceiveMessage", function (user, message) {
    var listItem = document.createElement("li");
    listItem.textContent = `${user} says ${message}`;
    document.getElementById("messagesList").appendChild(listItem);
});

connection.on('ReceiveTypingStatus', (user, isTyping) => {
    const messagesList = document.getElementById('messagesList');
    const typingStatus = `${user} is typing....`;

    if (isTyping) {
        //Display typing status
        const typingItem = document.createElement('li');
        typingItem.textContent = typingStatus;
        messagesList.appendChild(typingItem);
    } else {
        //  Remove typing status
        const items = messagesList.getElementsByTagName('li');
        for (let i = 0; i < items.length; i++) {
            if (items[i].textContent === typingStatus) {
                items[i].remove();
            }
        }
    }
})

connection.start().then(function () {
    document.getElementById("sendButton").disabled = false;
}).catch(function (err) {
    return console.error(err.toString());
});

document.getElementById("sendButton").addEventListener("click", function (event) {
    var user = document.getElementById("userInput").value;
    var message = document.getElementById("messageInput").value;
    connection.invoke("SendMessage", user, message).catch(function (err) {
        return console.error(err.toString());
    });
    document.getElementById("messageInput").value = "";
    event.preventDefault();
});