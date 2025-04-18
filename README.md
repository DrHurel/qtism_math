# QTism Math

![QT Robot](https://qtrobot.com/wp-content/uploads/2019/03/QTrobot-for-autism-social-skills-emotional.png)

QTism Math is an interactive mathematical learning application designed to help children practice and improve their math skills through an engaging robot interface. The application uses voice recognition and AI to provide a personalized learning experience.

**Try it now: [https://qtism-math.web.app/](https://qtism-math.web.app/)**

## Features

- **Interactive Voice Interface**: Speak to the robot to answer questions or request new problems
- **Multiple Problem Types**: Practice with calculation problems and true/false questions
- **Emotional Feedback**: The robot provides encouragement and feedback with different emotional expressions
- **Adaptive Explanations**: When you get stuck, ask for explanations tailored to your level of understanding
- **Child-Friendly Design**: Simple interface with clear visuals and supportive feedback

## How to Use

1. **Start the App**: Open the app in your browser at [https://qtism-math.web.app/](https://qtism-math.web.app/) (Chrome browser recommended for the best experience)
2. **Request a Problem**: Say "Pose-moi un problème de calcul" or "Donne-moi une question vrai ou faux"
3. **Answer the Question**: Speak your answer clearly into the microphone
4. **Get Feedback**: The robot will tell you if you're correct and show an emotional response
5. **Need Help?**: If you're stuck, ask "Explique-moi" or "Comment résoudre ce problème?"

## Technical Details

- Built with Flutter for cross-platform compatibility
- Firebase backend for data storage and authentication
- Voice recognition and natural language processing
- AI-powered response interpretation and feedback generation

## Development Setup

1. Clone the repository
```bash
git clone https://github.com/your-username/qtism_math.git
cd qtism_math
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Create a Firebase project
   - Add your Firebase configuration to `firebase_options.dart`

4. Run the application
```bash
flutter run
```

## Project Structure

- `lib/`: Contains the source code
  - `controllers/`: Application controllers
  - `pages/`: UI pages
  - `services/`: Service classes for AI, problem generation, etc.
  - `widgets/`: Reusable UI components

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- QT Robot platform
- Flutter and Firebase teams
- All contributors to the project
