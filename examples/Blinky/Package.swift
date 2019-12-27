// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Blinky",
    products: [
        .executable(name: "Blinky", targets: ["Blinky"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-embedded/stm32", .branch("master")),
    ],
    targets: [
        .target(
            name: "Blinky", dependencies: ["STM32F4"], linkerSettings: [.linkedLibrary("nosys")]
        ),
    ]
)
