import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Thảo Nguyên - Language Center Management System",
  description: "Hệ thống quản lý trung tâm ngoại ngữ Thảo Nguyên",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="vi">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
