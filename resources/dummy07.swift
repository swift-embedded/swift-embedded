import EPD
import Logging
import STM32F4
import UARTLogHandler

// initialize the board
let device = try STM32F4()

// initialize logging
let logger: Logger = try {
    let uart = device.uart3
    try uart.configure(.init(baudrate: 115_200))
    LoggingSystem.bootstrap { label in
        UARTLogHandler(label: label, uart: uart)
    }
    return Logger(label: "com.embedded-swift.examples.uart-logging")
}()

let display: Display = try {
    // configure SPI
    try device.spi3.configure(.init(
        sck: device.gpio.pin(peripheral: .B, number: 3),
        miso: device.gpio.pin(peripheral: .B, number: 4),
        mosi: device.gpio.pin(peripheral: .B, number: 5)
    ))
    // configure other required gpio
    let cs = device.gpio.pin(peripheral: .A, number: 4, mode: .output)
    let busy = device.gpio.pin(peripheral: .D, number: 15, mode: .input(pull: .no))
    let dc = device.gpio.pin(peripheral: .D, number: 14, mode: .output)
    let reset = device.gpio.pin(peripheral: .F, number: 12, mode: .output)
    // initialize the display driver
    return try Display(spi: device.spi3, cs: cs, busy: busy, dc: dc, reset: reset)
}()

// configure button pin
let userButton = device.gpio.pin(peripheral: .C, number: 13, mode: .input(pull: .up))

// start the application
logger.info("hardware successfully configured; starting application")
let application = Application(display: display, userButton: userButton, logger: logger)
application.run()
