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
