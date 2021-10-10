/*
 * The MIT License
 *
 * Copyright 2017-2021 Tertium Technology.
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

class DeviceDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, AbstractReaderListenerProtocol, AbstractResponseListenerProtocol, AbstractInventoryListenerProtocol, AbstractZhagaListenerProtocol {

    @IBOutlet weak var lblDevice: UILabel!
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var txtInitialCommands: UITextView!
    @IBOutlet weak var tblTags: UITableView!
    @IBOutlet weak var pikSelectCommand: UIPickerView!
    @IBOutlet weak var pikSelectCategory: UIPickerView!
    @IBOutlet weak var btnStartOperation: UIButton!
    @IBOutlet weak var txtCustomCommands: UITextView!
    @IBOutlet weak var lblBatteryStatus: UILabel!
    
    let categoriesLabels = [
                      "  Common" ,
                      "  BLE",
                      "  Memory",
                      "  Tertium",
                      "  Tag",
                      "  Zhaga",
    ]
    
    let commonOperationsLabels = [
                        "  Get Security Level",
                        "  Set Security Level: NONE",
                        "  Set Security Level: LEGACY",
                        "  Set Security Level: LESC",
                        "  Get Name",
                        "  Set Name",
                        "  Default BLE Configuration",
    ]
    
    let BLEOperationsLabels = [
                         "  Set Advertising Interval",
                         "  Set BLE Power",
                         "  Set Connection Interval",
                         "  Set Slave Latency",
                         "  Set Supervision Timeout",
                         "  Get Advertising Interval",
                         "  Get BLE Power",
                         "  Get Connection Interval",
                         "  Get Connection Interval and MTU",
                         "  Get MAC Address",
                         "  Get Slave Latency",
                         "  Get Supervision Timeout",
                         "  Get BLE Firmware Version",
    ]
    
    let memoryOperationsLabels = [
                        "  Read User Memory (0)",
                        "  Read User Memory (1)",
                        "  Write User Memory"
    ]
    
    let tertiumOperationsLabels = [
                             "  Reset",
                             "  Default Setup",
                             "  IsHF",
                             "  IsUHF",
                             "  Test Availability",
                             "  Get Battery Status",
                             "  Get Firmware Version",
                             "  Get Shutdown Time",
                             "  Get RF Power",
                             "  Do Inventory",
                             "  Clear inventory",
                             "  Get Battery Level",
                             "  Get ISO15693 Option Bits (Only HF)",
                             "  Get ISO15693 Extension Flag(Only HF)",
                             "  Get ISO15693 Bitrate(Only HF)",
                             "  Get EPC Frequency (only UHF)",
                             "  Sound",
                             "  Light",
                             "  Stop Light",
                             "  Set Shutdown Time (300)",
                             "  Set Inventory Parameters",
                             "  Set RF Power",
                             "  Set ISO15693 Option Bits (Only HF)",
                             "  Set ISO15693 Extension Flag(Only HF)",
                             "  Set ISO15693 Bitrate(Only HF)",
                             "  Set EPC Frequency (only UHF)",
                             "  setScanOnInput",
                             "  setNormalScan",
                             "  ISO15693tunnel w/encrypted",
    ]
    
    let tagOperationsLabels = [
                             "  Read/Write selected tag",
                             "  Lock selected tag",
                             "  Write access password",
                             "  Write kill password for selected tag",
                             "  Kill selected tag",
                             "  Read TID for selected tag",
                             "  Write ID for selected tag",
    ]
    
    let zhagaOperationsLabels = [
                            "  Reboot",
                            "  Off",
                            "  Get HMI Support",
                            "  Get Sound for Inventory",
                            "  Get Sound for Command",
                            "  Get Sound for Error",
                            "  Get Led for Inventory",
                            "  Get Led for Command",
                            "  Get Led for Error",
                            "  Get Vibration for Inventory",
                            "  Get Vibration for Command",
                            "  Get Vibration for Error",
                            "  Get Activated Button",
                            "  Get RF OnOff",
                            "  Get AutoOnOff",
                            "  Default Configuration",
                            "  GetRF",
                            "  SetRF",
                            "  SetHMI",
                            "  Set Sound for Inventory",
                            "  Set Sound for Command",
                            "  Set Sound for Error",
                            "  Set Led for Inventory",
                            "  Set Led for Command",
                            "  Set Led for Error",
                            "  Set Vibration for Inventory",
                            "  Set Vibration for Command",
                            "  Set Vibration for Error",
                            "  Activate Button",
                            "  Set RF OnOff",
                            "  Set Auto Off",
                            "  Transparent"
    ]
        
    let operationsUnused = [
                      "  Select Operation",
                      "  Get RF tunnel config(Ony HF)",
                      "  Set RF tunnel config(Ony HF)",
                      "  Start Tunnel",
                      "  setScanOnInput",
                      "  setNormalScan",
                      "  Extended tag tests",
                    ]
    
    /*
    let operations = ["  Select Operation",
                      "  Test Availability",
                      "  Sound",
                      "  Light",
                      "  Stop Light",
                      "  Set Shutdown Time (300)",
                      "  Get Shutdown Time",
                      "  Set RF Power",
                      "  Get RF Power",
                      "  Set ISO15693 Option Bits (Only HF)",
                      "  Get ISO15693 Option Bits (Only HF)",
                      "  Set ISO15693 Extension Flag(Only HF)",
                      "  Get ISO15693 Extension Flag(Only HF)",
                      "  Set ISO15693 Bitrate(Only HF)",
                      "  Get ISO15693 Bitrate(Only HF)",
                      "  Get RF tunnel config(Ony HF)",
                      "  Set RF tunnel config(Ony HF)",
                      "  Set EPC Frequency (only UHF)",
                      "  Get EPC Frequency (only UHF)",
                      "  Get Security Level",
                      "  Set Security Level: NONE",
                      "  Set Security Level: LEGACY",
                      "  Set Security Level: LESC",
                      "  Start Tunnel",
                      "  setScanOnInput",
                      "  setNormalScan",
                      "  Do Inventory",
                      "  Clear inventory",
                      "  Extended tag tests",
                      "  Write access password",
                      "  Read selected tag",
                      "  Write selected tag",
                      "  Lock selected tag",
                      "  Read TID for selected tag",
                      "  Write ID for selected tag",
                      "  Write kill password for selected tag",
                      "  Kill selected tag"
                    ]
    */
    
    let lockoperationslabels = [
                          "Memory write protected",
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
    
    var _operationCategoriesLabels: [[String]] = [];
    var _currentOperationsLabels: [String]  = [];
    
    //
    var _commonOperations: [() -> ()] = []
    var _bleOperations: [() -> ()] = []
    var _memoryOperations: [() -> ()] = []
    var _tertiumOperations: [() -> ()] = []
    var _tagOperations: [() -> ()] = []
    var _zhagaOperations: [() -> ()] = []
    
    var _opertions: [[() -> ()]] = []
    var _currentOperations: [() -> ()] = []
    
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
    private var _selectedCategoryRow: Int = 0
    private var _selectedCommandRow: Int = 0
    private var _selectedLockOperation: Int = 0
    private var _repeatingCommandIndex: Int = 0
    private var _lastCommandType: CommandType = .initialCommands
    private var _connected: Bool = false
    private var _inExtendedView: Bool = false
    private var _lastRepeatingCommand: Int = 0
    private var _alertController: UIAlertController?
    private var _customController: UIAlertController?
    private var _selectedTag: Int = 0
    
    private var _sentCommand: Bool = false
    
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
        InitOperationsArrays()
        
        //
        _font = UIFont(name: "Terminal", size: 10.0)
        
        //
        lblDevice.text = deviceName
        
        _timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(self.repeatingCommandsTick), userInfo: nil, repeats: true)
        _eventsForwarder.readerListenerDelegate = self
        _eventsForwarder.inventoryListenerDelegate = self
        _eventsForwarder.responseListenerDelegate = self
        _eventsForwarder.zhagaListenerDelegate = self
        _sentCommand = false
        
        //
        txtInitialCommands.layer.borderColor = UIColor.blue.cgColor
        txtInitialCommands.layer.borderWidth = 3.0
        txtCustomCommands.layer.borderColor = UIColor.blue.cgColor
        txtCustomCommands.layer.borderWidth = 3.0
        updateBatteryLabel()
        enableStartButton(enabled: false)
    }
    
    func InitOperationsArrays() {
        //
        _operationCategoriesLabels = [
            commonOperationsLabels,
            BLEOperationsLabels,
            memoryOperationsLabels,
            tertiumOperationsLabels,
            tagOperationsLabels,
            zhagaOperationsLabels
        ]
        
        //
        _currentOperationsLabels = _operationCategoriesLabels[0];
        
        //
        _commonOperations = [
            {
                // Get Security level
                self._api.getSecurityLevel()
            },
            
            {
                // Set Security level: NONE
                self._api.setSecurityLevel(level: 0)
            },

            {
                // Set Security level: LEGACY
                self._api.setSecurityLevel(level: 1)
            },

            {
                // Set Security level: LESC
                self._api.setSecurityLevel(level: 2)
            },
            
            {
                // Get Name
                self._api.getName()
            },
            
            {
                // Set Name
                self.showGenericStringAlertView(title: "Input name", message: "Set name") { UIAlertAction in
                    if let textFields = self._alertController?.textFields {
                        let nameField = textFields[0]
                        
                        if let text = nameField.text {
                            self._api.setName(device_name: text)
                        }
                    }
                }
            },
            
            {
                // Default BLE Configuration
                self._api.defaultBLEconfiguration(mode: 1, erase_bonding: true)
            },
        ]
        
        //
        _bleOperations = [
            {
                // Set Advertising Interval
                self._api.setAdvertisingInterval(interval: 250)
            },
            
            {
                // Set Ble Power
                self._api.setBLEpower(power: 7)
            },
            
            {
                // Set Connection Interval
                self._api.setConnectionInterval(min_interval: 15, max_interval: 30)
            },
            
            {
                // Set Slave Latency
                self._api.setSlaveLatency(latency: 1)
            },
            
            {
                // Set supervision timeout
                self._api.setSupervisionTimeout(timeout: 5000)
            },
            
            {
                // Get advertising interval
                self._api.getAdvertisingInterval()
            },
            
            {
                // Get BLE Power
                self._api.getBLEpower()
            },
            
            {
                // Get connection interval
                self._api.getConnectionInterval()
            },
            
            {
                // Get connection interval and MTU
                self._api.getConnectionIntervalAndMTU()
            },
            
            {
                // Get MAC Address
                self._api.getMACaddress()
            },

            {
                // Get Slave Latency
                self._api.getSlaveLatency()
            },

            {
                // Get Supervision Timeout
                self._api.getSupervisionTimeout()
            },

            {
                // Get BLE Firmware Version
                self._api.getBLEfirmwareVersion()
            },
        ]
        
        //
        _memoryOperations = [
            {
                // Read User Memory(0)
                self._api.readUserMemory(block: 0)
            },

            {
                // Read User Memory(1)
                self._api.readUserMemory(block: 1)
            },

            {
                // Write User Memory
                self.showWriteUserMemoryAlertView(actionHandler: { UIAlertAction in
                    if let textFields = self._alertController?.textFields {
                        let blockField = textFields[0]
                        let dataField = textFields[1]
                        let block = Int(blockField.text!) ?? -1
                        if block == -1 {
                            return
                        }
                        self._api.writeUserMemory(block: block, data: PassiveReader.hexStringToByte(hex: dataField.text!))
                    }
                })
            },
        ]
        
        //
        _tertiumOperations = [
            {
                // Reset
                self._api.reset(bootloader: true)
            },
            
            {
                // Default setup
                self._api.defaultSetup()
            },
            
            {
                // IsHF
                if self._api.isHF() == true {
                    self.appendTextToBuffer(text: "IsHF () == true", color: .yellow)
                } else {
                    self.appendTextToBuffer(text: "IsHF () == false", color: .yellow)
                }

                self.enableStartButton(enabled: true)
            },
            
            {
                // IsUHF
                if self._api.isUHF() == true {
                    self.appendTextToBuffer(text: "IsUHF () == true", color: .yellow)
                } else {
                    self.appendTextToBuffer(text: "IsUHF () == false", color: .yellow)
                }

                self.enableStartButton(enabled: true)
            },

            {
                // testAvailability
                self._api.testAvailability()
            },
            
            {
                // getBatteryStatus
                self._api.getBatteryStatus()
            },

            {
                // getFirmwareVersion
                self._api.getFirmwareVersion()
            },

            {
                // getShutdownTime
                self._api.getShutdownTime()
            },

            {
                // getRFpower
                self._api.getRFpower()
            },

            {
                // Do Inventory
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
                self._selectedTag = 0
                
                // IMPORTANT! force no command sent, inventory doesn't notify back!
                self.enableStartButton(enabled: true)
                self.appendTextToBuffer(text: "Tag list cleared", color: .white)
            },

            {
                // getBatteryLevel
                self._api.getBatteryLevel()
            },

            {
                // getISO15693optionBits
                self._api.getISO15693optionBits()
            },

            {
                // getISO15693extensionFlag
                self._api.getISO15693extensionFlag()
            },

            {
                // getISO15693bitrate
                self._api.getISO15693bitrate()
            },
            
            {
                // Get EPC Frequency
                self._api.getEPCfrequency()
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
                // Set Inventory Parameters
                self._api.setInventoryParameters(feedback: PassiveReader.FEEDBACK_SOUND_AND_LIGHT, timeout: 1000, interval: 1000)
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
                // SetISO15693optionBits
                self._api.setISO15693optionBits(optionBits: PassiveReader.ISO15693_OPTION_BITS_NONE)
            },

            {
                // SetISO15693extensionFlag
                self._api.setISO15693extensionFlag(flag: true, permanent: false)
            },

            {
                // SetISO15693bitrate
                self._api.setISO15693bitrate(bitrate: PassiveReader.ISO15693_HIGH_BITRATE, permanent: false)
            },

            {
                // SetEPCfrequency
                self._api.setEPCfrequency(frequency: PassiveReader.RF_CARRIER_866_9_MHZ)
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
                // TODO: ISO15693tunnel
                self.showTunnellingAlertView(encrypted: false, actionHandler: { (action: UIAlertAction) in
                    if let textFields = self._customController?.textFields {
                        let commandField = textFields[0]
                        var flagField: UITextField?
                        
                        if (textFields.count > 1) {
                            flagField = textFields[1]
                        }
                        
                        if (commandField.text == nil || commandField.text?.count == 0) {
                            self.appendTextToBuffer(text: "Comamand is mandatory!", color: UIColor.red)
                            self.enableStartButton(enabled: true)
                            self._inExtendedView = false
                            return;
                        }
                        
                        if (flagField != nil) {
                            if (flagField!.text == nil || flagField!.text?.count == 0) {
                                self.appendTextToBuffer(text: "Flag is mandatory!", color: UIColor.red)
                                self.enableStartButton(enabled: true)
                                self._inExtendedView = false
                                return;
                            }
                            self._inExtendedView = false
                            self._api.ISO15693encryptedTunnel(flag: PassiveReader.hexStringToByte(hex: flagField!.text!)[0], command: PassiveReader.hexStringToByte(hex: commandField.text!))
                        } else {
                            self._inExtendedView = false
                            self._api.ISO15693tunnel(command: PassiveReader.hexStringToByte(hex: commandField.text!))
                        }
                    }
                })
            },
        ]
        
        //
        _tagOperations = [
            /*
            {
                // Read selected tag
                if self._tags.count != 0 {
                    if let tag = self._tags[self._selectedTag] as? ISO15693_tag? {
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
            */
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
            /*
            {
                // Write selected tag
                let date: Date = Date()
                let calendar = Calendar.current
                let minutes = calendar.component(.minute, from: date)
                
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
            */
            {
                // Lock selected tag
                if self._tags.count != 0 {
                    if let tag = self._tags[self._selectedTag] as? ISO15693_tag? {
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
            },
            
            {
                // Read TID for first tag
                if self._tags.count != 0 {
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
        ]
        
        //
        _zhagaOperations = [
            {
                // Reboot
                self._api.reboot()
            },

            {
                // Off
                self._api.off()
            },

            {
                // getHMIsupport
                self._api.getHMIsupport()
            },

            {
                // getSoundForInventory
                self._api.getSoundForInventory()
            },

            {
                // getSoundForCommand
                self._api.getSoundForCommand()
            },

            {
                // getSoundForError
                self._api.getSoundForError()
            },

            {
                // getLEDforInventory
                self._api.getLEDforInventory()
            },

            {
                // getLEDforCommand
                self._api.getLEDforCommand()
            },

            {
                // getLEDforError
                self._api.getLEDforError()
            },

            {
                // getVibrationForInventory
                self._api.getVibrationForInventory()
            },

            {
                // getVibrationForCommand
                self._api.getVibrationForCommand()
            },

            {
                // getVibrationForError
                self._api.getVibrationForError()
            },

            {
                // getActivatedButton
                self._api.getActivatedButton()
            },

            {
                // getRFonOff
                self._api.getRFonOff()
            },

            {
                // getAutoOff
                self._api.getAutoOff()
            },

            {
                // defaultConfiguration
                self._api.defaultConfiguration()
            },
            
            {
                // getRF
                self._api.getRF()
            },
            
            {
                // setRF
                self._api.setRF(RF_on: true)
            },
            
            {
                // setHMI
                self._api.setHMI(sound_frequency: 960, sound_on_time: 400, sound_off_time: 200, sound_repetition: 2,
                                 light_color: AbstractZhagaListener.LED_YELLOW, light_on_time: 200, light_off_time: 200, light_repetition: 3,
                                 vibration_on_time: 0, vibration_off_time: 0, int: 0)
            },
            
            {
                // setSoundForInventory
                self._api.setSoundForInventory(sound_frequency: 3000, sound_on_time: 50, sound_off_time: 40, sound_repetition: 3)
            },

            {
                // setSoundForCommand
                self._api.setSoundForCommand(sound_frequency: 2730, sound_on_time: 100, sound_off_time: 0, sound_repetition: 1)
            },

            {
                // setSoundForError
                self._api.setSoundForError(sound_frequency: 1000, sound_on_time: 400, sound_off_time: 0, sound_repetition: 1)
            },

            {
                // setLEDforInventory
                self._api.setLEDforInventory(light_color: AbstractZhagaListener.LED_GREEN, light_on_time: 50, light_off_time: 40, light_repetition: 3)
            },

            {
                // setLEDforCommand
                self._api.setLEDforCommand(light_color: AbstractZhagaListener.LED_YELLOW, light_on_time: 100, light_off_time: 0, light_repetition: 1)
            },

            {
                // setLEDforError
                self._api.setLEDforError(light_color: AbstractZhagaListener.LED_RED, light_on_time: 400, light_off_time: 0, light_repetition: 1)
            },

            {
                // setVibrationForInventory
                self._api.setVibrationForInventory(vibration_on_time: 50, vibration_off_time: 40, vibration_repetition: 3)
            },

            {
                // setVibrationForCommand
                self._api.setVibrationForCommand(vibration_on_time: 100, vibration_off_time: 0, vibration_repetition: 1)
            },

            {
                // setVibrationForError
                self._api.setVibrationForError(vibration_on_time: 400, vibration_off_time: 0, vibration_repetition: 1)
            },

            {
                // activateButton
                self._api.activateButton(activated_button: 1)
            },

            {
                // setRFonOff
                self._api.setRFonOff(RF_power: 100, RF_off_timeout: 3000, RF_on_preactivation: 0)
            },

            {
                // setAutoOff
                self._api.setAutoOff(OFF_time: 600)
            },
            
            {
                // Set Name
                self.showGenericStringAlertView(title: "Input command bytes", message: "Transparent command") { UIAlertAction in
                    if let textFields = self._alertController?.textFields {
                        let nameField = textFields[0]
                        
                        if let text = nameField.text {
                            self._api.transparent(command: PassiveReader.hexStringToByte(hex: text))
                        }
                    }
                }
            },
        ]
                
        //
        _opertions = [
            _commonOperations,
            _bleOperations,
            _memoryOperations,
            _tertiumOperations,
            _tagOperations,
            _zhagaOperations
        ]

        //
        _currentOperations = _opertions[0]
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
        _sentCommand = false
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
        
        if _sentCommand == true {
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
            _sentCommand = true
        }
    }
    
    func callCustomOperation(method: Int) {
        if btnStartOperation.isEnabled == false {
            return
        }
        
        /*
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
                // getRFforISO15693tunnel
                self._api.getRFforISO15693tunnel()
            },
            
            {
                // setRFforISO15693tunnel
                self._inExtendedView = true
                self.showTunnellingSettingsAlertView(actionHandler: { (action: UIAlertAction) in
                    if let textFields = self._customController?.textFields {
                        let delayField = textFields[0]
                        let timeOutField = textFields[1]

                        if (delayField.text == nil || delayField.text?.count == 0) {
                            self.appendTextToBuffer(text: "Delay is mandatory!", color: UIColor.red)
                            self.enableStartButton(enabled: true)
                            self._inExtendedView = false
                            return;
                        }
                        
                        if (timeOutField.text == nil || timeOutField.text?.count == 0) {
                            self.appendTextToBuffer(text: "timeout is mandatory!", color: UIColor.red)
                            self.enableStartButton(enabled: true)
                            self._inExtendedView = false
                            return;
                        }
                        
                        self._inExtendedView = false
                        self._api.setRFforISO15693tunnel(delay: Int(NSString(string: delayField.text!).intValue), timeout: Int(NSString(string: timeOutField.text!).intValue))
                    }
                })
            },
            
            {
                // SetEPCfrequency
                self._api.setEPCfrequency(frequency: PassiveReader.RF_CARRIER_866_9_MHZ)
            },
            
            {
                // GetEPCFrequency
                self._api.getEPCfrequency()
            },
            
            {
                // Get Security level
                self._api.getSecurityLevel()
            },
            
            {
                // Set Security level: NONE
                self._api.setSecurityLevel(level: 0)
            },

            {
                // Set Security level: LEGACY
                self._api.setSecurityLevel(level: 1)
            },

            {
                // Set Security level: LESC
                self._api.setSecurityLevel(level: 2)
            },

            {
                // Tunnel command
                self.showTunnellingAlertView(encrypted: false, actionHandler: { (action: UIAlertAction) in
                    if let textFields = self._customController?.textFields {
                        let commandField = textFields[0]
                        var flagField: UITextField?
                        
                        if (textFields.count > 1) {
                            flagField = textFields[1]
                        }
                        
                        if (commandField.text == nil || commandField.text?.count == 0) {
                            self.appendTextToBuffer(text: "Comamand is mandatory!", color: UIColor.red)
                            self.enableStartButton(enabled: true)
                            self._inExtendedView = false
                            return;
                        }
                        
                        if (flagField != nil) {
                            if (flagField!.text == nil || flagField!.text?.count == 0) {
                                self.appendTextToBuffer(text: "Flag is mandatory!", color: UIColor.red)
                                self.enableStartButton(enabled: true)
                                self._inExtendedView = false
                                return;
                            }
                            self._inExtendedView = false
                            self._api.ISO15693encryptedTunnel(flag: PassiveReader.hexStringToByte(hex: flagField!.text!)[0], command: PassiveReader.hexStringToByte(hex: commandField.text!))
                        } else {
                            self._inExtendedView = false
                            self._api.ISO15693tunnel(command: PassiveReader.hexStringToByte(hex: commandField.text!))
                        }
                    }
                })
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
                self._selectedTag = 0
                
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
                // Write selected tag
                let date: Date = Date()
                let calendar = Calendar.current
                let minutes = calendar.component(.minute, from: date)
                
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
         */
        
        _lastCommandType = .customCommand
        enableStartButton(enabled: false)
        _currentOperations[method]()
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
        
        if _tags.count == 0 {
            cell.lblTagID.text = "n/a";
            return cell;
        }
        
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
                _api.connect(reader_address: deviceName)
            } else {
                _api.disconnect()
            }
        }
    }
    
    @IBAction func btnStartOperationPressed(_ sender: Any) {
        callCustomOperation(method: _selectedCommandRow)
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
        initialCommandsBuffer.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: color]))
        txtInitialCommands.attributedText = initialCommandsBuffer.copy() as? NSAttributedString
        scrollDown(textView: txtInitialCommands)
    }
    
    func appendCustomCommandsBuffer(text: String, color: UIColor) {
        customCommandsBuffer.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: color]))
        txtCustomCommands.attributedText = customCommandsBuffer.copy() as? NSAttributedString
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
        } else if _lastCommandType == .repeatingCommand {
            // do nothing...
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
        if pickerView == pikSelectCategory {
            var pickerLabel: UILabel? = (view as? UILabel)
            if pickerLabel == nil {
                pickerLabel = UILabel()
                pickerLabel?.font = UIFont(name: "System", size: 10)
                pickerLabel?.textAlignment = .left
            }
            
            pickerLabel?.text = categoriesLabels[row]
            pickerLabel?.textColor = .black
            return pickerLabel!
        } else if pickerView == pikSelectCommand {
            var pickerLabel: UILabel? = (view as? UILabel)
            if pickerLabel == nil {
                pickerLabel = UILabel()
                pickerLabel?.font = UIFont(name: "System", size: 10)
                pickerLabel?.textAlignment = .left
            }
            
            pickerLabel?.text = _currentOperationsLabels[row]
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
        if pickerView == pikSelectCategory {
            return categoriesLabels[row]
        } else if pickerView == pikSelectCommand {
            return _currentOperationsLabels[row]
        } else {
            return "Kill op";
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pikSelectCategory {
            return categoriesLabels.count
        } else if pickerView == pikSelectCommand {
            return _currentOperationsLabels.count
        } else {
            return lockoperationslabels.count;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pikSelectCategory {
            _selectedCategoryRow = row;
            _currentOperationsLabels = _operationCategoriesLabels[row];
            _currentOperations = _opertions[row]
            _selectedCommandRow = 0
            pikSelectCommand.reloadAllComponents()
        } else if pickerView == pikSelectCommand {
            _selectedCommandRow = row
        } else {
            _selectedLockOperation = row
        }
    }
    
    func updateBatteryLabel() {
        lblBatteryStatus.text = String(format: "Available: %@ Battery status: %d Level: %0.2f", (_deviceAvailable ? "yes": "No"), _batteryStatus, _batteryLevel)
    }
    
    //
    func pushCommands() {
        // REMOVE
        //print("pushCommands()")
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
        if let tag = tag as? EPC_tag {
            appendTextToBuffer(text: "inventoryEvent tag: " + tag.toString() + " RSSI: " + String(tag.getRSSI()), color: .white)
        } else {
            appendTextToBuffer(text: "inventoryEvent tag: " + tag.toString(), color: .white)
        }
        tag.setTimeout(timeout: 2000)
        tblTags.reloadData()
        _selectedTag = 0
        tblTags.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
    }
    
    // AbstractReaderListenerProtocol implementation
    func connectionFailedEvent(error: Int) {
        let temp = String(format: "error %d", error)
        _connected = false
        let alertView = UIAlertView(title: "Connection failed!", message: temp, delegate: nil, cancelButtonTitle: "OK")
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

        //
        _tags.removeAll()
        tblTags.reloadData()
        _selectedTag = 0

        //
        _batteryLevel = 0
        _batteryStatus = 0
        _deviceAvailable = false
        updateBatteryLabel()
    }
    
    func batteryStatusEvent(status: Int) {
        _batteryStatus = status
        updateBatteryLabel()
        let batteryStatus = String(format: "Battery status %d", status)
        appendTextToBuffer(text: batteryStatus, color: .white, command: AbstractReaderListener.GET_BATTERY_STATUS_COMMAND)
    }
    
    func batteryLevelEvent(level: Float) {
        _batteryLevel = level
        updateBatteryLabel()
        let batteryLevel = String(format: "Battery level %f", level)
        appendTextToBuffer(text: batteryLevel, color: .white, command: AbstractReaderListener.GET_BATTERY_LEVEL_COMMAND)
    }
    
    func availabilityEvent(available: Bool) {
        _deviceAvailable = available
        updateBatteryLabel()
        appendTextToBuffer(text: "availabilityEvent " + (available ? "yes": "no"), color: .white, command: AbstractReaderListener.TEST_AVAILABILITY_COMMAND)
    }
    
    func resultEvent(command: Int, error: Int) {
        //
        //print("DeviceDetailViewer()::ResultEvent()")
        enableStartButton(enabled: true)
        let errStr = (error == 0 ? "NO error": String(format: "Error %d", error))
        let result = String(format: "Result command = %d %@", command, errStr)
        appendTextToBuffer(text: result, color: (error == 0 ? .white : .red))
        _sentCommand = false;
        DispatchQueue.main.async {
            self.pushCommands()
        }
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
        let tunnelEvent = String(format: "tunnelEvent: data = %@", PassiveReader.bytesToString(bytes: data!))
        appendTextToBuffer(text: tunnelEvent, color: .white)
        enableStartButton(enabled: true)
    }
    
    func securityLevelEvent(level: Int) {
        let securityEvent = String(format: "Security level: %d", level);
        appendTextToBuffer(text: securityEvent, color: .white)
        enableStartButton(enabled: true)
    }
    
    func showGenericStringAlertView(title: String, message: String, actionHandler: ((UIAlertAction) -> Swift.Void)?) {
        _alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        _alertController!.addTextField { (field: UITextField) in
            field.placeholder = "type something"
            field.textColor = .blue
            field.clearButtonMode = .whileEditing
            field.borderStyle = .roundedRect
        }
        
        _alertController!.addAction(UIAlertAction(title: "OK", style: .default, handler: actionHandler))
        _alertController!.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler:  { (action: UIAlertAction) in
            self.enableStartButton(enabled: true)
        }))
        present(_alertController!, animated: true, completion: nil)
    }
    
    func showWriteUserMemoryAlertView(actionHandler: ((UIAlertAction) -> Swift.Void)?) {
        _alertController = UIAlertController(title: "Enter block(0/1) and data", message: "Write user memory", preferredStyle: .alert)
        _alertController!.addTextField { (field: UITextField) in
            field.placeholder = "block"
            field.textColor = .blue
            field.clearButtonMode = .whileEditing
            field.borderStyle = .roundedRect
        }
        
        _alertController!.addTextField { (field: UITextField) in
            field.placeholder = "data"
            field.textColor = .blue
            field.clearButtonMode = .whileEditing
            field.borderStyle = .roundedRect
        }

        _alertController!.addAction(UIAlertAction(title: "OK", style: .default, handler: actionHandler))
        _alertController!.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler:  { (action: UIAlertAction) in
            self.enableStartButton(enabled: true)
        }))
        present(_alertController!, animated: true, completion: nil)
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
    
    func showTunnellingSettingsAlertView(actionHandler: ((UIAlertAction) -> Swift.Void)?) {
        _customController = UIAlertController(title: "Tunnelling", message: "Enter tunneling parameter", preferredStyle: .alert)
        _customController!.addTextField { (field: UITextField) in
            field.placeholder = "delay"
            field.textColor = .blue
            field.clearButtonMode = .whileEditing
            field.borderStyle = .roundedRect
        }
        
        _customController!.addTextField { (field: UITextField) in
            field.placeholder = "timeout"
            field.textColor = .blue
            field.clearButtonMode = .whileEditing
            field.borderStyle = .roundedRect
        }
        
        _customController!.addAction(UIAlertAction(title: "OK", style: .default, handler: actionHandler))
        _customController!.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (action: UIAlertAction) in
            self.enableStartButton(enabled: true)
        }))
        present(_customController!, animated: true, completion: nil)
    }

    func showTunnellingAlertView(encrypted: Bool, actionHandler: ((UIAlertAction) -> Swift.Void)?) {
        if(encrypted == true) {
            _customController = UIAlertController(title: "Tunnelling", message: "Enter tunnel command (encrypted)", preferredStyle: .alert)
        } else {
            _customController = UIAlertController(title: "Tunnelling", message: "Enter tunnel command (not encrypted)", preferredStyle: .alert)
        }
        
        _customController!.addTextField { (field: UITextField) in
            field.placeholder = "command"
            field.textColor = .blue
            field.clearButtonMode = .whileEditing
            field.borderStyle = .roundedRect
        }
        
        if (encrypted == true) {
            _customController!.addTextField { (field: UITextField) in
                field.placeholder = "flag"
                field.textColor = .blue
                field.clearButtonMode = .whileEditing
                field.borderStyle = .roundedRect
            }
            let action = UIAlertAction(title: "UNENCRYPTED", style: .default, handler: { (action: UIAlertAction) in
                self.showTunnellingAlertView(encrypted: false, actionHandler: actionHandler)
            })
            _customController!.addAction(action)
        } else {
            let action = UIAlertAction(title: "ENCRYPTED", style: .default, handler: { (action: UIAlertAction) in
                self.showTunnellingAlertView(encrypted: true, actionHandler: actionHandler)
            })
            _customController!.addAction(action)
        }
        
        _customController!.addAction(UIAlertAction(title: "OK", style: .default, handler: actionHandler))
        _customController!.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler:  { (action: UIAlertAction) in
            self.enableStartButton(enabled: true)
        }))
        present(_customController!, animated: true, completion: nil)
    }
    
    // TOOD: implement new method
    func nameEvent(device_name: String) {
        let name = String(format: "Name: %@", device_name)
        appendTextToBuffer(text: name, color: .white)
    }
    
    func advertisingIntervalEvent(advertising_interval: Int) {
        let temp = String(format: "Advertising interval: %d", advertising_interval)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func BLEpowerEvent(BLE_power: Int) {
        let temp = String(format: "BLE Power: %d", BLE_power)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func connectionIntervalEvent(min_interval: Float, max_interval: Float) {
        let temp = String(format: "Connection intervals: min %f max %f", min_interval, max_interval)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func connectionIntervalAndMTUevent(connection_interval: Float, MTU: Int) {
        let temp = String(format: "Connection and mtu: connection %f MTU %d", connection_interval, MTU)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func MACaddressEvent(MAC_address: [UInt8]?) {
        let temp = String(format: "MAC Address: %@", PassiveReader.bytesToString(bytes: MAC_address!))
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func slaveLatencyEvent(slave_latency: Int) {
        let temp = String(format: "Slave latency: %d", slave_latency)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func supervisionTimeoutEvent(supervision_timeout: Int) {
        let temp = String(format: "Supervision timeout: %d", supervision_timeout)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func BLEfirmwareVersionEvent(major: Int, minor: Int) {
        let temp = String(format: "Ble firmware version: %d.%d", major, minor)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func userMemoryEvent(data_block: [UInt8]?) {
        let temp = String(format: "User memory event: %@", PassiveReader.bytesToString(bytes: data_block!))
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func disconnectionSuccessEvent() {
        appendTextToBuffer(text: "Disconnection successfull", color: .white)
    }
    
    // cazzo
    func buttonEvent(button: Int, time: Int) {
        let temp = String(format: "button: %d time: %d\r\n", button, time)
        appendCustomCommandsBuffer(text: temp, color: .green)
    }
    
    func deviceEventEvent(event_number: Int, event_code: Int) {
        let temp = String(format: "DeviceEvent: %d eventCode: %d\r\n", event_number, event_code)
        appendCustomCommandsBuffer(text: temp, color: .green)
    }
    
    func HMIevent(LED_color: Int, sound_vibration: Int, button_number: Int) {
        let temp = String(format: "LEDColor: %d Sound Vibration: %d Button Number: %d", LED_color, sound_vibration, button_number)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func soundForInventoryEvent(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int) {
        let temp = String(format: "sound_frequency: %d sound_on_time: %d sound_off_time: %d sound_repetition: %d", sound_frequency, sound_on_time, sound_off_time, sound_repetition)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func soundForCommandEvent(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int) {
        let temp = String(format: "sound_frequency: %d sound_on_time: %d sound_off_time: %d sound_repetition: %d", sound_frequency, sound_on_time, sound_off_time, sound_repetition)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func soundForErrorEvent(sound_frequency: Int, sound_on_time: Int, sound_off_time: Int, sound_repetition: Int) {
        let temp = String(format: "sound_frequency: %d sound_on_time: %d sound_off_time: %d sound_repetition: %d", sound_frequency, sound_on_time, sound_off_time, sound_repetition)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func LEDforInventoryEvent(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int) {
        let temp = String(format: "light_color: %d light_on_time: %d light_off_time: %d light_repetition: %d", light_color, light_on_time, light_off_time, light_repetition)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func LEDforCommandEvent(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int) {
        let temp = String(format: "light_color: %d light_on_time: %d light_off_time: %d light_repetition: %d", light_color, light_on_time, light_off_time, light_repetition)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func LEDforErrorEvent(light_color: Int, light_on_time: Int, light_off_time: Int, light_repetition: Int) {
        let temp = String(format: "light_color: %d light_on_time: %d light_off_time: %d light_repetition: %d", light_color, light_on_time, light_off_time, light_repetition)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func vibrationForInventoryEvent(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int) {
        let temp = String(format: "vibration_on_time: %d vibration_off_time: %d vibration_repetition: %d", vibration_on_time, vibration_off_time, vibration_repetition)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func vibrationForCommandEvent(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int) {
        let temp = String(format: "vibration_on_time: %d vibration_off_time: %d vibration_repetition: %d", vibration_on_time, vibration_off_time, vibration_repetition)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func vibrationForErrorEvent(vibration_on_time: Int, vibration_off_time: Int, vibration_repetition: Int) {
        let temp = String(format: "vibration_on_time: %d vibration_off_time: %d vibration_repetition: %d", vibration_on_time, vibration_off_time, vibration_repetition)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func activatedButtonEvent(activated_button: Int) {
        let temp = String(format: "activated_button: %d", activated_button)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func RFonOffEvent(RF_power: Int, RF_off_timeout: Int, RF_on_preactivation: Int) {
        let temp = String(format: "RF_power: %d RF_off_timeout: %d RF_on_preactivation: %d", RF_power, RF_off_timeout, RF_on_preactivation)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func autoOffEvent(OFF_time: Int) {
        let temp = String(format: "OFF_time: %d", OFF_time)
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func transparentEvent(answer: [UInt8]?) {
        let temp = String(format: "transparentEvent: %@", PassiveReader.bytesToString(bytes: answer!))
        appendTextToBuffer(text: temp, color: .white)
    }
    
    func RFevent(RF_on: Bool) {
        let temp = String(format: "RF_on: %@", RF_on ? "yes" : "no")
        appendTextToBuffer(text: temp, color: .white)
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
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
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
