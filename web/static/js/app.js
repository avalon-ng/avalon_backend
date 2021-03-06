// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
import { createSocket } from "./socket"

let socket;

document.getElementById('anonymousButton').addEventListener('click', () => {
	socket = createSocket();
})

document.getElementById('submitUserButton').addEventListener('click', () => {
	socket.sendMessageToUser({ 
		id : document.getElementById('idInput').value,
		message : document.getElementById('messageInput').value
	})
})

document.getElementById('submitRoomButton').addEventListener('click', () => {
	socket.sendMessageToRoom({ 
		message : document.getElementById('messageInput').value
	})
})

document.getElementById('createButton').addEventListener('click', () => {
	socket.createRoom();
})

document.getElementById('joinButton').addEventListener('click', () => {
	socket.joinRoom({
		number : document.getElementById('numberInput').value
	})
})

document.getElementById('watchButton').addEventListener('click', () => {
	socket.watchRoom({
		number : document.getElementById('numberInput').value
	})
})

document.getElementById('leaveButton').addEventListener('click', () => {
	socket.leaveRoom();
})

document.getElementById('startButton').addEventListener('click', () => {
	socket.startGame();
})