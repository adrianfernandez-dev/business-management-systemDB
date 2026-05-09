# Business Management System

Inventory and sales management system developed with C#, ASP.NET Core, Entity Framework Core, and SQL Server.

This project was designed to manage products, orders, invoices, customers, and inventory processes for a business environment.

---

## 🚀 Features

* Inventory management
* Sales and order tracking
* Invoice generation
* Customer management
* Product categorization
* SQL Server database integration
* Automated stock validation using triggers

---

## 🛠️ Tech Stack

### Backend

* C#
* ASP.NET Core
* Entity Framework Core

### Database

* SQL Server
* SQL Server Management Studio (SSMS)

### Networking & Tools

* Git & GitHub
* Visual Studio 2022

---

## 🗄️ Database Configuration

To run this project locally, update the SQL Server connection settings in:

* `TopCabinetsDbContext.cs`
* `appsettings.json`

Example connection string:

```json id="8mhfd9"
"ConnectionStrings": {
  "DefaultConnection": "Server=YOUR_SERVER_NAME;Database=TopCabinets_DB;Trusted_Connection=True;TrustServerCertificate=True;"
}
```

---

## 📂 Database Setup

The SQL database script is included in:

```text id="7qv2yr"
/database/TopCabinets_DB.sql
```

### Setup Instructions

1. Open SQL Server Management Studio (SSMS)
2. Execute the SQL script
3. Configure the connection string
4. Open the solution in Visual Studio 2022
5. Run the project


## 📌 Project Structure

```text id="h7p5kg"
business-management-system/
│
├── database/
├── screenshots/
├── docs/
├── TopCabinetsCorpApp/
├── README.md
└── TopCabinetsCorpApp.sln
```

---

## 👨‍💻 Author

Adrian Fernandez

* GitHub: https://github.com/adrianfernandez-dev
* LinkedIn: https://www.linkedin.com/in/adrian-fernández-3a449432b

---

## 📄 License

This project is licensed under the MIT License.
