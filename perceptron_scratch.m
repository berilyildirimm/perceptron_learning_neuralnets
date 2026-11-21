%% ADIM 2: Sıfırdan Tek Nöron (Perceptron) Öğrenme Algoritması ve Karar Sınırı
clear;          % Çalışma alanındaki eski değişkenleri temizler
clc;            % Komut penceresini temizler
close all;      % Açık grafik pencerelerini kapatır

load('logic_dataset.mat'); % Adım 1'de üretip kaydettiğimiz X, y_AND ve y_XOR verilerini yükler

% --- HİPERPARAMETRELER ---
learningRate = 0.1; % Öğrenme oranı (nöron hata yaptığında ağırlıkları ne büyüklükte güncelleyecek)
epochs = 25;        % Veri setinin tamamının nörona kaç tur (epoch) gösterileceği

% =========================================================================
% BÖLÜM A: AND KAPISI EĞİTİMİ (Doğrusal Ayrılabilir Problem)
% =========================================================================
w_and = zeros(1, 2); % Giriş ağırlıklarını [w1, w2] başlangıçta sıfır olarak tanımlar
b_and = 0;           % Bias (eşik kaydırma) değerini başlangıçta sıfır olarak tanımlar
errors_and = zeros(epochs, 1); % Her turdaki (epoch) toplam hata sayısını kaydedecek boş vektör

for ep = 1:epochs                    % 1'den 25'e kadar eğitim turlarını başlatır
    errorCount = 0;                  % O turdaki yanlış tahmin sayacını sıfırlar
    for i = 1:length(X)              % 400 adet sensör/sinyal ölçümünün her birini tek tek nörona verir
        x_i = X(i, :);               % i. örneğin giriş gerilimlerini [V1, V2] alır
        target = y_AND(i);           % i. örneğin olması gereken gerçek AND çıkışını alır

        % 1. İleri Besleme (Forward Pass): Ağırlıklı toplamı hesapla
        z = dot(w_and, x_i) + b_and; % z = w1*V1 + w2*V2 + b formülünü hesaplar

        % 2. Aktivasyon Fonksiyonu (Step / Basamak Fonksiyonu)
        y_pred = double(z >= 0);     % Toplam 0 veya büyükse çıkış 1, küçükse 0 üretir

        % 3. Hata Hesabı ve Perceptron Öğrenme Kuralı ile Güncelleme
        err = target - y_pred;       % Gerçek değer ile tahmin arasındaki farkı bulur (-1, 0 veya +1 olur)
        if err ~= 0                  % Eğer nöron yanlış tahmin yaptıysa (hata 0 değilse)
            w_and = w_and + learningRate * err * x_i; % Ağırlıkları hatayı azaltacak yönde günceller
            b_and = b_and + learningRate * err;       % Bias değerini hatayı azaltacak yönde günceller
            errorCount = errorCount + 1;              % Hata sayacını 1 artırır
        end                          % Güncelleme koşulunu kapatır
    end                              % 400 örneklik iç döngüyü bitirir
    errors_and(ep) = errorCount;     % Bu turda yapılan toplam hata sayısını kaydeder
end                                  % AND eğitimi dış döngüsünü bitirir

% =========================================================================
% BÖLÜM B: XOR KAPISI EĞİTİMİ (Tek Nöronun Sınırını Görmek İçin)
% =========================================================================
w_xor = zeros(1, 2); % XOR problemi için ağırlıkları sıfırdan başlatır
b_xor = 0;           % XOR problemi için bias değerini sıfırdan başlatır
errors_xor = zeros(epochs, 1); % XOR eğitimindeki tur bazlı hataları tutacak vektör

for ep = 1:epochs                    % 25 eğitim turunu başlatır
    errorCount = 0;                  % Tur hata sayacını sıfırlar
    for i = 1:length(X)              % 400 örneği tek tek döner
        x_i = X(i, :);               % Giriş gerilimlerini alır
        target = y_XOR(i);           % Gerçek XOR etiketini alır

        z = dot(w_xor, x_i) + b_xor; % Ağırlıklı toplamı hesaplar
        y_pred = double(z >= 0);     % Basamak aktivasyonu uygular

        err = target - y_pred;       % Hatayı hesaplar
        if err ~= 0                  % Hata varsa ağırlıkları ve bias'ı günceller
            w_xor = w_xor + learningRate * err * x_i;
            b_xor = b_xor + learningRate * err;
            errorCount = errorCount + 1;
        end
    end
    errors_xor(ep) = errorCount;     % Tur sonunda kalan hataları kaydeder (hiç sıfırlanmadığını göreceğiz)
end

% =========================================================================
% BÖLÜM C: GÖRSELLEŞTİRME VE GRAFİK KAYDI
% =========================================================================
fig1 = figure('Name', 'Perceptron Ogrenme ve Karar Siniri', 'Position', [100, 100, 1000, 430]);

% Sol Grafik: Eğitim Turları (Epoch) İlerledikçe Hata Değişimi
subplot(1, 2, 1);
plot(1:epochs, errors_and, '-bo', 'LineWidth', 1.5, 'DisplayName', 'AND Kapısı Hataları'); hold on;
plot(1:epochs, errors_xor, '-rs', 'LineWidth', 1.5, 'DisplayName', 'XOR Kapısı Hataları');
title('Eğitim Süreci: Epoch Başına Yanlış Sınıflandırma');
xlabel('Eğitim Turu (Epoch)');
ylabel('Hatalı Örnek Sayısı (400 üzerinden)');
legend('Location', 'best'); grid on;

% Sağ Grafik: AND Kapısı İçin Nöronun Öğrendiği Karar Sınırı (w1*V1 + w2*V2 + b = 0)
subplot(1, 2, 2);
gscatter(X(:,1), X(:,2), y_AND, 'rb', 'ox', 7); hold on;
v1_line = linspace(-0.4, 1.4, 100); % V1 ekseni boyunca çizgi noktaları oluşturur
% w1*V1 + w2*V2 + b = 0 denkleminden V2'yi yalnız bırakarak doğru denklemini yazarız:
v2_line = -(w_and(1) * v1_line + b_and) / w_and(2); 
plot(v1_line, v2_line, 'k--', 'LineWidth', 2, 'DisplayName', 'Perceptron Karar Sınırı');
ylim([-0.4 1.4]); % Y ekseni sınırlarını sabitler
title('AND Kapısı İçin Öğrenilen Doğrusal Karar Sınırı');
xlabel('Giriş 1 Gerilimi V_1 (V)');
ylabel('Giriş 2 Gerilimi V_2 (V)');
legend({'Logic 0', 'Logic 1', 'Karar Sınırı'}, 'Location', 'northwest');
grid on;

% Grafiği GitHub'da kullanmak üzere 300 DPI çözünürlükte kaydeder
exportgraphics(fig1, 'perceptron_boundary.png', 'Resolution', 300);
disp('Adim 2 tamamlandi: perceptron_boundary.png kaydedildi.');