import Foundation

enum NudgeOrdering {
    static func active(_ nudges: [Nudge]) -> [Nudge] {
        nudges
            .filter { !$0.isCompleted }
            .sorted { lhs, rhs in
                switch (lhs.dueDate, rhs.dueDate) {
                case let (left?, right?):
                    if left != right { return left < right }
                    return lhs.createdAt < rhs.createdAt
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                case (nil, nil):
                    return lhs.createdAt < rhs.createdAt
                }
            }
    }

    static func completed(_ nudges: [Nudge]) -> [Nudge] {
        nudges
            .filter(\.isCompleted)
            .sorted { lhs, rhs in
                let left = lhs.completedAt ?? lhs.createdAt
                let right = rhs.completedAt ?? rhs.createdAt
                return left > right
            }
    }
}
