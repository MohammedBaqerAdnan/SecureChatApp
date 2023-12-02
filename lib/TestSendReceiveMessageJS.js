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

/////////////////////////////////////////////////////////////// original code to handle single user /////////////////////////////////////////////////////////////////////

/*

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

*/

////////////////////////////////////////////////////////////// modified code with unique userId to handle multiple users /////////////////////////////////////////////////////////////////////

const express = require("express");
const { Client } = require("whatsapp-web.js");
const http = require("http");
const app = express();
const server = http.createServer(app);

app.use(express.json());

let clients = {};
let messages = {}; // New object to store messages

app.get("/start-whatsapp", (req, res) => {
  let userId = req.query.userId;
  if (!userId) {
    return res.status(400).send("Missing userId");
  }

  if (!clients[userId]) {
    // Check if client already exists
    clients[userId] = new Client();
    messages[userId] = []; // Initialize an empty array for messages for new user

    clients[userId].on("qr", (qr) => {
      console.log("QR RECEIVED", qr);
      clients[userId].qrCode = qr;
    });

    // Replace the following section with the provided code
    clients[userId].on("message", async (msg) => {
      console.log("MESSAGE RECEIVED", msg.body);

      if (msg.hasMedia) {
        const media = await msg.downloadMedia();

        // Convert media to base64
        const mediaBase64 = `data:${
          media.mimetype
        };base64,${media.data.toString("base64")}`;

        messages[userId].push({
          body: msg.body,
          from: msg.from,
          time: new Date(),
          media: mediaBase64,
        });
      } else {
        messages[userId].push({
          body: msg.body,
          from: msg.from,
          time: new Date(),
        });
      }

      if (msg.body === "hello") {
        msg.reply("Hello, human!");
      }
    });

    clients[userId].initialize();
  }

  res.send("WhatsApp client started");
});

app.get("/get-qr", (req, res) => {
  let userId = req.query.userId;
  let qrCode = clients[userId] ? clients[userId].qrCode : "";
  res.json({ qr: qrCode });
});

app.get("/get-messages", (req, res) => {
  let userId = req.query.userId;
  let userMessages = messages[userId] ? messages[userId] : [];
  res.json({ messages: userMessages });
  messages[userId] = []; // Clear the messages after they are fetched
});

app.post("/send-message", async (req, res) => {
  const userId = req.query.userId;
  const { num, message } = req.body;
  if (!userId || !num || !message) {
    returnres
      .status(400)
      .send("Missing unique userId, number or message in the request");
  }
  try {
    await clients[userId].sendMessage(`${num}@c.us`, message);
    res.send("Message sent");
  } catch (error) {
    console.error(error);
    res.status(500).send("An error occurred while sending the message.");
  }
});
app.get("/reset-whatsapp", (req, res) => {
  let userId = req.query.userId;
  if (!userId) {
    return res.status(400).send("Missing userId");
  }

  // Check if a client exists for the user
  if (clients[userId]) {
    // If a client exists, destroy it
    clients[userId].destroy();
    // Remove the client and its messages from the respective objects
    delete clients[userId];
    delete messages[userId];
  }

  res.send("WhatsApp client reset");
});

server.listen(3000, () => {
  console.log("Server running on port 3000");
});

/////////////////////////////////////////// modified code with unique userId to handle multiple users and add data persistence to store qr code and session data and add local authentication /////////////////////////////////////////////////////////////////////

