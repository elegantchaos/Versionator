import Foundation

extension String {
  /// Initialise a string from an async sequence of UInt8.
  /// Consumes the entire sequence.
  public init<T: AsyncSequence>(_ sequence: T, encoding: String.Encoding = .utf8) async where T.Element == UInt8 {
    var buffer: [UInt8] = []
    do {
      for try await byte in sequence {
        buffer.append(byte)
      }
    } catch {

    }

    self = String(bytes: buffer, encoding: encoding) ?? ""
  }
}
