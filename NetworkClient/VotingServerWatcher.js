const request = require('request-promise');
const fs = require("fs");

SERVER_DOMAIN = "http://localhost:8000";

async function getCurrentCommand() {
	if (new Date().getSeconds() == 1) {
		const command = JSON.parse(await request.get(SERVER_DOMAIN + "/currentCommand"));
		console.log(command)
		if (!command.error) {
			fs.writeFile('janky_commands.txt', command.content, err => {
				if (err) console.error(err)
				else console.log("Current Command: " + command.content)
			})
		} else {
			console.error(command.errorContent);
		}
	}
}

setInterval(getCurrentCommand, 1000);