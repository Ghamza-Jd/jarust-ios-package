// This file was autogenerated by some hot garbage in the `uniffi` crate.
// Trust me, you don't want to mess with it!
import Foundation

// Depending on the consumer's build setup, the low-level FFI code
// might be in a separate module, or it might be compiled inline into
// this module. This is a bit of light hackery to work with both.
#if canImport(JarustNative)
import JarustNative
#endif

fileprivate extension RustBuffer {
    // Allocate a new buffer, copying the contents of a `UInt8` array.
    init(bytes: [UInt8]) {
        let rbuf = bytes.withUnsafeBufferPointer { ptr in
            RustBuffer.from(ptr)
        }
        self.init(capacity: rbuf.capacity, len: rbuf.len, data: rbuf.data)
    }

    static func from(_ ptr: UnsafeBufferPointer<UInt8>) -> RustBuffer {
        try! rustCall { ffi_jarust_1043_rustbuffer_from_bytes(ForeignBytes(bufferPointer: ptr), $0) }
    }

    // Frees the buffer in place.
    // The buffer must not be used after this is called.
    func deallocate() {
        try! rustCall { ffi_jarust_1043_rustbuffer_free(self, $0) }
    }
}

fileprivate extension ForeignBytes {
    init(bufferPointer: UnsafeBufferPointer<UInt8>) {
        self.init(len: Int32(bufferPointer.count), data: bufferPointer.baseAddress)
    }
}

// For every type used in the interface, we provide helper methods for conveniently
// lifting and lowering that type from C-compatible data, and for reading and writing
// values of that type in a buffer.

// Helper classes/extensions that don't change.
// Someday, this will be in a library of its own.

fileprivate extension Data {
    init(rustBuffer: RustBuffer) {
        // TODO: This copies the buffer. Can we read directly from a
        // Rust buffer?
        self.init(bytes: rustBuffer.data!, count: Int(rustBuffer.len))
    }
}

// Define reader functionality.  Normally this would be defined in a class or
// struct, but we use standalone functions instead in order to make external
// types work.
//
// With external types, one swift source file needs to be able to call the read
// method on another source file's FfiConverter, but then what visibility
// should Reader have?
// - If Reader is fileprivate, then this means the read() must also
//   be fileprivate, which doesn't work with external types.
// - If Reader is internal/public, we'll get compile errors since both source
//   files will try define the same type.
//
// Instead, the read() method and these helper functions input a tuple of data

fileprivate func createReader(data: Data) -> (data: Data, offset: Data.Index) {
    (data: data, offset: 0)
}

// Reads an integer at the current offset, in big-endian order, and advances
// the offset on success. Throws if reading the integer would move the
// offset past the end of the buffer.
fileprivate func readInt<T: FixedWidthInteger>(_ reader: inout (data: Data, offset: Data.Index)) throws -> T {
    let range = reader.offset..<reader.offset + MemoryLayout<T>.size
    guard reader.data.count >= range.upperBound else {
        throw UniffiInternalError.bufferOverflow
    }
    if T.self == UInt8.self {
        let value = reader.data[reader.offset]
        reader.offset += 1
        return value as! T
    }
    var value: T = 0
    let _ = withUnsafeMutableBytes(of: &value, { reader.data.copyBytes(to: $0, from: range)})
    reader.offset = range.upperBound
    return value.bigEndian
}

// Reads an arbitrary number of bytes, to be used to read
// raw bytes, this is useful when lifting strings
fileprivate func readBytes(_ reader: inout (data: Data, offset: Data.Index), count: Int) throws -> Array<UInt8> {
    let range = reader.offset..<(reader.offset+count)
    guard reader.data.count >= range.upperBound else {
        throw UniffiInternalError.bufferOverflow
    }
    var value = [UInt8](repeating: 0, count: count)
    value.withUnsafeMutableBufferPointer({ buffer in
        reader.data.copyBytes(to: buffer, from: range)
    })
    reader.offset = range.upperBound
    return value
}

