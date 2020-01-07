import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:jtbcontract/data/contactUserInfo.dart';
import 'package:jtbcontract/inputPhoneNumber.dart';
import 'package:jtbcontract/saveFriend.dart';
import 'package:jtbcontract/service/soundSearcher.dart';


class GetContactPage extends StatefulWidget {

  final int selectedIndex;
  const GetContactPage({Key key, this.selectedIndex}) : super(key: key);

  @override
  _GetContactPageState createState() => _GetContactPageState();
}

class _GetContactPageState extends State<GetContactPage> {
  List<Contact> _contacts;
  var contacts;
  ContactUserInfo contactUserInfo = new ContactUserInfo();

  @override
  void initState() {
    refreshContacts();
    _textEditingController.addListener(textListener);
    super.initState();
    
  }

  @override
  void dispose(){
    _textEditingController.dispose();
    super.dispose();
    
  }


  textListener() async{
    List<Contact> searchedContact = new List<Contact>();
    for(Contact c in contacts){
      bool result = await searchPhoneNumber(c);
      if(result == true) searchedContact.add(c);
    }
    
    setState(() {
      _contacts = searchedContact;
    });
  }

  void refreshContacts() async{
    //PermissionStatus permissionStatus = await _getContactPermission();
    //if (permissionStatus == PermissionStatus.granted) {
      // Load without thumbnails initially.
    contacts = (await ContactsService.getContacts(withThumbnails: false)).toList();
    setState(() {
      _contacts = contacts;
    });

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
  }


  TextEditingController _textEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if(widget.selectedIndex == 0){ // 작성페이지
            inputPhoneNumber();
          } 
          else if(widget.selectedIndex == 2){
            saveFriend();
          }
          
        } ,
        label: Text('input New Number'),
        icon: Icon(Icons.open_in_new),
        backgroundColor: Colors.pink,
      ),
        
      
      appBar: AppBar(
        title: Text('Contact'),
        backgroundColor: Colors.black,
      ),

      body: Column(children: <Widget>[
        Padding(padding: EdgeInsets.all(5),),
        SizedBox(
          height: 100,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              
              controller: _textEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search Name',
              ),
            ),
          ),
        ),
   
        Expanded(
          flex: 1,
          child: SafeArea(
            child: _contacts != null
                ? ListView.builder(
              itemCount: _contacts.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Contact c = _contacts.elementAt(index);
                return ListTile(
                  onTap: () {
                    
                    getPhoneNumber(c);
                    getPhoneName(c);

                    Navigator.pop(context, contactUserInfo);
                  },
                  leading: (c.avatar != null && c.avatar.length > 0)
                      ? CircleAvatar(backgroundImage: MemoryImage(c.avatar), backgroundColor: Colors.black, foregroundColor: Colors.white,)
                      : CircleAvatar(child: Text(c.initials(),), backgroundColor: Colors.black, foregroundColor: Colors.white,),
                  title: Text(c.displayName ?? ""),
                );
              },
            )
                : Center(child: CircularProgressIndicator(),),
          ),
        ),
      ],)
    );
  }

  inputPhoneNumber() async {
    try{
      contactUserInfo = await Navigator.push(context, MaterialPageRoute(builder: (context) => InputPhoneNumber()));
      //selectedPhoneNumber = await Navigator.pushNamed(context, InputPhoneNumberRoute);
      if(contactUserInfo.phoneNumber != null && contactUserInfo.name != null) Navigator.pop(context, contactUserInfo);
    }
    catch(Exception)
    {
      print('phoneNumber is null');
    }
   
  }

   saveFriend() async {
    contactUserInfo = await Navigator.push(context, MaterialPageRoute(builder: (context) => SaveFriend()));
    //selectedPhoneNumber = await Navigator.pushNamed(context, InputPhoneNumberRoute);
    if(contactUserInfo.phoneNumber != null && contactUserInfo.name != null) Navigator.pop(context, contactUserInfo);
  }

  getPhoneNumber(Contact _c) async{
    
    List<String> liPhoneNumber = _c.phones.map((i) => i.value).toList();
    for(String s in liPhoneNumber){
      if(s.substring(0, 3).contains('010') 
        || s.substring(0, 3).contains('011')
        || s.substring(0, 3).contains('016')
        || s.substring(0, 3).contains('017')
        || s.substring(0, 3).contains('019'))
      {
        contactUserInfo.phoneNumber = s;
        return;
      }
    }
  }

  getPhoneName(Contact _c) async {
    contactUserInfo.name = _c.displayName;
  }

  searchPhoneNumber(Contact _c) async{
    if(SoundSearcher.matchString(_c.displayName, _textEditingController.text)){
      return true;
    }
    else return false;
  }
}
