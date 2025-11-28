import 'package:flutter/material.dart';

void showSettings<T>({
  required BuildContext context,
  required Function(T) setterFunction,
  required String Function(T) formatFunction,
  required List<T> currentList,
  Function(T)? removeFunction, // optional callback for removing
  Widget? bottomWidget,
  bool removable = false,
}) {
  void onTap(int index) {
    Navigator.pop(context);
    setterFunction(currentList[index]);
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return FractionallySizedBox(
            heightFactor: 0.8,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: List.generate(
                        currentList.length,
                        (index) => ListTile(
                          title: Text(formatFunction(currentList[index])),
                          trailing: removable && index != 0
                              ? IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () {
                                    removeFunction?.call(currentList[index]);

                                    setModalState(() {});
                                  },
                                )
                              : null,
                          onTap: () {
                            onTap(index);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                bottomWidget ?? Container(),
              ],
            ),
          );
        },
      );
    },
  );
}
