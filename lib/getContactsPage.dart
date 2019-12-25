import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:jtbcontract/inputPhoneNumber.dart';
import 'package:jtbcontract/service/routingConstants.dart';
import 'package:jtbcontract/service/soundSearcher.dart';


class GetContactPage extends StatefulWidget {
  @override
  _GetContactPageState createState() => _GetContactPageState();
}

class _GetContactPageState extends State<GetContactPage> {
  List<Contact> _contacts;
  var contacts;
  String selectedPhoneNumber;

  @override
  void initState() {
   
    super.initState();
    refreshContacts();
    _textEditingController.addListener(textListener);
  }

  @override
  void dispose(){
    super.dispose();
    _textEditingController.dispose();
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
    //} 
    // else {
    //   _handleInvalidPermissions(permissionStatus);
    // }
  }

//   Future<PermissionStatus> _getContactPermission() async {
//     PermissionStatus permission = await PermissionHandler()
//         .checkPermissionStatus(PermissionGroup.contacts);
//     if (permission != PermissionStatus.granted &&
//         permission != PermissionStatus.disabled) {
//       Map<PermissionGroup, PermissionStatus> permissionStatus =
//           await PermissionHandler()
//               .requestPermissions([PermissionGroup.contacts]);
//       return permissionStatus[PermissionGroup.contacts] ??
//           PermissionStatus.unknown;
//     } else {
//       return permission;
//     }
//   }

  
  // void _handleInvalidPermissions(PermissionStatus permissionStatus) {
  //   if (permissionStatus == PermissionStatus.denied) {
  //     throw new PlatformException(
  //         code: "PERMISSION_DENIED",
  //         message: "Access to location data denied",
  //         details: null);
  //   } else if (permissionStatus == PermissionStatus.disabled) {
  //     throw new PlatformException(
  //         code: "PERMISSION_DISABLED",
  //         message: "Location data is not available on device",
  //         details: null);
  //   }
  // }

  TextEditingController _textEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          inputPhoneNumber();
          
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
              itemCount: _contacts?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                Contact c = _contacts?.elementAt(index);
                return ListTile(
                  onTap: () {
                    
                    getPhoneNumber(c);
                    
                    Navigator.pop(context, selectedPhoneNumber);
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
    selectedPhoneNumber = await Navigator.push(context, MaterialPageRoute(builder: (context) => InputPhoneNumber()));
    //selectedPhoneNumber = await Navigator.pushNamed(context, InputPhoneNumberRoute);
    if(selectedPhoneNumber != null) Navigator.pop(context, selectedPhoneNumber);
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
        selectedPhoneNumber = s;
        return;
      }
    }
  }

  searchPhoneNumber(Contact _c) async{
    if(SoundSearcher.matchString(_c.displayName, _textEditingController.text)){
      return true;
    }
    else return false;
  }
}
