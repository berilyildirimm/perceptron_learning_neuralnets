%% ADIM 1: Gürültülü Dijital Lojik Sinyal Veri Seti Üretimi (AND ve XOR)
clear;          % Çalışma alanındaki (Workspace) tüm eski değişkenleri siler
clc;            % Command Window (komut penceresi) ekranını temizler
close all;      % Önceden açık kalmış tüm grafik (Figure) pencerelerini kapatır
rng(42);        % Rastgele sayı üretecini sabitler (kodu her çalıştırdığında aynı gürültü üretilsin diye)

samplesPerClass = 100; % 4 lojik durumun (00, 01, 10, 11) her biri için 100'er adet örnek üretilecek (Toplam 400)
noiseStd = 0.12;       % Devredeki hat gürültüsünün standart sapması (0.12 Volt'luk dalgalanma ekler)

% 4 temel lojik giriş kombinasyonu: [Giriş 1 Gerilimi (V1), Giriş 2 Gerilimi (V2)]
baseInputs = [0 0;     % Durum 1: V1 = 0V, V2 = 0V
              0 1;     % Durum 2: V1 = 0V, V2 = 1V
              1 0;     % Durum 3: V1 = 1V, V2 = 0V
              1 1];    % Durum 4: V1 = 1V, V2 = 1V

X = [];         % Tüm gürültülü giriş gerilimlerini tutacak boş matris (döngü sonunda 400x2 boyutunda olacak)
y_AND = [];     % AND kapısının doğru çıkış etiketlerini (0 veya 1) tutacak boş vektör (400x1)
y_XOR = [];     % XOR kapısının doğru çıkış etiketlerini (0 veya 1) tutacak boş vektör (400x1)

for i = 1:4     % 4 temel lojik durumun her biri için sırayla döngüye girer
    % İdeal gerilim seviyesinin (örneğin [0 1]) üzerine Gaussian (Normal) dağılımlı rastgele gürültü ekler
    % randn(100, 2) -> ortalaması 0, standart sapması 1 olan 100x2'lik rastgele matris üretir
    noisySamples = baseInputs(i, :) + noiseStd * randn(samplesPerClass, 2);

    X = [X; noisySamples]; % Üretilen 100 yeni gürültülü ölçümü X matrisinin altına (satır olarak) ekler

    % İdeal girişler için AND (&) ve XOR işlemlerini hesaplar; mantıksal (true/false) sonucu sayıya (1/0) çevirir
    andLabel = double(baseInputs(i, 1) & baseInputs(i, 2));      % Sadece [1 1] durumunda 1, diğerlerinde 0 olur
    xorLabel = double(xor(baseInputs(i, 1), baseInputs(i, 2)));   % Girişler birbirinden farklıysa ([0 1], [1 0]) 1 olur

    % Hesaplanan tek bir etiketi, üretilen 100 örneğin tamamına atamak için 100 kez alt alta kopyalar
    y_AND = [y_AND; repmat(andLabel, samplesPerClass, 1)];        % 100 adet etiketi y_AND vektörünün altına ekler
    y_XOR = [y_XOR; repmat(xorLabel, samplesPerClass, 1)];        % 100 adet etiketi y_XOR vektörünün altına ekler
end             % 4 durumluk veri üretim döngüsünü sonlandırır

% Üretilen gürültülü sinyal dağılımlarını yan yana iki grafikte görselleştirir
figure('Name', 'Sentetik Lojik Sinyal Veri Seti', 'Position', [100, 100, 950, 420]); % Pencere başlığı ve boyutunu ayarlar

subplot(1, 2, 1);                                  % 1 satır, 2 sütunluk ızgaranın 1. (sol) grafiğini seçer
gscatter(X(:,1), X(:,2), y_AND, 'rb', 'ox', 7);    % X'in 1. ve 2. sütununu y_AND etiketine göre kırmızı 'o' ve mavi 'x' ile çizer
title('Gürültülü AND Kapısı Sinyalleri (Doğrusal Ayrılabilir)'); % Sol grafiğe başlık ekler
xlabel('Giriş 1 Gerilimi V_1 (V)');                % X ekseni etiketini yazar
ylabel('Giriş 2 Gerilimi V_2 (V)');                % Y ekseni etiketini yazar
legend({'Logic 0', 'Logic 1'}, 'Location', 'northwest'); % Hangi rengin/şeklin neyi temsil ettiğini sol üste ekler
grid on;                                           % Grafik arka planına okunabilirliği artıran ızgara çizgileri ekler

subplot(1, 2, 2);                                  % 1 satır, 2 sütunluk ızgaranın 2. (sağ) grafiğini seçer
gscatter(X(:,1), X(:,2), y_XOR, 'rb', 'ox', 7);    % Aynı noktaları bu kez XOR etiketlerine göre renklendirerek çizer
title('Gürültülü XOR Kapısı Sinyalleri (Doğrusal Ayrılamaz)'); % Sağ grafiğe başlık ekler
xlabel('Giriş 1 Gerilimi V_1 (V)');                % X ekseni etiketini yazar
ylabel('Giriş 2 Gerilimi V_2 (V)');                % Y ekseni etiketini yazar
legend({'Logic 0', 'Logic 1'}, 'Location', 'northwest'); % Açıklama kutusunu sol üste ekler
grid on;                                           % Izgara çizgilerini aktif eder

% Üretilen X matrisi ile y_AND, y_XOR etiketlerini sonraki adımlarda kullanmak üzere diske kaydeder
save('logic_dataset.mat', 'X', 'y_AND', 'y_XOR');
disp('Veri seti basariyla olusturuldu ve logic_dataset.mat olarak kaydedildi.'); % İşlemin bittiğini komut penceresine yazar