import Foundation

/// Renders card text: `[m]864-9439[/m]` becomes a tappable `tel:` link,
/// `**bold**` becomes bold. `[m]...[/m]` isn't real Markdown, so it's rewritten
/// into standard Markdown link syntax first and Foundation's Markdown parser
/// handles both concerns in one pass.
enum CardMarkup {
    private static let phoneTag = /\[m\](?<display>[^\[]*)\[\/m\]/

    static func attributedString(_ raw: String) -> AttributedString {
        let rewritten = raw.replacing(phoneTag) { match in
            let display = String(match.output.display)
            let dialable = display.filter { $0.isNumber || $0 == "+" || $0 == "#" }
            return "[\(display)](tel:\(dialable))"
        }

        var options = AttributedString.MarkdownParsingOptions()
        options.interpretedSyntax = .inlineOnlyPreservingWhitespace
        if let parsed = try? AttributedString(markdown: rewritten, options: options) {
            return parsed
        }
        return AttributedString(raw)
    }

    /// Strips markdown/tel-link syntax down to readable text, for VoiceOver
    /// accessibility labels (which shouldn't speak "asterisk asterisk").
    static func plainText(_ raw: String) -> String {
        String(attributedString(raw).characters)
    }
}
