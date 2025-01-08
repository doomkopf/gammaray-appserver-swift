import NIO

func stringToTerminatedBuffer(_ str: String) -> ByteBuffer {
    var buffer = ByteBuffer(string: "\(str)0")
    buffer.setBytes([0], at: buffer.readableBytes - 1)
    return buffer
}
