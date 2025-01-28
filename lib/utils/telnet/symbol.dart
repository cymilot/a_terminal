// ignore_for_file: constant_identifier_names

const CR = 13;
const LF = 10;
const NUL = 0;

const TEL_IS = 0;
const TEL_SEND = 1;
const TEL_INFO = 2;

const XON = 0x11;
const XOFF = 0x13;

enum TelnetCommand {
  /// 240	End of subnegotiation parameters.
  SE(0xF0),

  /// 241 No operation.
  NOP(0xF1),

  /// 242 The data stream portion of a Synch. This should always be accompanied by a TCP Urgent notification.
  DM(0xF2),

  /// 243 Break. Indicates that the "break" or "attention" key was hit.
  BRK(0xF3),

  /// 244 Suspend, interrupt or abort the process to which the NVT is connected.
  IP(0xF4),

  /// 245 Abort output. Allows the current process to run to completion but do not send its output to the user.
  AO(0xF5),

  /// 246 Are you there? Send back to the NVT some visible evidence that the AYT was received.
  AYT(0xF6),

  /// 247 Erase character. The receiver should delete the last preceding undeleted character from the data stream.
  EC(0xF7),

  /// 248 Erase line. Delete characters from the data stream back to but not including the previous CRLF.
  EL(0xF8),

  /// 249 Go ahead. Used, under certain circumstances, to tell the other end that it can transmit.
  GA(0xF9),

  /// 250 Subnegotiation of the indicated option follows.
  SB(0xFA),

  /// 251 Indicates the desire to begin performing, or confirmation that you are now performing, the indicated option.
  WILL(0xFB),

  /// 252 Indicates the refusal to perform, or continue performing, the indicated option.
  WONT(0xFC),

  /// 253 Indicates the request that the other party perform, or confirmation that you are expecting the other party to perform, the indicated option.
  DO(0xFD),

  /// 254 Indicates the demand that the other party stop performing, or confirmation that you are no longer expecting the other party to perform, the indicated option.
  DONT(0xFE),

  /// 255 Interpret as command
  IAC(0xFF);

  const TelnetCommand(this.value);

  final int value;

  static TelnetCommand? fromInt(int value) {
    for (final command in values) {
      if (command.value == value) {
        return command;
      }
    }
    return null;
  }
}

enum TelnetOption {
  /// 0 Binary Transmission
  BT(0),

  /// 1 Echo
  ECHO(1),

  /// 2 Reconnection
  RCN(2),

  /// 3 Suppress Go Ahead
  SGA(3),

  /// 4 Approx Message Size Negotiation
  AMSN(4),

  /// 5 Status
  STATUS(5),

  /// 6 Timing Mark
  TMK(6),

  /// 7 Remote Controlled Trans and Echo
  RCTE(7),

  /// 8 Output Line Width
  OLNW(8),

  /// 9 Output Page Size
  OPGS(9),

  /// 10 Output Carriage-Return Disposition
  OCRD(10),

  /// 11 Output Horizontal Tab Stops
  OHTS(11),

  /// 12 Output Horizontal Tab Disposition
  OHTD(12),

  /// 13 Output Formfeed Disposition
  OFD(13),

  /// 14 Output Vertical Tabstops
  OVTS(14),

  /// 15 Output Vertical Tab Disposition
  OVTD(15),

  /// 16 Output Linefeed Disposition
  OLFD(16),

  /// 17 Extended ASCII
  EXA(17),

  /// 18 Logout
  LOUT(18),

  /// 19 Byte Macro
  BMA(19),

  /// 20 Data Entry Terminal
  DET(20),

  /// 21 Supdup
  SUP(21),

  /// 22 Supdup Output
  SUPO(22),

  /// 23	Send Location
  SLOCA(23),

  /// 24 Terminal Type
  TTYPE(24),

  /// 25 End of Record
  EOR(25),

  /// 26 TACACS User Identification
  TUI(26),

  /// 27 Output Marking
  OMARK(27),

  /// 28 Terminal Location Number
  TLN(28),

  /// 29 3270 Regime
  S3270(29),

  /// 30 X.3 PAD
  X3PAD(30),

  /// 31 Negotiate About Window Size
  NAWS(31),

  /// 32 Terminal Speed
  TSPEED(32),

  /// 33 Remote Flow Control
  RFC(33),

  /// 34 Line Mode
  LM(34),

  /// 35 X Display Location
  XDISL(35),

  /// 36 Environment Option
  OLDENV(36),

  /// 37 Authentication Option
  AUTH(37),

  /// 38 Encryption Option
  ENCRYPT(38),

  /// 39 New Environment Option
  NEWENV(39),

  /// 40 TN3270E
  TN3270E(40),

  /// 41
  XAUTH(41),

  /// 42
  CHARSET(42),

  /// 43 Telnet Remote Serial Port (RSP)
  RSP(43),

  /// 44 Com Port Control Option
  CM(44),

  /// 45 Suppress Local Echo
  SSU(45),

  /// 46 Telnet Start TLS
  STLS(46),

  /// 47 Com Port Control Option
  CPOP(47),

  /// 48 SEND-URL
  SURL(48),

  /// 49 FORWARD_X
  FORX(49),

  /// 138 TELOPT PRAGMA LOGON
  PRALO(138),

  /// 139	TELOPT SSPI LOGON
  SSPILO(139),

  /// 140	TELOPT PRAGMA HEARTBEAT
  PRAHB(140),

  /// 255 Extended-Options-List
  EOL(255);

  const TelnetOption(this.value);

  final int value;

  static TelnetOption? fromInt(int value) {
    for (final option in values) {
      if (option.value == value) {
        return option;
      }
    }
    return null;
  }
}

enum SessionState {
  topLevel,
  seenIAC,
  seenDO,
  seenDONT,
  seenWILL,
  seenWONT,
  seenSB,
  subnegGOT,
  subnegIAC,
}
