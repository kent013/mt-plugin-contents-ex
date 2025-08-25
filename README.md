# ContentsEx Plugin for Movable Type

## 概要

ContentsEx プラグインは、Movable Type の標準的な `MTContents` タグを拡張し、非公開のコンテンツを含めて取得できるようにするプラグインです。

## 機能

- `MTContents` と同じ動作（デフォルト）
- `include_unpublished` パラメータで非公開コンテンツの取得を制御
- すべての既存の `MTContents` パラメータをサポート

## インストール

1. `mt/cms/plugins/` ディレクトリに `mt-plugin-contents-ex` フォルダをコピーします
2. Movable Type の管理画面でプラグインが有効になっていることを確認します

## 使用方法

### 基本的な使用（MTContentsと同じ動作）

```xml
<mt:ContentsEx content_type="news">
    <mt:ContentLabel />
</mt:ContentsEx>
```

### 非公開コンテンツを含める

```xml
<mt:ContentsEx content_type="news" include_unpublished="1">
    <mt:ContentLabel /> - <mt:ContentStatus />
</mt:ContentsEx>
```

### 明示的に公開のみを指定

```xml
<mt:ContentsEx content_type="news" include_unpublished="0">
    <mt:ContentLabel />
</mt:ContentsEx>
```

## パラメータ

### include_unpublished

- **型**: 真偽値（0 または 1）
- **デフォルト**: 0
- **説明**:
  - `0` または未指定: 公開されたコンテンツのみを取得（MTContentsと同じ）
  - `1`: すべてのステータスのコンテンツを取得（下書き、公開、レビュー、予約投稿を含む）

### その他のパラメータ

`MTContents` タグで使用可能なすべてのパラメータがそのまま使用できます：

- `content_type`: コンテンツタイプの指定
- `limit`: 取得件数の制限
- `offset`: オフセット
- `sort_by`: ソート項目
- `sort_order`: ソート順（ascend/descend）
- `category`: カテゴリフィルタ
- `author`: 著者フィルタ
- その他すべての MTContents パラメータ

## 使用例

### 例1: 最新の10件（非公開含む）を取得

```xml
<mt:ContentsEx content_type="news" include_unpublished="1" limit="10" sort_order="descend">
    <div class="content-item">
        <h3><mt:ContentLabel /></h3>
        <p>ステータス: <mt:ContentStatus /></p>
        <p>作成日: <mt:ContentDate /></p>
    </div>
</mt:ContentsEx>
```

### 例2: ステータスごとにスタイルを変える

```xml
<mt:ContentsEx content_type="news" include_unpublished="1">
    <mt:If tag="ContentStatus" eq="Draft">
        <div class="draft">
    <mt:ElseIf tag="ContentStatus" eq="Publish">
        <div class="published">
    <mt:ElseIf tag="ContentStatus" eq="Review">
        <div class="review">
    <mt:ElseIf tag="ContentStatus" eq="Future">
        <div class="scheduled">
    </mt:If>
        <mt:ContentLabel />
    </div>
</mt:ContentsEx>
```

### 例3: 件数の比較

```xml
<p>公開済み: <mt:ContentsEx content_type="news"><mt:ContentsCount /></mt:ContentsEx>件</p>
<p>全件: <mt:ContentsEx content_type="news" include_unpublished="1"><mt:ContentsCount /></mt:ContentsEx>件</p>
```

## 注意事項

- `include_unpublished="1"` を使用する場合は、非公開コンテンツが表示されることを考慮してください
- 管理画面やプレビュー用途での使用を推奨します
- 公開サイトで使用する場合は、適切なアクセス制御を実装してください

## 作者

kent013

## バージョン

1.0
