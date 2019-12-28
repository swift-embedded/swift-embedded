import CLittlevGL
import EPD
import Logging

func createDisplayBuffer(width: Int, height: Int) -> UnsafeMutablePointer<lv_disp_buf_t> {
    // prepare buffers
    let rawDisplayBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: (width * height) / 8)
    let displayBuffer = UnsafeMutablePointer<lv_disp_buf_t>.allocate(capacity: 1)
    lv_disp_buf_init(displayBuffer,
                     UnsafeMutablePointer(rawDisplayBuffer),
                     nil,
                     UInt32(width * height))
    return displayBuffer
}

class DisplayManagement {
    static var logger: Logger?
    private(set) static var display: Display?
    private(set) static var driver: lv_disp_drv_t = lv_disp_drv_t()

    @discardableResult
    static func register(display: Display, buffer: UnsafeMutablePointer<lv_disp_buf_t>) -> UnsafeMutablePointer<lv_disp_t> {
        guard DisplayManagement.display == nil else {
            fatalError("display already registered")
        }
        DisplayManagement.display = display
        lv_disp_drv_init(&driver)
        driver.buffer = buffer
        driver.hor_res = lv_coord_t(display.height)
        driver.ver_res = lv_coord_t(display.width)
        driver.rounder_cb = { DisplayManagement.rounder_cb(driver: $0, area: $1) }
        driver.flush_cb = { DisplayManagement.flush_cb(driver: $0, area: $1, color_p: $2) }
        driver.set_px_cb = { DisplayManagement.set_px_cb(driver: $0, buffer: $1, bufferWidth: $2, x: $3, y: $4, color: $5, opa: $6) }
        return lv_disp_drv_register(&driver)
    }

    private static func rounder_cb(driver _: UnsafeMutablePointer<lv_disp_drv_t>!, area: UnsafeMutablePointer<lv_area_t>!) {
        area.pointee.y1 = 0
        area.pointee.y2 = lv_coord_t(display?.width ?? 2) - 1
    }

    private static func projectToBuffer(x: Int, y: Int, width: Int) -> (x: Int, y: Int) {
        (x: width - 1 - y, y: x)
    }

    private static func flush_cb(driver: UnsafeMutablePointer<lv_disp_drv_t>!, area: UnsafePointer<lv_area_t>!, color_p: UnsafeMutablePointer<lv_color_t>!) {
        guard let display = display else {
            lv_disp_flush_ready(driver)
            return
        }
        logger?.info("buffer flush starting")
        do {
            let (bufferX2, bufferY1) = projectToBuffer(x: Int(area.pointee.x1), y: Int(area.pointee.y1), width: Int(driver.pointee.ver_res))
            let (bufferX1, bufferY2) = projectToBuffer(x: Int(area.pointee.x2), y: Int(area.pointee.y2), width: Int(driver.pointee.ver_res))
            let xRange = bufferX1 ... bufferX2
            let yRange = bufferY1 ... bufferY2
            try display.setDataEntryMode(direction: (x: .increment, y: .increment), scanline: .x)
            try display.setMemoryArea(x: xRange, y: yRange)
            try display.setMemoryPointer(x: bufferX1, y: bufferY1)
            let pixelCount = xRange.count * yRange.count
            let buffer = UnsafeMutableRawPointer(color_p).bindMemory(to: UInt8.self, capacity: pixelCount / 8)
            try display.fill(data: ContiguousArray(UnsafeBufferPointer(start: buffer, count: pixelCount / 8)))
            try display.displayFrame()
            try display.setDataEntryMode(direction: (x: .increment, y: .increment), scanline: .x)
            try display.setMemoryArea(x: xRange, y: yRange)
            try display.setMemoryPointer(x: bufferX1, y: bufferY1)
            try display.fill(data: ContiguousArray(UnsafeBufferPointer(start: buffer, count: pixelCount / 8)))
            logger?.info("buffer flush done")
        } catch {
            logger?.error("buffer flushing failed: \(error)")
        }
        lv_disp_flush_ready(driver)
    }

    private static func set_px_cb(driver: UnsafeMutablePointer<lv_disp_drv_t>!,
                                  buffer: UnsafeMutablePointer<UInt8>!,
                                  bufferWidth _: lv_coord_t,
                                  x: lv_coord_t,
                                  y: lv_coord_t,
                                  color: lv_color_t,
                                  opa _: lv_opa_t) {
        let (bufferX, bufferY) = projectToBuffer(x: Int(x), y: Int(y), width: Int(driver.pointee.ver_res))
        let width = lv_area_get_height(&driver.pointee.buffer!.pointee.area)
        let pixelIndex = Int(width) * bufferY + bufferX
        if color.full > 0 {
            buffer[pixelIndex / 8] |= (1 << (7 - (pixelIndex % 8)))
        } else {
            buffer[pixelIndex / 8] &= ~(1 << (7 - (pixelIndex % 8)))
        }
    }
}
