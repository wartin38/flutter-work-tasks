import 'package:flutter/material.dart';
import 'package:workos/constants/my_colors.dart';

class GlobalMethod {
  static void showErrorDialog(
      {required String error, required BuildContext ctx}) {
    showDialog(
        context: ctx,
        builder: (context) {
          return AlertDialog(
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    'https://image.flaticon.com/icons/png/512/1370/1370553.png',
                    height: 20,
                    width: 20,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text('Ocurrió un error'),
                ),
              ],
            ),
            content: Text(
              '$error',
              style: TextStyle(
                  color: MyColors.darkBlue,
                  fontSize: 20,
                  fontStyle: FontStyle.italic),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Entendido',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        });
  }
}
