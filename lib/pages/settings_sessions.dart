import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_school/model/Expenses.dart';
import 'package:app_school/boxes.dart';
import 'package:app_school/widget/addSessionDialog.dart';
import 'package:app_school/services/session_service.dart';


class Settings_session extends StatefulWidget {

  const Settings_session({Key? key}) : super(key: key);

  @override
  State<Settings_session> createState() => _Settings_sessionState();
}

class _Settings_sessionState extends State<Settings_session> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.green[700],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
      context: context,
      builder: (context) => AddSessionDialog(
        onClickDone: (
            isActive,
            name,
            carryForward,
            ) async {

          try {

            await SessionService.createSession(
              name,
              carryForward,
            );

          } catch (e) {

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(

              SnackBar(
                content: Text(
                  e.toString(),
                ),
              ),
            );
          }

        },
      )
    ),
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<Box<Sessions>>(
        valueListenable: Sess.getTransactions().listenable(),
        builder: (context, box, _) {
          final sessions = box.values.toList().cast<Sessions>();
          // transactions.sort((b, a )=> a.date.compareTo(b.date));
          return buildContent(sessions);
        },
      ),
    );
  }
  Widget buildContent(List<Sessions> sessions){
    if(sessions.isEmpty){
      return Center(
        child: Text(
          'No Session Defined yet!',
          style: TextStyle(fontSize: 24),
        ),
      );
    }
    else {
      return Column(
        children: [
           Expanded(
             child: ListView.builder(
               padding: EdgeInsets.all(8),
               itemCount: sessions.length,
               itemBuilder: (BuildContext context, int index) {
                 final session = sessions[index];
                 return buildTransaction(context, session);
               },
             ),
           )
        ],
      );
    }
  }
  Widget buildTransaction(
      BuildContext context,
      Sessions session,
      ) {
    return Card(
      color: Colors.white,
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        title: Row(
          children: [
            Expanded(
              child: Text(
                session.session,
                maxLines: 2,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (session.isLocked)
              const Icon(
                Icons.lock,
                color: Colors.red,
              ),
          ],
        ),
        trailing: buildIcon(session.isActive),
        children: [
          buildButtons(context, session),
        ],
        ),
      );
  }
  Widget buildIcon (isActive) {
    if(isActive == true) {
      return Icon(Icons.check, color: Colors.green[700],);
    }
    else {
      return Text('');
    }
  }
  Widget buildButtons(BuildContext context, Sessions session) => Row(
    children: [
      Expanded(
        child: TextButton.icon(
          label: const Text(''),
          icon: const Icon(Icons.edit),
          onPressed: () {

            if (session.isLocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Locked session cannot be edited.',
                  ),
                ),
              );
              return;
            }
            showDialog(
              context: context,
              builder: (context) => AddSessionDialog(
                sessions: session,
                onClickDone: (isActive, name, carryForward) =>
                    SessionService.editSession(
                      session,
                      name,
                      isActive,
                    ),
              ),
            );
          },
        ),
      ),
      Expanded(
        child: TextButton.icon(
          label: Text(''),
          icon: Icon(Icons.delete,),
          onPressed: () async {
            if (session.isLocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Locked Session can not be deleted. Unlock to delete",
                  ),
                ),
              );
              return;
            }
            final error = await
            SessionService
                .deleteSession(
              session,
            );

            if (error != null) {

              showDialog(

                context: context,

                builder: (_) => AlertDialog(

                  title: const Text(
                    'Alert',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),

                  content: Text(error),

                  actions: [

                    TextButton(

                      onPressed: () {

                        Navigator.pop(
                          context,
                        );
                      },

                      child: const Text(
                        'OK',
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      Expanded(
        child: checkActive(session),
      ),
      Expanded(
        child: lockUnlockButton(session),
      )
    ],
  );
  Widget checkActive (session){
    if(session.isActive){
      return Text('');
    }
    else {
      return TextButton.icon(
        label: Text(''),
        icon: Icon(Icons.check,),
        onPressed: () => makeActive(session),
      );
    }
  }
  Widget lockUnlockButton(Sessions session) {
    return TextButton.icon(
      icon: Icon(
        session.isLocked
            ? Icons.lock_open
            : Icons.lock,
      ),
      label: Text(''),
      onPressed: () => toggleSessionLock(session),
    );
  }
  Future<void> makeActive(
      Sessions session,
      ) async {

    await SessionService
        .setActiveSession(
      session,
    );
  }
  Future<void> toggleSessionLock(
      Sessions session,
      ) async {
    final shouldLock = !session.isLocked;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          shouldLock
              ? 'Lock Session'
              : 'Unlock Session',
        ),
        content: Text(
          shouldLock
              ? 'Are you sure you want to lock this session? '
              'Transactions can no longer be modified.'
              : 'Are you sure you want to unlock this session?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: Text(
              shouldLock
                  ? 'Lock'
                  : 'Unlock',
            ),
          ),
        ],
      ),
    );

    if (result != true) return;

    session.isLocked = shouldLock;

    await session.save();
  }
}