// Reads a float at the current offset.
fileprivate func readFloat(_ reader: inout (data: Data, offset: Data.Index)) throws -> Float {
    return Float(bitPattern: try readInt(&reader))
}

// Reads a float at the current offset.
fileprivate func readDouble(_ reader: inout (data: Data, offset: Data.Index)) throws -> Double {
    return Double(bitPattern: try readInt(&reader))
}

// Indicates if the offset has reached the end of the buffer.
fileprivate func hasRemaining(_ reader: (data: Data, offset: Data.Index)) -> Bool {
    return reader.offset < reader.data.count
}

// Define writer functionality.  Normally this would be defined in a class or
// struct, but we use standalone functions instead in order to make external
// types work.  See the above discussion on Readers for details.

fileprivate func createWriter() -> [UInt8] {
    return []
}

fileprivate func writeBytes<S>(_ writer: inout [UInt8], _ byteArr: S) where S: Sequence, S.Element == UInt8 {
    writer.append(contentsOf: byteArr)
}

// Writes an integer in big-endian order.
//
// Warning: make sure what you are trying to write
// is in the correct type!
fileprivate func writeInt<T: FixedWidthInteger>(_ writer: inout [UInt8], _ value: T) {
    var value = value.bigEndian
    withUnsafeBytes(of: &value) { writer.append(contentsOf: $0) }
}

fileprivate func writeFloat(_ writer: inout [UInt8], _ value: Float) {
    writeInt(&writer, value.bitPattern)
}

fileprivate func writeDouble(_ writer: inout [UInt8], _ value: Double) {
    writeInt(&writer, value.bitPattern)
}

// Protocol for types that transfer other types across the FFI. This is
// analogous go the Rust trait of the same name.
fileprivate protocol FfiConverter {
    associatedtype FfiType
    associatedtype SwiftType

    static func lift(_ value: FfiType) throws -> SwiftType
    static func lower(_ value: SwiftType) -> FfiType
    static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> SwiftType
    static func write(_ value: SwiftType, into buf: inout [UInt8])
}

// Types conforming to `Primitive` pass themselves directly over the FFI.
fileprivate protocol FfiConverterPrimitive: FfiConverter where FfiType == SwiftType { }

extension FfiConverterPrimitive {
    public static func lift(_ value: FfiType) throws -> SwiftType {
        return value
    }

    public static func lower(_ value: SwiftType) -> FfiType {
        return value
    }
}

// Types conforming to `FfiConverterRustBuffer` lift and lower into a `RustBuffer`.
// Used for complex types where it's hard to write a custom lift/lower.
fileprivate protocol FfiConverterRustBuffer: FfiConverter where FfiType == RustBuffer {}

extension FfiConverterRustBuffer {
    public static func lift(_ buf: RustBuffer) throws -> SwiftType {
        var reader = createReader(data: Data(rustBuffer: buf))
        let value = try read(from: &reader)
        if hasRemaining(reader) {
            throw UniffiInternalError.incompleteData
        }
        buf.deallocate()
        return value
    }

    public static func lower(_ value: SwiftType) -> RustBuffer {
        var writer = createWriter()
        write(value, into: &writer)
        return RustBuffer(bytes: writer)
    }
}
// An error type for FFI errors. These errors occur at the UniFFI level, not
// the library level.
fileprivate enum UniffiInternalError: LocalizedError {
    case bufferOverflow
    case incompleteData
    case unexpectedOptionalTag
    case unexpectedEnumCase
    case unexpectedNullPointer
    case unexpectedRustCallStatusCode
    case unexpectedRustCallError
    case unexpectedStaleHandle
    case rustPanic(_ message: String)

    public var errorDescription: String? {
        switch self {
        case .bufferOverflow: return "Reading the requested value would read past the end of the buffer"
        case .incompleteData: return "The buffer still has data after lifting its containing value"
        case .unexpectedOptionalTag: return "Unexpected optional tag; should be 0 or 1"
        case .unexpectedEnumCase: return "Raw enum value doesn't match any cases"
        case .unexpectedNullPointer: return "Raw pointer value was null"
        case .unexpectedRustCallStatusCode: return "Unexpected RustCallStatus code"
        case .unexpectedRustCallError: return "CALL_ERROR but no errorClass specified"
        case .unexpectedStaleHandle: return "The object in the handle map has been dropped already"
        case let .rustPanic(message): return message
        }
    }
}

