// const { Client } = require('whatsapp-web.js');
// const qrcode = require('qrcode-terminal');
// const client = new Client();

// client.on('qr', (qr) => {
//     // Generate and scan this code with your phone
//     // console.log('QR RECEIVED', qr);
//     qrcode.generate(qr, { small: true });
// });

// client.on('ready', () => {
//     console.log('Client is ready!');
// });

// client.on('message', msg => {
//     console.log('MESSAGE RECEIVED', msg.body);

//     if (msg.body == 'hello') {
//         msg.reply('Hello, human!');
//     }
// });

// client.initialize();

const express = require("express");
const { Client } = require("whatsapp-web.js");
const http = require("http");

const app = express();
const client = new Client();
const server = http.createServer(app);
app.use(express.json());

let qrCode = "";
let messages = [];

client.on("qr", (qr) => {
  console.log("QR RECEIVED", qr);
  qrCode = qr;
});

client.on("message", (msg) => {
  console.log("MESSAGE RECEIVED", msg.body);
  messages.push({
    body: msg.body,
    from: msg.from,
    time: new Date(),
  });
  if (msg.body == "hello") {
    msg.reply("Hello, human!");
  }
});

app.get("/start-whatsapp", (req, res) => {
  client.initialize();
  res.send("WhatsApp client started");
});

app.get("/get-qr", (req, res) => {
  res.json({ qr: qrCode });
});

app.get("/get-messages", (req, res) => {
  res.json({ messages: messages });
  messages = []; // Clear the messages after sending to avoid sending them twice
});

app.post("/send-message", async (req, res) => {
  if (!req.body.num || !req.body.message) {
    return res.status(400).send("Missing number or message in the request");
  }

  try {
    const number = req.body.num;
    const message = req.body.message;
    await client.sendMessage(`${number}@c.us`, message);
    res.send("Message sent");
  } catch (error) {
    console.error(error);
    res.status(500).send("An error occurred while sending the message.");
  }
});

server.listen(3000, () => {
  console.log("Server running on port 3000");
});
