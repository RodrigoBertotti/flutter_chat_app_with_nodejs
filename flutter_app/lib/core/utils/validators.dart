


/// Adapted from https://stackoverflow.com/a/63292899/4508758
String? validateEmail (String? value) {
  final requiredError = validateRequired(value);
  if(requiredError != null){
    return requiredError;
  }

  const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
  final regex = RegExp(pattern);

  return !regex.hasMatch(value!) ? 'Invalid email address' : null;
}

String? validateRequired (String? value) {
  return value!.isNotEmpty == true ? null : 'This field is required';
}

String? validateCreatePassword(String? value) {
  final requiredError = validateRequired(value);
  if(requiredError != null){
    return requiredError;
  }
  if(value!.length < 6){
    return "The password should contain at least 6 characters";
  }
  return null;
}