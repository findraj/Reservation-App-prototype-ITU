/// AccountProvider - Poskytovatel stavu a funkcnosti pre spravu uctov.
///
/// Tato trieda spravuje zoznam uctov (accounts) a interaguje s AccountAPI
/// pre ziskavanie, vkladanie a mazanie uctov z backendu.
///
/// ## Funkcie
/// - Umoznuje ziskavat zoznam vsetkych uctov.
/// - Poskytuje metody pre vkladanie a mazanie uctov.
/// - Pouziva `ChangeNotifier` pre aktualizaciu UI v reakcii na zmeny stavu.
///
/// ## Pouzitie
/// Pouziva sa v spojeni s `Provider` balickom pre spristupnenie dat
/// o uctoch cez celej aplikacii.
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
