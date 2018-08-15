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

class ExtendedTagTestsWriteViewController: UIViewController {
    @IBOutlet weak var btnStartOperation: UIButton!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtData: UITextView!
    @IBOutlet weak var txtPassword: UITextField!
    
    var _mainVC: ExtendedTagTestsViewController?
    private let _api = PassiveReader.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        _mainVC?.btnStartOperationWrite = btnStartOperation
        txtData.autocapitalizationType = .allCharacters
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hexStringToData(string: String) -> [UInt8] {
        var array = [UInt8](repeating: 0, count: string.count / 2)
        
        for i in 0..<string.count / 2 {
            array[i] = UInt8(PassiveReader.hexToByte(hex: PassiveReader.getStringSubString(str: string, start: i*2, end: i*2+2)))
        }
        
        return array;
    }
    
    func isValidChar(char: Character) -> Bool {
        var asciiCode: UInt32?
        
        asciiCode = String(char).unicodeScalars.filter{$0.isASCII}.first?.value
        if let asciiCode = asciiCode {
            if asciiCode >= 48 && asciiCode <= 57 {
                return true;
            }
            
            if asciiCode >= 65 && asciiCode <= 70 {
                return true;
            }
            
            if asciiCode >= 97 && asciiCode <= 102 {
                return true;
            }
        }
        
        return false
    }
    
    func verifyString(string: String) -> Bool {
        for char in string {
            if !isValidChar(char: char) {
                return false;
            }
        }
        
        return true;
    }
    
    @IBAction func btnStartClick(_ sender: Any) {
        var tag: Tag?
        
        view.endEditing(true)
        if let data = txtData.text {
            if verifyString(string: data) == false {
                _mainVC?.appendText(text: "Extraneous characters in data string, only 0-9, A-F accepted!", color: .red)
                return
            }
            
            if data.count == 0 {
                _mainVC?.appendText(text: "Empty data string!", color: .red)
                return
            }
            
            if data.count % 2 != 0 {
                _mainVC?.appendText(text: "Supplied data must be a string of hex values. Length must be even!", color: .red)
                return
            }
            
            tag = _mainVC?.getSelectedTag()
            if let address = Int(txtAddress.text!) {
                if let tag = (tag as? ISO15693_tag) {
                    if (data.count / 2) % 4 == 0 {
                        tag.setTimeout(timeout: 2000)
                        _mainVC?.enableStartButton(enabled: false)
                        tag.write(address: address, data: hexStringToData(string: data))
                        _mainVC?.appendText(text: String(format: "Writing %d blocks at address %d to tag %@", data.count / 8, address, tag.toString()), color: .yellow)
                    } else {
                        _mainVC?.appendText(text: String(format: "Error, data length must be multiple of four bytes", data.count / 8, address), color: .red)
                    }
                } else if let tag = (tag as? ISO14443A_tag) {
                    _mainVC?.appendText(text: "Tag id: " + tag.toString(), color: UIColor.white)
                } else if let tag = (tag as? EPC_tag) {
                    if (data.count / 2) % 2 == 0 {
                        _mainVC?.enableStartButton(enabled: false)
                        tag.write(address: address, data: hexStringToData(string: data), password: nil)
                        _mainVC?.appendText(text: String(format: "Writing %d blocks at address %d to tag %@", data.count / 4, address, tag.toString()), color: .yellow)
                    } else {
                        _mainVC?.appendText(text: String(format: "Error, data length must be multiple of two bytes", data.count / 4, address), color: .red)
                    }
                }
            } else {
                _mainVC?.appendText(text: "Wrong address specified", color: .red)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
