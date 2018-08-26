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
import UIKit
import RfidPassiveAPILib

class DeviceDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, AbstractReaderListenerProtocol, AbstractResponseListenerProtocol, AbstractInventoryListenerProtocol {
    @IBOutlet weak var lblDevice: UILabel!
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var lblBatteryStatus: UILabel!
    @IBOutlet weak var txtInitialCommands: UITextView!
    @IBOutlet weak var pikSelectCommand: UIPickerView!
    @IBOutlet weak var txtCustomCommands: UITextView!
    @IBOutlet weak var btnStartOperation: UIButton!
    @IBOutlet weak var tblTags: UITableView!
    
    let operations = ["Select Operation",
                      "Test Availability",
                      "Sound",
                      "Light",
                      "Stop Light",
                      "Set Shutdown Time (300)",
                      "Get Shutdown Time",
                      "Set RF Power",
                      "Get RF Power",
                      "Set ISO15693 Option Bits (Only HF)",
                      "Get ISO15693 Option Bits (Only HF)",
                      "Set ISO15693 Extension Flag(Only HF)",
                      "Get ISO15693 Extension Flag(Only HF)",
                      "Set ISO15693 Bitrate(Only HF)",
                      "Get ISO15693 Bitrate(Only HF)",
                      "Set EPC Frequency (only UHF)",
                      "Get EPC Frequency (only UHF)",
                      "setScanOnInput",
                      "setNormalScan",
                      "Do Inventory",
                      "Clear inventory",
                      "Extended tag tests",
                      "Write access password",
                      "Read selected tag",
                      "Write selected tag",
                      "Lock selected tag",
                      "Read TID for selected tag",
                      "Write ID for selected tag",
                      "Write kill password for selected tag",
                      "Kill selected tag"
                    ]
    
    let lockoperationslabels = ["Memory write protected",
                          "Memory write forbidden",
                          "ID write forbidden",
                          "Access-password protected",
                          "Kill-password protected",
                          "Access-password rewrite forbidden",
                          "Kill-password rewrite forbidden"
                          ]
    let lockoperationsvalues = [
        EPC_tag.MEMORY_PASSWORD_WRITABLE,
        EPC_tag.MEMORY_NOTWRITABLE,
        EPC_tag.ID_NOTWRITABLE,
        EPC_tag.ACCESSPASSWORD_PASSWORD_READABLE_WRITABLE,
        EPC_tag.KILLPASSWORD_PASSWORD_READABLE_WRITABLE,
        EPC_tag.ACCESSPASSWORD_UNREADABLE_UNWRITABLE,
        EPC_tag.KILLPASSWORD_UNREADABLE_UNWRITABLE
    ]
    
    private let _api = PassiveReader.getInstance()
    private let _eventsForwarder = EventsForwarder.getInstance()
    private var _timer: Timer = Timer()
    private var _font: UIFont?
    private var _tags: [Tag?] = []
    
    private var _batteryLevel: Float = 0
    private var _batteryStatus: Int = 0
    private var _deviceAvailable: Bool = false
    
    private var _currentInitialOperation: Int = 0
    private var _maxInitialOperations: Int = 1
    private var _selectedRow: Int = 0
    private var _selectedLockOperation: Int = 0
    private var _repeatingCommandIndex: Int = 0
    private var _lastCommandType: CommandType = .initialCommands
    private var _connected: Bool = false
    private var _inExtendedView: Bool = false
    private var _lastRepeatingCommand: Int = 0
    private var _alertController: UIAlertController?
    private var _selectedTag: Int = 0
    
    enum CommandType: Int {
        case noCommand = 0
        case initialCommands
        case customCommand
        case repeatingCommand
    }
    
    private var initialCommandsBuffer = NSMutableAttributedString()
    private var customCommandsBuffer = NSMutableAttributedString()
    
    var deviceName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        _font = UIFont(name: "Terminal", size: 10.0)
        
        //
        lblDevice.text = deviceName
        
