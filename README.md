# install-cream-playbook

## 開発・評価環境

- MacOSX: Catalina 10.15.7
- ansible: core 2.11.6
- python: 3.10.0
- sshpass: 1.06

# 手順

本playbookを使ったcream install手順を示す。

以下のOSインスタンスにインストールする

```sh:host
SODA開発サーバー
ip: 153.120.45.64
rootパスワード:  d4MTZNHJ 」
```

1. ホスト情報を取得し、Inventoryエントリを編集する

```sh:INVENTRIES/d4MTZNHJ
[all]
d4MTZNHJ ansible_port=22 ansible_host=153.120.45.64 ansible_user=root ansible_password=d4MTZNHJ
```

2. ansible ping

上記Inventoryでansible導通確認を行う。

```sh:
taku@takus-iMac SaaS-cream % ansible -m ping -i INVENTRIES/d4MTZNHJ all
```

https://asciinema.org/a/FRSXiKRoj9NBSMKIJiGsUDP41

3. site.ymlの実行

```sh:site.yml
taku@takus-iMac SaaS-cream % ansible-playbook -i INVENTRIES/d4MTZNHJ site.yml

```

このplaybookを実行すると、user creamの公開鍵ペアが生成されます。
"(playbookディレクトリ)/KEYS/(ホスト名)/home/cream/.ssh/"
公開鍵をgitolite-adminに登録し、公開ホスト名の配布を受けます。
また、鍵ペアはchmode 600して、以下の手順で使用します。

https://asciinema.org/a/JFhYlVUlXlMMphXepY8tpQ1K9


4. 登録

公開鍵をgitolite-adminに登録し、公開ホスト名を取得したら、Inventoryエントリを編集する

```sh:INVENTRIES/d4MTZNHJ.doascream
[all]
d4MTZNHJ ansible_port=10022 ansible_host=153.120.45.64 ansible_user=cream ansible_ssh_private_key_file=KEYS/d4MTZNHJ/home/cream/.ssh/id_rsa public_hostname=cream_test1102
```

変更箇所はポート番号、ユーザ名、認証鍵指定それとpublic_hostnameに公開ホスト名を指定します。

5. pingの実行

新しいInventoryでansible pingを行い、導通性を確認する。

```sh:
taku@takus-iMac SaaS-cream % ansible -m ping -i INVENTRIES/d4MTZNHJ.doascream all
```

6. site2.ymlの実行

```sh:site2.yml
taku@takus-iMac SaaS-cream % ansible-playbook -i INVENTRIES/d4MTZNHJ.doascream site2.yml

```

https://asciinema.org/a/WtxjcX9JP7rk089GSr23j3npB


7. creamで/home/cream/bundler-apa.shを手動起動

注意：制限：現在bundler-apa.shがansibleから正しく動作しません。

user creamでサーバにログインして。手動で起動してください。

```sh:
[cream@ik1-218-79310 ~]$ ls
A  bundler-apa.sh  creamcrontab  rails  rbenv.sh  ruby-build  ruby-build2.sh
[cream@ik1-218-79310 ~]$ sh bundler-apa.sh
```

# playbook&roles詳細

各playbookとroleについて

## site.yml

最初に実行するplaybook

構築前確認とuser creamでアクセスできるようにします。

## 01confirm.yml

構築前確認を行うplaybook

この時のInventoryエントリーは以下のようになります。

```sh:inventory
d4MTZNHJ ansible_port=22 ansible_host=153.120.45.64 ansible_user=root ansible_password=d4MTZNHJ
```

### roles/01confirm:

443/10022ポートオープン

### roles/02doasroot.yml

構築前確認後、先ずrootユーザで行うロールになります。

1. add user cream(鍵ペアの作成)
2. visudo
3. sshd_config

このロールではuser creamの作成と鍵ペアの生成が行われます。creamのpasswordはInventoryエントリの第１エントリ（ここでは「ホスト名」と呼びます）と同じになります。また鍵ペアはansibeを実行したホストの
"(playbookディレクトリ)/KEYS/(ホスト名)/home/cream/.ssh/" ディレクトリにfetchされます。以降、user creamでアクセスするには、このpasswordもしくは鍵ペアを使います。

このロール実行後はsshポートが10022になります。以降は、必要に応じてinventoryのエントリを変更してください。

また、手続きとして、公開鍵をgitolite-adminに登録し、公開ホスト名の配布を受けます。

これ以降はuser creamでの設定になりますので、inventoryのエントリ変更が必要になります。
認証情報は上記のpasswordもしくは鍵ペアを使うことになります。また配布を受けた公開ホスト名をpublic_hostname変数に設定します。

```sh:inventory
d4MTZNHJ ansible_port=10022 ansible_host=153.120.45.64 ansible_user=cream ansible_ssh_private_key_file=KEYS/d4MTZNHJ/home/cream/.ssh/id_rsa public_hostname=cream_test1102
```

## site2.yml

このplaybookではuser creamで行うタスクです。

### roles/03doascream.yml

このplaybookではuser creamで行います。

### roles/031doascream

このロールでは環境設定などで必要となる以下の処理を行う
1. 各種ライブラリのインストール
2. http/mariadbのインストールと起動
3. rbevn/ruby/gemのbuild・インストール

### roles/032mysql

このロールでは
1. mariadb(mysql)pythonライブラリのインストール
2. rootパスワードの設定（rootのpasswordはvars/main.ymlに記載）
3. user creamの作成(creamユーザ名のpasswordはvars/main.ymlに記載。creamリポジトリのrails/cream/config/database.ymlとは連動していないので、注意)
4. db creamの作成

### roles/033gitconfig

このロールでは、creamのリポジトリをcloneします。

### roles/034httpd

このロールではhttpの環境設定を行います。
1. config設定（ここではSSL・httpはありませんので注意）
2. httpポートの開放
3. httpdの再起動
4. CREAM起動スクリプト(bundler-apa.sh)の実行(## 注意・制限：現状ansibleから起動できないので、shellで起動してください。)

### roles/035crontab

このロールではcreamに必要なcronのコメントエントリを登録します。
