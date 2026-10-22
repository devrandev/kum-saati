# Kum Saati

macOS için menü çubuğundan kontrol edilen, ekranda yüzen bir odak sayacı. Süre ilerledikçe dairenin içi dolar. SwiftUI ve AppKit kullanır; harici bağımlılığı yoktur.

## Çalıştırma

macOS 26.5 veya üzeri ve bu sürümü destekleyen Xcode gerekir. Proje Xcode 26.6 ile geliştirildi.

1. `Kum Saati.xcodeproj` dosyasını aç.
2. `Kum Saati` şemasını ve `My Mac` hedefini seç.
3. Gerekirse **Signing & Capabilities** bölümünden kendi geliştirme takımını seç.
4. **⌘R** ile çalıştır.

## Kullanım

| Hareket | İşlev |
| --- | --- |
| Merkezden sürükle | Daireyi taşı |
| Merkeze çift tıkla | Başlat, duraklat veya yeni tur başlat |
| Dış kenarı sürükle | Süreyi ileri veya geri sar |
| Fare üzerindeyken sağ alttaki tutamacı sürükle | Boyutlandır |
| Fareyi daireye getir | Seçili aralıktaki tur sayısını göster |
| Menü çubuğundaki kum saatine tıkla | Ayarlar ve kontroller |

Süre 1–1440 dakika arasında ayarlanabilir. Yeni süreyi uygulamak mevcut turu sıfırlar. Daire çalışırken yeşil, duraklatıldığında veya tamamlandığında sarıdır. İlerleme yokken %10 opak siyah görünür.

Sayaç otomatik başlamaz. Tur bitince, Mac uyuyunca veya ekran kilitlenince durur; devam etmek için tekrar başlatmak gerekir. Süreyi elle sarmak turu duraklatır ve o tur istatistiğe eklenmez.

## Veriler

Tamamlanan turlar `rounds.json` dosyasında, süre ve filtre ayarları `UserDefaults` içinde saklanır. Uygulama yeniden açıldığında mevcut tur sıfırlanır; geçmiş korunur.

```text
~/Library/Containers/pomodoro.Kum-Saati/Data/Library/Application Support/KumSaati/rounds.json
```

İstatistikler son 12 saat, son 15 saat, son 10 gün veya bu ay için filtrelenebilir. 60 günden eski kayıtlar otomatik temizlenir.

## Proje yapısı

```text
Kum Saati/
  App/           Uygulama yaşam döngüsü ve sistem olayları
  Circle/        Çizim, fare etkileşimleri ve pencere
  MenuBar/       Menü çubuğu ve kontrol paneli
  Timer/         Sayaç ve istatistik filtreleri
  Persistence/   JSON geçmişi ve ayarlar
  Resources/     Metinler ve görsel kaynaklar
Tests/           XCTest testleri
```

## Testler

Xcode'da `Kum Saati` şeması seçiliyken **⌘U** veya terminalden:

```sh
xcodebuild -project "Kum Saati.xcodeproj" \
  -scheme "Kum Saati" \
  -destination 'platform=macOS' \
  -derivedDataPath .build \
  CODE_SIGNING_ALLOWED=NO test
```

Testler uygulamayı açmadan, geçici verilerle çalışır. `Tested Sources` grubu, test hedefine dahil edilen üretim dosyalarına referans verir.

Sayaç, kayıt işlemleri ve fare etkileşimleri test edilir. Gerçek uyku/kilit, çoklu ekran ve görsel davranış elle kontrol edilmelidir.
