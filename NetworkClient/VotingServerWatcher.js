const fs = require("fs")
const readline = require("readline")
const { io } = require("socket.io-client");

const rl = readline.createInterface({
	input: process.stdin,
	output: process.stdout,
});

rl.question("Please enter web socket url: ", url => {
	console.log("Awaiting server connection...")
	const socket = io(url);
	socket.once("connection established", () => {
		console.log("Connected to server!")

		socket.on("currentCommand", (...args) => {
			try {
				const command = args[0];
				if (!command.error) {
					fs.writeFile('janky_commands.txt', command.content, err => {
						if (err) throw err
						else console.log("Current Command: " + command.content)
					})
				} else {
					throw command.errorContent
				}

			} catch (error) {
				console.error(err)
			}
		});
	})
});