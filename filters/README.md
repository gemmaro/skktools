# filters/ ディレクトリ

For non-Japanese users: Please consult the header of each script for instruction in English.

## はじめに

SKK 辞書を加工・編纂するためのツール群です。


## 実行環境

バージョン 2.1 以降の ruby が必要です。skkdictools.rb を ruby のロード
パスが通っている場所に置いてください。

## abbrev-convert.rb

英数文字からカタカナ語に変換する abbrev ペアを抽出し、ひらがな・カタカ
ナ変換や和英変換用のペアに加工します。

L 辞書の abbrev ペアを元に、和英変換辞書を作成します。

```
% abbrev-convert.rb -w SKK-JISYO.L | skkdic-expr2 > SKK-JISYO.waei
```

### 動作モード

* `-e`
abbrev ペアを抽出します。「cat /キャット/」

* `-k`
abbrev ペアを、ひらがな・カタカナ変換ペアに加工して出力します。
「きゃっと /キャット/」

* `-K`
-k と同様ですが、元の見出しを annotation として添付します。
「きゃっと /キャット;cat/」

* `-w`
abbrev ペアを、和英変換ペアに加工して出力します。
「きゃっと /cat/」

### その他のオプション

* `-p`
※を含む、または ? で終わる annotation を持つ候補を除外します。

* `-s VAL`
文字数 VAL 以下の候補を除外します。

* `-u`
元のペアについていた annotation を添付せずに削除します。

## abbrev-simplify-keys.rb

abbrev エントリの見出しを小文字化し、英数文字以外の記号を全て除去して
出力します。
```
% abbrev-simplify-keys.rb -s 3 SKK-JISYO.L > tmp.txt
% skkdic-expr2 SKK-JISYO.L + tmp.txt > SKK-JISYO.L.modified
```

L 辞書から、見出しが 3 文字以上の abbrev ペアを抽出し、見出しを単純化し
て L 辞書に戻してやります。

	「B-spline /Ｂ−スプライン/」 => 「bspline /Ｂ−スプライン/」

## annotation-filter.rb

SKK 辞書の annotation を加工・抽出します。

```
% annotation-filter.rb SKK-JISYO.L | skkdic-expr2 > SKK-JISYO.L.unannotated
```

何も指定しなければ、全ての annotation を除去して出力します。
(skkdic-expr2 が必要な他は unannotation.awk と同等です。)

```
% annotation-filter.rb -d SKK-JISYO.L | skkdic-expr2 > SKK-JISYO.L.minimally-annotated
```

`-d` を指定すると、プリセット済みのフィルタを適用します。annotation に
「※」を含む、または ? で終わる候補を削除し、「旧字」「異体字」「本字」
「大字」「†」「→」を含むものを除く全てのannotation を削除して出力しま
す。

```
% annotation-filter.rb -d -e '\[卑\] -U 'NB:' -j 5 SKK-JISYO.L | skkdic-expr2 > SKK-JISYO.L.minimally-annotated
```

`-d` にさらに条件を追加することもできます。「[卑]」を含む annotation を
持つ語を削除 (`-e`) し、「NB:」を含む annotation は削除せずに残します (`-U`)。
また、候補が 5 個以上あるエントリでは annotation の削除は行いません (`-j`)。
`-e`, `-u`, `-U`, `-x` などで指定する文字列は ruby の正規表現として扱われます。

```
% annotation-filter.rb -k -s -u '原義|字義' SKK-JISYO.L | skkdic-expr2 > SKK-JISYO.L.slightly-unannotated
```

`-k` を指定すると、標準では annotation を削除しなくなります。この例では、
「原義」または「字義」を含む annotation (`-u`)、及び見出しと候補が一対一に
対応しているエントリにつけられた annotation (`-s`) のみを削除して出力しま
す。

```
% annotation-filter.rb -t -k -x '\[化学\]' SKK-JISYO.L | skkdic-expr2 > SKK-JISYO.L.chemistry
```

`-t` を指定すると、条件に合った annotation を持つペアのみを出力します。
この例では、「[化学]」と annotate された語のみを抽出しています。

全ての場合で、annotation のうち「‖」以降の部分は自動的に削除されます
が、`-b` を与えることで逆に「‖」以降は決して削除されない動作になります。
「‖」以降の文字列は、`-u` などの対象にもなりません。原則的に、全て消す
か、全て残すかになります。「‖」以降は annotation ではなく comment であ
るというわけです。（conjugation.rb の項目参照）

```
% annotation-filter.rb -Btk -x 'ワ行五段' SKK-JISYO.notes
```

`-B` を指定すると、この特別扱いを行わず、「‖」以降も通常の annotation 
として扱います。

### asayaKe.rb

送り仮名を持っている okuri-nasi ペアを、okuri-ari に変換して出力します。

	「あさやけ /朝焼け/」 → 「あさやk /朝焼/」

```
% asayaKe.rb -p SKK-JISYO.L > SKK-JISYO.asayaKe
% skkdic-expr2 SKK-JISYO.L + SKK-JISYO.asayaKe > SKK-JISYO.L.new
```

