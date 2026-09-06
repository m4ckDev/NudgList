import Foundation

extension Date {
    var nudgeDisplayText: String {
        formatted(date: .abbreviated, time: .shortened)
    }
}
