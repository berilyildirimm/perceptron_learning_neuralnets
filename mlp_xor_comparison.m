%% ADIM 3: Çok Katmanlı Yapay Sinir Ağı (MLP) ile XOR Problemi Çözümü
clear;          % Çalışma alanındaki eski değişkenleri temizler
clc;            % Komut penceresini temizler
close all;      % Açık grafik pencerelerini kapatır

load('logic_dataset.mat'); % Adım 1'de oluşturduğumuz X (girişler) ve y_XOR (etiketler) verilerini yükler

% 1. Çok Katmanlı Yapay Sinir Ağı (Multi-Layer Perceptron) Eğitimi
% Tek bir nöron düz bir çizgi çekebildiği için XOR'u çözememişti.
% Burada MATLAB'in 'fitcnet' fonksiyonuyla gizli katmanında (Hidden Layer) 8 nöron bulunan bir ağ kuruyoruz:
mlpModel = fitcnet(X, y_XOR, ...
    'LayerSizes', 8, ...           % Gizli katmanda 8 adet yapay nöron kullan
    'Activations', 'tanh', ...     % Doğrusal olmayan (kıvrımlı) sınır çizebilmek için hiperbolik tanjant aktivasyonu
    'Standardize', true);          % Giriş verilerini eğitim öncesi ölçeklendir

% 2. Karar Bölgesi (Decision Region) Haritası İçin 2B Izgara (Grid) Oluşturma
% Grafikteki tüm arka planı (-0.4V ile 1.4V arasını) sık noktalara bölüp her birini ağa soracağız:
[v1_grid, v2_grid] = meshgrid(linspace(-0.4, 1.4, 200), linspace(-0.4, 1.4, 200));
gridPoints = [v1_grid(:), v2_grid(:)]; % 200x200 = 40.000 test noktasını alt alta matris yapar

% Eğittiğimiz yapay sinir ağına bu 40.000 noktanın hangi sınıfa (0 mı 1 mi) ait olduğunu tahmin ettirir:
gridPred = predict(mlpModel, gridPoints);
gridPredMatrix = reshape(gridPred, size(v1_grid)); % Tahminleri tekrar 200x200 harita boyutuna getirir

% 3. Görselleştirme ve Grafik Kaydı
fig2 = figure('Name', 'MLP XOR Karar Siniri', 'Position', [150, 150, 750, 550]);

% Arka planı ağın tahmin ettiği bölgelere göre açık kırmızı ve açık maviye boyar:
contourf(v1_grid, v2_grid, gridPredMatrix, [0 0.5 1], 'LineColor', 'none');
colormap([1 0.85 0.85; 0.85 0.90 1]); % 0 bölgesi açık kırmızı, 1 bölgesi açık mavi tonunda boyanır
hold on;

% Gerçek gürültülü sensör verilerini (400 noktayı) boyalı haritanın üzerine çizer:
gscatter(X(:,1), X(:,2), y_XOR, 'rb', 'ox', 7);

% Doğruluk (Accuracy) oranını hesaplayıp başlığa yazar:
trainPred = predict(mlpModel, X);
accuracy = mean(trainPred == y_XOR) * 100;

title(sprintf('Çok Katmanlı Yapay Sinir Ağı (MLP) ile XOR Çözümü (Doğruluk: %.1f%%)', accuracy));
xlabel('Giriş 1 Gerilimi V_1 (V)');
ylabel('Giriş 2 Gerilimi V_2 (V)');
legend({'Karar Bölgeleri', 'Logic 0', 'Logic 1'}, 'Location', 'northwest');
grid on;

% Grafiği GitHub'da kullanmak üzere 300 DPI çözünürlükte kaydeder:
exportgraphics(fig2, 'xor_nn_comparison.png', 'Resolution', 300);
disp('Adim 3 tamamlandi: xor_nn_comparison.png kaydedildi.');