/*
const express = require("express");
const { Client, LocalAuth } = require("whatsapp-web.js"); // Include LocalAuth
const http = require("http");
const app = express();
const server = http.createServer(app);

app.use(express.json());

let clients = {};
let messages = {}; // New object to store messages

app.get("/start-whatsapp", (req, res) => {
  let userId = req.query.userId;
  if (!userId) {
    return res.status(400).send("Missing userId");
  }
  clients[userId] = new Client({
    // Use LocalAuth strategy
    authStrategy: new LocalAuth(),
    // Specify the dataPath if you want, default is '.wwebjs_auth'
    // dataPath: 'path/to/your/data/directory'
  });
  messages[userId] = []; // Initialize an empty array for messages for new user
  clients[userId].on("qr", (qr) => {
    console.log("QR RECEIVED", qr);
    clients[userId].qrCode = qr;
  });

  clients[userId].on("message", (msg) => {
    console.log("MESSAGE RECEIVED", msg.body);

    messages[userId].push({
      // Push message to respective user's array in messages object
      body: msg.body,
      from: msg.from,
      time: new Date(),
    });

    if (msg.body === "hello") {
      msg.reply("Hello, human!");
    }
  });

  clients[userId].initialize();
  res.send("WhatsApp client started");
});

app.get("/get-qr", (req, res) => {
  let userId = req.query.userId;
  let qrCode = clients[userId] ? clients[userId].qrCode : "";
  res.json({ qr: qrCode });
});

app.get("/get-messages", (req, res) => {
  let userId = req.query.userId;
  let userMessages = messages[userId] ? messages[userId] : [];
  res.json({ messages: userMessages });
  messages[userId] = []; // Clear the messages after they are fetched
});

app.post("/send-message", async (req, res) => {
  console.log("Existing keys in clients:", Object.keys(clients));
  const userId = req.query.userId;
  const { num, message } = req.body;
  if (!userId || !num || !message) {
    returnres
      .status(400)
      .send("Missing unique userId, number or message in the request");
  }
  try {
    await clients[userId].sendMessage(`${num}@c.us`, message);
    res.send("Message sent");
  } catch (error) {
    console.error(error);
    res.status(500).send("An error occurred while sending the message.");
  }
});

server.listen(3000, () => {
  console.log("Server running on port 3000");
});
*/

/////////////

/*
const express = require("express");
const { Client } = require("whatsapp-web.js");
const http = require("http");
const app = express();
const server = http.createServer(app);
const fs = require("fs");
const SESSION_FILE_PATH = "./whatsapp-session.json";

app.use(express.json());

let clients = {};
let messages = {}; // New object to store messages

app.get("/start-whatsapp", (req, res) => {
  let userId = req.query.userId;
  if (!userId) {
    return res.status(400).send("Missing userId");
  }

  let sessionCfg;
  if (fs.existsSync(SESSION_FILE_PATH)) {
    sessionCfg = require(SESSION_FILE_PATH);
  }

  clients[userId] = new Client({
    session: sessionCfg,
    puppeteer: {
      headless: true,
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
    },
  });

  messages[userId] = []; // Initialize an empty array for messages for new user

  clients[userId].on("authenticated", (session) => {
    console.log("AUTHENTICATED", session);
    sessionCfg = session;
    fs.writeFile(SESSION_FILE_PATH, JSON.stringify(session), function (err) {
      if (err) {
        console.error(err);
      }
    });
  });

  clients[userId].on("qr", (qr) => {
    // Generate and scan this code with your phone
    console.log("QR RECEIVED", qr);
    clients[userId].qrCode = qr;
  });

  clients[userId].on("ready", () => {
    console.log("Client is ready!");
  });

  clients[userId].on("message", (msg) => {
    console.log("MESSAGE RECEIVED", msg.body);

    messages[userId].push({
      // Push message to respective user's array in messages object
      body: msg.body,
      from: msg.from,
      time: new Date(),
    });

    if (msg.body === "hello") {
      msg.reply("Hello, human!");
    }
  });

  clients[userId].initialize();
  res.send("WhatsApp client started");
});

app.get("/get-qr", (req, res) => {
  let userId = req.query.userId;
  let qrCode = clients[userId] ? clients[userId].qrCode : "";
  res.json({ qr: qrCode });
});

app.get("/get-messages", (req, res) => {
  let userId = req.query.userId;
  let userMessages = messages[userId] ? messages[userId] : [];
  res.json({ messages: userMessages });
  messages[userId] = []; // Clear the messages after they are fetched
});

app.post("/send-message", async (req, res) => {
  const userId = req.query.userId;
  const { num, message } = req.body;
  if (!userId || !num || !message) {
    returnres
      .status(400)
      .send("Missing unique userId, number or message in the request");
  }
  try {
    await clients[userId].sendMessage(`${num}@c.us`, message);
    res.send("Message sent");
  } catch (error) {
    console.error(error);
    res.status(500).send("An error occurred while sending the message.");
  }
});

server.listen(3000, () => {
  console.log("Server running on port 3000");
});

*/