fileprivate let CALL_SUCCESS: Int8 = 0
fileprivate let CALL_ERROR: Int8 = 1
fileprivate let CALL_PANIC: Int8 = 2

fileprivate extension RustCallStatus {
    init() {
        self.init(
            code: CALL_SUCCESS,
            errorBuf: RustBuffer.init(
                capacity: 0,
                len: 0,
                data: nil
            )
        )
    }
}

private func rustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T {
    try makeRustCall(callback, errorHandler: {
        $0.deallocate()
        return UniffiInternalError.unexpectedRustCallError
    })
}

private func rustCallWithError<T, F: FfiConverter>
(_ errorFfiConverter: F.Type, _ callback: (UnsafeMutablePointer<RustCallStatus>) -> T) throws -> T
where F.SwiftType: Error, F.FfiType == RustBuffer
{
    try makeRustCall(callback, errorHandler: { return try errorFfiConverter.lift($0) })
}

private func makeRustCall<T>(_ callback: (UnsafeMutablePointer<RustCallStatus>) -> T, errorHandler: (RustBuffer) throws -> Error) throws -> T {
    var callStatus = RustCallStatus.init()
    let returnedVal = callback(&callStatus)
    switch callStatus.code {
    case CALL_SUCCESS:
        return returnedVal

    case CALL_ERROR:
        throw try errorHandler(callStatus.errorBuf)

    case CALL_PANIC:
        // When the rust code sees a panic, it tries to construct a RustBuffer
        // with the message.  But if that code panics, then it just sends back
        // an empty buffer.
        if callStatus.errorBuf.len > 0 {
            throw UniffiInternalError.rustPanic(try FfiConverterString.lift(callStatus.errorBuf))
        } else {
            callStatus.errorBuf.deallocate()
            throw UniffiInternalError.rustPanic("Rust panic")
        }

    default:
        throw UniffiInternalError.unexpectedRustCallStatusCode
    }
}

// Public interface members begin here.


fileprivate struct FfiConverterUInt32: FfiConverterPrimitive {
    typealias FfiType = UInt32
    typealias SwiftType = UInt32

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> UInt32 {
        return try lift(readInt(&buf))
    }

    public static func write(_ value: SwiftType, into buf: inout [UInt8]) {
        writeInt(&buf, lower(value))
    }
}

