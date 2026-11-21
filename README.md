Tek Nöron (Perceptron) ve Yapay Sinir Ağları ile Dijital Sinyal Sınıflandırma

Bu projede, yapay sinir ağlarının en temel yapı taşı olan **Perceptron** algoritmasının çalışma mantığını ve sınırlarını MATLAB ortamında sıfırdan kodlayarak inceledim. Elektronikte op-amp ile kurulan ağırlıklı toplayıcı ve karşılaştırıcı (comparator) devrelerinin yazılımsal karşılığı olan tek bir yapay nörona **AND** ve **XOR** lojik kapılarını öğrettim; tek nöronun doğrusal sınırlarının yetmediği noktada ise **Çok Katmanlı Yapay Sinir Ağı (MLP)** kullanarak problemi çözdüm.

---

 Adım Adım Neler Yaptım ve Neler Gözlemledim?

Adım 1: İdeal Olmayan Gerçekçi Sinyal Veri Seti Üretimi (`step1_data_generation.m`)
* Gerçek bir elektronik devrede kablolardan veya sensörlerden okunan gerilim değerleri hiçbir zaman tam olarak `0 V` veya `1 V` olmaz; elektriksel gürültü ve parazitler nedeniyle `0.08 V` veya `0.92 V` gibi dalgalanmalar gösterir.
* Elektriğin bu ideal olmayan doğasını simüle etmek için `0 V` (Logic 0) ve `1 V` (Logic 1) gerilim seviyelerinin üzerine standart sapması `0.12 V` olan Gaussian gürültü ekledim.
* İki giriş hattı ($V_1$ ve $V_2$) kullanarak `00`, `01`, `10` ve `11` durumlarının her biri için 100'er adet olmak üzere toplam **400 ölçüm noktası** ürettim ve bu veri setine hem **AND** hem de **XOR** kapılarının doğru çıkışlarını öğrettim.

 Adım 2: Sıfırdan Perceptron Öğrenmesi ve Doğrusal Sınır Analizi (`step2_perceptron_scratch.m`)
* Hazır bir yapay zeka kütüphanesi kullanmadan, bir nöronun temel denklemini ($z = w_1 V_1 + w_2 V_2 + b$) ve basamak (step) aktivasyon fonksiyonunu döngülerle sıfırdan yazdım.
* 25 eğitim turu (**Epoch**) boyunca nöronun yaptığı hatalara bakarak ağırlıklarını ($w_1, w_2$) ve eşik kaydırma değerini ($b$) kendi kendine güncellemesini sağladım:
  * **AND Kapısı Gözlemi:** Sadece `(1, 1)` bölgesi Logic 1 olduğu ve diğer üç bölge Logic 0 kaldığı için veri doğrusal olarak ayrılabiliyordu. Nöron **10. epoch** civarında hatayı tamamen **0**'a indirdi ve iki sınıfın arasına tek bir düz karar çizgisi çekmeyi başardı. Hata sıfırlandıktan sonra öğrenme kuralı gereği ağırlıklar sabitlendi.
  * **XOR Kapısı Gözlemi:** XOR kapısında Logic 1'ler `(0, 1)` ve `(1, 0)` noktalarında, Logic 0'lar ise `(0, 0)` ve `(1, 1)` noktalarında çapraz yerleştiği için tek bir düz çizgi bu iki grubu ayıramadı. Eğitim turu sayısı artırılsa bile hata hiçbir zaman sıfıra inmedi ve tek nöronun doğrusal sınırı net bir şekilde gözlemlendi.

 Adım 3: Çok Katmanlı Yapay Sinir Ağı (MLP) ile XOR Çözümü (`step3_mlp_xor_comparison.m`)
* Tek nöronun çektiği tek bir düz çizginin yetmediği XOR problemini çözmek için gizli katmanında (hidden layer) **8 nöron** ve doğrusal olmayan geçişler sağlayabilen `tanh` aktivasyon fonksiyonu bulunan çok katmanlı bir yapay sinir ağı (`fitcnet`) eğittim.
* Birden fazla nöronun birleşmesiyle ağın 2 boyutlu gerilim uzayında kıvrımlı karar bölgeleri oluşturabildiğini ve gürültülü XOR sinyallerini yüksek doğrulukla sınıflandırdığını gözlemledim.

