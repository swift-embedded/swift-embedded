import Logging
import STM32F4
import UARTLogHandler

// initialize the board
let device = try STM32F4()

// initialize the uart interface
let uart = device.uart3
try uart.configure(.init(baudrate: 115_200))

// and initialize logging with UART
LoggingSystem.bootstrap { label in
    UARTLogHandler(label: label, uart: uart)
}

//
// and enjoy!
//

// let's create some logger
let logger = Logger(label: "com.embedded-swift.examples.uart-logging")

// and log something
var counter = 1
while true {
    logger.info("message number \(counter)")
    counter += 1
    device.sleep(.seconds(1))
}
