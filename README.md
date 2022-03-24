# memo_snapshot
即時反映される簡易メモアプリ
## 画像
### 初期画面
<img width="300" src="https://user-images.githubusercontent.com/67848399/159882550-071238de-e3e0-4533-ae68-ffebd0768135.png">


### 登録後画面
5件だけ表示させ、上から新しい順になるようにしています。
<img width="300" src="https://user-images.githubusercontent.com/67848399/159882532-d9083d02-876d-4d31-96cb-e39712ee2053.png">

## コード部分
### snapshot
すごい雑な認識で、即時更新（監視）をしてくれるもの程度に認識しています。
```dart
final Stream<QuerySnapshot> _wordsStream =
    FirebaseFirestore.instance.collection('wordList').orderBy('create_at', descending: true).limit(5).snapshots();
```
#### 通常はこんな感じ
```dart
var snapshotId = await FirebaseFirestore.instance.collection('wordList').orderBy('id', descending: true).limit(1).get();
```

- `Stream<QuerySnapshot>`で定義すること
- 最後は`.get()`ではなく`.snapshots()`とすること

### 表示部分
Streamで取得しているので`StreamBuilder`を用います。簡易的に「取得エラー」「待機中」の処理もできます。
```dart
      body: StreamBuilder<QuerySnapshot>(
        stream: _wordsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // なんかエラーが起きた時
          if (snapshot.hasError) {
            return const Center(
                child: Text(
              'ERROR!! Something went wrong',
              style: TextStyle(fontSize: 30),
            ));
          }
          // 読み込み待ちの時
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text(
                "Loading...",
                style: TextStyle(fontSize: 30),
              ),
            );
          }
        .... 略
```

#### body
bodyはシンプルにListViewで表示です。
```dart
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
```
