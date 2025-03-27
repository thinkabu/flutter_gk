import 'package:flutter/material.dart';
import 'package:flutter_gk/main.dart';

class Navbar extends StatelessWidget {
  final Function(DrawerSections) onSectionSelected;

  const Navbar({super.key, required this.onSectionSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("Nguyễn Hữu Thịnh"),
            accountEmail: Text("thinhnh.22ite@vku.udn.vn"),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  "https://scontent.fdad1-3.fna.fbcdn.net/v/t39.30808-6/474746290_1304799510770681_7448314800583217492_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=6ee11a&_nc_ohc=HtG7EGhfNs0Q7kNvgFYh5h1&_nc_oc=AdnDPLtMJUgTTVW6MffRZdg9-lgaLXOBt3tKXdEitSLBQ2LEra54QkXoc2xyg5l7Yd2MKZcRFkTSZiDddMK1M58c&_nc_zt=23&_nc_ht=scontent.fdad1-3.fna&_nc_gid=nTQMILHSwfgYEK3mcfJnfw&oh=00_AYHu7gPDjfeHsrPCbsj5PizehrR17yos0-jrW_HrI7hr8g&oe=67E7F057",
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey,
              image: DecorationImage(
                image: NetworkImage(
                  "https://wallpapers.com/images/hd/image-background-cv93vlvo4gv804kd.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(Icons.view_list),
                  title: Text("Product List"),
                  onTap: () => onSectionSelected(DrawerSections.productList),
                ),
                ListTile(
                  leading: Icon(Icons.manage_accounts),
                  title: Text("CRUD Product"),
                  onTap: () => onSectionSelected(DrawerSections.crudProduct),
                ),
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text("Favorite"),
                  onTap: () => print("tap"),
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text("Setting"),
                  onTap: () => print("tap"),
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Exit"),
            onTap: () => onSectionSelected(DrawerSections.exit),
          ),
        ],
      ),
    );
  }
}
