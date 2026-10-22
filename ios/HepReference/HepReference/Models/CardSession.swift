import Observation

/// What the fellow has chosen on the card now on screen — owned by
/// `CardDetailView`, so it lasts while the card is open (and while a linked
/// card is pushed on top) and resets when the card is left. Holds no
/// patient data: only which branch of the card is showing.
@Observable
final class CardSession {
    /// The age chip picked in the card's `age_switch`; nil until one is tapped.
    var age: AgeBand?
}
