import 'package:flutter/material.dart';
import '../model/Expenses.dart';

class AddSessionDialog extends StatefulWidget {
  final Sessions? sessions;
  final Function(bool isActive, String session) onClickDone;

  const AddSessionDialog({
    Key? key,
    this.sessions,
    required this.onClickDone,
  }) : super(key: key);

  @override
  State<AddSessionDialog> createState() => _AddSessionDialogState();
}

class _AddSessionDialogState extends State<AddSessionDialog> {
  final formKey = GlobalKey<FormState>();
  final sessionController = TextEditingController();
  bool isActive = false;
  @override
  void initState (){
    super.initState();
    if (widget.sessions != null) {
      final sessions = widget.sessions!;
      sessionController.text = sessions.session;
      isActive = sessions.isActive;
    }
  }
  @override
  void dispose() {
    sessionController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sessions != null;
    final title = isEditing ? 'Edit Session' : 'Add Session';
    return AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 8),
              buildName(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        buildCancelButton(context),
        buildAddButton(context, isEditing: isEditing),
      ],
    );
  }
  Widget buildName() => TextFormField(
    controller: sessionController,
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      hintText: 'Enter Session',
    ),
    validator: (name) =>
    name != null && name.isEmpty ? 'Enter Session' : null,
  );
  Widget buildCancelButton(BuildContext context) => TextButton(
    child: Text('Cancel'),
    onPressed: () => Navigator.of(context).pop(),
  );

  Widget buildAddButton(BuildContext context, {required bool isEditing}) {
    final text = isEditing ? 'Save' : 'Add';

    return TextButton(
      child: Text(text),
      onPressed: () async {
        final isValid = formKey.currentState!.validate();

        if (isValid) {
          final name = sessionController.text;

          widget.onClickDone(isActive, name);

          Navigator.of(context).pop();
        }
      },
    );
  }
}
