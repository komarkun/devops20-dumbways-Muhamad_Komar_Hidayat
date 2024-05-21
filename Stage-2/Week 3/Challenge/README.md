### Challenge Week3 Gitlab Runner on self hosted Machine

untuk melakukan implementasi gitlab runner di projek CI/CD kita, hal pertama yang perlu dilakukan adalah menginstall gitlab runner nya di server yang mau kita jadikan selfhosted oleh si gitlab nya. dan kita wajib melihat ke dokumentasi resmi untuk installasi tersebut.

server ubuntu/debian :

```bash
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash


sudo apt-get install gitlab-runner
```

![Alt text](https://media.discordapp.net/attachments/1242141738857136178/1242379772202319912/Screenshot_from_2024-05-21_11-56-19.png?ex=664d9fd3&is=664c4e53&hm=fdb9ca6a333bb40a0bae12d72ed5a39d25d5f89519cc62a28287e450b00e45e4&=&format=webp&quality=lossless&width=1179&height=663)

setelah terinstall/ langkah selanjutnya adalah kita registrasi runner tersebut, buka terlebih dahulu di web site gitlab runner nya lalu masuk ke projek yang telah kita upload dan masuk ke settingan gitlab runner.

![Alt text](https://media.discordapp.net/attachments/1242141738857136178/1242379772567355402/Screenshot_from_2024-05-21_11-54-10.png?ex=664d9fd4&is=664c4e54&hm=969dacfc0bb3ae4a733312f9783dd9f097e5c11b4efbd882b87c9b03ec17f209&=&format=webp&quality=lossless&width=1440&height=590)

setelah itu kita masukan step by step yg ada di server yg sudah terinstall gitlab runner.

```bash
sudo gitlab-runner register

# Masukan Link url gitlab dan masukan juga aitorize token yg sudah di generate di gitlabnya
```

Kita bisa centang run untag runner supaya lebih eazy peazy lagi, karena jika di centang maka artinya semua tag nya nanti akan di jalankan. dan jangan lupa pilih executor nya (shell) atau apapun bebas sesuai yang ada di pipeline

![Alt text](https://media.discordapp.net/attachments/1242141738857136178/1242383575932997642/image.png?ex=664da35e&is=664c51de&hm=958fe36268ce1255263965612046185394aa38475df0056416f8fe20621c0252&=&format=webp&quality=lossless&width=1179&height=663)
![Alt text](https://media.discordapp.net/attachments/1242141738857136178/1242379771883683850/Screenshot_from_2024-05-21_12-02-12.png?ex=664d9fd3&is=664c4e53&hm=08804049990a6bc5bd29fed223a33025267691052944982e079d8c1fef2f6176&=&format=webp&quality=lossless&width=1440&height=256)

setelah semua sudah komplit kita bisa run ulang pipeline
![Alt text](https://media.discordapp.net/attachments/1242141738857136178/1242295355404718080/image.png?ex=664d5135&is=664bffb5&hm=2661d2f93367b7f16647afafc3d7a66e88c7369103df777f14c9ec5aa58d097b&=&format=webp&quality=lossless&width=1310&height=663)

dan wajib sekali kita matikan runner bawaannya supaya nanti menggunakan runner yg sudah kita setup

![Alt text](https://cdn.discordapp.com/attachments/1242141738857136178/1242384628099190815/image.png?ex=664da459&is=664c52d9&hm=f8a9aa3afa8a89f38e37c45011cd216ff05a9955df97603154414e5f8ea48eed&)

jangan lupa cek kembali dengan lebih detail apakah pipeline kita sudah running dengan menggunakan gitlab runner atau tidak dengan mengecek lebih detail lagi ke dalam.

![Alt text](https://media.discordapp.net/attachments/1242141738857136178/1242379771204337674/Screenshot_from_2024-05-21_14-32-03.png?ex=664d9fd3&is=664c4e53&hm=b9a1170316a302582a416dbc0f2cf13c4cb1c54ed4fedd8539fd3a0f59068aa9&=&format=webp&quality=lossless&width=1440&height=525)

untuk di case saya nama runner instance nya adalah komar-runner-machine artinya runner tersebut berhasil kita jalankan
