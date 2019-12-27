// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "HelloWorld",
    products: [
        .executable(name: "HelloWorld", targets: ["HelloWorld"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-embedded/arm-semihosting", .branch("master")),
        .package(url: "https://github.com/swift-embedded/stm32", .branch("master")),
    ],
    targets: [
        .target(
            name: "HelloWorld",
            dependencies: ["STM32F4", "Semihosting"]
        ),
    ]
)
