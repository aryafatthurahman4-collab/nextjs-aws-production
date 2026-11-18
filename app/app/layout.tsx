import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Next.js AWS Production",
  description: "Production-grade Next.js deployment on AWS EC2 with Docker, NGINX, SSL & CI/CD",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">{children}</body>
    </html>
  );
}
