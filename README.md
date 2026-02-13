# SkyCast: A Modern Weather Experience

![SkyCast App Preview](assets/images/preview.png)

SkyCast is a high-performance weather application designed to deliver atmospheric insights with a focus on visual elegance and real-time accuracy. Developed using the Flutter framework, it leverages a glassmorphic design language to provide a premium user experience across platforms.

## Core Features

SkyCast is built to offer more than just a temperature reading. It provides a comprehensive view of the environment through a series of thoughtful features:

*   **Real-time Weather Data**: Instant access to current meteorological conditions for any city globally.
*   **Predictive Forecasts**: A multi-day forecast breakdown to help you plan your schedule with confidence.
*   **Glassmorphic Design**: A modern, translucent interface that uses blur effects and vibrant gradients to create a futuristic feel.
*   **Persistent Search History**: The app remembers your recently searched cities, allowing for quick transitions between locations without re-typing.
*   **Detailed Metrics**: Beyond the temperature, SkyCast provides critical data points including humidity, wind speed, atmospheric pressure, and "feels like" conditions.
*   **Smooth Transitions**: Integrated animations provide a fluid experience as you navigate between search results and detailed weather reports.

## Technical Foundation

The application is engineered for reliability and speed, utilizing a clean service-oriented architecture.

*   **Flutter & Dart**: Utilized for a responsive, native-quality interface on both Android and iOS.
*   **OpenWeatherMap API**: The primary data source for reliable, global weather information.
*   **Persistence**: Uses local storage to maintain user preferences and search history across sessions.
*   **Internationalization**: Integrated date and time formatting for a localized experience.

## Getting Started

To explore SkyCast on your local development environment:

1.  **Repository Setup**: Clone or download the source code to your machine.
2.  **Dependencies**: Run `flutter pub get` in your terminal to fetch the necessary packages.
3.  **API Configuration**:
    *   Obtain a free API key from [OpenWeatherMap](https://openweathermap.org/api).
    *   Insert your key into the `WeatherService` file located at `lib/app/data/service/weather_service.dart`.
4.  **Launch**: Execute `flutter run` on your preferred emulator or physical device.

## Design Philosophy

SkyCast was built with the belief that utility apps shouldn't be boring. By combining functional data with rich aesthetics, the application transforms a routine check of the weather into a visually engaging experience. It prioritizes clarity, performance, and a "human-first" approach to information delivery.
