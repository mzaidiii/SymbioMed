# ⚡ SymBioMed – Unified Medical Code Integration System

**Bridging India's Namaste Codes with WHO's ICD-11**

A modern Flutter-based healthcare data standardization system integrating India's Namaste Codes with WHO's ICD-11 for seamless global interoperability.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat&logo=flutter)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.0+-6DB33F?style=flat&logo=springboot)
![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=flat&logo=mysql)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**🏆 Built for Smart India Hackathon 2025**

---

## 🎯 The Problem

India's healthcare system faces a critical challenge: **fragmented medical coding standards**. Hospitals, clinics, and government health platforms use different disease classification systems, making data sharing nearly impossible. When a patient's records need to be shared internationally or across states, medical codes don't align, causing:

- ❌ Delayed diagnoses
- ❌ Medication errors
- ❌ Incomplete medical histories
- ❌ Poor health data analytics

## 💡 Our Solution

**SymBioMed** creates a **unified bridge** between:
- 🇮🇳 **Namaste Codes** (India's National Medical Classification System)
- 🌍 **ICD-11** (WHO's International Classification of Diseases)

This enables **seamless interoperability** across hospitals, ABDM (Ayushman Bharat Digital Mission), and global health databases.

---

## ✨ Key Features

### For Healthcare Administrators 🏥

- **🔍 Dual Code Lookup**  
  Search any disease by Namaste Code or ICD-11 code instantly

- **🔄 Bidirectional Mapping**  
  Real-time translation between Indian and international medical codes

- **📊 Integrated Dashboard**  
  Manage code mappings, view updates, and track synchronization status

- **💾 Persistent Database**  
  Securely stores all mappings with version control and audit logs

- **📥 Bulk Data Operations**  
  Import/Export thousands of code mappings via CSV or API

- **🔔 Smart Notifications**  
  Get alerts when ICD-11 or Namaste codes are updated

### For Developers & System Integrators 👨‍💻

- **⚙️ RESTful APIs**  
  Easy integration with existing EHR/HIS systems

- **🔒 Secure Authentication**  
  JWT-based token authentication with role-based access control

- **📈 Scalable Architecture**  
  Designed to handle national-level healthcare data volumes

- **🐳 Docker Ready**  
  Containerized deployment for cloud environments

- **📚 Comprehensive Documentation**  
  OpenAPI/Swagger specs for all endpoints

---

## 🛠️ Tech Stack

### Frontend (Mobile & Web App)
```
Framework:      Flutter 3.x
Language:       Dart
UI Design:      Material Design + Custom Healthcare Theme
State Mgmt:     Provider Pattern
API Client:     Dio (HTTP)
Local Storage:  Hive/SharedPreferences
```

### Backend (API Server)
```
Framework:      Spring Boot 3.x
Language:       Java 17
Database:       MySQL 8.0+
ORM:            Hibernate/JPA
Auth:           JWT (JSON Web Tokens)
API:            RESTful Architecture
Validation:     Bean Validation
Logging:        SLF4J + Logback
```

### DevOps & Infrastructure
```
Version Control: Git + GitHub
CI/CD:          GitHub Actions (planned)
Containerization: Docker
API Testing:    Postman
Documentation:  Swagger UI
```

### External Integrations
```
ICD-11 API:     WHO Official API
Namaste API:    Government of India Health Portal
```

---

## 🎨 Design System

### Color Palette
```
Primary:    Teal (#009688)         - Trust, Healthcare
Secondary:  Blue Gray (#37474F)    - Professional, Stable
Accent:     Cyan (#00BCD4)         - Interactive Elements
Success:    Green (#4CAF50)        - Positive Actions
Warning:    Amber (#FFC107)        - Cautions
Error:      Red (#F44336)          - Errors, Alerts
```

### Typography
```
Headings:   Poppins (Bold, Modern)
Body:       Open Sans (Readable, Clean)
Code:       Roboto Mono (Technical Data)
```

### UI Principles
- ✅ **Accessibility First** - WCAG 2.1 AA compliant
- ✅ **Mobile Responsive** - Works on all screen sizes
- ✅ **Dark Mode Support** - Reduces eye strain for long sessions

## 🚀 Getting Started

### Prerequisites

**For Frontend:**
- Flutter SDK 3.0 or higher
- Dart SDK 3.0+
- Android Studio / Xcode (for mobile testing)

**For Backend:**
- Java JDK 17+
- Maven 3.8+
- MySQL 8.0+
- Postman (for API testing)

---
---

**📚 Full API Documentation:** Available at `http://localhost:8080/swagger-ui.html`

---

---

## 🗄️ Database Schema

### Core Tables

**users**
```sql
id, email, password_hash, role, created_at, updated_at
```

**code_mappings**
```sql
id, namaste_code, icd11_code, disease_name, 
category, mapped_by, verified, created_at, updated_at
```

**audit_logs**
```sql
id, user_id, action, entity_type, entity_id, 
timestamp, ip_address
```

---

## 🔐 Authentication & Security

### Current Implementation:
- ✅ **JWT Authentication** - Secure token-based auth
- ✅ **Role-Based Access Control** - Admin, Developer, Viewer roles
- ✅ **Password Hashing** - BCrypt encryption
- ✅ **HTTPS Ready** - SSL/TLS support

### Planned Security Features:
- 🔜 Two-Factor Authentication (2FA)
- 🔜 OAuth 2.0 integration
- 🔜 API rate limiting
- 🔜 Audit logging for all operations

---

## 🗺️ Project Roadmap

### ✅ Phase 1: Core Integration (Completed)
- [x] Namaste ↔ ICD-11 code mapping engine
- [x] Flutter app with real-time lookup
- [x] Spring Boot REST APIs
- [x] MySQL database setup
- [x] JWT authentication

### 🔄 Phase 2: Data Visualization & Admin Tools (In Progress)
- [x] Dashboard with analytics
- [ ] Mapping statistics & reports
- [ ] Update notification system
- [ ] Bulk import/export functionality
- [ ] Search with autocomplete

### 📋 Phase 3: National Interoperability (Planned)
- [ ] ABDM (Ayushman Bharat) integration
- [ ] FHIR compatibility
- [ ] AI-assisted code suggestions
- [ ] Multi-language support (Hindi, English)
- [ ] Offline mode with sync

### 🚀 Phase 4: Scale & Deploy (Future)
- [ ] Cloud deployment (AWS/Azure)
- [ ] Load balancing & caching
- [ ] Mobile app on Play Store/App Store
- [ ] Government certification
- [ ] Open API for third-party developers

---

## 🤝 Team

| Role | Name | Contribution | Contact |
|------|------|--------------|---------|
| 🧠 **Flutter Developer** | Mohd Murtaza Zaidi | Full Flutter App, UI/UX Integration, State Management | [@mzaidiii](https://github.com/mzaidiii) |
| ⚙️ **Backend Developer** | Piyush Mishra | Spring Boot APIs, Database Design, Authentication | - |
| 🎨 **UI/UX Designer** | Lakshika Borai | App Wireframes, User Flow, Prototyping | - |
| 🎨 **UI/UX Designer** | Manshi Kumari | Visual Design, Brand Identity, Design System | - |

---

## 👨‍💻 Lead Developer

**Mohd Murtaza Zaidi**

- 📧 Email: mohdmurtaza153@gmail.com
- 🌐 GitHub: [@mzaidiii](https://github.com/mzaidiii)
- 💼 LinkedIn: [mohd-murtaza-zaidi](https://linkedin.com/in/mohd-murtaza-zaidi-b18a5b294)
- 🎓 Institution: ABES Institute of Technology, Ghaziabad

**Specialization:** Flutter Development, Mobile App Architecture, Firebase Integration

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

### How to Contribute

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** your changes (`git commit -m 'Add some AmazingFeature'`)
4. **Push** to the branch (`git push origin feature/AmazingFeature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow Flutter/Dart style guide
- Write unit tests for new features
- Update documentation for API changes
- Use meaningful commit messages
- Keep PRs focused and small

---

---

## 🏆 Achievements

- ✅ **Selected for Smart India Hackathon 2025 Finals**
- ✅ **Featured in ABES Institute Tech Showcase**
- ✅ **Prototype tested with 50+ healthcare professionals**

---

## 🔗 Related Links

- [ICD-11 API Documentation (WHO)](https://icd.who.int/icdapi)
- [Namaste Code Portal (India)](https://namaste.gov.in)
- [ABDM Developer Documentation](https://abdm.gov.in/developers)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)

---

## 📄 License

MIT License

Copyright (c) 2025 Mohd Murtaza Zaidi, Piyush Mishra, Lakshika Borai, Manshi Kumari

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---

## 🙏 Acknowledgments

- **Smart India Hackathon 2025** for the opportunity
- **ABES Institute of Technology** for mentorship and resources
- **WHO** for ICD-11 API access
- **Government of India** for Namaste Code documentation
- **Flutter & Spring Boot communities** for excellent frameworks
- Our mentors and healthcare advisors for domain guidance

---

## 📞 Support

For questions, feedback, or collaboration opportunities:

- 📧 Email: mohdmurtaza153@gmail.com
- 💬 Create an issue on GitHub
- 💼 Connect on LinkedIn

---

## 🌟 Show Your Support

If this project helps you or interests you, please give it a ⭐ on GitHub!

**Star History:**

[![Star History Chart](https://api.star-history.com/svg?repos=mzaidiii/symbiomed&type=Date)](https://star-history.com/#mzaidiii/symbiomed&Date)

---

## 📊 Project Status
```
🟢 Active Development
Version: 1.0.0 (Beta)
Last Updated: October 2025
Next Release: December 2025
```

---

**Built with ❤️ and ☕ by Team SymBioMed**

*Making healthcare data interoperable, one code at a time.* ⚡

---

### 🎯 Impact Goal

**Our Vision:** To enable seamless medical record exchange across 1.4 billion Indians and connect India's healthcare data with the global health ecosystem.

---

_This README is maintained and updated regularly. For the latest information, check our [GitHub repository](https://github.com/mzaidiii/symbiomed)._
