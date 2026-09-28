# ✍️ Writing Learner

> *An AI tutor for Japanese → English translation, tuned for university entrance exams.*

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![Gemini](https://img.shields.io/badge/Google-Gemini%201.5%20Flash-4285F4?logo=google&logoColor=white)
![Riverpod](https://img.shields.io/badge/state-Riverpod-00B0FF)


## 🌟 Highlights

- 🤖 **Endless practice questions** — Gemini writes new, exam-level Japanese sentences (think the University of Tokyo's 和文英訳) every time
- 📝 **Instant, explained feedback** — your English is corrected phrase by phrase, and each change comes with a short reason in Japanese
- 🧩 **Fill-in-the-blank drills** — key expressions are blanked out so you can focus on the phrases that matter
- 📚 **Built-in study sets** — Japanese proverbs (ことわざ) and key English sentence patterns (構文)


## ℹ️ Overview

Translating Japanese into natural English is one of the hardest parts of Japanese university entrance exams, and it's also the part where students most need someone to check their work. Writing Learner uses Google's Gemini model to act as that checker.

The app generates a Japanese sentence and you translate it. It then compares your answer with a model translation, highlights what it would change and explains why. You can then revise your answer and try again. The fill-in-the-blank modes turn the same idea into shorter drills built around specific idioms, proverbs and grammar patterns.


### ✍️ Author

Built by [Yuki Ishihara](https://github.com/pe-tanman). More projects on my [portfolio](https://portfolio-pe-tanmans-projects.vercel.app).


## 🚀 Usage

| Mode | What happens |
| --- | --- |
| **AI東大英訳** (AI translation) | Translate an AI-generated, exam-level sentence and get corrections with reasons |
| **AI東大穴埋め** (AI fill-in) | Fill in the key expressions missing from an English translation |
| **ことわざ** (proverbs) | Practice translating well-known Japanese proverbs |
| **構文** (sentence patterns) | AI-generated fill-in drills built around essential English sentence structures |


## ⬇️ Installation

Requirements: [Flutter](https://docs.flutter.dev/get-started/install) 3.22+ (Dart ≥ 3.4) and a free [Gemini API key](https://aistudio.google.com/app/apikey).

```bash
git clone https://github.com/pe-tanman/writing_learner.git
cd writing_learner
flutter pub get
```

Create a `.env` file in the project root:

```bash
GEMINI_API_KEY=your_key_here
```

Then run:

```bash
flutter run
```

> [!WARNING]
> Never commit your `.env` file. Make sure `.env` is listed in `.gitignore`.
