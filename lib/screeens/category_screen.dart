import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/categories.dart';
import '../../widgets/message_dialog.dart';
import '../../widgets/new_category.dart';

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
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(large),
                    topRight: Radius.circular(large),
                  ),
                ),
                builder: (_) {
                  return ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(large),
                      topRight: Radius.circular(large),
                    ),
                    child: GestureDetector(
                      onTap: () {},
                      child: NewCategory(),
                      behavior: HitTestBehavior.opaque,
                    ),
                  );
                },
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(large),
        padding: EdgeInsets.symmetric(vertical: medium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(large)),
        ),
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
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
                  onLongPress: () {
                    MessageDialog.showMessageDialog(
                      context,
                      'Delete Category',
                      'Are you sure to delete category data?',
                      'Delete',
                      () async {
                        try {
                          await Provider.of<Categories>(context, listen: false)
                              .deleteCategoryItem(category.id!);
                        } catch (error) {
                          MessageDialog.showPopUpMessage(
                            context,
                            'Delete Category',
                            'Failed to delete data category!',
                          );
                        }
                      },
                    );
                  },
                  onTap: () {
                    MessageDialog.showMessageDialog(
                      context,
                      'Edit Category',
                      'Are you sure to edit category data?',
                      'Yes',
                      () async {
                        await showModalBottomSheet(
                          isScrollControlled: true,
                          context: ctx,
                          builder: (_) {
                            return GestureDetector(
                              onTap: () {},
                              child: NewCategory(
                                categoryId: category.id,
                              ),
                              behavior: HitTestBehavior.opaque,
                            );
                          },
                        );
                      },
                    );
                  },
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
    );
  }
}
