/// account_provider.dart
/// provider pre databazu account
/// 
/// Autor: Jan Findra (xfindr01)
import 'package:flutter/foundation.dart';
import 'package:vyperto/api/account_api.dart';
import 'package:vyperto/model/account.dart';

class AccountProvider extends ChangeNotifier {
  late AccountAPI _accountApi;

  List<Account> _accounts = [];

  AccountProvider() {
    _accountApi = AccountAPI();
  }

  List<Account> get accountsList => _accounts;

  Future<void> fetchAccounts() async {
    final List<Account> fetchedAccounts = await _accountApi.fetchAccounts();
    _accounts = fetchedAccounts;

    notifyListeners();
  }

  Future<void> providerInsertAccount(
    Account account,
  ) async {
    await _accountApi.insertAccount(account);
    await fetchAccounts();
  }

  Future<void> providerDeleteAccount(
    Account account,
  ) async {
    await _accountApi.deleteAccount(account);
    await fetchAccounts();
  }
}
