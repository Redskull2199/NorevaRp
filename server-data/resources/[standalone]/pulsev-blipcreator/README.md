# pulsev-blipcreator

QBCore için Türkçe blip yönetim paneli. Blipler oxmysql ile kalıcıdır; çevrimiçi oyuncular create/update/delete ve aktif/pasif değişikliklerini anında alır. Sprite galerisi 817 ID ve 86 renk içerir; bütün görseller yereldir.

## Kurulum

1. ZIP içindeki `pulsev-blipcreator` klasörünü sunucunun `resources` dizinine kopyalayın. Klasör adını koruyun.
2. `sql/pulsev_blips.sql` dosyasını sunucunuzun veritabanına içe aktarın. Mevcut blip tablosu ve kayıtları değiştirilmez. Yeni `pulsev_blip_permissions` tablosu resource başlangıcında da `CREATE TABLE IF NOT EXISTS` ile hazırlanır; DB kullanıcısında CREATE izni yoksa SQL dosyasını önceden içe aktarın.
3. `server.cfg` içinde sıralama:

```cfg
ensure oxmysql
ensure qb-core
ensure pulsev-blipcreator
```

4. OneSync açık ve oyun build'i en az 3258 olmalıdır. Kurulumdan sonra resource'ı başlatın; yetkili oyuncu `/blipcreator` komutunu kullanabilir.

Yerel entegrasyon QBCore 1.3.0 ve oxmysql 2.14.1 API'lerine göre hazırlanmıştır. Runtime bağımlılıkları yalnızca `qb-core` ve `oxmysql` olur.

## Yetkiler ve ayarlar

`/admin` komutunun veya bir admin menüsünün bulunması gerekmez. Varsayılan erişim, QBCore `admin`, `superadmin`, `god` rollerinden biri **veya** `command.blipcreator`, `pulsev.blipcreator` ACE yetkilerinden biriyle verilir. Sunucuda mevcut `add_ace group.admin command allow` kuralı, bu gruptaki oyuncuların `command.blipcreator` kontrolünü geçmesini sağlar; ayrıca QBCore rolü vermek gerekmez. `mod` rolü tek başına yeterli değildir. Yerel QBCore'da `superadmin` tanımlı değildir; Config'e adını yazmak tek başına rol oluşturmaz.

Bütün yönetim işlemleri, teleport ve sırada bekleyen yazmalar sunucuda aktif QBCore karakteri, oturum ve güncel yetkiyle tekrar doğrulanır. `server/main.lua`, komutu doğrudan `RegisterCommand` ile Config/QBCore/DB başlangıcından önce kaydeder. Başlangıç hatası komutu kaldırmaz; çalıştırılınca nedenini loglar ve paneli kapalı tutar. Permission yalnızca çalıştırmada ve yönetim isteklerinde denetlenir. Genel erişim ACE kuralı eklenmez. Yetkisi kaldırılan oyuncunun bekleyen işlemi yürütülmez.

Mevcut rol/ACE ile başarılı `/blipcreator` açılışında blip yönetimi yetkisi, sunucunun `GetPlayerIdentifierByType(source, 'license')` sonucuna SQL'de kaydedilir. Sonraki resource/server restart'larında aynı `license:` için erişim geri yüklenir; source ID veya karakter değişimi yetkiyi kaybettirmez. Bu kayıt yalnızca blip yönetimi içindir, QBCore admin rolünü başka komutlara geri vermez. Yeni oyuncuya otomatik yetki verilmez; eksik/geçersiz license erişimi reddedilir. Kalıcı kayıt yapıldıktan sonra yalnızca geçici QBCore/ACE rolünü kaldırmak blip yetkisini geri almaz; aşağıdaki revoke komutu kullanılır.

Yalnızca sunucu konsolunda (oyuncular kullanamaz):

```text
blipcreatorpermission grant <server-id veya license:40-karakter-hex>
blipcreatorpermission revoke <server-id veya license:40-karakter-hex>
```

`revoke`, aynı license için kalıcı red kaydeder ve mevcut rol/ACE olsa bile doğrudan event'leri/bekleyen işlemleri engeller; yeniden erişim için `grant` gerekir. Yetki kaydı SQL tamamlanmadan başarılı sayılmaz. ACL yüklenirken komut `unavailable` döner; `Database ready` sonrasında tekrar kullanın. Komut adı Config'de değişirse bu komut da `<Command>permission` olur. License/audit alanları client girdisinden alınmaz.