この操作で、送り仮名のある語は原則として全て okuri-ari として入力でき
るようになります。


`-e` を指定した場合は変換せずに抽出のみを行い、`-E` を指定した場合は変換前
と変換後の両方のペアを出力します。

`-o` を指定すると、削除した送り仮名を comment として添付します。

	「あさやけ /朝焼け/」 → 「あさやk /朝焼;‖-け/」

`-O` を指定すると、skk-henkan-okuri-strictly に対応した形式で出力します。
（実験的なものです）

	「あさやけ /朝焼け/」 → 「あさやk /朝焼/[け/朝焼]/」

`-u` で、元のペアについていた annotation を削除します。

`-p` で、※を含む、または ? で終わる annotation を持つ候補を除外します。

## complete-numerative.rb

　#0,#1,#2,#3 のいずれかを含む数値変換ペアから、#0,#1,#2,#3 のそれぞれを
含む 4 つのペアを作成して出力します。不揃いな数値変換エントリを補完する
のに用います。

	「#つぼ /#1坪/」 → 「#つぼ /#3坪/#1坪/#0坪/#2坪/」

```
% complete-numerative.rb SKK-JISYO.L > SKK-JISYO.num
% skkdic-expr2 SKK-JISYO.L + SKK-JISYO.num > SKK-JISYO.L.new
```

　こうしてやれば、「２０坪」は入力できても「二十坪」は入力できないといっ
たことがなくなります。

```
% complete-numerative.rb -o 0312 SKK-JISYO.L > SKK-JISYO.num
% skkdic-expr2 SKK-JISYO.L - SKK-JISYO.num + SKK-JISYO.num > SKK-JISYO.L.new
```

`-o` で、出力順をデフォルトの /#3/#1/#0/#2/ から変更できます。この例の操
作によって、全ての数値変換ペアを好みに合った出現順に並べ替えることができ
ます。

`-u` で、元のペアについていた annotation を削除します。

`-p` で、※を含む、または ? で終わる annotation を持つ候補を除外します。

## conjugation.rb

単語に付与された comment （「‖」以降の annotation）を利用して、必要な
各種派生形を出力します。主に、comment つき辞書 SKK-JISYO.notes や、品詞
情報を出力する変換スクリプトである prime2skk.rb, ipadic2skk.rb と併用し
て利用します。

	「あいしあu /愛し合;‖ワ行五段[wiueot(c)]/」
	↓
	「あいしあw /愛し合/」
	「あいしあi /愛し合/」
	「あいしあu /愛し合/」
	「あいしあe /愛し合/」
	「あいしあo /愛し合/」
	「あいしあt /愛し合/」
	「あいしあc /愛し合/」 ※ -p が指定された時のみ、(c)の部分も展開します

標準では、全ての okuri-ari エントリと、候補が一文字の okur-nasi ペアが
対象となります。`-o` を指定すれば全ての okuri-nasi エントリが対象になり、
逆に `-O` を指定すれば、全ての okuri-nasi エントリが対象外となります。この
制限は、莫大な数になるサ変動詞と形容動詞の出力を必要に応じて制御するため
のものです。

`-x` で、※を含む、または ? で終わる annotation を持つ候補を除外します。

`-u` を指定すると、派生形には annotation を付与しません。
`-U` を指定すると、原形（元の単語）からも annotation を除去します。

`-c` を指定すると、派生形には comment を付与しません。
`-C` を指定すると、原形（元の単語）からも comment を除去します。

## make-tankan-dic.rb

見出しがひらがなで、候補が漢字一文字のペアを抽出します。L 辞書にこの処
理を施すと、skk-tankan.el に適したコンパクトな単漢字辞書を生成できます。

`-u` で、元のペアについていた annotation を削除します。
`-p` で、※を含む、または ? で終わる annotation を持つ候補を除外します。

```
% make-tankan-dic.rb SKK-JISYO.L | skkdic-expr2 > SKK-JISYO.tankan
```

	;; .skk
	(add-to-list 'skk-search-prog-list
	  '(skk-tankan-search 'skk-search-jisyo-file
	    "~/skk/dic/SKK-JISYO.tankan" 0))

## 半自動適用

CVS をご利用の方は、skk/dic ディレクトリで `make all` とすればこれらのスク
リプトを応用した各種のプリセット辞書を生成できます。

* 和英変換や形容動詞・サ変動詞の okuri-ari 変換に対応した `SKK-JISYO.L+`

* annotation を最小限に抑えた `SKK-JISYO.L.taciturn`

* SKK で提供している全ての辞書を統合した `SKK-JISYO.total+zipcode`

などがその一例です。skk/dic/Makefile もご参照ください。

## 共通の注意事項

* 現時点では、ユーザー辞書に含まれる、送り仮名を含んだデータ("[]"で括ら
れたもの)には対応していません。

* EUC-JP 以外のエンコーディングにも対応していません。

* ほぼ全てのスクリプトが、skkdic-expr2 との併用を前提としています。出力
結果を実際の辞書として使用する前に必ず skkdic-expr2 を通すようにしてくだ
さい。

## 著者

三田祐介 < clefs<span></span>@mail.goo.ne.jp >
