const crypto = require("crypto");
const fs = require("fs");
const express = require("express");
const path = require("path");
const sharp = require("sharp"); //npm install sharp
const { Client, MessageMedia } = require("whatsapp-web.js"); // <- Include MessageMedia here
const http = require("http");
const app = express();
const server = http.createServer(app);
const bodyParser = require("body-parser");
const { log } = require("console");

app.use(
  bodyParser.urlencoded({
    limit: "50mb",
    extended: true,
    parameterLimit: 50000,
  })
);

//default DES_KEY
const DES_KEY = "12345678901234567890123456789012";

// Adds a JSON body parser middleware
app.use(bodyParser.json({ limit: "50mb" }));

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
    // Error handling event for this client
    clients[userId].on("error", (error) => {
      console.error("WhatsApp Client Error for userId:", userId, error);
    });

    // Replace the following section with the provided code
    clients[userId].on("message", async (msg) => {
      console.log("MESSAGE RECEIVED", msg.body);

      let isMediaMessage = false;
      if (msg.hasMedia) {
        isMediaMessage = true;
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
          isMediaMessage: isMediaMessage,
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
    return res
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

app.post("/send-media-message", async (req, res) => {
  const userId = req.query.userId;
  const { num, message, mediaBase64 } = req.body;
  //print mediaBase64 in file
  fs.writeFileSync("Testing2MediaBase64.txt", mediaBase64);
  if (!userId || !num || !mediaBase64) {
    return res
      .status(400)
      .send("Missing unique userId, number or media in the request");
  }

  //craete cipher object
  const cipher = crypto.createCipheriv(
    "aes-256-cbc",
    Buffer.from(DES_KEY),
    Buffer.alloc(16, 0)
  );
  //print cipher string console
  console.log("cipher", cipher);
  //create encrypt media
  let encrypted = cipher.update(mediaBase64, "utf8", "hex");
  encrypted += cipher.final("hex");
  fs.writeFileSync("Testing2Encrypted.txt", encrypted);

  // create MessageMedia from base64 data
  const media = new MessageMedia(
    "application/octet-stream",
    encrypted,
    "Media"
  );

  try {
    await clients[userId].sendMessage(`${num}@c.us`, message, { media });

    res.send("Message sent");
  } catch (error) {
    console.error(error);
    res.status(500).send("An error occurred while sending the message.");
  }
});
app.post("/decrypt-file", async (req, res) => {
  try {
    //extracts the base64 data
    let { imageData } = req.body;
    console.log("Entered decrypt-file");
    // Removing `data:application/octet-stream;base64,` from imageData
    console.log("Before replace");
    imageData = imageData.replace("data:application/octet-stream;base64,", "");
    console.log("After replace");
    //print imageData in file
    fs.writeFileSync("Testing2ImageData.txt", imageData);

    //decodes the base64 data
    console.log("Before buff");
    // let buff = Buffer.from(imageData.split(",")[1], "base64");
    console.log("After buff");
    //print buff in file
    // fs.writeFileSync("Testing2Buff.txt", buff);
    console.log("After write buff");
    const decipher = crypto.createDecipheriv(
      "aes-256-cbc",
      Buffer.from(DES_KEY),
      Buffer.alloc(16, 0)
    );
    console.log("decipher", decipher);

    //Decrypt it
    console.log("Before decrypted");
    // let decrypted = decipher.update(imageData, "base64", "utf8");
    let decrypted = decipher.update(imageData, "hex", "utf8");
    decrypted += decipher.final("utf8");
    console.log("After decrypted");
    // add at beginging `data:application/octet-stream;base64,` to decrypted
    decrypted = `data:image/jpeg;base64,${decrypted}`;
    //print decrypted data in file
    fs.writeFileSync("Testing2Decrypted.txt", decrypted);
    console.log("After write decrypted");

    //return the decrypted image data
    //print length of decrypted data in console
    console.log("decrypted.length", decrypted.length);
    res.json({ imageData: decrypted });
    return;
  } catch (error) {
    // Error occurred during the decryption
    res.status(500).send("An error occurred during the decryption.");
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
