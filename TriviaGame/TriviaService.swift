import Foundation
internal import UIKit

enum TriviaError: Error {
    case invalidURL
    case invalidResponse
    case apiError
}

struct TriviaService {

    static func fetchQuestions(
        configuration: TriviaConfiguration
    ) async throws -> [TriviaQuestion] {

        var components = URLComponents(
            string: "https://opentdb.com/api.php"
        )

        var queryItems = [
            URLQueryItem(
                name: "amount",
                value: String(configuration.numberOfQuestions)
            )
        ]

        if let category = configuration.category.apiID {
            queryItems.append(
                URLQueryItem(
                    name: "category",
                    value: String(category)
                )
            )
        }

        if let difficulty = configuration.difficulty.apiValue {
            queryItems.append(
                URLQueryItem(
                    name: "difficulty",
                    value: difficulty
                )
            )
        }

        if let type = configuration.type.apiValue {
            queryItems.append(
                URLQueryItem(
                    name: "type",
                    value: type
                )
            )
        }

        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw TriviaError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TriviaError.invalidResponse
        }

        let triviaResponse = try JSONDecoder().decode(
            TriviaResponse.self,
            from: data
        )

        guard triviaResponse.responseCode == 0 else {
            throw TriviaError.apiError
        }

        return triviaResponse.results.map { apiQuestion in

            let correctAnswer = apiQuestion.correctAnswer.decodedHTML

            let allAnswers =
                (apiQuestion.incorrectAnswers +
                 [apiQuestion.correctAnswer])
                .map { $0.decodedHTML }
                .shuffled()

            return TriviaQuestion(
                question: apiQuestion.question.decodedHTML,
                correctAnswer: correctAnswer,
                answers: allAnswers,
                category: apiQuestion.category.decodedHTML,
                difficulty: apiQuestion.difficulty.capitalized
            )
        }
    }
}
extension String {

    var decodedHTML: String {

        guard let data = self.data(using: .utf8) else {
            return self
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        return (try? NSAttributedString(
            data: data,
            options: options,
            documentAttributes: nil
        ).string) ?? self
    }
}
