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
import RfidPassiveAPILib

class EventsForwarder: AbstractReaderListenerProtocol, AbstractResponseListenerProtocol, AbstractInventoryListenerProtocol, AbstractZhagaListenerProtocol
{
    var readerListenerDelegate: AbstractReaderListenerProtocol? = nil
    var inventoryListenerDelegate: AbstractInventoryListenerProtocol? = nil
    var responseListenerDelegate: AbstractResponseListenerProtocol? = nil
    var zhagaListenerDelegate: AbstractZhagaListenerProtocol? = nil
    
    private let _api = PassiveReader.getInstance()
    static private let _sharedInstance = EventsForwarder()
    
    init() {
        _api.readerListenerDelegate = self
        _api.inventoryListenerDelegate = self
        _api.responseListenerDelegate = self
        _api.zhagaListenerDelegate = self
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
    func connectionFailedEvent(error: Int) {
        readerListenerDelegate?.connectionFailedEvent(error: error)
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
    
    func securityLevelEvent(level: Int) {
        readerListenerDelegate?.securityLevelEvent(level: level)
    }

    func nameEvent(device_name: String) {
        zhagaListenerDelegate?.nameEvent(device_name: device_name)
    }
    
    func advertisingIntervalEvent(advertising_interval: Int) {
        readerListenerDelegate?.advertisingIntervalEvent(advertising_interval: advertising_interval)
    }
    
    func BLEpowerEvent(BLE_power: Int) {
        readerListenerDelegate?.BLEpowerEvent(BLE_power: BLE_power)
    }
    
    func connectionIntervalEvent(min_interval: Float, max_interval: Float) {
        readerListenerDelegate?.connectionIntervalEvent(min_interval: min_interval, max_interval: max_interval)
    }
    
    func connectionIntervalAndMTUevent(connection_interval: Float, MTU: Int) {
        readerListenerDelegate?.connectionIntervalAndMTUevent(connection_interval: connection_interval, MTU: MTU)
    }
    
    func MACaddressEvent(MAC_address: [UInt8]?) {
        readerListenerDelegate?.MACaddressEvent(MAC_address: MAC_address)
    }
    
    func slaveLatencyEvent(slave_latency: Int) {
        readerListenerDelegate?.slaveLatencyEvent(slave_latency: slave_latency)
    }
    
    func supervisionTimeoutEvent(supervision_timeout: Int) {
        readerListenerDelegate?.supervisionTimeoutEvent(supervision_timeout: supervision_timeout)
    }
    
    func BLEfirmwareVersionEvent(major: Int, minor: Int) {
        readerListenerDelegate?.BLEfirmwareVersionEvent(major: major, minor: minor)
    }
    
    func userMemoryEvent(data_block: [UInt8]?) {
        readerListenerDelegate?.userMemoryEvent(data_block: data_block)
    }
    
    func disconnectionSuccessEvent() {
        zhagaListenerDelegate?.disconnectionSuccessEvent()
    }
    
    func buttonEvent(button: Int, time: Int) {
        zhagaListenerDelegate?.buttonEvent(button: button, time: time)
    }
    
    func deviceEventEvent(event_number: Int, event_code: Int) {
        zhagaListenerDelegate?.deviceEventEvent(event_number: event_number, event_code: event_number)
    }
    
    func HMIevent(LED_color: Int, sound_vibration: Int, button_number: Int) {
        zhagaListenerDelegate?.HMIevent(LED_color: LED_color, sound_vibration: sound_vibration, button_number: button_number)
    }
    
    func soundForInventoryEvent(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int) {
        zhagaListenerDelegate?.soundForInventoryEvent(sound_frequency: sound_frequency, sound_on_time: sound_on_time, sound_off_time: sound_off_time, sound_repetition: sound_repetition)
    }
    
    func soundForCommandEvent(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int) {
        zhagaListenerDelegate?.soundForCommandEvent(sound_frequency: sound_frequency, sound_on_time: sound_on_time, sound_off_time: sound_off_time, sound_repetition: sound_repetition)
    }
    
    func soundForErrorEvent(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int) {
        zhagaListenerDelegate?.soundForErrorEvent(sound_frequency: sound_frequency, sound_on_time: sound_on_time, sound_off_time: sound_off_time, sound_repetition: sound_repetition)
    }
    
    func LEDforInventoryEvent(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int) {
        zhagaListenerDelegate?.LEDforInventoryEvent(light_color: light_color, light_on_time: light_on_time, light_off_time: light_off_time, light_repetition: light_repetition)
    }
    
    func LEDforCommandEvent(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int) {
        zhagaListenerDelegate?.LEDforCommandEvent(light_color: light_color, light_on_time: light_on_time, light_off_time: light_off_time, light_repetition: light_repetition)
    }
    
    func LEDforErrorEvent(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int) {
        zhagaListenerDelegate?.LEDforErrorEvent(light_color: light_color, light_on_time: light_on_time, light_off_time: light_off_time, light_repetition: light_repetition)
    }
    
    func vibrationForInventoryEvent(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int) {
        zhagaListenerDelegate?.vibrationForInventoryEvent(vibration_on_time: vibration_on_time, vibration_off_time: vibration_on_time, vibration_repetition: vibration_repetition)
    }
    
    func vibrationForCommandEvent(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int) {
        zhagaListenerDelegate?.vibrationForCommandEvent(vibration_on_time: vibration_on_time, vibration_off_time: vibration_repetition, vibration_repetition: vibration_repetition)
    }
    
    func vibrationForErrorEvent(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int) {
        zhagaListenerDelegate?.vibrationForErrorEvent(vibration_on_time: vibration_on_time, vibration_off_time: vibration_repetition, vibration_repetition: vibration_repetition)
    }
    
    func activatedButtonEvent(activated_button: Int) {
        zhagaListenerDelegate?.activatedButtonEvent(activated_button: activated_button)
    }
    
    func RFonOffEvent(RF_power: Int, RF_off_timeout: Int, RF_on_preactivation: Int) {
        zhagaListenerDelegate?.RFonOffEvent(RF_power: RF_power, RF_off_timeout: RF_power, RF_on_preactivation: RF_on_preactivation)
    }
    
    func autoOffEvent(OFF_time: Int) {
        zhagaListenerDelegate?.autoOffEvent(OFF_time: OFF_time)
    }
    
    func transparentEvent(answer: [UInt8]?) {
        zhagaListenerDelegate?.transparentEvent(answer: answer)
    }
    
    func RFevent(RF_on: Bool) {
        zhagaListenerDelegate?.RFevent(RF_on: RF_on)
    }
}
