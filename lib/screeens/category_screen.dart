import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puri_expenses/providers/categories.dart';
import 'package:puri_expenses/widgets/new_category.dart';

import '../constants.dart';

class CategoryScreen extends StatelessWidget {
  static const routeName = '/categories';
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dataCategories = Provider.of<Categories>(context).items;
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) {
                  return GestureDetector(
                    onTap: () {},
                    child: NewCategory(),
                    behavior: HitTestBehavior.opaque,
                  );
                },
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(medium),
        child: Expanded(
          child: Card(
            child: ListView.builder(
              itemBuilder: (ctx, idx) {
                var category = dataCategories[idx];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        category.name!,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      subtitle: Text(category.description!),
                      leading: CircleAvatar(
                        // Theme.of(context).accentColor,
                        radius: 30,
                        child: Padding(
                          padding: EdgeInsets.all(2),
                          child: FittedBox(
                            child: Text(
                              (idx + 1).toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (idx < dataCategories.length - 1)
                      Divider(
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                  ],
                );
              },
              itemCount: dataCategories.length,
            ),
          ),
        ),
      ),
    );
  }
}
