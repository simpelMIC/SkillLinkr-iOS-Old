# Skilllinkr-iOS

Skilllinkr-iOS is a SwiftUI-based iOS application that allows users to manage their profiles and connect with others based on shared skills and interests. It integrates with a backend API for user authentication, registration, and profile management.

## Features

- **User Authentication**: Login and registration functionalities using JWT token authentication.
- **Profile Management**: Update user profile information including first name, last name, and email.
- **Connection**: Ability to connect with other users based on shared skills and interests.
- **Error Handling**: Comprehensive error handling for API requests and responses.

## Installation

To run Skilllinkr-iOS locally, follow these steps:

1. Clone the repository:
   ```bash
   git clone https://github.com/simpelMIC/Skilllinkr-iOS.git
   ```

2. Open the project in Xcode.

3. Update `AppSettings` in `HTTPModule.swift` with your API endpoint and initial user token.

4. Build and run the project on a simulator or device.

## Usage

1. **Login/Register**: Use the provided UI to login or register with your credentials.
   
2. **Profile Management**: Update your profile information by entering new details in the respective fields and clicking "Update User".

3. **Connection**: Explore other users and connect with them based on shared skills and interests.

## Dependencies

- Swift 5
- SwiftUI
- Combine
- Codable for JSON serialization/deserialization

## Contact

For questions or support, please contact simpelMIC at apps@micstudios.de or visit the [GitHub repository](https://github.com/simpelMIC/Skilllinkr-iOS) to submit issues or feature requests.
