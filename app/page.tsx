export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <header className="bg-white shadow-sm">
        <nav className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
          <div className="flex items-center space-x-2">
            <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold">TN</span>
            </div>
            <h1 className="text-xl font-bold text-gray-900">Thảo Nguyên</h1>
          </div>
          <ul className="hidden md:flex space-x-8">
            <li><a href="#" className="text-gray-700 hover:text-blue-600">Trang chủ</a></li>
            <li><a href="#" className="text-gray-700 hover:text-blue-600">Khóa học</a></li>
            <li><a href="#" className="text-gray-700 hover:text-blue-600">Giáo viên</a></li>
            <li><a href="#" className="text-gray-700 hover:text-blue-600">Liên hệ</a></li>
          </ul>
          <div className="space-x-4">
            <button className="px-4 py-2 text-blue-600 border border-blue-600 rounded-lg hover:bg-blue-50">Đăng nhập</button>
            <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">Đăng ký</button>
          </div>
        </nav>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="text-center mb-12">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
            Học Ngoại Ngữ - Mở Lời Tương Lai
          </h2>
          <p className="text-xl text-gray-600 mb-8">
            Thảo Nguyên đồng hành cùng bạn chinh phục mọi ngôn ngữ
          </p>
          <button className="px-8 py-3 bg-blue-600 text-white rounded-lg text-lg font-semibold hover:bg-blue-700">
            Khám phá khóa học
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
          <div className="bg-white rounded-lg shadow-md p-6">
            <div className="text-3xl mb-4">👨‍🏫</div>
            <h3 className="text-xl font-bold text-gray-900 mb-2">Giáo viên Chuyên Nghiệp</h3>
            <p className="text-gray-600">Đội ngũ giáo viên giàu kinh nghiệm, có chứng chỉ quốc tế</p>
          </div>
          <div className="bg-white rounded-lg shadow-md p-6">
            <div className="text-3xl mb-4">💻</div>
            <h3 className="text-xl font-bold text-gray-900 mb-2">Học Trực Tuyến Hiện Đại</h3>
            <p className="text-gray-600">Nền tảng học tập tiên tiến với công nghệ mới nhất</p>
          </div>
          <div className="bg-white rounded-lg shadow-md p-6">
            <div className="text-3xl mb-4">🏆</div>
            <h3 className="text-xl font-bold text-gray-900 mb-2">Chứng Chỉ Quốc Tế</h3>
            <p className="text-gray-600">Cấp chứng chỉ được công nhận toàn cầu</p>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-8">
          <h3 className="text-2xl font-bold text-gray-900 mb-6">Khóa Học Nổi Bật</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {['Tiếng Anh A1', 'IELTS Foundation', 'TOEIC 450+', 'Tiếng Trung HSK 1'].map((course, idx) => (
              <div key={idx} className="border border-gray-200 rounded-lg p-4 hover:shadow-lg transition-shadow">
                <h4 className="font-semibold text-gray-900 mb-2">{course}</h4>
                <p className="text-sm text-gray-600 mb-4">8 chủ đề • 12 buổi</p>
                <button className="w-full px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm font-medium">
                  Đăng ký
                </button>
              </div>
            ))}
          </div>
        </div>
      </main>

      <footer className="bg-gray-900 text-white mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
            <div>
              <h4 className="font-bold mb-4">Về Thảo Nguyên</h4>
              <p className="text-gray-400 text-sm">Trung tâm ngoại ngữ hàng đầu với nhiều năm kinh nghiệm</p>
            </div>
            <div>
              <h4 className="font-bold mb-4">Khóa Học</h4>
              <ul className="text-gray-400 text-sm space-y-2">
                <li><a href="#" className="hover:text-white">Tiếng Anh</a></li>
                <li><a href="#" className="hover:text-white">IELTS</a></li>
                <li><a href="#" className="hover:text-white">TOEIC</a></li>
                <li><a href="#" className="hover:text-white">Tiếng Trung</a></li>
              </ul>
            </div>
            <div>
              <h4 className="font-bold mb-4">Hỗ Trợ</h4>
              <ul className="text-gray-400 text-sm space-y-2">
                <li><a href="#" className="hover:text-white">Liên hệ</a></li>
                <li><a href="#" className="hover:text-white">FAQ</a></li>
                <li><a href="#" className="hover:text-white">Chính sách</a></li>
                <li><a href="#" className="hover:text-white">Điều khoản</a></li>
              </ul>
            </div>
            <div>
              <h4 className="font-bold mb-4">Liên Hệ</h4>
              <p className="text-gray-400 text-sm">Email: info@thaonguyen.com</p>
              <p className="text-gray-400 text-sm">Phone: 0123 456 789</p>
              <p className="text-gray-400 text-sm">Địa chỉ: Tp.HCM</p>
            </div>
          </div>
          <div className="border-t border-gray-800 pt-8 text-center text-gray-400 text-sm">
            <p>&copy; 2024 Thảo Nguyên. All rights reserved.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
