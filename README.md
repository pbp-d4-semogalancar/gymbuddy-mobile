# GymBuddy Mobile 🏋🏽🔥💪🏼

![Built_with-Flutter-0256D6](https://img.shields.io/badge/Built_with-Flutter-0256D6?style=flat-square)

[![Build Status](https://app.bitrise.io/app/7618b70e-f581-4785-a563-84e3e45ed207/status.svg?token=84kn4JlFwYnUJ0Ubrr1XBQ&branch=main)](https://app.bitrise.io/app/7618b70e-f581-4785-a563-84e3e45ed207)

# Download

Download aplikasi versi terbaru: [Download APK](https://app.bitrise.io/app/7618b70e-f581-4785-a563-84e3e45ed207/installable-artifacts/54bb2a8980d6c1ad/public-install-page/869a5bdcea5396a7e4f634102bd3efbb)

---

# Anggota Kelompok D04
- 2406358762	Riyaan Baihaqi
- 2406347380	Dery Andreas Tampubolon
- 2406495962	Wildan Muhammad Hafidz
- 2406495666	Rexy Adrian Fernando
- 2406495760	Raihana Auni Zakia
- 2406495501	Alderryl Juan Fauza

---

# Deskripsi Aplikasi
Setiap orang memiliki alasan yang berbeda-beda untuk berolahraga, ada orang yang ingin tubuh lebih kuat, ada yang mengejar bentuk tubuh impian, dan ada juga yang sekadar ingin hidup lebih sehat. Namun, yang sama dari semua alasan itu adalah tantangan yang dihadapi saat ingin memulai. Banyak sekali orang yang kebingunan workout apa yang sebaiknya dilakukan, bagaimana cara melakukan workout tersebut dengan benar, dan bagaimana agar bisa tetap seimbang dan konsisten hingga mencapai target. Gymbuddy hadir untuk menjawab seluruh tantangan tersebut dengan menciptakan sistem workout yang terstruktur, fleksibel, dan mudah diikuti.

Mulailah rutinitas workout anda bersama gymbuddy. Dimulai dari memilih workout melalui fitur how to pengguna dapat menjelajahi tutorial-tutorial workout sesuai dengan kebutuhannya. Pengguna tidak perlu ragu lagi, seluruh instruksi sudah tersaji dengan jelas. Selesai workout, hasilnya akan langsung tersimpan oleh fitur log yang dapat memberikan statistik workout anda selama seminggu bahkan sebulan. Gymbuddy juga memberikan tempat untuk saling bertanya, berbagi pengalaman, dan menemukan inspirasi melalui fitur community.  

Sudah siap untuk mendapatkan tubuh yang lebih kuat, bentuk tubuh impian, atau hidup yang lebih sehat? Dengan gymbuddy target anda akan tercapai dengan lebih cepat dan mudah!

---

# Daftar Modul

## How To ❓
- Dikerjakan oleh Wildan Muhammad Hafidz
- Fitur How To memungkinkan anda untuk menjelajahi berbagai tutorial workout yang relevan sesuai jenis otot yang ingin dilatih. Dengan fitur ini, anda dapat memilih jenis workout sesuai kebutuhan sehingga tidak ada kata tidak untuk produktif!

## Planner ✅
- Dikerjakan oleh Alderryl Juan Fauza 
- Modul **Planner** merupakan bagian dari fitur **log aktivitas** yang memungkinkan anda menyusun rancangan kegiatan workout pribadi anda. Dengan fitur ini, workout anda akan semakin lebih jelas, tertata, dan progresif!

## Target 🗓️
- Dikerjakan oleh Riyaan Baihaqi
- Modul **Target** memungkinkan anda untuk melihat realisasi planner anda. Modul ini memungkinkan anda untuk melakukan update progress dari planner anda, filtering progress bulanan dan mingguan, serta update realisasi target ke **log**.

## Profile 🤝
- DIkerjakan oleh Rexy Adrian Fernando
- Modul **Profile** memungkinkan anda untuk melakukan kostumisasi serta melihat profile orang lain. Modul ini memungkinkan anda mengenal lebih banyak orang sehingga membuka relasi lebih banyak.

## Thread 📝
- Dikerjakan oleh Dery Andreas Tampubolon
- Modul **Thread** merupakan bagian dari fitur **community** memungkinkan anda bertanya maupun sharing dengan pengguna lainnya. Dengan fitur ini, anda dapat memahami lebih banyak kegiatan workout.

## Reply 🌐
- Dikerjakan oleh Raihana Auni Zakia
- Modul **Reply** merupakan bagian dari fitur **community** memungkinkan anda untuk menjawab di community sekaligus sharing kegiatan workout anda. Dengan fitur ini, anda dapat membantu pengguna lainnya dalam kegiatan workout mereka.

---

# Dataset
GymBuddy menggunakan dataset publik berupa kaggle berikut:

- [**Gym Exercises Dataset (Kaggle)**](https://www.kaggle.com/datasets/rishitmurarka/gym-exercises-dataset) — *(author: rishitmurarka)*

  Dataset ini berisi berbagai informasi mengenai aktivitas gym, seperti:
  - 💪 Jenis workout  
  - 🏋️‍♀️ Equipment yang diperlukan  
  - 🧭 Langkah-langkah (step-by-step) kegiatan  
  - 🎯 Target otot yang ingin dilatih

  Dataset ini dibuat dengan *field* yang terdiri dari **nama kegiatan**, **deskripsi kegiatan**, hingga **waktu workout** agar mendukung produktivitas dan progress anda.

---

# Role Pengguna

## 1. Admin
- Admin dapat menghapus thread dan reply yang dibuat oleh user.

## 2. User
- User nantinya dapat melihat berbagai kegiatan workout yang dapat dilakukan beserta step by stepnya pada menu How To, membuat target dan memantau progress di log aktivitas, serta sharing rangkaian kegiatan melalui menu community.

---

# Alur Pengintegrasian dengan Web Service

Pengintegrasian aplikasi flutter dengan web service Django menggunakan fetch data berbasis API, di mana proses pengambilan dan pengiriman data dilakukan dalam format JSON. Proses dimulai dengan tahap autentikasi. Aplikasi mengirimkan kredensial pengguna ke endpoint auth/api/login/. Jika berhasil, server Django akan memberikan token autentikasi. Dalam kasus ini, digunakan package ```CookieRequest``` berfungsi mengelola cookie secara otomatis, termasuk session login Django. Kemudian, instance ```CookieRequest``` perlu dibagikan ke semua komponen di aplikasi Flutter karena menyimpan session/cookie login, misal saat login ke backend Django, server mengirim cookie (misal sessionid). ```CookieRequest``` menyimpan cookie ini di memori agar request selanjutnya bisa diautentikasi. Hal ini membuat semua request ke server yang memerlukan autentikasi dapat langsung menggunakan cookie login yang sama, yang sebelumnya disimpan. Penggunaan package ini dan _permission classes_ pada view Django memastikan bahwa backend hanya memproses permintaan dari pengguna yang sudah terverifikasi. Proses ini adalah tahap awal yang memungkinkan backend mengintegrasikan setiap aktivitas, mulai dari membuat log latihan hingga membalas Thread, dengan akun pengguna yang terverifikasi.

Langkah berikutnya adalah integrasi data untuk fitur-fitur spesifik. Dalam kasus ini, digunakan package ```http``` untuk mengirim request dan menerima response berupa JSON. Package ```http``` adalah package standar di Flutter/Dart untuk melakukan HTTP request (GET, POST, PUT, DELETE) ke server. Untuk semua fitur aplikasi seperti konten (Howto), komunitas (Thread dan Reply), planner (Workout Log dan Target), serta User Profile, aplikasi akan mengirimkan sebuah http request disertai dengan token autentikasi dari ```CookieRequest```. Server Django kemudian menerima request tersebut, memverifikasi token, dan memprosesnya berdasarkan tipe request (GET untuk mengambil data, POST untuk membuat data baru, PUT untuk memperbarui data, dan DELETE untuk menghapus data). Setelah selesai diproses, Django mengembalikan data dalam bentuk JSON melalui endpoint API yang sesuai. Setelah menerima data berbentuk JSON, aplikasi Flutter akan melakukan _parsing_ data tersebut untuk menampilkannya kepada pengguna atau untuk memperbarui state pada aplikasi. Secara keseluruhan, proses pertukaran data antara aplikasi Flutter dan server Django dilakukan melalui HTTP request–response dengan format data JSON sebagai standar utamanya.

# Link Figma
Link : https://www.figma.com/design/gd4ThrbN9Kt4ddC3wJG0LE/GymBuddy-fixed?node-id=0-1&t=98SSVTNFPLh6NyIG-1

# Link youtube video mockup
https://youtu.be/2xEFZSPYuvE?si=GGCLCeBegXWeahbx

# Implementasi bonus individu
Link blog Riyaan Baihaqi untuk implementasi testing: https://medium.com/@riyaanb2306/beyond-flutter-test-mastering-widget-integration-testing-in-gymbuddy-a-developers-reality-check-87b82560705c

Link blog Riyaan Baihaqi untuk advanced state management: https://medium.com/@riyaanb2306/escaping-setstate-hell-scalable-state-management-in-gymbuddy-using-provider-e84598eb859c
