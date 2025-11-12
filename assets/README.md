# Assets Directory

## 📁 Cấu trúc thư mục

```
assets/
├── images/          # Hình ảnh (logo, placeholder, etc.)
├── icons/           # Icons tùy chỉnh
├── animations/      # Lottie animations
└── fonts/           # Custom fonts (optional)
```

## 🖼️ Images

Đặt các file hình ảnh vào thư mục `images/`:
- `logo.png` - Logo ứng dụng
- `placeholder.png` - Placeholder cho course thumbnails
- `empty_state.png` - Empty state illustrations
- `error_state.png` - Error state illustrations

### Recommended sizes:
- Logo: 512x512px (PNG với transparent background)
- Placeholder: 1280x720px
- Icons: 48x48px, 96x96px, 192x192px

## 🎨 Icons

Đặt custom icons vào thư mục `icons/`:
- `app_icon.png` - App launcher icon (1024x1024px)

## 🎬 Animations

Đặt Lottie animation files (.json) vào thư mục `animations/`:
- `loading.json` - Loading animation
- `success.json` - Success animation
- `error.json` - Error animation

### Tải Lottie animations miễn phí:
- https://lottiefiles.com/

## 🔤 Fonts (Optional)

Nếu muốn sử dụng custom fonts:

1. Download Poppins font từ Google Fonts:
   https://fonts.google.com/specimen/Poppins

2. Đặt các file vào `fonts/`:
   - `Poppins-Regular.ttf`
   - `Poppins-Bold.ttf`
   - `Poppins-Medium.ttf` (optional)
   - `Poppins-SemiBold.ttf` (optional)

3. Uncomment phần fonts trong `pubspec.yaml`:
   ```yaml
   fonts:
     - family: Poppins
       fonts:
         - asset: assets/fonts/Poppins-Regular.ttf
         - asset: assets/fonts/Poppins-Bold.ttf
           weight: 700
   ```

4. Chạy `flutter pub get`

## 📝 Lưu ý

- **Hiện tại**: App đang sử dụng Google Fonts (tải online), không cần custom fonts
- **Images**: Có thể để trống, app sẽ dùng placeholder mặc định
- **Icons**: Material Icons được sử dụng, không cần custom icons
- **Animations**: Optional, có thể thêm sau

## 🚀 Quick Setup (Minimal)

Để chạy app ngay lập tức, bạn **KHÔNG CẦN** thêm bất kỳ file nào vào thư mục assets. App sẽ hoạt động bình thường với:
- Google Fonts cho typography
- Material Icons cho icons
- Placeholder colors cho images
- CircularProgressIndicator cho loading

## 📦 Thêm assets sau này

Khi muốn customize:

1. Thêm files vào thư mục tương ứng
2. Chạy `flutter pub get`
3. Restart app

Không cần thay đổi code, app sẽ tự động sử dụng assets nếu có.
