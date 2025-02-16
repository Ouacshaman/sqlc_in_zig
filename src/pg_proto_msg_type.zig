const MessageHeader = struct {
    type: u8,
    length: u32,
};

const MessageType = enum(u8) { Query = 'Q', Authentication = 'R', RowDescription = 'T', DataRow = 'D' };
