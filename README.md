# NorevaRP FiveM kaynak kopyası

Bu depo NorevaRP projesinin kaynak ve oyun asset kopyasıdır. Büyük ikili dosyalar Git LFS ile saklanır; klonladıktan sonra `git lfs pull` gerekir.

## Güvenlik durumu

6 Ekim 2026 tarihli salt okunur incelemede 26 resource içinde 27 şüpheli JavaScript yükleyicisi ve ciddi server event yetkilendirme açıkları bulundu. Bazı yükleyiciler manifestlerden çağrılıyor ve uzak kod çalıştırma davranışı içeriyor. Kod düzeltmeleri uygulanmadı. Bu kopyayı güvenilir kaynaklarla karşılaştırmadan ve rapordaki sorunları gidermeden sunucuda çalıştırmayın.

## İçerik

- `server-data/resources/`: kaynak kodu, NUI derlemeleri ve oyun asset dosyaları.
- `server-data/server.cfg` ve `settings.cfg`: yapılandırma kopyaları. Gerçek lisans, Steam API, DB, webhook ve upload anahtarları maskelendi. Yapılandırmadaki kişisel yönetici/oyuncu identifier değerleri de maskelendi.
- `database/`: seçilmiş tablo şemaları ve destek SQL dosyaları. Resource SQL dosyaları kendi konumlarında da korunur.
- `start.bat`: yerel başlangıç dosyasının kopyası.

FXServer dosyaları, txAdmin hesapları, cache, loglar, node_modules, eski yedekler, arşivler, telefon crypto secret ve kişisel kayıt içeren eski SQL dump bu depoda bulunmaz. Sunucu binary dosyaları ayrıca edinilmeli; resource bağımlılıkları kurulmalı ve maskelenmiş yapılandırma değerleri özel ortamda tamamlanmalıdır. Mevcut kaynak hataları ve dependency sorunları düzeltilmedi.

Maskeleme yalnızca Git kopyasında uygulandı; yerel çalışan sunucunun dosyaları değiştirilmedi. Gerçek anahtarları veya oyuncu verilerini Git geçmişine eklemeyin.