fileprivate struct FfiConverterString: FfiConverter {
    typealias SwiftType = String
    typealias FfiType = RustBuffer

    public static func lift(_ value: RustBuffer) throws -> String {
        defer {
            value.deallocate()
        }
        if value.data == nil {
            return String()
        }
        let bytes = UnsafeBufferPointer<UInt8>(start: value.data!, count: Int(value.len))
        return String(bytes: bytes, encoding: String.Encoding.utf8)!
    }

    public static func lower(_ value: String) -> RustBuffer {
        return value.utf8CString.withUnsafeBufferPointer { ptr in
            // The swift string gives us int8_t, we want uint8_t.
            ptr.withMemoryRebound(to: UInt8.self) { ptr in
                // The swift string gives us a trailing null byte, we don't want it.
                let buf = UnsafeBufferPointer(rebasing: ptr.prefix(upTo: ptr.count - 1))
                return RustBuffer.from(buf)
            }
        }
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> String {
        let len: Int32 = try readInt(&buf)
        return String(bytes: try readBytes(&buf, count: Int(len)), encoding: String.Encoding.utf8)!
    }

    public static func write(_ value: String, into buf: inout [UInt8]) {
        let len = Int32(value.utf8.count)
        writeInt(&buf, len)
        writeBytes(&buf, value.utf8)
    }
}


public protocol RawJaConnectionProtocol {
    func `create`(`kaInterval`: UInt32, `cb`: RawJaConnectionCallback)

}

public class RawJaConnection: RawJaConnectionProtocol {
    fileprivate let pointer: UnsafeMutableRawPointer

    // TODO: We'd like this to be `private` but for Swifty reasons,
    // we can't implement `FfiConverter` without making this `required` and we can't
    // make it `required` without making it `public`.
    required init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }

    deinit {
        try! rustCall { ffi_jarust_1043_RawJaConnection_object_free(pointer, $0) }
    }




    public func `create`(`kaInterval`: UInt32, `cb`: RawJaConnectionCallback)  {
        try!
        rustCall() {

            jarust_1043_RawJaConnection_create(self.pointer,
                                               FfiConverterUInt32.lower(`kaInterval`),
                                               FfiConverterCallbackInterfaceRawJaConnectionCallback.lower(`cb`), $0
            )
        }
    }

}


public struct FfiConverterTypeRawJaConnection: FfiConverter {
    typealias FfiType = UnsafeMutableRawPointer
    typealias SwiftType = RawJaConnection

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> RawJaConnection {
        let v: UInt64 = try readInt(&buf)
        // The Rust code won't compile if a pointer won't fit in a UInt64.
        // We have to go via `UInt` because that's the thing that's the size of a pointer.
        let ptr = UnsafeMutableRawPointer(bitPattern: UInt(truncatingIfNeeded: v))
        if (ptr == nil) {
            throw UniffiInternalError.unexpectedNullPointer
        }
        return try lift(ptr!)
    }

    public static func write(_ value: RawJaConnection, into buf: inout [UInt8]) {
        // This fiddling is because `Int` is the thing that's the same size as a pointer.
        // The Rust code won't compile if a pointer won't fit in a `UInt64`.
        writeInt(&buf, UInt64(bitPattern: Int64(Int(bitPattern: lower(value)))))
    }

    public static func lift(_ pointer: UnsafeMutableRawPointer) throws -> RawJaConnection {
        return RawJaConnection(unsafeFromRawPointer: pointer)
    }

    public static func lower(_ value: RawJaConnection) -> UnsafeMutableRawPointer {
        return value.pointer
    }
}


public protocol RawJaContextProtocol {

}

public class RawJaContext: RawJaContextProtocol {
    fileprivate let pointer: UnsafeMutableRawPointer

    // TODO: We'd like this to be `private` but for Swifty reasons,
    // we can't implement `FfiConverter` without making this `required` and we can't
    // make it `required` without making it `public`.
    required init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }
    public convenience init() throws {
        self.init(unsafeFromRawPointer: try

                  rustCallWithError(FfiConverterTypeRawJaError.self) {

            jarust_1043_RawJaContext_new($0)
        })
    }

    deinit {
        try! rustCall { ffi_jarust_1043_RawJaContext_object_free(pointer, $0) }
    }





}


public struct FfiConverterTypeRawJaContext: FfiConverter {
    typealias FfiType = UnsafeMutableRawPointer
    typealias SwiftType = RawJaContext

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> RawJaContext {
        let v: UInt64 = try readInt(&buf)
        // The Rust code won't compile if a pointer won't fit in a UInt64.
        // We have to go via `UInt` because that's the thing that's the size of a pointer.
        let ptr = UnsafeMutableRawPointer(bitPattern: UInt(truncatingIfNeeded: v))
        if (ptr == nil) {
            throw UniffiInternalError.unexpectedNullPointer
        }
        return try lift(ptr!)
    }

