# Examples

## ウォームアップ

- sample-notes.txt の第1フィールドを加工したものに置き換える例。
- 例の為の例だが、実践で必要になる要素は含まれている。
- この例を理解した上で、anki のデッキを一括で加工したい場合、次のような流れになる。
  1. Anki から notes をテキスト形式でエクスポート(必要に応じて空フィールを用意しておく)
  2. `extract-field.rb` や `mapper.rb` を駆使し、`items` ファイルに書き出す
  3. `insertt-field.rb` を使って、`items` のフィールドを置き換え、ファイルに書き出す。
  4. Ankiにインポート

`sample-notes.txt` はタブ区切りのこんな内容のテキスト。便宜上タブ文字を"\t"に置き換えている。

```
$ cat sample-notes.txt\t
apple\tりんご\t
orange\tオレンジ\t
grape\tグレープ\tmarked
rice\tライス\t
hat\t帽子\t
```

`extract-fields.rb` で第1フィールド(0が最初のフィールド)を抜き出して、`mapper.rb` に渡す。
ここでは `mapper.rb` はもらった単語を括弧付きにして返している。
確認して問題なければ `items` ファイルに書き出し。

```
$ cat sample-notes.txt | ruby extract-fields.rb -f1
りんご
オレンジ
グレープ
ライス
帽子
$ cat sample-notes.txt | ruby extract-fields.rb -f1 | ruby mapper.rb
( りんご )
( オレンジ )
( グレープ )
( ライス )
( 帽子 )
$ cat sample-notes.txt | ruby extract-fields.rb -f1 | ruby mapper.rb > items
```

`insert-field.rb` に渡す。
```
$ ruby insert-field.rb sample-notes.txt items
 0: "apple"
 1: "りんご"
 2: ""

Usage: add-quiz.rb [options] TARGET_FILE FROM_FILE
    -i, --index VALUE                Index to insert/replace(-r) field. (default: )
    -r, --replace                    Replace field insetead of insert(default behavior). (default: false)
    -c, --check                      Check with first line. (default: false)
```

index 1の"りんご"後に `items` ファイルのアイテムを挿入したいので、オプションは `-i 2`  
`-c` のチェックオプションをつけて実行

```
$ ruby insert-field.rb sample-notes.txt items  -i 2 -c
{:index=>2, :replace=>false, :check=>true}
 0: "apple"
 1: "りんご"
 2: "( りんご ) <---- Inserted"
 3: ""
```

うまくいってそうなので、`sample-notes-new.txt` に書き出し。

```
$ ruby insert-field.rb sample-notes.txt items  -i 2 -c > sample-notes-new.txt
$ cat sample-notes-new.txt
{:index=>2, :replace=>false, :check=>true}
 0: "apple"
 1: "りんご"
 2: "( りんご ) <---- Inserted"
 3: ""
$ ruby insert-field.rb sample-notes.txt items  -i 2  > sample-notes-new.txt
$ cat sample-notes-new.txt
apple	りんご	( りんご )
orange	オレンジ	( オレンジ )
grape	グレープ	( グレープ )	marked
rice	ライス	( ライス )
hat	帽子	( 帽子 )
```

### 画像へのリンクを追加する

mapper の実装は以下
```ruby
def map(item)
  %!<img src="google-img--#{item}.jpg">!
end
```

例
```
$ cat sample.tsv
tactic	戦術、戦法、作戦
backfire	計画などが裏目に出る、エンジン・車がさか火を起こす
catastrophic	壊滅的な、大異変の、最悪の
$ cat sample.tsv | ruby extract-fields.rb -f0
tactic
backfire
catastrophic
$
$ cat sample.tsv | ruby extract-fields.rb -f0 | ruby mapper.rb
<img src="google-img--tactic.jpg">
<img src="google-img--backfire.jpg">
<img src="google-img--catastrophic.jpg">
$ cat sample.tsv | ruby extract-fields.rb -f0 | ruby mapper.rb  > items
$ ruby insert-field.rb sample.tsv items
 0: "tactic"
 1: "戦術、戦法、作戦"

Usage: add-quiz.rb [options] TARGET_FILE FROM_FILE
    -i, --index VALUE                Index to insert/replace(-r) field. (default: )
    -r, --replace                    Replace field insetead of insert(default behavior). (default: false)
    -c, --check                      Check with first line. (default: false)
$
$ ruby insert-field.rb sample.tsv items -i 2 -c
{:index=>2, :replace=>false, :check=>true}
 0: "tactic"
 1: "戦術、戦法、作戦"
 2: "<img src=\"google-img--tactic.jpg\"> <---- Inserted"
$
$ ruby insert-field.rb sample.tsv items -i 2
tactic	戦術、戦法、作戦	<img src="google-img--tactic.jpg">
backfire	計画などが裏目に出る、エンジン・車がさか火を起こす	<img src="google-img--backfire.jpg">
catastrophic	壊滅的な、大異変の、最悪の	<img src="google-img--catastrophic.jpg">
$
```

# 各スクリプトの説明

# insert-field.rb

`TARGET_FILE` の指定したフィールドに、FROM_FILEに 書かれたアイテムを一つずつ読み込んで挿入する。  

```
$ ruby insert-field.rb -h
Usage: add-quiz.rb [options] TARGET_FILE FROM_FILE
    -i, --index VALUE                Index to insert/replace(-r) field. (default: )
    -r, --replace                    Replace field insetead of insert(default behavior). (default: false)
    -c, --check                      Check with first line. (default: false)
$
```

## extract-fields.rb

help

```
$ ruby extract-fields.rb -h
Usage: extract-fields [options]
    -r, --report                     Report field configuration from very 1st line. (default: false)
    -s, --split VALUE                string value (default: "\t")
    -j, --join VALUE                 string value (default: "\t")
    -f, --fields one,two,three       fields to extract (default: [])
```

Now explain with this `sample.txt` each fields are separated with tab(`\t`) char.

```
$ cat sample.txt
foo1	foo2	foo3
bar1	bar2	bar3
baz1	baz2	baz3
```

`-r` is useful to check field number from very 1st line.

```
$ cat sample.txt | ruby extract-fields.rb -r
opts: {:report=>true, :split=>"\t", :join=>"\t", :fields=>[]}
args: []

 1: foo1
 2: foo2
 3: foo3

```

Now lets' extract field 1 and 3.

```
$ cat sample.txt | ruby extract-fields.rb -f 1,3
foo1	foo3
bar1	bar3
baz1	baz3
```

This time, I extract 1 and 3, but custom order.

```
$ cat sample.txt | ruby extract-fields.rb -f 3,1
foo3	foo1
bar3	bar1
baz3	baz1
```

With `-j` option, I can join fields with custom string, here I use `--`.

```
$ cat sample.txt | ruby extract-fields.rb -f 3,1 -j '--'
foo3--foo1
bar3--bar1
baz3--baz1
$
```

## mapper.rb

標準入力から来たテキストを加工して、標準出力に出す、超単純なフィルタ.
毎回、必要に応じて適宜書き換えて使用することを想定。
