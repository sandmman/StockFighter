
import Foundation

struct Utilities {

    static let fileName = "sandbox/StockFighter/Sources/storage.txt"

    static func write(level: String, id: String) throws {
        let text = "\(id) \(level)"
        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.documentDirectory, NSSearchPathDomainMask.allDomainsMask, true).first {

            let path = NSURL(fileURLWithPath: dir).appendingPathComponent(fileName)

            do {
                try text.write(to: path, atomically: false, encoding: NSUTF8StringEncoding)
            } catch {/* error handling here */
                throw StockFighterErrors.GameNotInitialized
            }
        }
    }

    static func read() -> [String]? {
        var ret: [String]? = nil

        if let dir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.documentDirectory, NSSearchPathDomainMask.allDomainsMask, true).first {

            let path = NSURL(fileURLWithPath: dir).appendingPathComponent(fileName)

            do {
                let str = try String(NSString(contentsOf: path, encoding: NSUTF8StringEncoding))
                ret = str.characters.split(separator: " ").map { String($0) }
            }
            catch {/* error handling here */}
        }

        return ret
    }
}