    public static func write(_ value: RawJaContext, into buf: inout [UInt8]) {
        // This fiddling is because `Int` is the thing that's the same size as a pointer.
        // The Rust code won't compile if a pointer won't fit in a `UInt64`.
        writeInt(&buf, UInt64(bitPattern: Int64(Int(bitPattern: lower(value)))))
    }

    public static func lift(_ pointer: UnsafeMutableRawPointer) throws -> RawJaContext {
        return RawJaContext(unsafeFromRawPointer: pointer)
    }

    public static func lower(_ value: RawJaContext) -> UnsafeMutableRawPointer {
        return value.pointer
    }
}


public protocol RawJaSessionProtocol {

}

public class RawJaSession: RawJaSessionProtocol {
    fileprivate let pointer: UnsafeMutableRawPointer

    // TODO: We'd like this to be `private` but for Swifty reasons,
    // we can't implement `FfiConverter` without making this `required` and we can't
    // make it `required` without making it `public`.
    required init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }

    deinit {
        try! rustCall { ffi_jarust_1043_RawJaSession_object_free(pointer, $0) }
    }





}


public struct FfiConverterTypeRawJaSession: FfiConverter {
    typealias FfiType = UnsafeMutableRawPointer
    typealias SwiftType = RawJaSession

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> RawJaSession {
        let v: UInt64 = try readInt(&buf)
        // The Rust code won't compile if a pointer won't fit in a UInt64.
        // We have to go via `UInt` because that's the thing that's the size of a pointer.
        let ptr = UnsafeMutableRawPointer(bitPattern: UInt(truncatingIfNeeded: v))
        if (ptr == nil) {
            throw UniffiInternalError.unexpectedNullPointer
        }
        return try lift(ptr!)
    }

    public static func write(_ value: RawJaSession, into buf: inout [UInt8]) {
        // This fiddling is because `Int` is the thing that's the same size as a pointer.
        // The Rust code won't compile if a pointer won't fit in a `UInt64`.
        writeInt(&buf, UInt64(bitPattern: Int64(Int(bitPattern: lower(value)))))
    }

    public static func lift(_ pointer: UnsafeMutableRawPointer) throws -> RawJaSession {
        return RawJaSession(unsafeFromRawPointer: pointer)
    }

    public static func lower(_ value: RawJaSession) -> UnsafeMutableRawPointer {
        return value.pointer
    }
}


public struct RawJaConfig {
    public var `uri`: String
    public var `apisecret`: String?
    public var `rootNamespace`: String?

    // Default memberwise initializers are never public by default, so we
    // declare one manually.
    public init(`uri`: String, `apisecret`: String?, `rootNamespace`: String?) {
        self.`uri` = `uri`
        self.`apisecret` = `apisecret`
        self.`rootNamespace` = `rootNamespace`
    }
}


extension RawJaConfig: Equatable, Hashable {
    public static func ==(lhs: RawJaConfig, rhs: RawJaConfig) -> Bool {
        if lhs.`uri` != rhs.`uri` {
            return false
        }
        if lhs.`apisecret` != rhs.`apisecret` {
            return false
        }
        if lhs.`rootNamespace` != rhs.`rootNamespace` {
            return false
        }
        return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(`uri`)
        hasher.combine(`apisecret`)
        hasher.combine(`rootNamespace`)
    }
}


public struct FfiConverterTypeRawJaConfig: FfiConverterRustBuffer {
    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> RawJaConfig {
        return try RawJaConfig(
            `uri`: FfiConverterString.read(from: &buf),
            `apisecret`: FfiConverterOptionString.read(from: &buf),
            `rootNamespace`: FfiConverterOptionString.read(from: &buf)
        )
    }

    public static func write(_ value: RawJaConfig, into buf: inout [UInt8]) {
        FfiConverterString.write(value.`uri`, into: &buf)
        FfiConverterOptionString.write(value.`apisecret`, into: &buf)
        FfiConverterOptionString.write(value.`rootNamespace`, into: &buf)
    }
}


