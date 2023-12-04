// //function take text as string to be encrypted or decrypted , key for vigenere to add it with text , encrypt flag for (1-encrypted ,0-decrypted)
// String vigenere(String text, String key, int encrypt) {
// //list to stores ascii code of key and text
//   List<int> textCodeUnits = text.codeUnits;
//   List<int> keyCodeUnits = key.codeUnits;
//   String result = '';
// //index for the key list
//   int j = 0;
//   for (var i = 0; i < text.length; i++) {
//     if (encrypt == 1) {
//       // Encryption: (text + key) % 26 + 65 why 65 because A start from 65 in ascii
//       int x = (textCodeUnits[i] + keyCodeUnits[j]) % 26 + 65;
// //convert back to character using ascii
//       result += String.fromCharCode(x);
//     } else {
//       // Decryption:
//       int y = ((textCodeUnits[i] - keyCodeUnits[j]) % 26 + 26) % 26;
//       result += String.fromCharCode(y + 65);
//     }
// //if iteration end rest otherwise increment j to go over the k
//     if (j < key.length - 1) {
//       j++;
//     } else {
//       j = 0;
//     }
//   }
//   return result;
// }

String vigenere(String inputText, String key, int encrypt) {
  String result = '';
  var j = 0;
  key = key.toUpperCase();
  for (var i = 0; i < inputText.length; i++) {
    var char = inputText[i].toUpperCase();
    var keyCode = key[j].codeUnitAt(0) - 'A'.codeUnitAt(0);
    if (encrypt == 1) {
      var encryptedChar =
          ((char.codeUnitAt(0) + keyCode - 'A'.codeUnitAt(0)) % 26);
      result += String.fromCharCode(encryptedChar + 'A'.codeUnitAt(0));
    } else {
      var decryptedChar =
          ((char.codeUnitAt(0) - keyCode - 'A'.codeUnitAt(0)) % 26);
      result += String.fromCharCode(decryptedChar < 0
          ? decryptedChar + 26 + 'A'.codeUnitAt(0)
          : decryptedChar + 'A'.codeUnitAt(0));
    }
    j = (j + 1) % key.length;
  }
  return result;
}
