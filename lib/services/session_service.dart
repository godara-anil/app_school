import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:flutter/material.dart';
import 'package:app_school/model/category_model.dart';
import 'package:app_school/services/account_service.dart';

class SessionService {

  static ValueNotifier<int>
  activeSessionNotifier =
  ValueNotifier<int>(
    getActiveSessionKey(),
  );

  // GET ACTIVE SESSION
  static Sessions getActiveSession() {

    final sessions =
    Sess.getTransactions()
        .values
        .where((session) => session.isActive)
        .toList()
        .cast<Sessions>();

    // CREATE DEFAULT SESSION
    if (sessions.isEmpty) {

      final session = Sessions()
        ..session = '2020-21'
        ..isActive = true
        ..isLocked = false;
      Sess.getTransactions().add(session);

      return session;
    }

    return sessions.first;
  }

  // GET ACTIVE SESSION KEY
  static int getActiveSessionKey() {

    return getActiveSession().key;
  }

  // GET ACTIVE SESSSION LOCK STATUS
  static bool getActiveSessionLockStatus() {
    return getActiveSession().isLocked;
  }

  static const String lockedMessage =
      'Active session is locked. Unlock it to make changes.';



  // GET ALL SESSIONS
  static List<Sessions> getAllSessions() {

    final sessions =
    Sess.getTransactions()
        .values
        .toList()
        .cast<Sessions>();

    return sessions;
  }

  // ADD SESSION
  static Future<void> addSession(
      String sessionName,
      ) async {

    final session = Sessions()
      ..session = sessionName
      ..isActive = false
      ..isLocked = false;

    await Sess.getTransactions().add(session);
  }

  static Future<void> editSession(
      Sessions session,
      String sessionName,
      bool isActive,
      ) async {

    session.session = sessionName;

    session.isActive = isActive;

    await session.save();
  }

  static Future<String?> canDeleteSession(
      Sessions session,
      ) async {

    if (session.isActive) {

      return
        "Can not delete active session.";
    }

    final transactions =
    Boxes.getTransactions()
        .values
        .where(
          (tx) =>
      tx.sessionKey ==
          session.key,
    )
        .toList();

    if (transactions.isNotEmpty) {

      return
        "Can not delete session having transactions.";
    }

    return null;
  }

  // SET ACTIVE SESSION
  static Future<void> setActiveSession(
      Sessions selectedSession,
      ) async {

    final sessions = getAllSessions();

    for (var session in sessions) {

      session.isActive = false;

      await session.save();
    }

    selectedSession.isActive = true;

    await selectedSession.save();
    activeSessionNotifier.value =
        selectedSession.key;
  }

  // DELETE SESSION
  static Future<String?> deleteSession(
      Sessions session,
      ) async {
    final error =
    await canDeleteSession(
      session,
    );

    if (error != null) {

      return error;
    }

    await session.delete();

    return null;
  }

  static Future<void>
  ensureOpeningBalanceCategory() async {

    final exists =
    CategoryBox
        .getCategories()
        .values
        .any(
          (c) =>
      c.name
          .toLowerCase() ==
          "opening balance",
    );

    if (exists) return;

    await CategoryBox
        .getCategories()
        .add(

      Category(
        name:
        "Opening Balance",
        isExpense:
        false,
        isActive:
        true,
      ),
    );
  }

  static Future<void>
  createSession(
      String sessionName,
      bool carryForward,
      ) async {
    final sessionExists =
    Sess.getTransactions()
        .values
        .any(
          (s) =>
      s.session
          .trim()
          .toLowerCase() ==
          sessionName
              .trim()
              .toLowerCase(),
    );

    if (sessionExists) {
      throw Exception(
        "Session already exists",
      );
    }
    final newSession = Sessions()
      ..session = sessionName
      ..isActive = false;

    await Sess
        .getTransactions()
        .add(newSession);

    if (!carryForward) {

      await setActiveSession(
        newSession,
      );

      return;
    }

    await ensureOpeningBalanceCategory();

    final accounts =
    AccountsBox
        .getAccounts()
        .values
        .where(
          (a) => a.isActive,
    )
        .cast<Account>();

    final activeSession =
    getActiveSession();

    for (final account in accounts) {

      final balance =
      AccountService
          .getAccountBalance(
        account,
      );

      if (balance == 0) {
        continue;
      }

      final tx = Expenses()

        ..amount =
        balance.abs()

        ..isExpense =
            balance < 0

        ..date =
        DateTime.now()

        ..category =
            "Opening Balance"

        ..sessionKey =
            newSession.key

        ..accountId =
        account.key.toString()

        ..remarks =
            "Carry Forward from ${activeSession.session}";

      await Boxes
          .getTransactions()
          .add(tx);
    }

    await setActiveSession(
      newSession,
    );
  }
}