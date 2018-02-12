/*
 * The MIT License
 *
 * Copyright 2017 Tertium Technology.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
import Foundation
import UIKit

class EventsForwarder: AbstractReaderListenerProtocol, AbstractResponseListenerProtocol, AbstractInventoryListenerProtocol
{
    var readerListenerDelegate: AbstractReaderListenerProtocol? = nil
    var inventoryListenerDelegate: AbstractInventoryListenerProtocol? = nil
    var responseListenerDelegate: AbstractResponseListenerProtocol? = nil
    
    private let _api = PassiveReader.getInstance()
    static private let _sharedInstance = EventsForwarder()
    
    init() {
        _api.readerListenerDelegate = self
        _api.inventoryListenerDelegate = self
        _api.responseListenerDelegate = self
    }
    
    static func getInstance() -> EventsForwarder {
        return _sharedInstance
    }
    
    // AbstractResponseListenerProtocol implementation
    func writeIDevent(tagID: [UInt8]?, error: Int) {
        responseListenerDelegate?.writeIDevent(tagID: tagID, error: error)
    }
    
    func writePasswordEvent(tagID: [UInt8]?, error: Int) {
        responseListenerDelegate?.writePasswordEvent(tagID: tagID, error: error)
    }
    
    func readTIDevent(tagID: [UInt8]?, error: Int, TID: [UInt8]?) {
        responseListenerDelegate?.readTIDevent(tagID: tagID, error: error, TID: TID)
    }
    
    func readEvent(tagID: [UInt8]?, error: Int, data: [UInt8]?) {
        responseListenerDelegate?.readEvent(tagID: tagID, error: error, data: data)
    }
    
    func writeEvent(tagID: [UInt8]?, error: Int) {
        responseListenerDelegate?.writeEvent(tagID: tagID, error: error)
    }
    
    func lockEvent(tagID: [UInt8]?, error: Int) {
        responseListenerDelegate?.lockEvent(tagID: tagID, error: error)
    }
    
    func killEvent(tagID: [UInt8]?, error: Int) {
        responseListenerDelegate?.killEvent(tagID: tagID, error: error)
    }
    
    // AbstractInventoryListenerProtocol implementation
    func inventoryEvent(tag: Tag) {
        inventoryListenerDelegate?.inventoryEvent(tag: tag)
    }
    
    // AbstractReaderListenerProtocol implementation
    func connectionFailureEvent(error: Int) {
        readerListenerDelegate?.connectionFailureEvent(error: error)
    }
    
    func connectionSuccessEvent() {
        readerListenerDelegate?.connectionSuccessEvent()
    }
    
    func disconnectionEvent() {
        readerListenerDelegate?.disconnectionEvent()
    }
    
    func availabilityEvent(available: Bool) {
        readerListenerDelegate?.availabilityEvent(available: available)
    }
    
    func resultEvent(command: Int, error: Int) {
        readerListenerDelegate?.resultEvent(command: command, error: error)
    }
    
    func batteryStatusEvent(status: Int) {
        readerListenerDelegate?.batteryStatusEvent(status: status)
    }
    
    func firmwareVersionEvent(major: Int, minor: Int) {
        readerListenerDelegate?.firmwareVersionEvent(major: major, minor: minor)
    }
    
    func shutdownTimeEvent(time: Int) {
        readerListenerDelegate?.shutdownTimeEvent(time: time)
    }
    
    func RFpowerEvent(level: Int, mode: Int) {
        readerListenerDelegate?.RFpowerEvent(level: level, mode: mode)
    }
    
    func batteryLevelEvent(level: Float) {
        readerListenerDelegate?.batteryLevelEvent(level: level)
    }
    
    func RFforISO15693tunnelEvent(delay: Int, timeout: Int) {
        readerListenerDelegate?.RFforISO15693tunnelEvent(delay: delay, timeout: timeout)
    }
    
    func ISO15693optionBitsEvent(option_bits: Int) {
        readerListenerDelegate?.ISO15693optionBitsEvent(option_bits: option_bits)
    }
    
    func ISO15693extensionFlagEvent(flag: Bool, permanent: Bool) {
        readerListenerDelegate?.ISO15693extensionFlagEvent(flag: flag, permanent: permanent)
    }
    
    func ISO15693bitrateEvent(bitrate: Int, permanent: Bool) {
        readerListenerDelegate?.ISO15693bitrateEvent(bitrate: bitrate, permanent: permanent)
    }
    
    func EPCfrequencyEvent(frequency: Int) {
        readerListenerDelegate?.EPCfrequencyEvent(frequency: frequency)
    }
    
    func tunnelEvent(data: [UInt8]?) {
        readerListenerDelegate?.tunnelEvent(data: data)
    }
}