public func FfiConverterTypeRawJaConfig_lift(_ buf: RustBuffer) throws -> RawJaConfig {
    return try FfiConverterTypeRawJaConfig.lift(buf)
}

public func FfiConverterTypeRawJaConfig_lower(_ value: RawJaConfig) -> RustBuffer {
    return FfiConverterTypeRawJaConfig.lower(value)
}


public enum RawJaError {



    // Simple error enums only carry a message
    case RuntimeCreationFailure(message: String)

}

public struct FfiConverterTypeRawJaError: FfiConverterRustBuffer {
    typealias SwiftType = RawJaError

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> RawJaError {
        let variant: Int32 = try readInt(&buf)
        switch variant {




        case 1: return .RuntimeCreationFailure(
            message: try FfiConverterString.read(from: &buf)
        )


        default: throw UniffiInternalError.unexpectedEnumCase
        }
    }

    public static func write(_ value: RawJaError, into buf: inout [UInt8]) {
        switch value {




        case let .RuntimeCreationFailure(message):
            writeInt(&buf, Int32(1))
            FfiConverterString.write(message, into: &buf)


        }
    }
}


extension RawJaError: Equatable, Hashable {}

extension RawJaError: Error { }

fileprivate extension NSLock {
    func withLock<T>(f: () throws -> T) rethrows -> T {
        self.lock()
        defer { self.unlock() }
        return try f()
    }
}

fileprivate typealias UniFFICallbackHandle = UInt64
fileprivate class UniFFICallbackHandleMap<T> {
    private var leftMap: [UniFFICallbackHandle: T] = [:]
    private var counter: [UniFFICallbackHandle: UInt64] = [:]
    private var rightMap: [ObjectIdentifier: UniFFICallbackHandle] = [:]

    private let lock = NSLock()
    private var currentHandle: UniFFICallbackHandle = 0
    private let stride: UniFFICallbackHandle = 1

    func insert(obj: T) -> UniFFICallbackHandle {
        lock.withLock {
            let id = ObjectIdentifier(obj as AnyObject)
            let handle = rightMap[id] ?? {
                currentHandle += stride
                let handle = currentHandle
                leftMap[handle] = obj
                rightMap[id] = handle
                return handle
            }()
            counter[handle] = (counter[handle] ?? 0) + 1
            return handle
        }
    }

    func get(handle: UniFFICallbackHandle) -> T? {
        lock.withLock {
            leftMap[handle]
        }
    }

    func delete(handle: UniFFICallbackHandle) {
        remove(handle: handle)
    }

    @discardableResult
    func remove(handle: UniFFICallbackHandle) -> T? {
        lock.withLock {
            defer { counter[handle] = (counter[handle] ?? 1) - 1 }
            guard counter[handle] == 1 else { return leftMap[handle] }
            let obj = leftMap.removeValue(forKey: handle)
            if let obj = obj {
                rightMap.removeValue(forKey: ObjectIdentifier(obj as AnyObject))
            }
            return obj
        }
    }
}

// Magic number for the Rust proxy to call using the same mechanism as every other method,
// to free the callback once it's dropped by Rust.
private let IDX_CALLBACK_FREE: Int32 = 0

// Declaration and FfiConverters for RawJaConnectionCallback Callback Interface

public protocol RawJaConnectionCallback : AnyObject {
    func `onConnectionSuccess`(`connection`: RawJaConnection)
    func `onConnectionFailure`()
    func `onSessionCreationSuccess`(`session`: RawJaSession)
    func `onSessionCreationFailure`()

}

