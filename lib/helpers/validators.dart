String? fullNameValidator(value) {
  if (value == '' || value.isEmpty) {
    return 'Full name is required';
  }
  return null;
}

String? emailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email is required';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? secondPhoneValidator(value) {
  if (value == '' || value.isEmpty) {
    return null;
  } else {
    final RegExp jordanPhoneRegExp = RegExp(r'^(?:\+962|0)7[789]\d{7}$');
    if (!jordanPhoneRegExp.hasMatch(value)) {
      return 'Enter a valid Jordanian phone number';
    }
    return null;
  }
}

String? descriptionValidator(value) {
  if (value == '' || value.isEmpty) {
    return 'Description is required';
  }
  return null;
}
