//
//  ContentView.swift
//  TriviaGame
//
//  Created by user296006 on 10/18/26.
//

import SwiftUI

struct ContentView: View {

    @State private var numberOfQuestions = 10

    @State private var selectedCategory:
        TriviaCategory = .any

    @State private var selectedDifficulty:
        TriviaDifficulty = .any

    @State private var selectedType:
        TriviaType = .any

    var body: some View {

        NavigationStack {

            Form {

                Section("Number of Questions") {

                    Stepper(
                        "\(numberOfQuestions) Questions",
                        value: $numberOfQuestions,
                        in: 5...20
                    )
                }

                Section("Category") {

                    Picker(
                        "Category",
                        selection: $selectedCategory
                    ) {

                        ForEach(TriviaCategory.allCases) { category in
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                }

                Section("Difficulty") {

                    Picker(
                        "Difficulty",
                        selection: $selectedDifficulty
                    ) {

                        ForEach(TriviaDifficulty.allCases) { difficulty in
                            Text(difficulty.rawValue)
                                .tag(difficulty)
                        }
                    }
                }

                Section("Question Type") {

                    Picker(
                        "Type",
                        selection: $selectedType
                    ) {

                        ForEach(TriviaType.allCases) { type in
                            Text(type.rawValue)
                                .tag(type)
                        }
                    }
                }

                Section {

                    NavigationLink {

                        GameView(
                            configuration: TriviaConfiguration(
                                numberOfQuestions: numberOfQuestions,
                                category: selectedCategory,
                                difficulty: selectedDifficulty,
                                type: selectedType
                            )
                        )

                    } label: {

                        HStack {

                            Spacer()

                            Text("Start Trivia")
                                .fontWeight(.bold)

                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Trivia Challenge")
        }
    }
}

#Preview {
    ContentView()
}
