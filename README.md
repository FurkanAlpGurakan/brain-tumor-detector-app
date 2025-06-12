🧠 BrainUp – Beyin Tümörü Tespiti için Yapay Zeka Destekli Mobil Uygulama
BrainUp, beyin MR görüntüleri üzerinden yapay zeka ile tümör tespiti yapabilen mobil bir sağlık uygulamasıdır. Uygulama, kullanıcıların yüklediği MR görüntülerini analiz ederek “Normal” veya “Anormal” sonucu sunar ve tüm sonuçları kullanıcı bazlı olarak saklar.

📌 Bu proje, TÜBİTAK 2209-A – Üniversite Öğrencileri Araştırma Projeleri Destekleme Programı kapsamında desteklenmiştir.

🎯 Proje Amacı
Beyin tümörlerinin erken teşhisine yardımcı olacak yapay zeka destekli mobil bir sistem geliştirmek.

Tıbbi uzmanlık gerektirmeden, kullanıcı dostu arayüzü ile kişisel sağlık takibi sağlamak.

Kullanıcıların test geçmişlerini görsel ve tarihsel olarak takip etmelerine imkân tanımak.

⚙️ Kullanılan Teknolojiler
Bileşen	Teknoloji
Frontend	Flutter (Dart)
Backend	Python, Flask
Yapay Zeka	TensorFlow, Keras
Veritabanı	Firebase Firestore
Kimlik Doğrulama	Firebase Authentication
Görsel Depolama	Firebase Storage
Model Servis Sağlayıcı	Ngrok
Eğitim Ortamı	Google Colab
Dataset	Kaggle – Brain MRI Images for Brain Tumor Detection

🧩 Sistem Mimarisi
Kullanıcı uygulamayı açar, oturum kontrolü SplashScreen üzerinden yapılır.

Giriş yapan kullanıcı MainScreen'e yönlendirilir.

Kullanıcı kameradan veya galeriden MR görüntüsü yükler.

Görüntü base64'e çevrilir ve Flask API'ye gönderilir.

Flask API, modeli çalıştırarak sonucu “Normal” veya “Anormal” olarak JSON formatında döner.

Sonuç hem ekranda gösterilir hem de Firebase Firestore ve Storage'a kaydedilir.

Geçmiş test sonuçları OldTestScreen üzerinden filtrelenebilir.

🧠 Yapay Zeka Modeli
Eğitildiği veri seti: Kaggle - Brain MRI Images for Brain Tumor Detection

Model: Basit CNN (Conv2D, MaxPooling2D, Dense, Dropout)

Eğitim çıktısı: .keras formatında model

Doğruluk oranı: ~%90

Threshold değeri: 0.7 (üzeri “Anormal”, altı “Normal”)

📱 Uygulama Modülleri
SplashScreen – Giriş kontrolü ve animasyon

LoginScreen – Firebase tabanlı kullanıcı girişi

RegisterScreen – Yeni kullanıcı kaydı

PasswordResetScreen – Şifre sıfırlama

MainScreen – Ana yönlendirme ekranı

HomeScreen – MR görüntüsü yükleme ve test işlemi

OldTestScreen – Geçmiş test sonuçlarını listeleme ve silme

☁️ Veritabanı Yapısı (Firestore)
Koleksiyonlar:

users – Kullanıcı profili

test_results – Her test için sonuç, tarih, görüntü URL’si, olasılık

Firebase Storage:

MR görüntüleri kullanıcı ID’lerine göre depolanır

📎 Örnek Bağlantılar
📂 Proje Dökümanları ve Demo Videosu

📝 Lisans
Bu proje, TÜBİTAK 2209-A desteğiyle, eğitim ve akademik amaçlarla geliştirilmiştir. Yaygınlaştırma veya ticari kullanımlar için geliştirici izni alınması önerilir.