Farklı bir sunucu yetki sistemi için `Config.Permissions` rol listesini ve `Config.AcePermissions` ACE listesini düzenleyin. Yalnızca QBCore kullanmak için `AcePermissions = {}`; yalnızca ACE kullanmak için `Permissions = {}` ayarlanabilir. İki listenin aynı anda boş olması veya `user`/`builtin.everyone` kullanılması geçersiz Config sayılır; panel kapalı tutulur, komut kayıtlı kalır. Eski Config'de `AcePermissions` bulunmuyorsa yalnızca roller kullanılır. Komut adını değiştirirseniz `command.blipcreator` ACE adını da yeni komuta göre düzenleyin.

Özel yönetici grubuna yalnızca bu resource'ın yetkisini vermek için sunucu konsolunda veya `server.cfg` içinde örnek:

```cfg
add_ace group.blipadmins pulsev.blipcreator allow
add_principal identifier.license:YOUR_LICENSE group.blipadmins
```

`YOUR_LICENSE` yerine yetki verilecek kişinin gerçek license kimliğini yazın. Mevcut `group.admin` kuralı yeterliyse ek yetki kuralı gerekmez.

`config.lua` komut, izinler, debug, varsayılan görünüm, metin/koordinat/scale sınırları, maksimum kayıt, bildirim adaptörü ve süre/istek sınırlarını içerir. Varsayılan limit 500, sprite 280, renk 3, scale 0.80. Scale 0.10–2.00; renkler 0–85. Config metin sınırları SQL kolon kapasitesini aşamaz. `category` yönetim etiketidir; `map_category` ayrı GTA kategorisidir.

Bildirim varsayılanı `qbcore`; `nui` veya `custom` seçilebilir. Custom adaptörde `customEvent` yerel client event'inin adı olur. Başka resource zorunlu bağımlılık yapılmaz. Alan hataları ayrıca formda gösterilir.

## Kullanım

Yeni blip veya düzenleme formunda galeri/renk seçicisini ve **Mevcut Konumumu Kullan** düğmesini kullanın. Konum işlemi heading'i de doldurur. Canlı oyun önizlemesi yalnızca ilgili yöneticide geçici tek bliptir; kaydedilmez. Paneli küçülttükten sonra komutla aynı taslağa dönebilirsiniz. Browser ikon rengi yaklaşık görünüm sunar; gerçek harita/minimap sonucunu oyun önizlemesinde kontrol edin. Display 0/1/7 veya alpha 0 seçimi blipi görünmez yapabilir.

Silme ve teleport onay ister. Teleport yalnızca yaya admin içindir, kayıtlı Z korunur, routing bucket değişmez. Collision yüklenemezse eski konuma dönülür.

Çakışmada taslak korunur; güncel kaydı yeniden yükleyip değişikliklerinizi uygulayın. Kaydetme timeout'unda otomatik tekrar yapılmaz: işlem commit edilmiş olabilir, listeyi yenileyin. Resource kapandığında focus, preview ve teleport freeze/fade temizlenir.

## Sorun giderme ve doğrulama

Güncellenen dosyaları yükledikten sonra sunucu konsolunda `restart pulsev-blipcreator` çalıştırın; ardından karakteriniz yüklüyken oyun içinde `/blipcreator` yazın. Konsolda `server/main.lua loaded; RegisterCommand /blipcreator completed (restricted=false)` mesajı komut kaydını; ardından `QBCore export ready`, `Command handler ready` ve `Database ready` mesajları panel hazırlığını doğrular. F8'de `client/main.lua loaded; chat suggestion /blipcreator added` mesajı görünür. Chat önerisi client başlangıcı, karakter yükleme ve `chat`/`0r-chatv3` restart'ında eklenir. Yetki tanı logları `Debug = false` olsa da her komut denemesinde yazılır; license, Discord kimliği, citizenid veya bağlantı bilgileri loglanmaz.

Örnek yetki reddi:

```text
[pulsev-blipcreator] /blipcreator source=7 permission_denied: reason=permission_denied active_player=true qbcore=[admin=false,superadmin=false,god=false] ace=[command.blipcreator=false,pulsev.blipcreator=false]
```

