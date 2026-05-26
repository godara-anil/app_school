import 'package:app_school/boxes.dart';
import 'package:app_school/model/Expenses.dart';

class SessionService {

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
        ..isActive = true;

      Sess.getTransactions().add(session);

      return session;
    }

    return sessions.first;
  }

  // GET ACTIVE SESSION KEY
  static int getActiveSessionKey() {

    return getActiveSession().key;
  }

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
      ..isActive = false;

    await Sess.getTransactions().add(session);
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
  }

  // DELETE SESSION
  static Future<void> deleteSession(
      Sessions session,
      ) async {

    await session.delete();
  }
}