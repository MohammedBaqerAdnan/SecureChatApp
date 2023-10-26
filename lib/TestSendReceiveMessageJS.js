const { Client } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const client = new Client();

client.on('qr', (qr) => {
    // Generate and scan this code with your phone
    // console.log('QR RECEIVED', qr);
    qrcode.generate(qr, { small: true });
});

client.on('ready', () => {
    console.log('Client is ready!');
});

client.on('message', msg => {
    console.log('MESSAGE RECEIVED', msg.body);

    if (msg.body == 'hello') {
        msg.reply('Hello, human!');
    }
});

client.initialize();
