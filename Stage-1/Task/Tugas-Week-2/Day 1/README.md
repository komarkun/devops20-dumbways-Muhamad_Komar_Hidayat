# Summary Day 1 Week 2

## BASH

BASH (Bourne Again Shell) adalah penerjemah baris perintah yang banyak digunakan untuk sistem operasi mirip Unix dan Unix, termasuk Linux. Ini berfungsi sebagai shell default untuk sebagian besar distribusi Linux karena fleksibilitas, ketahanan, dan fiturnya yang luas. Berikut ringkasan aspek-aspek utamanya:

Interpretasi Perintah: BASH menafsirkan perintah pengguna, menjalankannya dan memberikan umpan balik sebagai keluaran. Ini mendukung berbagai perintah dan utilitas yang tersedia di lingkungan Linux.

Scripting: BASH juga merupakan bahasa scripting, memungkinkan pengguna untuk menulis dan menjalankan skrip untuk mengotomatisasi tugas, melakukan administrasi sistem, dan mengembangkan aplikasi. Skrip BASH biasanya memiliki ekstensi .sh.

Fitur Pemrograman Shell: BASH menawarkan berbagai konstruksi pemrograman seperti loop, kondisional, fungsi, dan variabel, memungkinkan pengguna membuat skrip dan aplikasi yang kompleks.

Pengeditan Baris Perintah: BASH menyediakan fitur pengeditan baris perintah, termasuk riwayat perintah, pengikatan kunci yang dapat disesuaikan, dan pintasan untuk entri dan pengeditan perintah yang efisien.

Kontrol Pekerjaan: BASH mendukung kontrol pekerjaan, memungkinkan pengguna untuk mengelola beberapa proses yang berjalan di latar belakang, menunda/melanjutkan proses, dan beralih antara tugas latar depan dan latar belakang.

Ekspansi Shell: BASH melakukan ekspansi shell, yang mencakup ekspansi wildcard (globbing), ekspansi brace, ekspansi tilde, dan ekspansi variabel, menyederhanakan entri perintah dan skrip.

Pengalihan dan Pipa: BASH mendukung pengalihan input/output dan pemipaan, memungkinkan pengguna untuk mengarahkan output perintah ke file, menggabungkan beberapa perintah menggunakan pipa, dan memanipulasi aliran data secara efisien.

Kustomisasi: BASH sangat dapat dikustomisasi, memungkinkan pengguna untuk mengkonfigurasi berbagai aspek lingkungan shell, termasuk tampilan prompt, alias, variabel lingkungan, dan perilaku shell.

Fitur Shell Interaktif: BASH menyediakan fitur shell interaktif seperti penyelesaian tab, penyelesaian baris perintah, dan bantuan peka konteks, meningkatkan produktivitas pengguna dan kemudahan penggunaan.

Ekstensibilitas: BASH mendukung ekstensi dan plugin shell melalui alat dan kerangka kerja pihak ketiga, memungkinkan pengguna untuk memperluas fungsinya dengan fitur dan kemampuan tambahan.

## Shell Command

- File Management:

cp: Copy files or directories.
mv: Move or rename files or directories.
rm: Remove files or directories.
mkdir: Create directories.
rmdir: Remove directories.

- File Manipulation:

cat: Concatenate and display file contents.
grep: Search for patterns in files.
sed: Stream editor for filtering and transforming text.
awk: Powerful pattern scanning and processing language.
find: Search for files in a directory hierarchy.
sort: Sort lines of text files.
cut: Extract sections from each line of files.
head: Output the first part of files.
tail: Output the last part of files.
wc: Count words, lines, and characters in a file.

- System Information:

uname: Print system information.
df: Report file system disk space usage.
du: Estimate file space usage.
free: Display amount of free and used memory in the system.
top: Display system processes in real-time.
ps: Report a snapshot of the current processes.

- Text Processing:

echo: Display a line of text.
printf: Format and print data.
tr: Translate or delete characters.
grep: Search for patterns in files.
awk: Text processing tool for pattern scanning and processing.
sed: Stream editor for filtering and transforming text.

- Networking:

ping: Send ICMP ECHO_REQUEST to network hosts.
ifconfig (or ip): Configure network interfaces.
netstat: Print network connections, routing tables, interface statistics, masquerade connections, and multicast memberships.
ssh: Secure Shell remote login client.

- Process Management:

ps: Report a snapshot of the current processes.
kill: Send signals to processes.
bg: Run jobs in the background.
fg: Bring jobs to the foreground.
nice: Modify the priority of processes.
nohup: Run commands immune to hangups.

- User and Group Management:

useradd: Create a new user or update default new user information.
userdel: Delete a user account and related files.
usermod: Modify a user account.
groupadd: Create a new group.
groupdel: Delete a group.
passwd: Change user password.