// The ForeignCallback that is passed to Rust.
fileprivate let foreignCallbackCallbackInterfaceRawJaConnectionCallback : ForeignCallback =
{ (handle: UniFFICallbackHandle, method: Int32, args: RustBuffer, out_buf: UnsafeMutablePointer<RustBuffer>) -> Int32 in
    func `invokeOnConnectionSuccess`(_ swiftCallbackInterface: RawJaConnectionCallback, _ args: RustBuffer) throws -> RustBuffer {
        defer { args.deallocate() }

        var reader = createReader(data: Data(rustBuffer: args))
        swiftCallbackInterface.`onConnectionSuccess`(
            `connection`:  try FfiConverterTypeRawJaConnection.read(from: &reader)
        )
        return RustBuffer()
        // TODO catch errors and report them back to Rust.
        // https://github.com/mozilla/uniffi-rs/issues/351

    }
    func `invokeOnConnectionFailure`(_ swiftCallbackInterface: RawJaConnectionCallback, _ args: RustBuffer) throws -> RustBuffer {
        defer { args.deallocate() }
        swiftCallbackInterface.`onConnectionFailure`()
        return RustBuffer()
        // TODO catch errors and report them back to Rust.
        // https://github.com/mozilla/uniffi-rs/issues/351

    }
    func `invokeOnSessionCreationSuccess`(_ swiftCallbackInterface: RawJaConnectionCallback, _ args: RustBuffer) throws -> RustBuffer {
        defer { args.deallocate() }

        var reader = createReader(data: Data(rustBuffer: args))
        swiftCallbackInterface.`onSessionCreationSuccess`(
            `session`:  try FfiConverterTypeRawJaSession.read(from: &reader)
        )
        return RustBuffer()
        // TODO catch errors and report them back to Rust.
        // https://github.com/mozilla/uniffi-rs/issues/351

    }
    func `invokeOnSessionCreationFailure`(_ swiftCallbackInterface: RawJaConnectionCallback, _ args: RustBuffer) throws -> RustBuffer {
        defer { args.deallocate() }
        swiftCallbackInterface.`onSessionCreationFailure`()
        return RustBuffer()
        // TODO catch errors and report them back to Rust.
        // https://github.com/mozilla/uniffi-rs/issues/351

    }


    let cb: RawJaConnectionCallback
    do {
        cb = try FfiConverterCallbackInterfaceRawJaConnectionCallback.lift(handle)
    } catch {
        out_buf.pointee = FfiConverterString.lower("RawJaConnectionCallback: Invalid handle")
        return -1
    }

    switch method {
    case IDX_CALLBACK_FREE:
        FfiConverterCallbackInterfaceRawJaConnectionCallback.drop(handle: handle)
        // No return value.
        // See docs of ForeignCallback in `uniffi/src/ffi/foreigncallbacks.rs`
        return 0
    case 1:
        do {
            out_buf.pointee = try `invokeOnConnectionSuccess`(cb, args)
            // Value written to out buffer.
            // See docs of ForeignCallback in `uniffi/src/ffi/foreigncallbacks.rs`
            return 1
        } catch let error {
            out_buf.pointee = FfiConverterString.lower(String(describing: error))
            return -1
        }
    case 2:
        do {
            out_buf.pointee = try `invokeOnConnectionFailure`(cb, args)
            // Value written to out buffer.
            // See docs of ForeignCallback in `uniffi/src/ffi/foreigncallbacks.rs`
            return 1
        } catch let error {
            out_buf.pointee = FfiConverterString.lower(String(describing: error))
            return -1
        }
    case 3:
        do {
            out_buf.pointee = try `invokeOnSessionCreationSuccess`(cb, args)
            // Value written to out buffer.
            // See docs of ForeignCallback in `uniffi/src/ffi/foreigncallbacks.rs`
            return 1
        } catch let error {
            out_buf.pointee = FfiConverterString.lower(String(describing: error))
            return -1
        }
    case 4:
        do {
            out_buf.pointee = try `invokeOnSessionCreationFailure`(cb, args)
            // Value written to out buffer.
            // See docs of ForeignCallback in `uniffi/src/ffi/foreigncallbacks.rs`
            return 1
        } catch let error {
            out_buf.pointee = FfiConverterString.lower(String(describing: error))
            return -1
        }

        // This should never happen, because an out of bounds method index won't
        // ever be used. Once we can catch errors, we should return an InternalError.
        // https://github.com/mozilla/uniffi-rs/issues/351
    default:
        // An unexpected error happened.
        // See docs of ForeignCallback in `uniffi/src/ffi/foreigncallbacks.rs`
        return -1
    }
}

