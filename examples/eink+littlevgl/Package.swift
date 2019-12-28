// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "eink+littlevgl",
    products: [
        .executable(name: "eink+littlevgl", targets: ["eink+littlevgl"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-embedded/stm32", .branch("master")),
        .package(url: "https://github.com/swift-embedded/hardware", .branch("master")),
        .package(url: "https://github.com/swift-embedded/littlevgl", .branch("master")),
        .package(url: "https://github.com/swift-embedded/epd", .branch("master")),
        .package(url: "https://github.com/apple/swift-log", .branch("master")),
    ],
    targets: [
        .target(
            name: "eink+littlevgl",
            dependencies: ["STM32F4", "Logging", "UARTLogHandler", "CLittlevGL", "EPD"],
            linkerSettings: [.linkedLibrary("nosys")]
        ),
    ]
)
