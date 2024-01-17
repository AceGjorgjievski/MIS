import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Clothes(clotheName: "", clotheColor: "", clotheSize: ""),
    );
  }
}

class Clothes extends StatefulWidget {
  Clothes({
    Key? key,
    required this.clotheName,
    required this.clotheColor,
    required this.clotheSize,
  }) : super(key: key);

  String clotheName = "";
  String clotheColor = "";
  String clotheSize = "";

  String get getClotheName => clotheName;

  @override
  State<Clothes> createState() => _ClothesState();

  String get getClotheColor => clotheColor;

  String get getClotheSize => clotheSize;
}

class _ClothesState extends State<Clothes> {
  List<Clothes> clothes = [];

  //method for adding and editing clothes
  void addClothes({int? index}) {
    List<String> clothesNames = [
      'Dress',
      'Jacket',
      'Skirt',
      'T-Shirt',
      'Blouse'
    ];
    List<String> clothesColors = ["Red", "Green", "Blue", "Purple", "Yellow"];
    List<String> clothesSizes = ["Small", "Medium", "Large"];

    String selectedClotheName =
        index != null ? clothes[index].getClotheName : clothesNames.first;
    String selectedClotheColor =
        index != null ? clothes[index].getClotheColor : clothesColors.first;
    String selectedClotheSize =
        index != null ? clothes[index].getClotheSize : clothesSizes.first;

    String? title = index != null
        ? '$selectedClotheName - $selectedClotheColor - $selectedClotheSize'
        : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title != null ? 'Editing:\n$title' : 'Add new Clothe'),
          content: SizedBox(
            height: 250,
            width: 200,
            child: Column(
              children: [
                Expanded(
                  child: DropdownMenu<String>(
                    initialSelection: selectedClotheName,
                    onSelected: (String? value) {
                      setState(() {
                        selectedClotheName = value!;
                      });
                    },
                    dropdownMenuEntries: clothesNames
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList(),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                Expanded(
                  child: DropdownMenu<String>(
                    initialSelection: selectedClotheColor,
                    onSelected: (String? value) {
                      setState(() {
                        selectedClotheColor = value!;
                      });
                    },
                    dropdownMenuEntries: clothesColors
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList(),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                Expanded(
                  child: DropdownMenu<String>(
                    initialSelection: selectedClotheSize,
                    onSelected: (String? value) {
                      setState(() {
                        selectedClotheSize = value!;
                      });
                    },
                    dropdownMenuEntries: clothesSizes
                        .map<DropdownMenuEntry<String>>((String value) {
                      return DropdownMenuEntry<String>(
                          value: value, label: value);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green
              ),
              onPressed: () {
                setState(() {
                  if (selectedClotheName.isNotEmpty &&
                      selectedClotheColor.isNotEmpty &&
                      selectedClotheSize.isNotEmpty) {
                    if (index != null) {
                      clothes[index] = Clothes(
                        clotheName: selectedClotheName,
                        clotheColor: selectedClotheColor,
                        clotheSize: selectedClotheSize,
                      );
                    } else {
                      clothes.add(Clothes(
                        clotheName: selectedClotheName,
                        clotheColor: selectedClotheColor,
                        clotheSize: selectedClotheSize,
                      ));
                    }
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text(
                index != null ? 'Modify' : 'Add',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void editClothe(int index) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.center,
          child: Text(
            'Clothes App - 201183',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.cyan,
      ),
      body: Column(
        children: [
          Text(
            clothes.isEmpty ? 'No Added Clothes' : 'All Added Clothes:',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: clothes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                      '${clothes[index].getClotheName} - ${clothes[index].getClotheColor} - ${clothes[index].getClotheSize}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            addClothes(index: index);
                          },
                          color: Colors.green,
                          icon: const Icon(
                            Icons.edit,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              clothes.removeAt(index);
                            });
                          },
                          color: Colors.green,
                          icon: const Icon(Icons.delete_outline_rounded),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () {
          addClothes();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
        ),
        child: const Text(
          'Add new Clothe',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
