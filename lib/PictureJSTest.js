const fs = require("fs");

//take base64 string from file mediabase64_2.txt
base64String = fs.readFileSync("Testing2Decrypted.txt", "utf8");

// Remove header
let base64Image = base64String.split(";base64,").pop();

fs.writeFile("output.png", base64Image, { encoding: "base64" }, function (err) {
  console.log("File created from base64 string!");
  if (err) {
    console.error(err);
  }
});
// const fs = require("fs");
// const crypto = require("crypto");

// // Your base64 string, read from file
// let base64String = fs.readFileSync("mediaBase64_2.txt", "utf8");

// // Key for DES encryption/decryption
// const DES_KEY = "12345678901234567890123456789012";

// const cipher = crypto.createCipheriv(
//   "aes-256-cbc",
//   Buffer.from(DES_KEY),
//   Buffer.alloc(16, 0)
// );
// //print cipher string console
// console.log("cipher", cipher);

// const decipher = crypto.createDecipheriv(
//   "aes-256-cbc",
//   Buffer.from(DES_KEY),
//   Buffer.alloc(16, 0)
// );
// console.log("decipher", decipher);

// // Encrypt the base64 string
// let encrypted = cipher.update(base64String, "utf8", "hex");
// encrypted += cipher.final("hex");
// // print encrypted data in file
// fs.writeFileSync("TestingEncrypted.txt", encrypted);

// // Decrypt the base64 string
// let decrypted = decipher.update(encrypted, "hex", "utf8");
// decrypted += decipher.final("utf8");
// // print decrypted data in file
// fs.writeFileSync("TestingDecrypted.txt", decrypted);

// // Remove header
// let base64Image = decrypted.split(";base64,").pop();
// // print base64Image in file
// fs.writeFileSync("TestingBase64Image.txt", base64Image);

// fs.writeFile("output.png", base64Image, { encoding: "base64" }, function (err) {
//   console.log("File created from base64 string!");
//   if (err) {
//     console.error(err);
//   }
// });
