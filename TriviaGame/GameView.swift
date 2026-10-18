//
//  GameView.swift
//  TriviaGame
//
//  Created by user296006 on 10/18/26.
//

import SwiftUI

struct GameView: View {

    let configuration: TriviaConfiguration

    @State private var questions: [TriviaQuestion] = []

    @State private var selectedAnswers:
        [UUID: String] = [:]

    @State private var isLoading = true

    @State private var errorMessage: String?

    @State private var score = 0

    @State private var showScore = false

    @State private var submitted = false

    var body: some View {

        Group {

            if isLoading {

                ProgressView("Loading Trivia...")

            } else if let errorMessage {

                VStack(spacing: 20) {

                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)

                    Text("Unable to Load Trivia")
                        .font(.headline)

                    Text(errorMessage)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        Task {
                            await loadQuestions()
                        }
                    }
                }
                .padding()

            } else {

                List {

                    ForEach(
                        Array(questions.enumerated()),
                        id: \.element.id
                    ) { index, question in

                        Section {

                            Text(question.question)
                                .font(.headline)
                                .padding(.vertical, 5)

                            Text(
                                "\(question.category) • \(question.difficulty)"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            ForEach(
                                question.answers,
                                id: \.self
                            ) { answer in

                                answerButton(
                                    answer,
                                    question: question
                                )
                            }

                            if submitted &&
                                selectedAnswers[question.id]
                                    != question.correctAnswer {

                                Text(
                                    "Correct answer: \(question.correctAnswer)"
                                )
                                .font(.caption)
                                .foregroundStyle(.green)
                            }

                        } header: {

                            Text(
                                "Question \(index + 1)"
                            )
                        }
                    }

                    Section {

                        Button {

                            calculateScore { finalScore in

                                score = finalScore
                                submitted = true
                                showScore = true
                            }

                        } label: {

                            HStack {

                                Spacer()

                                Text("Submit Answers")
                                    .fontWeight(.bold)

                                Spacer()
                            }
                        }
                        .disabled(
                            selectedAnswers.count
                            != questions.count ||
                            submitted
                        )
                    }
                }
            }
        }
        .navigationTitle("Trivia")
        .navigationBarTitleDisplayMode(.inline)

        .task {
            await loadQuestions()
        }

        .alert(
            "Trivia Complete!",
            isPresented: $showScore
        ) {

            Button("OK") { }

        } message: {

            Text(
                "You scored \(score) out of \(questions.count)!"
            )
        }
    }

    @ViewBuilder
    private func answerButton(
        _ answer: String,
        question: TriviaQuestion
    ) -> some View {

        Button {

            if !submitted {
                selectedAnswers[question.id] = answer
            }

        } label: {

            HStack {

                Image(
                    systemName:
                        selectedAnswers[question.id] == answer
                        ? "checkmark.circle.fill"
                        : "circle"
                )

                Text(answer)

                Spacer()
            }
            .foregroundStyle(
                answerColor(
                    answer,
                    question: question
                )
            )
        }
        .disabled(submitted)
    }

    private func answerColor(
        _ answer: String,
        question: TriviaQuestion
    ) -> Color {

        if submitted {

            if answer == question.correctAnswer {
                return .green
            }

            if selectedAnswers[question.id] == answer {
                return .red
            }
        }

        if selectedAnswers[question.id] == answer {
            return .blue
        }

        return .primary
    }

    private func calculateScore(
        completion: (Int) -> Void
    ) {

        var finalScore = 0

        for question in questions {

            if selectedAnswers[question.id]
                == question.correctAnswer {

                finalScore += 1
            }
        }

        completion(finalScore)
    }

    @MainActor
    private func loadQuestions() async {

        isLoading = true
        errorMessage = nil
        submitted = false
        selectedAnswers.removeAll()

        do {

            questions = try await TriviaService.fetchQuestions(
                configuration: configuration
            )

        } catch {

            errorMessage =
                "Please check your internet connection and try again."
        }

        isLoading = false
    }
}
