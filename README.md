# memo_snapshot
即時反映される簡易メモアプリ
## 画像

<table>
  <tr>
    <th>初期画面</th>
    <th>登録後画面</th>
  </tr>
  <tr>
    <td>
      <img width="300" src="https://user-images.githubusercontent.com/67848399/159882550-071238de-e3e0-4533-ae68-ffebd0768135.png">
    </td>
    <td>
      <img width="300" src="https://user-images.githubusercontent.com/67848399/159882532-d9083d02-876d-4d31-96cb-e39712ee2053.png">
    </td>
  </tr>
</table>

## コード部分
### snapshot
Flutterやってて初めて「SnapShot」って単語に出会いましたが、FlutterやFirebase用語ってわけではなく<br>
IT用語としてあるんですね。勉強になりました。

https://wa3.i-3-i.info/word14388.html

https://qiita.com/kabochapo/items/1ef39942ac1206c38b2d

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

## StreamBuilderとFutureBuilder
StreamBuilderを「即時更新してくれるもの」と理解するのは危ない。 <br>
以下の記事がとても参考になったのでリンク貼っておきます。<br>
タイムラインに効果的か？と思いましたが、開きっぱなしって言うのは怖い。Future Builder使って<br>
リロード機能とかが一般的な感じもする・・・。<br>
この辺はメモリやらパフォーマンスと比較して検討した方が良いのかなと思ってます。<br>
https://ryamamoto.netlify.app/2020/01/16/future-future-stream/
