<h1 align="center">HỆ THỐNG E-LEARNING TÍCH HỢP AI</h1>

<div align="center">
  <p align="center">
    <img src="https://upload.wikimedia.org/wikipedia/vi/thumb/3/3f/Logo_Dai_hoc_Dai_Nam.svg/1200px-Logo_Dai_hoc_Dai_Nam.svg.png" alt="DaiNam University Logo" width="200"/>
  </p>

[![Made by DNU](https://img.shields.io/badge/Made%20by-DNU-blue?style=for-the-badge)](https://daihocdainam.edu.vn/)
[![Fit DNU](https://img.shields.io/badge/FIT%20DNU-green?style=for-the-badge)](https://fitdnu.net/)
[![DaiNam University](https://img.shields.io/badge/DaiNam%20University-red?style=for-the-badge)](https://daihocdainam.edu.vn/)
</div>

<h2 align="center">Nền tảng học tập trực tuyến thông minh</h2>

<p align="left">
  Ứng dụng E-Learning tích hợp AI là nền tảng học tập thông minh sử dụng trí tuệ nhân tạo để cá nhân hóa trải nghiệm học tập. Hệ thống kết hợp công nghệ xử lý ngôn ngữ tự nhiên (NLP) với nền tảng học tập trực tuyến, giúp người dùng tiếp cận kiến thức một cách hiệu quả và tương tác. Ứng dụng được phát triển bởi sinh viên Khoa Công nghệ Thông tin, Trường Đại học Đại Nam.
</p>

---

## 🌟 Giới thiệu

- **📚 Học tập thông minh:** Hệ thống sử dụng AI để đề xuất lộ trình học tập phù hợp với từng người dùng.
- **🤖 Trợ lý ảo thông minh:** Hỗ trợ giải đáp thắc mắc 24/7 bằng công nghệ xử lý ngôn ngữ tự nhiên.
- **📊 Đánh giá năng lực:** Phân tích điểm mạnh, yếu của người học thông qua hệ thống bài kiểm tra thông minh.
- **🎯 Cá nhân hóa:** Đề xuất nội dung học tập dựa trên sở thích và khả năng của từng người dùng.
- **📱 Đa nền tảng:** Hoạt động trên mọi thiết bị: điện thoại, máy tính bảng và trình duyệt web.

---

## 🏗️ KIẾN TRÚC HỆ THỐNG
<p align="center">
  <img src="assets/images/system_architecture.png" alt="System Architecture" width="800"/>
</p>

---

## 📂 CẤU TRÚC DỰ ÁN

```
elearning_app/
├── android/               # Native Android code
├── assets/               # Hình ảnh, fonts, dữ liệu tĩnh
│   ├── images/           # Hình ảnh ứng dụng
│   └── icons/            # Icon ứng dụng
├── ios/                  # Native iOS code
├── lib/                  # Mã nguồn chính
│   ├── config/           # Cấu hình ứng dụng
│   ├── models/           # Các model dữ liệu
│   ├── providers/        # State management
│   ├── screens/          # Các màn hình
│   ├── services/         # Các dịch vụ (API, database, ...)
│   ├── utils/            # Tiện ích hỗ trợ
│   ├── widgets/          # Các widget tái sử dụng
│   └── main.dart         # Điểm khởi đầu ứng dụng
├── test/                 # Các file test
└── web/                  # Web-specific code
```

---

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase">
  <img src="https://img.shields.io/badge/Google_AI-4285F4?style=for-the-badge&logo=google-ai&logoColor=white" alt="Google AI">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android">
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white" alt="iOS">
  <img src="https://img.shields.io/badge/Web-4285F4?style=for-the-badge&logo=google-chrome&logoColor=white" alt="Web">
</div>

## 📱 Giới Thiệu

Ứng dụng E-Learning đa nền tảng được phát triển bằng Flutter, tích hợp trí tuệ nhân tạo (AI) để nâng cao trải nghiệm học tập. Ứng dụng cung cấp giải pháp học tập toàn diện với giao diện thân thiện, nội dung đa dạng và tính năng thông minh.

## ✨ Tính Năng Nổi Bật

### 🔐 Xác Thực & Bảo Mật
- Đăng nhập/Đăng ký bằng Email & Mật khẩu
- Đăng nhập bằng Google, Facebook
- Khôi phục mật khẩu tự động
- Quản lý hồ sơ cá nhân
- Phân quyền người dùng

### 📚 Quản Lý Khóa Học
- Duyệt danh sách khóa học đa dạng
- Tìm kiếm và lọc khóa học thông minh
- Xem trước nội dung khóa học
- Đánh giá và nhận xét khóa học
- Hệ thống thanh toán trực tuyến
- Tải xuống khóa học để học offline

### 🎥 Học Tập Tương Tác
- Trình phát video với đầy đủ chức năng
- Hỗ trợ đa nền tảng (YouTube, Vimeo, tự host)
- Chế độ Picture-in-Picture
- Điều chỉnh tốc độ phát
- Đánh dấu và ghi chú video
- Phụ đề đa ngôn ngữ

### 🤖 Trợ Lý Học Tập AI
- Chatbot hỗ trợ học tập 24/7
- Tự động tạo câu hỏi từ nội dung bài học
- Gợi ý lộ trình học tập cá nhân hóa
- Giải đáp thắc mắc tức thì
- Hỗ trợ đa ngôn ngữ

### 📝 Kiểm Tra & Đánh Giá
- Hệ thống bài kiểm tra đa dạng
- Tự động chấm điểm và nhận xét
- Luyện tập với ngân hàng câu hỏi
- Xem lại lịch sử làm bài
- Báo cáo tiến độ chi tiết

### 📊 Theo Dõi Tiến Độ
- Thống kê thời gian học tập
- Đánh giá năng lực qua các bài kiểm tra
- Mục tiêu học tập cá nhân
- Nhận huy hiệu và chứng chỉ
- So sánh với cộng đồng

## 🛠️ CÔNG NGHỆ SỬ DỤNG

<div align="center">

### 📱 Frontend
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue?style=for-the-badge&logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-2.17+-blue?style=for-the-badge&logo=dart)](https://dart.dev/)
[![Provider](https://img.shields.io/badge/Provider-State%20Management-orange?style=for-the-badge)](https://pub.dev/packages/provider)

### ☁️ Backend
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Google AI](https://img.shields.io/badge/Google_AI-4285F4?style=for-the-badge&logo=google-ai&logoColor=white)](https://ai.google/)
[![Stripe](https://img.shields.io/badge/Stripe-008CDD?style=for-the-badge&logo=stripe&logoColor=white)](https://stripe.com/)

### 🛠 Công Cụ Phát Triển
[![Android Studio](https://img.shields.io/badge/Android_Studio-3DDC84?style=for-the-badge&logo=android-studio&logoColor=white)](https://developer.android.com/studio)
[![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visual-studio-code&logoColor=white)](https://code.visualstudio.com/)
[![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)](https://git-scm.com/)
</div>

### Frontend
- **Flutter** - Framework đa nền tảng
- **Dart** - Ngôn ngữ lập trình
- **Provider** - Quản lý trạng thái ứng dụng
- **GetIt** - Service locator
- **Dio** - Xử lý API

### Backend
- **Firebase Authentication** - Xác thực người dùng
- **Cloud Firestore** - Cơ sở dữ liệu NoSQL
- **Firebase Storage** - Lưu trữ file
- **Cloud Functions** - Xử lý backend
- **Google Gemini AI** - Xử lý ngôn ngữ tự nhiên

### Công Cụ Phát Triển
- **Android Studio** - Môi trường phát triển
- **VS Code** - Trình soạn thảo code
- **Git** - Quản lý phiên bản
- **Figma** - Thiết kế giao diện

## 📸 HÌNH ẢNH ỨNG DỤNG

<div align="center">
  <img src="screenshots/home.png" width="200" alt="Màn hình chính">
  <img src="screenshots/course-detail.png" width="200" alt="Chi tiết khóa học">
  <img src="screenshots/learning.png" width="200" alt="Màn hình học tập">
  <img src="screenshots/quiz.png" width="200" alt="Làm bài kiểm tra">
</div>

## 🚀 HƯỚNG DẪN CÀI ĐẶT

### Yêu Cầu Hệ Thống
- **Flutter SDK** >= 3.0.0
- **Dart SDK** >= 2.17.0
- **Android Studio** / Xcode (tùy chọn)
- **Android SDK** / Xcode Command Line Tools

### Yêu Cầu Hệ Thống
- Flutter SDK >= 3.0.0
- Dart SDK >= 2.17.0
- Android Studio / Xcode (tùy chọn)
- Android SDK / Xcode Command Line Tools

### Các Bước Cài Đặt

1. **Clone repository**
   ```bash
   git clone https://github.com/yourusername/elearning-app.git
   cd elearning-app
   ```

2. **Cài đặt dependencies**
   ```bash
   flutter pub get
   ```

3. **Cấu hình Firebase**
   - Tạo project mới trên [Firebase Console](https://console.firebase.google.com/)
   - Thêm ứng dụng Android/iOS/Web
   - Tải file cấu hình và đặt đúng thư mục
   - Bật các dịch vụ: Authentication, Firestore, Storage

4. **Cấu hình Google Gemini AI**
   - Tạo API key từ Google AI Studio
   - Thêm API key vào file cấu hình

5. **Chạy ứng dụng**
   ```bash
   flutter run
   ```

## 🤝 ĐÓNG GÓP

Dự án được phát triển bởi:

| Họ và Tên         | Vai trò                                                        |
|-------------------|----------------------------------------------------------------|
| Quàng Minh Anh    | Phát triển giao diện người dùng, tích hợp AI, quản lý dự án    |

---

## 📞 LIÊN HỆ

- **Tác giả:** Quàng Minh Anh
- **Email:** quangminhanh2004@gmail.com
- **Khoa Công nghệ Thông tin**
- **Trường Đại học Đại Nam**
- **Địa chỉ:** Số 56 Vũ Trọng Phụng, Thanh Xuân, Hà Nội
- **Website:** [daihocdainam.edu.vn](https://daihocdainam.edu.vn/)

## 🙏 LỜI CẢM ƠN

Chúng tôi xin chân thành cảm ơn:
- Ban Giám hiệu Trường Đại học Đại Nam
- Quý thầy cô Khoa Công nghệ Thông tin
- Các bạn sinh viên đã tham gia đóng góp ý kiến
- Cộng đồng phát triển mã nguồn mở

---

<div align="center">
  <p>© 2025 Bản quyền thuộc về Nhóm phát triển E-Learning - Đại học Đại Nam</p>
  <p>
    <a href="https://daihocdainam.edu.vn/">
      <img src="https://daihocdainam.edu.vn/templates/dainamuniversity/images/logo.png" alt="Đại học Đại Nam" width="150">
    </a>
  </p>
</div>
- Thống kê chi tiết
- Certificates khi hoàn thành
- Learning streak & achievements

### 💳 Payment Integration
- Thanh toán qua Stripe
- Thanh toán qua Razorpay
- Lịch sử giao dịch
- Hóa đơn điện tử

### 🤖 AI Chatbot
- Trò chuyện với AI assistant
- Hỏi đáp về nội dung khóa học
- Giải thích khái niệm
- Gợi ý học tập
- Tạo quiz tự động

## 🚀 Cài đặt

```bash
# Clone repository
git clone <repository-url>

# Di chuyển vào thư mục
cd elearning_app

# Cài đặt dependencies
flutter pub get

# Chạy build_runner cho Hive
flutter pub run build_runner build

# Chạy ứng dụng
flutter run
```

## ⚙️ Cấu hình

### Firebase Setup
1. Tạo project trên Firebase Console
2. Thêm Android & iOS app
3. Download `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)
4. Enable Authentication, Firestore, Storage

### Payment Setup
1. **Stripe**: Thêm publishable key vào `lib/config/payment_config.dart`
2. **Razorpay**: Thêm API key vào config

### AI Chatbot Setup
1. Lấy API key từ Google AI Studio hoặc OpenAI
2. Thêm vào `lib/config/ai_config.dart`

## 📁 Cấu trúc dự án

```
lib/
├── config/           # Configuration files
├── models/           # Data models
├── services/         # Business logic & API
├── providers/        # State management
├── screens/          # UI screens
├── widgets/          # Reusable widgets
├── utils/            # Utilities & helpers
└── main.dart         # Entry point
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider + GetX
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Payment**: Stripe, Razorpay
- **AI**: Google Generative AI, ChatGPT
- **Video**: Chewie, YouTube Player
- **Local DB**: Hive

## 📱 Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📄 License

MIT License
