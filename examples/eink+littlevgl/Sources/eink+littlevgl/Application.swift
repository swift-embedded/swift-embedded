import CLittlevGL
import EPD
import Hardware
import Logging
import STM32F4

class Application {
    let display: Display
    let userButton: DigitalIn
    let logger: Logger

    let displayBuffer: UnsafeMutablePointer<lv_disp_buf_t>
    let logoImage = [swiftLogo]

    init(display: Display, userButton: DigitalIn, logger: Logger) {
        self.display = display
        self.userButton = userButton
        self.logger = logger

        // initialize littlevgl
        lv_init()
        registerSysTickHandler {
            lv_tick_inc(1)
        }

        // initialize screen
        displayBuffer = createDisplayBuffer(width: display.width, height: display.height)
        DisplayManagement.logger = logger
        DisplayManagement.register(display: display, buffer: displayBuffer)

        setupScreen()
    }

    func setupScreen() {
        let theme = lv_theme_mono_init(10, nil)
        lv_theme_set_current(theme)

        let horizontalContainer = lv_cont_create(lv_scr_act(), nil)
        lv_cont_set_fit(horizontalContainer, lv_fit_t(LV_FIT_FLOOD))
        lv_cont_set_layout(horizontalContainer, lv_layout_t(LV_LAYOUT_PRETTY))

        let logo = lv_img_create(horizontalContainer, nil)
        lv_img_set_src(logo, UnsafeRawPointer(UnsafePointer(logoImage)))
        lv_img_set_auto_size(logo, true)

        let label = lv_label_create(horizontalContainer, nil)
        lv_label_set_text(label, "Swift for Embedded Systems")
    }

    func run() -> Never {
        while true {
            lv_task_handler()
            sleep(.seconds(1))
        }
    }
}
