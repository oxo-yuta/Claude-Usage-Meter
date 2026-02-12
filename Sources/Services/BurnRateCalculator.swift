import Foundation

enum BurnRateCalculator {
    static func calculate(block: SessionBlock, costLimit: Double) -> BurnRate {
        let currentCost = block.totalCost
        let elapsed = block.elapsedMinutes
        let remaining = block.remainingMinutes

        let costPerMinute = elapsed > 0 ? currentCost / elapsed : 0
        let projectedAdditional = costPerMinute * remaining
        let projectedTotal = currentCost + projectedAdditional
        let willExceed = projectedTotal > costLimit

        var estimatedMinutesToLimit: Double? = nil
        if costPerMinute > 0 && currentCost < costLimit {
            estimatedMinutesToLimit = (costLimit - currentCost) / costPerMinute
        }

        return BurnRate(
            costPerMinute: costPerMinute,
            projectedTotalCost: projectedTotal,
            currentCost: currentCost,
            costLimit: costLimit,
            willExceedLimit: willExceed,
            estimatedMinutesToLimit: estimatedMinutesToLimit
        )
    }
}
