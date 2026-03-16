# SmartBudget

![SmartBudget](https://img.shields.io/badge/Flutter-3.0%2B-blue) ![License](https://img.shields.io/badge/License-MIT-green) ![Creator](https://img.shields.io/badge/Created%20by-Lwando%20Tsomi-brightgreen)

A comprehensive Flutter app for managing personal budgets, transactions, income, expenses, and financial goals with detailed analytics and reporting.

**👤 Creator:** Lwando Tsomi

## About the App

SmartBudget is a full-featured personal finance management application built with Flutter. It helps users track their spending, manage budgets by category, set financial goals, and analyze their financial trends through interactive reports and charts.

### Features

- **Dashboard**: Quick overview of your financial status with balance cards and recent transactions
- **Transactions**: Add, view, and manage all income and expense transactions
- **Budgets**: Create and monitor budgets for different spending categories
- **Goals**: Set and track financial goals with progress visualization
- **Reports & Analytics**: 
  - Summary statistics (total transactions, income, expenses, averages)
  - Expense breakdown by category with pie charts
  - Income breakdown by source
  - Spending trends and monthly comparisons
- **Data Management**: Export transaction data as CSV files
- **Notifications**: Get alerts when budget limits are approached
- **Settings**: Customize app preferences and categories

## Getting Started

1. **Install Flutter**: https://flutter.dev/docs/get-started/install
2. **Clone/Download** this project
3. **Install dependencies**: `flutter pub get`
4. **Run the app**: `flutter run`

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/
│   ├── transaction.dart      # Transaction data model
│   ├── budget.dart           # Budget data model
│   ├── category.dart         # Category data model
│   └── goal.dart             # Goal data model
├── services/
│   ├── database_service.dart # SQLite database operations
│   ├── reports_service.dart  # Analytics and reporting logic
│   ├── notification_service.dart # Push notifications
│   └── export_service.dart   # Data export functionality
├── providers/
│   ├── transaction_provider.dart   # Transaction state management
│   ├── budget_provider.dart        # Budget state management
│   ├── category_provider.dart      # Category state management
│   ├── goal_provider.dart          # Goal state management
│   └── data_upload_provider.dart   # Data upload state
├── screens/
│   ├── dashboard_screen.dart       # Main dashboard
│   ├── transactions_screen.dart    # Transaction list
│   ├── add_transaction_screen.dart # Add new transaction
│   ├── budgets_screen.dart         # Budget management
│   ├── goal_screen.dart            # Goals tracking
│   ├── reports_screen.dart         # Analytics & reports
│   ├── settings_screen.dart        # App settings
│   ├── calculation_screen.dart     # Quick calculator
│   └── data_upload_screen.dart     # Data import/export
├── widgets/
│   ├── balance_card.dart           # Reusable balance card
│   ├── category_icon.dart          # Category icon selector
│   └── transaction_tile.dart       # Transaction list item
└── utils/
    ├── constants.dart              # App constants
    └── date_formatter.dart         # Date formatting utilities
```

## Technologies Used

- **Flutter**: UI framework
- **Provider**: State management
- **SQLite**: Local database
- **FL Chart**: Data visualization
- **Flutter Local Notifications**: Push notifications

## Requirements

- Flutter SDK >=3.0.0
- Dart >=3.0.0

## Installation

### Clone the Repository

```bash
git clone https://github.com/lwandotsomi-svg/smartbudget.git
cd smartbudget
```

### Get Dependencies

```bash
flutter pub get
```

### Run

#### On Android/iOS Device
```bash
flutter run
```

#### On Web
```bash
flutter run -d chrome
```

#### On Windows
```bash
flutter run -d windows
```

## Usage

1. **Add Transactions**: Record your income and expenses with categories
2. **Set Budgets**: Define spending limits for each category
3. **Track Goals**: Create and monitor financial goals
4. **View Reports**: Analyze your spending patterns with detailed analytics
5. **Export Data**: Export your transaction history as CSV
6. **Receive Alerts**: Get notifications when approaching budget limits

## Features in Detail

### Dashboard
- Real-time balance overview
- Recent transaction history
- Quick statistics

### Transaction Management
- Add income and expense transactions
- Organize by category
- Add notes for tracking
- Support for recurring transactions

### Budget Management
- Create category-based budgets
- Monitor spending against limits
- Budget alerts and reminders

### Financial Goals
- Set saving targets
- Track progress towards goals
- View achievement timeline

### Analytics & Reports
- Summary statistics
- Expense breakdown by category (pie chart)
- Income sources visualization
- Monthly spending trends
- Year-over-year comparisons

### Data Management
- 100% offline - all data stored locally
- Export transactions to CSV
- No cloud sync (privacy first)
- No data collection

## Architecture

### State Management
The app uses the Provider pattern for state management, ensuring:
- Reactive UI updates
- Efficient data flow
- Easy testing and maintenance

### Local Storage
- SQLite database for persistent storage
- No external API dependencies
- Complete data ownership

### Notifications
- Flutter Local Notifications
- Cross-platform support
- Customizable alerts

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Lwando Tsomi** - Project Creator and Maintainer

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Feedback & Support

If you have suggestions or found a bug, please open an issue on GitHub.

## Disclaimer

SmartBudget is provided as-is for personal finance tracking. While every effort has been made to ensure accuracy, users are responsible for verifying financial calculations and data.

---

**Made with ❤️ by Lwando Tsomi**