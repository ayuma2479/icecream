# 屋台注文アプリ

ポップコーン350円、ナゲット400円、コーラ150円を選んで注文するFlutterアプリです。
フードとコーラのセットは50円引き、マヨネーズ・ケチャップは無料、紙ナプキンは10円です。
価格は税抜で、消費税10％を加算します。注文とレシートはブラウザ内で表示します。

公開URL: https://ayuma2479.github.io/icecream/

## 開発・確認

```sh
flutter pub get
flutter test
flutter run -d chrome
```

## GitHub Pagesの更新

Pagesの公開元は `main` ブランチの `/docs` です。
アプリを変更したら、公開用ファイルを再生成してコミット・pushします。

```sh
flutter build web --release --base-href /icecream/
rsync -a --delete build/web/ docs/
touch docs/.nojekyll
git add lib test web docs pubspec.lock README.md
git commit -m "Update ordering app"
git push origin main
```
