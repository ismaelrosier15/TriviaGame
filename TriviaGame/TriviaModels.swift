//
//  TriviaModels.swift
//  TriviaGame
//
//  Created by user296006 on 10/18/26.
//


import Foundation

struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [APITriviaQuestion]

    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

struct APITriviaQuestion: Codable {
    let type: String
    let difficulty: String
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case type
        case difficulty
        case category
        case question
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

struct TriviaQuestion: Identifiable {
    let id = UUID()
    let question: String
    let correctAnswer: String
    let answers: [String]
    let category: String
    let difficulty: String
}


enum TriviaCategory: String, CaseIterable, Identifiable {
    case any = "Any Category"
    case general = "General Knowledge"
    case books = "Books"
    case film = "Film"
    case music = "Music"
    case science = "Science & Nature"
    case computers = "Computers"
    case sports = "Sports"
    case geography = "Geography"
    case history = "History"

    var id: String { rawValue }

    var apiID: Int? {
        switch self {
        case .any:
            return nil
        case .general:
            return 9
        case .books:
            return 10
        case .film:
            return 11
        case .music:
            return 12
        case .science:
            return 17
        case .computers:
            return 18
        case .sports:
            return 21
        case .geography:
            return 22
        case .history:
            return 23
        }
    }
}

enum TriviaDifficulty: String, CaseIterable, Identifiable {
    case any = "Any Difficulty"
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var id: String { rawValue }

    var apiValue: String? {
        switch self {
        case .any:
            return nil
        default:
            return rawValue.lowercased()
        }
    }
}

enum TriviaType: String, CaseIterable, Identifiable {
    case any = "Any Type"
    case multiple = "Multiple Choice"
    case trueFalse = "True / False"

    var id: String { rawValue }

    var apiValue: String? {
        switch self {
        case .any:
            return nil
        case .multiple:
            return "multiple"
        case .trueFalse:
            return "boolean"
        }
    }
}

struct TriviaConfiguration {
    let numberOfQuestions: Int
    let category: TriviaCategory
    let difficulty: TriviaDifficulty
    let type: TriviaType
}
