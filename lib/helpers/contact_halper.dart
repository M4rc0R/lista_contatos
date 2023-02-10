import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contacTable = "contacTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imageColumn = "imageColumn";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  //Iniciando o banco de dados
  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contactsnew.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contacTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imageColumn TEXT)");
    });
  }

  //Salvando contatos no banco de dados
  Future<Contact> saveContact(Contact contact) async {
    Database? dbContact = await db;
    contact.id = await dbContact?.insert(contacTable, contact.toMap());
    return contact;
  }

  //Selecionando contatos no bando de dados
  Future<Contact?> getContact(int id) async {
    Database? dbContact = await db;
    List<Map> maps = await dbContact!.query(contacTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imageColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //Excluindo contatos do banco de dados
  Future<int> delteContact(int id) async {
    Database? dbContact = await db;
    return await dbContact!
        .delete(contacTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  //Atualizando contatos no banco de dados
  Future<int> updateContact(Contact contact) async {
    Database? dbContact = await db;
    return await dbContact!.update(contacTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  //Selecionando todos os contatos do bando de dados
  Future<List> getAllContact()async{
    Database? dbContact = await db;
    List listMap = await dbContact!.rawQuery("SELECT * FROM $contacTable");
    List<Contact> listContact = [];
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  //Obtendo o numero de contatos na lista
  Future<int?> getNumber() async{
    Database? dbContact = await db;
    return Sqflite.firstIntValue(await dbContact!.rawQuery("SELECT COUNT(*) FROM $contacTable"));
  }

  //Finalizando o banco de dados
  Future close() async{
    Database? dbContact = await db;
    dbContact!.close();
  }
}


//Mapeando itens de contatos

class Contact {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;
  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imageColumn];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imageColumn: img,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, image: $img)";
  }
}
