import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBManager{
  Database _database;

  String tableName = 'cart';
  String dbFileName = 'cart.db';

  String tableID = 'tableID';
  String id = 'id';

  Future openDB() async{
    if(_database == null){
      try{
        _database = await openDatabase(
            join(await getDatabasesPath(), dbFileName),
            version: 1,
            onCreate: (Database db, int version) async {
              await db.execute('CREATE TABLE $tableName ('
                  '$tableID INTEGER PRIMARY KEY AUTOINCREMENT, '
                  '$id INTEGER '
                  ')'
              );
            }
        );
      }catch(error){
        print(error.toString());
      }
    }
  }
}
