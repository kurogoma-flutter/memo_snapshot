import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// テキストボックスに文字を入れて送信ボタンを押すと、データベースに登録されるようにせよ。
// そして、データを画面に表示できる量だけ取り出して時刻順に並べて表示せよ。

class TextListPage extends StatefulWidget {
  const TextListPage({Key? key}) : super(key: key);

  @override
  _TextListPageState createState() => _TextListPageState();
}

class _TextListPageState extends State<TextListPage> {
  final TextEditingController _textController = TextEditingController();
  late String _text;

  @override
  void initState() {
    super.initState();
  }

  final Stream<QuerySnapshot> _wordsStream =
      FirebaseFirestore.instance.collection('wordList').orderBy('create_at', descending: true).limit(5).snapshots();

  _storeText() async {
    if (_text.isEmpty || _text == "") {
      return '入力されていません';
    }
    List<DocumentSnapshot> _last = [];
    int _lastId; // collectionの中で最新のID取得
    var snapshotId = await FirebaseFirestore.instance.collection('wordList').orderBy('id', descending: true).limit(1).get();
    setState(() {
      _last = snapshotId.docs;
    });
    _lastId = _last[0]['id'];
    int _id = _lastId + 1; // 登録するID

    await FirebaseFirestore.instance.collection('wordList').add({
      "id": _id,
      "text": _text,
      "create_at": Timestamp.now(),
    });
    setState(() {
      _text = '';
    });
    _textController.clear();
  }

  _createAtText(data) {
    var timestamp = data['create_at'];
    DateTime createdAt;
    DateFormat format = DateFormat('yyyy-MM-dd-H:m');
    if (timestamp is Timestamp) {
      // toDate()でDateTimeに変換
      createdAt = timestamp.toDate();
    } else {
      createdAt = DateTime.now();
    }

    return format.format(createdAt).toString();
  }

  @override
  Widget build(BuildContext context) {
    // メディアクエリ
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('単語一覧'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _wordsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
                child: Text(
              'ERROR!! Something went wrong',
              style: TextStyle(fontSize: 30),
            ));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text(
                "Loading...",
                style: TextStyle(fontSize: 30),
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        controller: _textController,
                        autovalidateMode: AutovalidateMode.onUserInteraction, // 入力時バリデーション
                        cursorColor: Colors.blueAccent,
                        decoration: const InputDecoration(
                          focusColor: Colors.red,
                          labelText: 'メモ',
                          hintText: 'テキストを入力してください',
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                          border: OutlineInputBorder(borderSide: BorderSide()),
                        ),
                        maxLines: 1,
                        onChanged: (value) {
                          setState(() {
                            _text = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "入力してください";
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          _storeText();
                        },
                        child: const Text(
                          '+',
                          style: TextStyle(fontSize: 32),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.cyan,
                          onPrimary: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  child: ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black45),
                        ),
                        child: ListTile(
                          leading: Text(data['id'].toString()),
                          title: Text(
                            data['text'] ?? 'データがありません',
                            style: const TextStyle(fontSize: 20),
                          ),
                          subtitle: Text(
                            _createAtText(data),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
