import Foundation

struct BurnRate {
    let costPerMinute: Double
    let projectedTotalCost: Double
    let currentCost: Double
    let costLimit: Double
    let willExceedLimit: Bool
    let estimatedMinutesToLimit: Double?

    var usagePercent: Double {
        guard costLimit > 0 else { return 0 }
        return min(currentCost / costLimit * 100, 100)
    }

    var projectedPercent: Double {
        guard costLimit > 0 else { return 0 }
        return projectedTotalCost / costLimit * 100
    }

    var remainingCost: Double {
        max(0, costLimit - currentCost)
    }

    static let zero = BurnRate(
        costPerMinute: 0,
        projectedTotalCost: 0,
        currentCost: 0,
        costLimit: 35.0,
        willExceedLimit: false,
        estimatedMinutesToLimit: nil
    )
}