        _timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(self.repeatingCommandsTick), userInfo: nil, repeats: true)
        _eventsForwarder.readerListenerDelegate = self
        _eventsForwarder.inventoryListenerDelegate = self
        _eventsForwarder.responseListenerDelegate = self
        
        //
        txtInitialCommands.layer.borderColor = UIColor.blue.cgColor
        txtInitialCommands.layer.borderWidth = 3.0
        txtCustomCommands.layer.borderColor = UIColor.blue.cgColor
        txtCustomCommands.layer.borderWidth = 3.0
        updateBatteryLabel()
        enableStartButton(enabled: false)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func reset() {
        _api.disconnect()
        enableStartButton(enabled: false)
        _lastCommandType = .initialCommands
        _currentInitialOperation = 0
        _maxInitialOperations = 1
        _batteryLevel = 0
        _batteryStatus = 0
        _deviceAvailable = false
        _tags.removeAll()
    }
    
    func callNextInitialOperation() {
        let initialCommandsMap = [
            {
                if self._api.isHF() {
                    self.appendTextToBuffer(text: "HF reader (for ISO-15693/ISO-14443 tags)", color: .white)
                } else {
                    self.appendTextToBuffer(text: "UHF reader (for EPC tags)", color: .white)
                }
                
                self.enableStartButton(enabled: true)
            },
            
            {
                self.appendTextToBuffer(text: "setInventoryType", color: .yellow)
                if self._api.isHF() {
                    self._api.setInventoryType(standard: PassiveReader.ISO15693_AND_ISO14443A_STANDARD)
                } else {
                    self._api.setInventoryType(standard: PassiveReader.EPC_STANDARD)
                }
            },
            
            {
                self.appendTextToBuffer(text: "getFirmwareVersion", color: .yellow)
                self._api.getFirmwareVersion()
            },
            
            {
                self.appendTextToBuffer(text: "setInventoryParameters", color: .yellow)
                self._api.setInventoryParameters(feedback: PassiveReader.FEEDBACK_SOUND_AND_LIGHT, timeout: 1000, interval: 1000)
            },
        ]
        
        if btnStartOperation.isEnabled == false {
            return
        }
        
        _lastCommandType = .initialCommands
        _maxInitialOperations = initialCommandsMap.count
        enableStartButton(enabled: false)
        initialCommandsMap[_currentInitialOperation]()
        _currentInitialOperation = _currentInitialOperation + 1
        if _currentInitialOperation == 1 {
            enableStartButton(enabled: false)
            initialCommandsMap[_currentInitialOperation]()
            _currentInitialOperation = _currentInitialOperation + 1
        }
    }
    
    func callCustomOperation(method: Int) {
        if btnStartOperation.isEnabled == false {
            return
        }
        
        let commandMap = [
            {
                self.enableStartButton(enabled: true)
            },
            
            {
                // Test Availability
                self._api.testAvailability()
            },
            
            {
                // Sound
                self._api.sound(frequency: 1000, step: 1000, duration: 1000, interval: 500, repetition: 3)
            },

            {
                // Light
                self._api.light(ledStatus: true, ledBlinking: 500)
            },

            {
                // Light off
                self._api.light(ledStatus: false, ledBlinking: 0)
            },

            {
                // Set Shutdown Time (300)
                self._api.setShutdownTime(time: 300)
            },

            {
                // Get Shutdown Time
                self._api.getShutdownTime()
            },

            {
                // Set RF Power
                if self._api.isHF() {
                    self._api.setRFpower(level: PassiveReader.HF_RF_FULL_POWER, mode: PassiveReader.HF_RF_AUTOMATIC_POWER)
                } else {
                    self._api.setRFpower(level: PassiveReader.UHF_RF_POWER_0_DB, mode: PassiveReader.UHF_RF_POWER_AUTOMATIC_MODE)
                }
            },
            
            {
                // Get RF Power
                self._api.getRFpower()
            },
            
            {
                // SetISO15693optionBits
                self._api.setISO15693optionBits(optionBits: PassiveReader.ISO15693_OPTION_BITS_NONE)
            },
            
            {
                // GetISO15693optionBits
                self._api.getISO15693optionBits()
            },
            
            {
                // SetISO15693extensionFlag
                self._api.setISO15693extensionFlag(flag: true, permanent: false)
            },
            
            {
                // GetISO15693extensionFlag
                self._api.getISO15693extensionFlag()
            },
            
            {
                // SetISO15693bitrate
                self._api.setISO15693bitrate(bitrate: PassiveReader.ISO15693_HIGH_BITRATE, permanent: false)
            },
            
            {
                // GetISO15693bitrate
                self._api.getISO15693bitrate()
            },
            
            {
                // GetEPCfrequency
                self._api.setEPCfrequency(frequency: PassiveReader.RF_CARRIER_866_9_MHZ)
            },
            
            {
                // GetEPCFrequency
                self._api.getEPCfrequency()
            },
            
            {
                // setScanOnInput
                self._api.setInventoryMode(mode: PassiveReader.SCAN_ON_INPUT_MODE)
            },
            
            {
                // setNormalScan
                self._api.setInventoryMode(mode: PassiveReader.NORMAL_MODE)
            },
            
            {
                //
                self._tags.removeAll()
                
                // Do inventoy
                self._api.doInventory()
                
                // IMPORTANT! force no command sent, inventory doesn't notify back!
                self.enableStartButton(enabled: true)
            },
            
            {
                // Clear inventory
                self._tags.removeAll()
                self.tblTags.reloadData()
                
                // IMPORTANT! force no command sent, inventory doesn't notify back!
                self.enableStartButton(enabled: true)
                self.appendTextToBuffer(text: "Tag list cleared", color: .white)
            },
            
            {
                // Extended tag tests
                var extTestsVC: ExtendedTagTestsViewController?
                
                if self._tags.count != 0 {
                    extTestsVC = (self.storyboard?.instantiateViewController(withIdentifier: "ExtendedTagTestsViewController") as? ExtendedTagTestsViewController?)!
                    if let view = extTestsVC {
                        view._tags = self._tags as! [Tag]
                        view.deviceDetailVC = self
                        view.deviceName = self.deviceName
                        self._inExtendedView = true
                        self.navigationController?.pushViewController(view, animated: true)
                    }
                } else {
                    self.appendTextToBuffer(text: "Please do inventory first!", color: .red)
                }
                self.enableStartButton(enabled: true)
            },
            
            {
                // Write access password
                if self._tags.count != 0 {
                    if let tag = self._tags[self._selectedTag] as? EPC_tag? {
                        self.showAccessPasswordAlertView(showOldPassword: true, showLockParameters: false, actionHandler: { (action: UIAlertAction) in
                            if let textFields = self._alertController?.textFields {
                                let passwordField = textFields[1]
                                let oldPasswordField = textFields[0]
                                
                                if passwordField.text!.count == 0 {
                                    self.appendTextToBuffer(text: "Access password is mandatory!", color: .red)
                                    self.enableStartButton(enabled: true)
                                    return
                                }
                                
                                if oldPasswordField.text!.count != 0 {
                                    tag?.writeAccessPassword(accessPassword: PassiveReader.hexStringToByte(hex: passwordField.text!), password: PassiveReader.hexStringToByte(hex: oldPasswordField.text!))
                                } else {
                                    tag?.writeAccessPassword(accessPassword: PassiveReader.hexStringToByte(hex: passwordField.text!), password: nil)
                                }
                            }
                        })
                    } else {
                        self.appendTextToBuffer(text: "Command is valid only on EPC tags!", color: .red)
                        self.enableStartButton(enabled: true)
                    }
                } else {
                    self.appendTextToBuffer(text: "Please do inventory first!", color: .red)
                    self.enableStartButton(enabled: true)
                }
            },
            
            {
                // Read selected tag
                if self._tags.count != 0 {
                    if let tag = self._tags[self._selectedTag] as? ISO15693_tag? {
                        tag?.setTimeout(timeout: 2000)
                        tag?.read(address: 0, blocks: 2)
                    //} else if let tag = self._tags[self._selectedTag] as? ISO14443A_tag? {
                    //    self.enableStartButton(enabled: true)
                    } else if let tag = self._tags[self._selectedTag] as? EPC_tag? {
                        tag?.read(address: 0, blocks: 4)
                    }
                } else {
                    self.appendTextToBuffer(text: "Please do inventory first!", color: .red)
                    self.enableStartButton(enabled: true)
                }
            },
            
            {
                //
                let date: Date = Date()
                let calendar = Calendar.current
                let minutes = calendar.component(.minute, from: date)
                
                // Write selected tag
                let data = [
                            UInt8(minutes),
                            UInt8(minutes+1),
                            UInt8(minutes+2),
                            UInt8(minutes+3),
                            UInt8(minutes+4),
                            UInt8(minutes+5),
                            UInt8(minutes+6),
                            UInt8(minutes+7)
                          ]
                
                if self._tags.count != 0 {
                    if let tag = self._tags[self._selectedTag] as? ISO15693_tag? {
                        tag?.setTimeout(timeout: 2000)
                        tag?.write(address: 0, data: data)
                    //} else if let tag = self._tags[self._selectedTag] as? ISO14443A_tag? {
                    //    self.enableStartButton(enabled: true)
                    } else if let tag = self._tags[self._selectedTag] as? EPC_tag? {
                        tag?.write(address: 0, data: data, password: nil)
                    }
                } else {
                    self.appendTextToBuffer(text: "Please do inventory first!", color: .red)
                    self.enableStartButton(enabled: true)
                }
            },
            
            {
                // Lock selected tag
                if self._tags.count != 0 {
                    if let tag = self._tags[self._selectedTag] as? ISO15693_tag? {
                        tag?.setTimeout(timeout: 2000)
                        tag?.lock(address: 0, blocks: 2)
                    //} else if let tag = self._tags[self._selectedTag] as? ISO14443A_tag? {
                    //    self.enableStartButton(enabled: true)
                    } else if let tag = self._tags[self._selectedTag] as? EPC_tag? {
                        //tag?.lock(lock_type: EPC_tag.MEMORY_NOTWRITABLE, password: nil)
                        self.showAccessPasswordAlertView(showOldPassword: false, showLockParameters: true, actionHandler: { (action: UIAlertAction) in
                            if let textFields = self._alertController?.textFields {
                                let passwordField = textFields[0]
                                if passwordField.text!.count != 0 {
                                    tag?.lock(lock_type: self.lockoperationsvalues[self._selectedLockOperation], password: PassiveReader.hexStringToByte(hex: passwordField.text!))
                                } else {
                                    tag?.lock(lock_type: self.lockoperationsvalues[self._selectedLockOperation], password: nil)
                                }
                            }
                        })
                    }
                } else {
                    self.appendTextToBuffer(text: "Please do inventory first!", color: .red)
                    self.enableStartButton(enabled: true)
                }
            },
            
            {
                if self._tags.count != 0 {
                    // Read TID for first tag
                    if let tag = self._tags[self._selectedTag] as? EPC_tag? {
                        //tag?.readTID(length: 8, password: nil)
                        self.showAccessPasswordAlertView(showOldPassword: false, showLockParameters: false, actionHandler: { (action: UIAlertAction) in
                            if let textFields = self._alertController?.textFields {
                                let passwordField = textFields[0]
                                if passwordField.text!.count != 0 {
                                    tag?.readTID(length: 8, password: PassiveReader.hexStringToByte(hex: passwordField.text!))
                                } else {
                                    tag?.readTID(length: 8, password: nil)
                                }
                            }
                        })
                    } else {
                        self.appendTextToBuffer(text: "Command unavailable on this tag", color: .red)
                        self.enableStartButton(enabled: true)
                    }
                } else {
                    self.appendTextToBuffer(text: "Please do inventory first!", color: .red)
                    self.enableStartButton(enabled: true)
                }
            },
            
            {
                // Write ID for first tag
                let ID = [
                    UInt8(0x00),
                    0x01,
                    0x02,
                    0x03,
                    0x04,
                    0x05,
                    0x06,
                    0x07,
                    0x08,
                    0x09,
                    0x0A,
                    0x0B,
                    0x0C,
                    0x0D,
                    0x0E,
                    0x0F
                ]
                
                if self._tags.count != 0 {
                    if let tag = self._tags[self._selectedTag] as? EPC_tag? {
                        tag?.writeID(ID: ID, NSI: 0)
                    } else {
                        self.appendTextToBuffer(text: "Command unavailable on this tag", color: .red)
                        self.enableStartButton(enabled: true)
                    }
                } else {
                    self.appendTextToBuffer(text: "Please do inventory first!", color: .red)
                    self.enableStartButton(enabled: true)
                }
            },
            
            {
                // Write kill password for selected tag
                if self._tags.count != 0 {
                    if let tag = self._tags[self._selectedTag] as? EPC_tag? {
                        //tag?.writeAccessPassword(accessPassword: , password: )
                        self.showAccessPasswordAlertView(showOldPassword: true, showLockParameters: false, actionHandler: { (action: UIAlertAction) in
                            if let textFields = self._alertController?.textFields {
                                let killPassword = textFields[1]
                                let accessPassword = textFields[0]
                                
                                if killPassword.text!.count == 0 {
                                    self.appendTextToBuffer(text: "Kill password is mandatory!", color: .red)
                                    self.enableStartButton(enabled: true)
                                    return
                                }

                                if accessPassword.text!.count != 0 {
                                    tag?.writeKillPassword(kill_password: PassiveReader.hexStringToByte(hex: killPassword.text!), password: PassiveReader.hexStringToByte(hex: accessPassword.text!))
                                } else {
                                    tag?.writeKillPassword(kill_password: PassiveReader.hexStringToByte(hex: killPassword.text!), password: nil)
                                }
                            }
                        })
                    } else {
                        self.appendTextToBuffer(text: "Command is valid only on EPC tags!", color: .red)
                        self.enableStartButton(enabled: true)
                    }
                } else {
                    self.appendTextToBuffer(text: "Please do inventory first!", color: .red)
                    self.enableStartButton(enabled: true)
                }
            },
            
            {
                // Kill selected tag
                if self._tags.count != 0 {
                    if let tag = self._tags[self._selectedTag] as? EPC_tag? {
                        //tag?.kill(password: [UInt8(0), 0, 0, 0])
                        self.showAccessPasswordAlertView(showOldPassword: false, showLockParameters: false, actionHandler: { (action: UIAlertAction) in
                            if let textFields = self._alertController?.textFields {
                                let passwordField = textFields[0]
                                if passwordField.text!.count != 0 {
                                    tag?.kill(password: PassiveReader.hexStringToByte(hex: passwordField.text!))
                                } else {
                                    tag?.kill(password: [UInt8(0), 0, 0, 0])
                                }
                            }
                        })
                    } else {
                        self.appendTextToBuffer(text: "Command unavailable on this tag", color: .red)
                        self.enableStartButton(enabled: true)
                    }
                } else {
                    self.appendTextToBuffer(text: "Please do inventory first!", color: .red)
                    self.enableStartButton(enabled: true)
                }
            }
        ]
        
        _lastCommandType = .customCommand
        enableStartButton(enabled: false)
        commandMap[method]()
    }
    
    @objc func repeatingCommandsTick(timer: Timer!) {
        if _connected && _inExtendedView == false && btnStartOperation.isEnabled == true && _currentInitialOperation >= _maxInitialOperations {
            if _repeatingCommandIndex >= 3 {
                _repeatingCommandIndex = 0
            }
            
            _lastCommandType = .repeatingCommand
            enableStartButton(enabled: false)
            
            if _repeatingCommandIndex == 0 {
                _api.getBatteryLevel()
                _lastRepeatingCommand = AbstractReaderListener.GET_BATTERY_LEVEL_COMMAND
            } else if _repeatingCommandIndex == 1 {
                _api.getBatteryStatus()
                _lastRepeatingCommand = AbstractReaderListener.GET_BATTERY_STATUS_COMMAND
            } else if _repeatingCommandIndex == 2 {
                _api.testAvailability()
                _lastRepeatingCommand = AbstractReaderListener.TEST_AVAILABILITY_COMMAND
            }
            
            _repeatingCommandIndex = _repeatingCommandIndex + 1
        }
    }
    
    // GUI Code
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tags.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExtendedTagTestsTagCell = tableView.dequeueReusableCell(withIdentifier: "ExtendedTagTestsTagCell") as! ExtendedTagTestsTagCell
        if let tag = _tags[indexPath.row]! as? EPC_tag {
            cell.lblTagID.text = _tags[indexPath.row]!.toString() + " RSSI: " + String(tag.getRSSI())
        } else {
            cell.lblTagID.text = _tags[indexPath.row]!.toString()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _selectedTag = indexPath.row
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnConnectPressed(_ sender: Any) {
        if let deviceName = deviceName {
            if _connected == false {
                reset()
                _api.connect(readerAddress: deviceName)
            } else {
                _api.disconnect()
            }
        }
    }
    
    @IBAction func btnStartOperationPressed(_ sender: Any) {
        callCustomOperation(method: _selectedRow)
    }
    
    //
    func enableStartButton(enabled: Bool) {
        btnStartOperation.isEnabled = enabled
        if !enabled {
            btnStartOperation.setTitleColor(.black, for: .normal)
            btnStartOperation.setTitleColor(.black, for: .selected)
        } else {
            btnStartOperation.setTitleColor(.white, for: .normal)
            btnStartOperation.setTitleColor(.gray, for: .selected)
        }
    }
    
    //
    func scrollDown(textView: UITextView) {
        let range = NSRange(location: textView.text.count - 1, length: 0)
        textView.scrollRangeToVisible(range)
    }
    
    func appendInitialCommandsBuffer(text: String, color: UIColor) {
        initialCommandsBuffer.append(NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor: color]))
        txtInitialCommands.attributedText = initialCommandsBuffer.copy() as! NSAttributedString
        scrollDown(textView: txtInitialCommands)
    }
    
    func appendCustomCommandsBuffer(text: String, color: UIColor) {
        customCommandsBuffer.append(NSAttributedString(string: text, attributes: [NSAttributedStringKey.foregroundColor: color]))
        txtCustomCommands.attributedText = customCommandsBuffer.copy() as! NSAttributedString
        scrollDown(textView: txtCustomCommands)
    }
    
    func appendTextToBuffer(text: String, error: Int) {
        if _lastCommandType == .repeatingCommand {
            return
        }
        
        if _lastCommandType == .initialCommands {
            appendInitialCommandsBuffer(text: text + "\r\n", color: (error == 0 ? .white : .red))
        } else if _lastCommandType == .customCommand {
            appendCustomCommandsBuffer(text: text + "\r\n", color: (error == 0 ? .white : .red))
        }
    }
    
    func appendTextToBuffer(text: String, color: UIColor) {
        if _lastCommandType == .initialCommands {
            appendInitialCommandsBuffer(text: text + "\r\n", color: color)
        } else { /* if _lastCommandType == .customCommand { */
            appendCustomCommandsBuffer(text: text + "\r\n", color: color)
        }
    }
    
    func appendTextToBuffer(text: String, color: UIColor, command: Int) {
        if command == _lastRepeatingCommand {
            return
        }
        
        appendTextToBuffer(text: text, color: color)
    }
    
    // UIPickerView
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if pickerView == pikSelectCommand {
            var pickerLabel: UILabel? = (view as? UILabel)
            if pickerLabel == nil {
                pickerLabel = UILabel()
                pickerLabel?.font = UIFont(name: "System", size: 10)
                pickerLabel?.textAlignment = .left
            }
            
            pickerLabel?.text = operations[row]
            pickerLabel?.textColor = .black
            return pickerLabel!
        } else {
            var pickerLabel: UILabel? = (view as? UILabel)
            if pickerLabel == nil {
                pickerLabel = UILabel()
                pickerLabel?.font = UIFont(name: "System", size: 10)
                pickerLabel?.textAlignment = .left
            }
            
            pickerLabel?.text = lockoperationslabels[row]
            pickerLabel?.textColor = .black
            return pickerLabel!
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pikSelectCommand {
            return operations[row]
        } else {
            return "Kill op";
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pikSelectCommand {
            return operations.count
        } else {
            return lockoperationslabels.count;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pikSelectCommand {
            _selectedRow = row
        } else {
            _selectedLockOperation = row
        }
    }
    
    func updateBatteryLabel() {
        lblBatteryStatus.text = String(format: "Available: %@ Battery status: %d Level: %0.2f", (_deviceAvailable ? "yes": "No"), _batteryStatus, _batteryLevel)
    }
    
    //
    func pushCommands() {
        if _currentInitialOperation < _maxInitialOperations {
            callNextInitialOperation()
        }
    }
    
    // AbstractResponseListenerProtocol implementation
    func writeIDevent(tagID: [UInt8]?, error: Int) {
        enableStartButton(enabled: true)
        appendTextToBuffer(text: "writeIDevent tag: " + PassiveReader.bytesToString(bytes: tagID) + ", error: " + String(error), error: error)
    }
    
    func writePasswordEvent(tagID: [UInt8]?, error: Int) {
        enableStartButton(enabled: true)
        appendTextToBuffer(text: "writePasswordEvent tag: " + PassiveReader.bytesToString(bytes: tagID) + ", error: " + String(error), error: error)
    }
    
    func readTIDevent(tagID: [UInt8]?, error: Int, TID: [UInt8]?) {
        enableStartButton(enabled: true)
        appendTextToBuffer(text: "readTIDevent tag: " + PassiveReader.bytesToString(bytes: tagID) + ", error: " + String(error) + ", TID: " + PassiveReader.bytesToString(bytes: TID), error: error)
    }
    
    func readEvent(tagID: [UInt8]?, error: Int, data: [UInt8]?) {
        enableStartButton(enabled: true)
        appendTextToBuffer(text: "readEvent tag: " + PassiveReader.bytesToString(bytes: tagID) + ", error: " + String(error) + ", Data: " + PassiveReader.bytesToString(bytes: data), error: error)
    }
    
    func writeEvent(tagID: [UInt8]?, error: Int) {
        enableStartButton(enabled: true)
        appendTextToBuffer(text: "writeEvent tag: " + PassiveReader.bytesToString(bytes: tagID) + ", error: " + String(error), error: error)
    }
    
    func lockEvent(tagID: [UInt8]?, error: Int) {
        enableStartButton(enabled: true)
        appendTextToBuffer(text: "lockEvent tag: " + PassiveReader.bytesToString(bytes: tagID) + ", error: " + String(error), error: error)
    }
    
    func killEvent(tagID: [UInt8]?, error: Int) {
        enableStartButton(enabled: true)
        appendTextToBuffer(text: "killEvent tag: " + PassiveReader.bytesToString(bytes: tagID) + ", error: " + String(error), error: error)
    }
    
    // AbstractInventoryListenerProtocol implementation
    func inventoryEvent(tag: Tag) {
        enableStartButton(enabled: true)
        _tags.append(tag)
        if let tag = self._tags[self._selectedTag] as? EPC_tag {
            appendTextToBuffer(text: "inventoryEvent tag: " + tag.toString() + " RSSI: " + String(tag.getRSSI()), color: .white)
        } else {
            appendTextToBuffer(text: "inventoryEvent tag: " + tag.toString(), color: .white)
        }
        
        tblTags.reloadData()
        _selectedTag = 0
    }
    
    // AbstractReaderListenerProtocol implementation
    func connectionFailureEvent(error: Int) {
        _connected = false
        let alertView = UIAlertView(title: "Connection failed!", message: "error", delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
    
    func connectionSuccessEvent() {
        enableStartButton(enabled: true)
        _connected = true
        btnConnect.setTitle("DISCONNECT", for: .normal)
        pushCommands()
    }
    
    func disconnectionEvent() {
        enableStartButton(enabled: false)
        _connected = false
        btnConnect.setTitle("CONNECT", for: .normal)
    }
    
    func availabilityEvent(available: Bool) {
        _deviceAvailable = available
        updateBatteryLabel()
        appendTextToBuffer(text: "availabilityEvent " + (available ? "yes": "no"), color: .white, command: AbstractReaderListener.TEST_AVAILABILITY_COMMAND)
    }
    
    func resultEvent(command: Int, error: Int) {
        enableStartButton(enabled: true)
        let errStr = (error == 0 ? "NO error": String(format: "Error %d", error))
        let result = String(format: "Result command = %d %@", command, errStr)
        appendTextToBuffer(text: result, error: error)
        
        DispatchQueue.main.async {
            self.pushCommands()
        }
    }
    
    func batteryStatusEvent(status: Int) {
        _batteryStatus = status
        updateBatteryLabel()
    }
    
    func firmwareVersionEvent(major: Int, minor: Int) {
        let firmwareVersion = String(format: "Firmware-version = %d.%d", major, minor)
        appendTextToBuffer(text: firmwareVersion, color: .white)
    }
    
    func shutdownTimeEvent(time: Int) {
        let shutdownTime = String(format: "Shutdown-time %d", time)
        appendTextToBuffer(text: shutdownTime, color: .white)
    }
    
    func RFpowerEvent(level: Int, mode: Int) {
        let rfPowerEvent = String(format: "RF-power: level = %d, mode = %d", level, mode)
        appendTextToBuffer(text: rfPowerEvent, color: .white)
    }
    
    func batteryLevelEvent(level: Float) {
        _batteryLevel = level
        updateBatteryLabel()
    }
    
    func RFforISO15693tunnelEvent(delay: Int, timeout: Int) {
        let rfForIsoEvent = String(format: "RFforISO15693tunnel: delay = %d, timeout = %d", delay, timeout)
        appendTextToBuffer(text: rfForIsoEvent, color: .white)
    }
    
    func ISO15693optionBitsEvent(option_bits: Int) {
        let ISO15693optionBits = String(format: "ISO15693optionBits: bits = %d", option_bits)
        appendTextToBuffer(text: ISO15693optionBits, color: .white)
    }
    
    func ISO15693extensionFlagEvent(flag: Bool, permanent: Bool) {
        let ISO15693extensionFlag = String(format: "ISO15693extensionFlag: flag = %@ permanent = %@", flag.description, permanent.description)
        appendTextToBuffer(text: ISO15693extensionFlag, color: .white)
    }
    
    func ISO15693bitrateEvent(bitrate: Int, permanent: Bool) {
        let ISO15693bitrate = String(format: "ISO15693bitrate: bitrate = %d permanent = %@", bitrate, permanent.description)
        appendTextToBuffer(text: ISO15693bitrate, color: .white)
    }
    
    func EPCfrequencyEvent(frequency: Int) {
        let EPCfrequency = String(format: "EPCfrequency: frequency = %d", frequency)
        appendTextToBuffer(text: EPCfrequency, color: .white)
    }
    
    func tunnelEvent(data: [UInt8]?) {
        let tunnelEvent = String(format: "tunnelEvent: data = %s", data!)
        appendTextToBuffer(text: tunnelEvent, color: .white)
    }
    
    func showAccessPasswordAlertView(showOldPassword: Bool, showLockParameters: Bool, actionHandler: ((UIAlertAction) -> Swift.Void)?) {
        _alertController = UIAlertController(title: "Password", message: "Enter access password", preferredStyle: .alert)
        _alertController!.addTextField { (field: UITextField) in
            if showOldPassword {
                field.placeholder = "old password"
            } else {
                field.placeholder = "password"
            }
            field.textColor = .blue
            field.clearButtonMode = .whileEditing
            field.borderStyle = .roundedRect
        }
        
        if showOldPassword {
            _alertController!.addTextField { (field: UITextField) in
                field.placeholder = "new password"
                field.textColor = .blue
                field.clearButtonMode = .whileEditing
                field.borderStyle = .roundedRect
            }
        }
        
        _selectedLockOperation = 0
        if showLockParameters {
            var pik: UIPickerView
            
            let vc = UIViewController()
            vc.preferredContentSize = CGSize(width: 250, height: 300)
            pik = UIPickerView()
            pik.delegate = self
            pik.dataSource = self
            pik.frame = CGRect(x: 0, y: 0, width: _alertController!.view.frame.width, height: 300)
            vc.view.addSubview(pik)
            _alertController?.setValue(vc, forKey: "contentViewController")
        }
        _alertController!.addAction(UIAlertAction(title: "OK", style: .default, handler: actionHandler))
        _alertController!.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler:  { (action: UIAlertAction) in
            self.enableStartButton(enabled: true)
        }))
        present(_alertController!, animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let nextVC = segue.destination as? ExtendedTagTestsViewController {
            nextVC.deviceDetailVC = self
        }
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        _timer.invalidate()
        _api.disconnect()
        
        _eventsForwarder.readerListenerDelegate = nil
        _eventsForwarder.inventoryListenerDelegate = nil
        _eventsForwarder.responseListenerDelegate = nil
    }
    
    @IBAction func unwindToDeviceDetailViewController(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        _eventsForwarder.readerListenerDelegate = self
        _eventsForwarder.inventoryListenerDelegate = self
        _eventsForwarder.responseListenerDelegate = self
        
        _inExtendedView = false
        if _connected {
            enableStartButton(enabled: true)
        }
    }
}
