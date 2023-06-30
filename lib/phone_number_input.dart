import 'package:extended_phone_number_input/consts/enums.dart';
import 'package:extended_phone_number_input/consts/strings_consts.dart';
import 'package:extended_phone_number_input/widgets/country_code_list.dart';
import 'package:extended_phone_number_input/models/country.dart';
import 'package:extended_phone_number_input/phone_number_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_validator/form_validator.dart';

class PhoneNumberInput extends StatefulWidget {
  final PhoneNumberInputController? controller;
  final String? initialValue;
  final String? initialCountry;
  final List<String>? excludedCountries;
  final List<String>? includedCountries;
  final bool allowPickFromContacts;
  final Widget? pickContactIcon;
  final void Function(String)? onChanged;
  final String? hint;
  final bool showSelectedFlag;
  final InputBorder? border;
  final String locale;
  final String? searchHint;
  final bool allowSearch;
  final CountryListMode countryListMode;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final TextStyle? errorStyle;
  final EdgeInsets? contentPadding;
  final ContactsPickerPosition contactsPickerPosition;
  final String? errorText;
  final Color? cursorColor;
  final Color? arrowIconColor;
  final Color? textColor;
  final FormFieldValidator<String>? inputValidator;

  const PhoneNumberInput({
    Key? key,
    this.controller,
    this.onChanged,
    this.initialValue,
    this.initialCountry,
    this.excludedCountries,
    this.allowPickFromContacts = true,
    this.pickContactIcon,
    this.includedCountries,
    this.hint,
    this.showSelectedFlag = true,
    this.border,
    this.locale = 'en',
    this.searchHint,
    this.allowSearch = true,
    this.countryListMode = CountryListMode.bottomSheet,
    this.enabledBorder,
    this.errorBorder,
    this.errorStyle,
    this.contentPadding,
    this.focusedBorder,
    this.contactsPickerPosition = ContactsPickerPosition.suffix,
    this.errorText,
    this.cursorColor,
    this.arrowIconColor,
    this.textColor,
    this.inputValidator
  }) : super(key: key);

  @override
  _CountryCodePickerState createState() => _CountryCodePickerState();
}

class _CountryCodePickerState extends State<PhoneNumberInput> {
  late PhoneNumberInputController _phoneNumberInputController;
  late TextEditingController _phoneNumberTextFieldController;
  late Future _initFuture;
  Country? _selectedCountry;

  @override
  void initState() {
    if (widget.controller == null) {
      _phoneNumberInputController = PhoneNumberInputController(
        context,
      );
    } else {
      _phoneNumberInputController = widget.controller!;
    }
    _initFuture = _init();
    _phoneNumberInputController.addListener(_refresh);
    _phoneNumberTextFieldController = TextEditingController();
    super.initState();
  }

  Future _init() async {
    await _phoneNumberInputController.init(
        initialCountryCode: widget.initialCountry,
        excludeCountries: widget.excludedCountries,
        includeCountries: widget.includedCountries,
        initialPhoneNumber: widget.initialValue,
        errorText: widget.errorText,
        locale: widget.locale);
  }

  void _refresh() {
    _phoneNumberTextFieldController.value = TextEditingValue(
        text: _phoneNumberInputController.phoneNumber,
        selection: TextSelection(
            baseOffset: _phoneNumberInputController.phoneNumber.length,
            extentOffset: _phoneNumberInputController.phoneNumber.length));

    setState(() {
      _selectedCountry = _phoneNumberInputController.selectedCountry;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(_phoneNumberInputController.fullPhoneNumber);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Column(
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    
                    cursorColor: widget.cursorColor,
                    controller: _phoneNumberTextFieldController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15),
                      FilteringTextInputFormatter.allow(kNumberRegex),
                    ],
                    onChanged: (v) {
                      _phoneNumberInputController.innerPhoneNumber = v;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: widget.inputValidator,

                    // validator: _phoneNumberInputController.validator,
                    keyboardType: TextInputType.phone,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                     errorStyle: widget.errorStyle ?? TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold
                      ),
                      contentPadding: widget.contentPadding ?? EdgeInsets.zero,
                      hintText: widget.hint,
                      border: widget.border,
                      hintStyle: const TextStyle(color: Color(0xFFB6B6B6)),
                      enabledBorder: widget.enabledBorder,
                      focusedBorder: widget.focusedBorder,
                      errorBorder: widget.errorBorder,
                      suffixIcon: Visibility(
                        visible: widget.allowPickFromContacts &&
                            widget.contactsPickerPosition ==
                                ContactsPickerPosition.suffix,
                        child: widget.pickContactIcon == null
                            ? IconButton(
                            onPressed: _phoneNumberInputController
                                .pickFromContacts,
                            icon: Icon(
                              Icons.contact_phone,
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                            ))
                            : InkWell(
                          onTap: _phoneNumberInputController
                              .pickFromContacts,
                          child: widget.pickContactIcon,
                        ),
                      ),
                      prefixIcon: InkWell(
                        onTap: _openCountryList,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_drop_down,
                                color: widget.arrowIconColor),
                            if (_selectedCountry != null &&
                                widget.showSelectedFlag)
                              Image.asset(
                                _selectedCountry!.flagPath,
                                height: 12,
                              ),
                            const SizedBox(
                              width: 4,
                            ),
                            if (_selectedCountry != null)
                              Text(
                                _selectedCountry!.dialCode,
                                style: TextStyle(
                                    color: widget.textColor),
                              ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              height: 24,
                              width: 1,
                              color: const Color(0xFFB9BFC5),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Visibility(
                    visible: widget.allowPickFromContacts &&
                        widget.contactsPickerPosition ==
                            ContactsPickerPosition.bottom,
                    child: widget.pickContactIcon == null
                        ? IconButton(
                        onPressed:
                        _phoneNumberInputController.pickFromContacts,
                        icon: Icon(
                          Icons.contact_phone,
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ))
                        : InkWell(
                      onTap: _phoneNumberInputController.pickFromContacts,
                      child: widget.pickContactIcon,
                    )),
              ],
            ),
          );
        });
  }

  void _openCountryList() {
    switch (widget.countryListMode) {
      case CountryListMode.bottomSheet:
        showModalBottomSheet(
            isScrollControlled: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            enableDrag: true,
            context: context,
            builder: (_) =>
                SizedBox(
                  height: 500,
                  child: CountryCodeList(
                      searchHint: widget.searchHint,
                      allowSearch: widget.allowSearch,
                      phoneNumberInputController: _phoneNumberInputController,
                      textColor: widget.textColor,
                  ),
                ));
        break;
      case CountryListMode.dialog:
        showDialog(
            context: context,
            builder: (_) =>
                AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  content: SizedBox(
                    width: double.maxFinite,
                    child: CountryCodeList(
                        searchHint: widget.searchHint,
                        allowSearch: widget.allowSearch,
                        phoneNumberInputController:
                        _phoneNumberInputController),
                  ),
                ));
        break;
    }
  }
}
