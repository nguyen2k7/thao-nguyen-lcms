# Thảo Nguyên - Language Center Management System (LCMS)

## 📋 Giới Thiệu

Hệ thống quản lý trung tâm ngoại ngữ toàn diện, tích hợp website công khai, đăng ký khóa học, thanh toán, Learning Hub, quản lý giáo viên, quản lý điều hành, quản trị hệ thống và báo cáo tài chính.

## 🏗️ Kiến Trúc Hệ Thống

```
Thảo Nguyên LCMS
├── Website Công Khai (Public)
├── Learning Hub (Student)
├── Teacher Portal
├── Manager Portal
├── Admin Portal
└── Financial Module
```

## 💻 Stack Công Nghệ

### Frontend
- **Framework**: Next.js 15
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **UI Components**: shadcn/ui (sắp tới)
- **Charts**: Recharts
- **Icons**: Lucide React

### Backend
- **Platform**: Supabase (Backend-as-a-Service)
- **Database**: PostgreSQL
- **Authentication**: Supabase Auth (JWT)
- **Storage**: Supabase Storage
- **Real-time**: Supabase Realtime

### Infrastructure
- **Deployment**: Vercel
- **Version Control**: GitHub
- **CI/CD**: GitHub Actions (sắp tới)

## 📁 Cấu Trúc Dự Án

```
lcms/
├── app/
│   ├── (public)/              # Website công khai
│   ├── (auth)/                # Authentication pages
│   ├── student/               # Learning Hub
│   ├── teacher/               # Teacher Portal
│   ├── manager/               # Manager Portal
│   ├── admin/                 # Admin Portal
│   ├── api/                   # API Routes
│   └── layout.tsx
├── components/                # Reusable components
├── features/                  # Feature modules
├── hooks/                     # Custom hooks
├── lib/                       # Utilities
├── services/                  # API services
├── database/                  # Database schema
├── types/                     # TypeScript types
├── utils/                     # Helper functions
├── styles/                    # Global styles
├── public/                    # Static files
└── docs/                      # Documentation
```

## 🚀 Cách Chạy Dự Án

### Yêu Cầu
- Node.js >= 18
- npm hoặc yarn
- Supabase account

### Installation

1. **Clone repository**
```bash
git clone https://github.com/nguyen2k7/thao-nguyen-lcms.git
cd thao-nguyen-lcms
```

2. **Cài dependencies**
```bash
npm install
```

3. **Tạo file .env.local**
```bash
cp .env.example .env.local
```

4. **Điền thông tin Supabase**
```
NEXT_PUBLIC_SUPABASE_URL=your_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key
```

5. **Chạy development server**
```bash
npm run dev
```

6. **Mở browser**
```
http://localhost:3000
```

## 📊 Phân Quyền (4 Roles)

| Role | Phạm Vi | Quyền Chính |
|------|--------|------------|
| **Học Viên** | Learning Hub | Học bài, làm bài tập, xem điểm |
| **Giáo Viên** | Lớp phụ trách | Đăng bài, chấm điểm, nhập điểm |
| **Quản Lý** | Toàn điều hành | Tuyển sinh, khóa học, lớp, thanh toán |
| **Quản Trị** | Hệ thống | Mọi thứ + Cài đặt system |

## 📈 Giai Đoạn Phát Triển

- [ ] **Giai đoạn 1**: Phân tích & thiết kế (Database ERD, API, User Flows)
- [ ] **Giai đoạn 2**: Setup & Foundation (Auth, RBAC)
- [ ] **Giai đoạn 3**: Core Features (Website, Đăng ký, Thanh toán)
- [ ] **Giai đoạn 4**: Learning Hub
- [ ] **Giai đoạn 5**: Teacher Portal
- [ ] **Giai đoạn 6**: Manager Portal
- [ ] **Giai đoạn 7**: Admin Portal
- [ ] **Giai đoạn 8**: Testing & Deployment

## 📚 Tài Liệu

Tất cả tài liệu nằm trong thư mục `docs/`:

- `01_PROJECT_OVERVIEW.md` - Tổng quan dự án
- `02_SYSTEM_DESCRIPTION.md` - Mô tả hệ thống chi tiết
- `03_DATABASE_ERD.md` - Database schema
- `04_API_DOCUMENTATION.md` - API endpoints
- `05_PERMISSION_SYSTEM.md` - Hệ thống phân quyền
- `06_FINANCIAL_MODULE.md` - Module tài chính
- `07_USER_FLOWS.md` - Quy trình người dùng

## 🔐 Bảo Mật

- JWT Authentication
- Role-based Access Control (RBAC)
- Encryption for sensitive data
- Audit logs

## 📝 Hướng Dẫn Đóng Góp

1. Fork repository
2. Tạo branch: `git checkout -b feature/your-feature`
3. Commit changes: `git commit -m 'Add new feature'`
4. Push to branch: `git push origin feature/your-feature`
5. Tạo Pull Request

## 📞 Liên Hệ

- Email: info@thaonguyen.com
- Phone: 0123 456 789
- Website: https://thaonguyen.com

## 📄 Giấy Phép

MIT License - xem file LICENSE để chi tiết

## 🎯 Mục Tiêu Dài Hạn

✨ Hệ thống quản lý trung tâm ngoại ngữ hiện đại
✨ Tích hợp đầy đủ từ tuyển sinh đến hoàn thành khóa học
✨ Trải nghiệm liền mạch cho học viên, giáo viên, quản lý
✨ Báo cáo tài chính chi tiết và chính xác

---

**Last Updated**: December 2024
**Version**: 0.1.0
