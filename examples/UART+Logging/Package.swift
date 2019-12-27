// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "UART+Logging",
    products: [
        .executable(name: "UART+Logging", targets: ["UART+Logging"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-embedded/stm32", .branch("master")),
        .package(url: "https://github.com/swift-embedded/hardware", .branch("master")),
        .package(url: "https://github.com/apple/swift-log", .branch("master")),
    ],
    targets: [
        .target(
            name: "UART+Logging",
            dependencies: ["STM32F4", "Logging", "UARTLogHandler"],
            linkerSettings: [.linkedLibrary("nosys")]
        ),
    ]
)
