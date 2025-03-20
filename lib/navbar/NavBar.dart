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
                  "https://scontent.fdad1-3.fna.fbcdn.net/v/t39.30808-6/474746290_1304799510770681_7448314800583217492_n.jpg?_nc_cat=110&ccb=1-7&_nc_sid=6ee11a&_nc_eui2=AeGLgcuM8utZOm_Oau8fwJC1fu6VbngVBzF-7pVueBUHMWHaT-yuuSFN9HKLdObuGedcldnXWlSvqxL1gHz7YU0p&_nc_ohc=UXPDs74O58wQ7kNvgHg_Oyl&_nc_oc=AdlFq56S3Q4-zBwnAQndgS6Ftwpm33eeoIAe_udi7PJmbln2qShimcyPqxc4moc55l11OyWCNb2xDUS-dNmQayRq&_nc_zt=23&_nc_ht=scontent.fdad1-3.fna&_nc_gid=I_xvFck-aeNkwkKh0VMK1w&oh=00_AYEwStMW1cBBTuaQ0dfi_YDx7Z1lR9xjrclkHCQatvfszw&oe=67E0B017",
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