---

## ⚡ Mühendislik Analizi ve Tasarım Kararları

1. Op-Amp Comparator (Karşılaştırıcı) Devresi ile Yapay Nöron İlişkisi
Bu projede kodladığım tek nöron yapısı, elektronikte **op-amp ile kurulan ağırlıklı toplayıcı + açık çevrim karşılaştırıcı (open-loop comparator)** devresinin yazılımsal karşılığıdır:

| Yapay Nöron (Perceptron) | Op-Amp Comparator Devresi | Fiziksel Karşılığı |
| :--- | :--- | :--- |
| **Girişler ($V_1, V_2$)** | Giriş Gerilimleri ($V_1, V_2$) | Devreye uygulanan sensör/sinyal hatları |
| **Ağırlıklar ($w_1, w_2$)** | Direnç Oranları ($R_f / R_1, R_f / R_2$) | Her girişin toplama ne kadar katkı yapacağı |
| **Bias ($b$)** | Referans Gerilimi ($V_{ref}$) | Karşılaştırma eşiğinin sıfırdan nereye kaydırıldığı |
| **Step Aktivasyonu ($z \ge 0$)** | Açık Çevrim Doyum ($+V_{sat}$ / $0\text{ V}$) | $V_+ > V_-$ olduğunda çıkışın aniden Logic 1'e vurması |

Klasik bir op-amp devresinde direnç oranlarını ($w$) ve referans voltajını ($b$) devreyi kurmadan önce biz hesaplarız; Perceptron algoritmasında ise nöron yaptığı hatalara bakarak bu parametreleri eğitim sırasında **kendi kendine optimize eder**.

 2. Neden Tek Giriş Yerine İki Giriş ($V_1, V_2$) Kullandım?
* Tek girişli ($V_1$) bir yapıda karar sınırı 2 boyutlu bir düzlemde çizgi değil, 1 boyutlu bir sayı doğrusu üzerinde tek bir eşik noktası ($V_1 = 0.5\text{ V}$ gibi) olurdu ve yalnızca bir **NOT (Değil)** kapısı veya basit bir voltaj dedektörü işlevi görürdü.
* Hem lojik kapıların (AND, XOR) iki giriş gerektirmesi hem de Perceptron'un **doğrusal ayrılabilirlik (linear separability)** sınırını 2 boyutlu grafikte görsel olarak kanıtlayabilmek için sistemi iki girişli tasarladım.

 3. Eğitim Turu Sayısı (`Epoch = 25` vs. `Epoch = 50`) Ne Değiştirir?
* **AND Kapısında:** Nöron 10. epoch'ta hatayı zaten `0`'a indirdiği için (`err = 0`), ağırlık güncelleme adımı durur ($w_{yeni} = w_{eski} + 0$). Dolayısıyla `epochs = 50` yapılsa dahi 10. turdan sonra karar çizgisinin konumu değişmez.
* **XOR Kapısında:** Eğitim turu 50 veya daha fazla yapılsa bile hata sıfıra inmez; çünkü sorun eğitim süresinin yetersizliği değil, tek bir düz doğrunun çapraz yerleşimli sınıfları geometrik olarak ayıramamasıdır.

---

 Repository Structure

```text
perceptron_neural_classifier/
├── data_generation.m      Adım 1: Gürültülü AND ve XOR sinyal verisi üretimi
├── perceptron_scratch.m   Adım 2: Sıfırdan Perceptron eğitimi ve karar sınırı
├── mlp_xor_comparison.m   Adım 3: Çok katmanlı sinir ağı (MLP) ile XOR çözümü
├── perceptron_boundary.png      Epoch-hata grafiği ve AND kapısı doğrusal karar sınırı
└── xor_nn_comparison.png        Çok katmanlı sinir ağının XOR karar bölgeleri haritası
