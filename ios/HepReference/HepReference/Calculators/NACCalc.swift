import Foundation

struct NACResult {
    let loadMg: Int
    let loadCapped: Bool
    let maintMg: Int
    let maintCapped: Bool
    let rateMgPerHour: Int
    let rateCapped: Bool
    let totalMg: Int
    let loadML: Double
    let maintML: Double
}

/// Standard 21-h IV NAC (Acetadote) three-bag regimen.
enum NACCalc {
    /// Acetadote 200 mg/mL (20%) — product concentration, not part of the dosing table.
    private static let concentrationMgPerML: Double = 200

    static func compute(weightKg: Double) -> NACResult? {
        guard weightKg > 0 else { return nil }
        let loadWeight = min(weightKg, 100)
        let maintWeight = min(weightKg, 50)
        let load = (loadWeight * 150).rounded()
        let maint = (maintWeight * 300).rounded()
        let rate = (maint / 20).rounded()
        return NACResult(
            loadMg: Int(load),
            loadCapped: weightKg > 100,
            maintMg: Int(maint),
            maintCapped: weightKg > 50,
            rateMgPerHour: Int(rate),
            rateCapped: rate >= 750,
            totalMg: Int(load + maint),
            loadML: (load / concentrationMgPerML * 10).rounded() / 10,
            maintML: (maint / concentrationMgPerML * 10).rounded() / 10
        )
    }
}
