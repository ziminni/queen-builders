# 🏗️ Queen Builders & Construction Supply Management System

A full-stack construction supply management system with **Django REST Framework** backend and **Flutter** frontend, featuring role-based access control, inventory management, POS, project tracking, and financial monitoring.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [Running the Application](#running-the-application)
- [Testing](#testing)
- [API Endpoints](#api-endpoints)
- [Role-Based Access](#role-based-access)
- [Screenshots](#screenshots)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This system manages hardware store operations including inventory tracking, sales transactions, construction project management, material transfers, and financial monitoring. Built with a clean MVVM architecture in Flutter and RESTful API design in Django.

## ✨ Features

### 👥 User Management
- Role-based access (Admin, Manager, Cashier, Project Supervisor, Staff)
- JWT authentication with token refresh
- User account CRUD operations
- Account action logging
- User profile management

### 📦 Inventory Management
- Real-time stock checking
- Inventory updates
- Stock movement history
- Low stock alerts

### 🏗️ Project Management
- Project CRUD operations
- Track project material usage
- Monitor project status and progress
- Project status updates

### 💰 Billing & POS
- Process sales transactions
- Generate sales records
- Auto-update inventory upon sale
- Transaction history

### 🚚 Material Transfer & Delivery
- Manage material requests
- Delivery status tracking
- Auto-deduct delivered materials
- Project inventory management
- Delivery history logs

### 📊 Financial Monitoring
- Accounts receivable tracking
- Payment recording
- Project cost monitoring

### 📈 Reporting & Analytics
- Stock status reports
- In-demand item analytics
- System metrics and reports
- Sales reports

## 🛠️ Tech Stack

### Backend
- **Django 4.2.30** - Web framework
- **Django REST Framework 3.14.0** - API development
- **Django REST Framework SimpleJWT 5.3.0** - JWT authentication
- **Django CORS Headers 4.3.1** - CORS handling
- **SQLite** (Development) / PostgreSQL (Production)

### Frontend
- **Flutter 3.x** - UI framework
- **Dio 5.3.2** - HTTP client
- **Provider 6.0.5** - State management
- **GoRouter 10.0.0** - Navigation
- **Flutter Secure Storage 9.0.0** - Token storage


## 📋 Prerequisites

- **Python 3.9+** with pip
- **Flutter 3.x** with Dart
- **Xcode** (for macOS development)
- **Git**

## 🚀 Installation

### Backend Setup

# Clone the repository
git clone https://github.com/yourusername/queen_builders.git
cd queen_builders/server

# Create virtual environment
python -m venv .env
source .env/bin/activate  # On Windows: .env\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Seed test data (optional)
python seed.py

# Start development server
python manage.py runserver

# Navigate to client directory
cd ../client

# Get Flutter dependencies
flutter pub get

# Run on macOS (development)
flutter run -d macos

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Run on web
flutter run -d chrome

## Testing

### Backend Testing

cd server

# Run Django tests
python manage.py test

# Test API endpoints with curl
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"admin123"}'

### Frontend Testing

cd client

# Run Flutter tests
flutter test

# Run widget tests
flutter test --tags=widget
