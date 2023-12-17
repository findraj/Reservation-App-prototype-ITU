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

    notifyListeners(); // Notify listeners to rebuild UI if necessary.
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
      await _accountApi.deleteAccount(account); // Corrected to pass a Reservation object
      await fetchAccounts();
  } // Refresh the list of reservations
}