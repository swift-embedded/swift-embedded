import STM32F4

let device = try STM32F4()

// configure the pins
let red = device.gpio.pin(peripheral: .B, number: 14, mode: .output)
let blue = device.gpio.pin(peripheral: .B, number: 7, mode: .output)
let green = device.gpio.pin(peripheral: .B, number: 0, mode: .output)

red.set(.high)
blue.set(.high)
green.set(.high)

// toggle the leds periodically
while true {
    device.sleep(.milliseconds(500))
    red.toggle()
    device.sleep(.milliseconds(500))
    blue.toggle()
    device.sleep(.milliseconds(500))
    green.toggle()
}