- `permission_denied`: hiçbir rol/ACE eşleşmedi. Kuraldaki oyuncu kimliğini ve grup kalıtımını kontrol edin; oyuncuya hata bildirimi de gider.
- `permission_check_failed`: izin sağlayıcısı hata verdi veya yok; ilgili kontrol `error`/`unavailable` olarak görünür ve tek başına erişim kazandırmaz.
- `console_source`: komut doğrudan sunucu konsolundan çalıştırıldı; panel açmak için oyun içinden kullanın.
- `player_not_loaded` / `inactive_player` / `invalid_player_identity`: aktif, geçerli QBCore karakteri henüz yok veya oturum bilgisi geçersiz.
- `permission_granted` ardından `panel_open_failed: code=unavailable`: yetki geçti, fakat DB başlangıcı tamamlanmadı/başarısız oldu veya bağımlılık durdu. Önceki `Startup failed` mesajını kontrol edin.
- `panel_open_sent`: sunucu yetkili snapshot'ı client'a gönderdi. Panel görünmüyorsa client F8/CEF/NUI hatalarını inceleyin; bu mesaj görsel açılmayı doğrulamaz.
- `Panel disabled ... command remains registered`: Config alanları veya `qb-core` başlangıcı hatalı; komut çalıştırılabilir ve hatayı bildirir, yönetim işlemleri kapalıdır. Config'i/bağımlılığı düzeltip resource'ı yeniden yükleyin.

Eksik tablo/DB bağlantı hatasında CRUD kapatılır. Migration/oxmysql başlangıç sırasını düzeltip resource'ı yeniden başlatın. Bozuk SQL satırları silinmez; yalnızca geçerli satırlar yayınlanır. oxmysql'in TINYINT(1) alanları için döndürdüğü boolean değerleri ve 0/1 değerleri kabul edilir; bu nedenle kayıtlı `enabled`/`short_range` alanları restart'ta kaybolmaz. Oluşturma/güncelleme/silme/aktiflik değişimi SQL'de tamamlandıktan sonra client'a yayınlanır. Başlangıçta tüm kayıtlar SQL'den yüklenir; pasif blipler yönetim listesinde kalır, haritada çizilmez. Harici SQL değişikliklerini genel olarak izleyen polling yoktur; yeniden yüklemek için restart kullanın.

Harita sync'i karakter yüklenmeden başlatılmaz. `QBCore:Client:OnPlayerLoaded` her girişte yeni public snapshot ister; resource restart'ında giriş yapmış client başlangıçta ve server'ın yeni epoch bildirimiyle sync olur. Normal oyuncular aktif blipleri görebilir; public snapshot yönetim yetkisi vermez ve note/audit alanlarını içermez. Her tam snapshot eski GTA handle'larını temizleyip her benzersiz SQL ID için `AddBlipForCoord` çağırır. Değişen blipin handle'ı da kaldırılıp yeniden oluşturulur; aynı kayıt için hâlâ geçerli handle varsa tekrar delta ikinci handle oluşturmaz. `DoesBlipExist` geçersiz handle'ların Lua önbelleğinde takılmasını önler.

Liste dolu fakat harita boşsa F8'de `Map snapshot applied: records=N handles=N` mesajını kontrol edin. `invalid_map_record` geçersiz render alanını, `map_handle_failed` GTA native'inin handle üretemediğini belirtir. `x/y/z`, sprite, color, scale, display ve boolean `short_range` render öncesinde kontrol edilir. Display 3/4 yalnızca büyük haritada, 5/9 yalnızca minimap'te görünür; `short_range=true` minimap mesafesini kısıtlar. Kaydedilmiş görünüm değerleri değiştirilmez.

Geliştirme doğrulaması resource dışında `tools/verify.ps1 -Sql` ile yapılır. Lua/JS davranış ve syntax testleri, izole MariaDB migration/CRUD ve yeni Lua runtime'larında resource restart senaryosu testleri vardır. Restart testleri aynı license/farklı source, bütün blip ayarlarının geri gelmesi, update/delete/pasif kayıt, tekrar gönderilen istek ve duplicate native blip kontrolünü kapsar. Bunlar gerçek FiveM/CEF, iki admin oturumu, native render/teleport ve resmon ölçümünün yerine geçmez; sunucuda bu kontrolleri kurulumdan sonra gerçekleştirin. Sunucunun mevcut rol/ACE kuralları değiştirilmez.

Bu workspace'te `tools/test_sql.ps1 -FxServer`, yerel FXServer/oxmysql kopyasıyla ayrı bir loopback test instance'ı başlatır ve üç gerçek resource restart'ını doğrular. SQL ve resource lifecycle gerçektir; oyuncu native'leri ve QBCore oyuncu/rol sağlayıcısı test fixture'ıdır. Canlı resource veya canlı DB üzerinde test kaydı oluşturmaz. Mevcut sunucunun lisans anahtarı yalnızca özel test config'inde kullanılır; test loglarında maskelenir. Test instance'ı ve geçici DB çalışma sonunda kapatılır.

Görsellerin kaynağı ve hash/provenance bilgileri `THIRD_PARTY_NOTICES.md` ile `html/assets/provenance.json` içindedir.
