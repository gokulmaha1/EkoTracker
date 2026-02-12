# EkoTracker Deployment Guide

## Prerequisites
- Node.js (v14+)
- MySQL Server
- Flutter SDK (v3.0+)
- Android Studio / VS Code
- Docker & Docker Compose (Optional)

## Backend Setup (Standard)
1. **Navigate to backend directory**:
   ```bash
   cd backend
   ```
2. **Install Dependencies**:
   ```bash
   npm install
   ```
3. **Configure Database**:
   - Create a MySQL database named `eko_tracker`.
   - Update `.env` file with your credentials:
     ```
     DB_HOST=localhost
     DB_USER=root
     DB_PASSWORD=yourpassword
     DB_NAME=eko_tracker
     JWT_SECRET=your_jwt_secret
     ```
   - Run the schema script to create tables:
     ```bash
     mysql -u root -p eko_tracker < schema.sql
     ```
4. **Start Server**:
   ```bash
   npm start
   ```
   The server will run on `http://localhost:3000`.
   The Admin Dashboard is available at `http://localhost:3000/index.html`.

## Backend Setup (Docker) 🐳
Easily deploy the backend and database with a single command.

1. **Run Docker Compose**:
   ```bash
   docker-compose up -d --build
   ```
2. **Access**:
   - Backend API: `http://localhost:3000`
   - Admin Dashboard: `http://localhost:3000/index.html`
   - Database: Accessible on port 3306 (User: root, Pass: rootpassword)

## Mobile App Setup
1. **Navigate to mobile_app directory**:
   ```bash
   cd mobile_app
   ```
2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configure API URL**:
   - Open `lib/core/constants.dart`.
   - Update `baseUrl` to your backend IP address (use `10.0.2.2` for Android Emulator, or your local IP `192.168.x.x` for physical device).
4. **Run App**:
   ```bash
   flutter run
   ```

## Admin Dashboard
- Access via `http://localhost:3000/index.html` after starting the backend.
- Default Admin credentials: You need to create an admin user manually in the database first or use the registration API (if enabled for public).
  ```sql
  INSERT INTO users (name, email, password_hash, role) VALUES ('Admin', 'admin@ekotracker.com', '$2b$10$YourHashedPassword', 'admin');
  ```
