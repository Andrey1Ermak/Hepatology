import Foundation

extension String {
    /// Parses user-typed decimal input regardless of the device's decimal
    /// separator. `.decimalPad` shows the separator for the device's current
    /// locale (e.g. "," on a Russian- or German-locale iPhone), but
    /// `Double.init?(String)` only ever accepts ".", so a locale-typed value
    /// like "12,5" silently failed to parse and every numeric_calc looked broken on those devices even though the
    /// keyboard accepted the input. Normalizing "," to "." here fixes every
    /// call site at the source instead of duplicating the fix in each view.
    var parsedDouble: Double? {
        Double(replacingOccurrences(of: ",", with: "."))
    }
}