// FfiConverter protocol for callback interfaces
fileprivate struct FfiConverterCallbackInterfaceRawJaConnectionCallback {
    // Initialize our callback method with the scaffolding code
    private static var callbackInitialized = false
    private static func initCallback() {
        try! rustCall { (err: UnsafeMutablePointer<RustCallStatus>) in
            ffi_jarust_1043_RawJaConnectionCallback_init_callback(foreignCallbackCallbackInterfaceRawJaConnectionCallback, err)
        }
    }
    private static func ensureCallbackinitialized() {
        if !callbackInitialized {
            initCallback()
            callbackInitialized = true
        }
    }

    static func drop(handle: UniFFICallbackHandle) {
        handleMap.remove(handle: handle)
    }

    private static var handleMap = UniFFICallbackHandleMap<RawJaConnectionCallback>()
}

extension FfiConverterCallbackInterfaceRawJaConnectionCallback : FfiConverter {
    typealias SwiftType = RawJaConnectionCallback
    // We can use Handle as the FfiType because it's a typealias to UInt64
    typealias FfiType = UniFFICallbackHandle

    public static func lift(_ handle: UniFFICallbackHandle) throws -> SwiftType {
        ensureCallbackinitialized();
        guard let callback = handleMap.get(handle: handle) else {
            throw UniffiInternalError.unexpectedStaleHandle
        }
        return callback
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> SwiftType {
        ensureCallbackinitialized();
        let handle: UniFFICallbackHandle = try readInt(&buf)
        return try lift(handle)
    }

    public static func lower(_ v: SwiftType) -> UniFFICallbackHandle {
        ensureCallbackinitialized();
        return handleMap.insert(obj: v)
    }

    public static func write(_ v: SwiftType, into buf: inout [UInt8]) {
        ensureCallbackinitialized();
        writeInt(&buf, lower(v))
    }
}

fileprivate struct FfiConverterOptionString: FfiConverterRustBuffer {
    typealias SwiftType = String?

    public static func write(_ value: SwiftType, into buf: inout [UInt8]) {
        guard let value = value else {
            writeInt(&buf, Int8(0))
            return
        }
        writeInt(&buf, Int8(1))
        FfiConverterString.write(value, into: &buf)
    }

    public static func read(from buf: inout (data: Data, offset: Data.Index)) throws -> SwiftType {
        switch try readInt(&buf) as Int8 {
        case 0: return nil
        case 1: return try FfiConverterString.read(from: &buf)
        default: throw UniffiInternalError.unexpectedOptionalTag
        }
    }
}

public func `rawJarustInitLogger`()  {
    try!

    rustCall() {

        jarust_1043_raw_jarust_init_logger($0)
    }
}


public func `rawJarustConnect`(`ctx`: RawJaContext, `config`: RawJaConfig, `cb`: RawJaConnectionCallback)  {
    try!

    rustCall() {

        jarust_1043_raw_jarust_connect(
            FfiConverterTypeRawJaContext.lower(`ctx`),
            FfiConverterTypeRawJaConfig.lower(`config`),
            FfiConverterCallbackInterfaceRawJaConnectionCallback.lower(`cb`), $0)
    }
}


/**
 * Top level initializers and tear down methods.
 *
 * This is generated by uniffi.
 */
public enum JarustLifecycle {
    /**
     * Initialize the FFI and Rust library. This should be only called once per application.
     */
    func initialize() {
    }
}
