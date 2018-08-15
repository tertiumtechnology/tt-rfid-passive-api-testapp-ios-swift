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

class ExtendedTagTestsReadViewController: UIViewController {
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtBlocks: UITextField!
    @IBOutlet weak var btnStartOperation: UIButton!
    @IBOutlet weak var txtPassword: UITextField!
    
    var _mainVC: ExtendedTagTestsViewController?
    private let _api = PassiveReader.getInstance()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        _mainVC?.btnStartOperation = btnStartOperation
        _mainVC?.btnStartOperationRead = btnStartOperation
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnStartClick(_ sender: Any) {
        var tag: Tag?
        
        view.endEditing(true)
        tag = _mainVC?.getSelectedTag()
        if let address = Int(txtAddress.text!) {
            if let blocks = Int(txtBlocks.text!) {
                if let tag = (tag as? ISO15693_tag) {
                    _mainVC?.enableStartButton(enabled: false)
                    tag.setTimeout(timeout: 2000)
                    _mainVC?.appendText(text: String(format: "Reading %d blocks at address %d from tag %@", blocks, address, tag.toString()), color: .yellow)
                    tag.read(address: address, blocks: blocks)
                } else if let tag = (tag as? ISO14443A_tag) {
                    _mainVC?.appendText(text: "Tag id: " + tag.toString(), color: UIColor.white)
                } else if let tag = (tag as? EPC_tag) {
                    _mainVC?.enableStartButton(enabled: false)
                    _mainVC?.appendText(text: String(format: "Reading %d blocks at address %d from tag %@", blocks, address, tag.toString()), color: .yellow)
                    tag.read(address: address, blocks: blocks, password: nil)
                }
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
