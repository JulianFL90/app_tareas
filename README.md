
📱 Task Management App – Technical Center

A mobile application built with Flutter to manage technical tasks inside an industrial maintenance center.

The goal of this project is to replace informal communication methods (WhatsApp / verbal communication) with a structured, traceable and scalable task management system.

🚩 Problem It Solves

In technical and industrial environments:

Tasks are communicated verbally

There is no historical record

It is unclear who created the task

Incidents are lost between shifts

No structured priority control exists

This application allows:

Creating tasks linked to a specific machine

Setting task priority

Registering the technician who created the task

Maintaining task history

Preparing the system for multi-center scalability

🧱 Tech Stack

Flutter (Dart)

Feature-based architecture

Domain-oriented structure

Designed for future integration with:

Drift (local database)

Backend API (NestJS / REST)

📂 Project Structure
lib/
├── app/
├── features/
│    └── tasks/
│         ├── domain/
│         ├── presentation/
│         └── data/ (planned)
└── main.dart


Clear separation between:

UI (presentation layer)

Domain models

Future data layer

⚙️ Current Status (MVP)

✔ Task creation
✔ Machine selection
✔ Priority selection
✔ Scalable project structure
🔜 Local persistence with Drift
🔜 Image attachment support
🔜 Multi-center support

🏗 Roadmap
Phase 1 – Local MVP

Local persistence using Drift

Task listing screen

Filtering by machine and priority

Phase 2 – Scalability

Multi-center support

Technician management

Simple authentication system

Phase 3 – Enterprise Expansion

Centralized backend

Cross-center synchronization

Spare parts request system between centers

Technical chatbot with shared documentation

▶️ How to Run
flutter pub get
flutter run

🎯 Long-Term Vision

Transform this project into a scalable industrial task management solution that enables:

Standardized incident tracking

Full traceability

Structured communication between centers

Future integration with predictive maintenance systems