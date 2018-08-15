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

class ExtendedTagTestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AbstractReaderListenerProtocol, AbstractResponseListenerProtocol, AbstractInventoryListenerProtocol {
    @IBOutlet weak var cntRead: UIView!
    @IBOutlet weak var cntWrite: UIView!
    @IBOutlet weak var tblTags: UITableView!
    @IBOutlet weak var segTests: UISegmentedControl!
    @IBOutlet weak var txtResult: UITextView!
    @IBOutlet weak var lblHeader: UILabel!
    weak var deviceDetailVC: DeviceDetailViewController?
    weak var extendedTagTestsReadVC: ExtendedTagTestsReadViewController?
    weak var extendedTagTestsWriteVC: ExtendedTagTestsWriteViewController?
    weak var btnStartOperation: UIButton?
    weak var btnStartOperationRead: UIButton?
    weak var btnStartOperationWrite: UIButton?
    
    var _tags: [Tag?]? = nil
    var deviceName: String?
    private let _api = PassiveReader.getInstance()
    private let _eventsForwarder = EventsForwarder.getInstance()
    private var _resultsBuffer = NSMutableAttributedString()
    private var _selectedRow: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        txtResult.layer.borderColor = UIColor.blue.cgColor
        txtResult.layer.borderWidth = 3.0
        lblHeader.text = deviceName!
        
        //
        _eventsForwarder.readerListenerDelegate = self
        _eventsForwarder.inventoryListenerDelegate = self
        _eventsForwarder.responseListenerDelegate = self
        
        tblTags.reloadData()
        tblTags.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
    }
  
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    @IBAction func segChange(_ sender: Any) {
        view.endEditing(true)
        if segTests.selectedSegmentIndex == 0 {
            btnStartOperation = btnStartOperationRead
            cntRead.isHidden = false
            cntWrite.isHidden = true
        } else if segTests.selectedSegmentIndex == 1 {
            btnStartOperation = btnStartOperationWrite
            cntRead.isHidden = true
            cntWrite.isHidden = false
        }
    }
    
    func getSelectedTag() -> Tag? {
        return _tags![_selectedRow];
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _tags!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ExtendedTagTestsTagCell = tableView.dequeueReusableCell(withIdentifier: "ExtendedTagTestsTagCell") as! ExtendedTagTestsTagCell
        cell.lblTagID.text = _tags?[indexPath.row]?.toString()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _selectedRow = indexPath.row
    }
    
    //
    func scrollDown(textView: UITextView) {
        let range = NSRange(location: textView.text.count - 1, length: 0)
        textView.scrollRangeToVisible(range)
    }
    
    func appendText(text: String, color: UIColor) {
        _resultsBuffer.append(NSAttributedString(string: text + "\r\n", attributes: [NSAttributedStringKey.foregroundColor: color]))
        txtResult.attributedText = _resultsBuffer.copy() as! NSAttributedString
        scrollDown(textView: txtResult)
    }
    
    func appendText(text: String, error: Int) {
        appendText(text: text , color: (error == 0 ? .white : .red))
    }
    
    func enableStartButton(enabled: Bool) {
        btnStartOperation?.isEnabled = enabled
        if !enabled {
            btnStartOperation?.setTitleColor(.black, for: .normal)
            btnStartOperation?.setTitleColor(.black, for: .selected)
        } else {
            btnStartOperation?.setTitleColor(.white, for: .normal)
            btnStartOperation?.setTitleColor(.gray, for: .selected)
        }
    }
    
    // AbstractResponseListenerProtocol implementation
    func writeIDevent(tagID: [UInt8]?, error: Int) {
        enableStartButton(enabled: true)
    }
    
    func writePasswordEvent(tagID: [UInt8]?, error: Int) {
        enableStartButton(enabled: true)
    }
    
    func readTIDevent(tagID: [UInt8]?, error: Int, TID: [UInt8]?) {
        enableStartButton(enabled: true)
    }
    
    func readEvent(tagID: [UInt8]?, error: Int, data: [UInt8]?) {
        enableStartButton(enabled: true)
        appendText(text: "readEvent tag: " + PassiveReader.bytesToString(bytes: tagID) + ", error: " + String(error) + ", Data: " + PassiveReader.bytesToString(bytes: data), error: error)
    }
    
    func writeEvent(tagID: [UInt8]?, error: Int) {
        enableStartButton(enabled: true)
        appendText(text: "writeEvent tag: " + PassiveReader.bytesToString(bytes: tagID) + ", error: " + String(error), error: error)
    }
    
    func lockEvent(tagID: [UInt8]?, error: Int) {
        enableStartButton(enabled: true)
    }
    
    func killEvent(tagID: [UInt8]?, error: Int) {
        enableStartButton(enabled: true)
    }
    
    // AbstractInventoryListenerProtocol implementation
    func inventoryEvent(tag: Tag) {
        enableStartButton(enabled: true)
    }
    
    // AbstractReaderListenerProtocol implementation
    func connectionFailureEvent(error: Int) {
        deviceDetailVC?.connectionFailureEvent(error: error)
        performSegue(withIdentifier: "ExtendedTagTestsUnwindSegue", sender: self)
    }
    
    func connectionSuccessEvent() {
        
    }
    
    func disconnectionEvent() {
        deviceDetailVC?.disconnectionEvent()
        performSegue(withIdentifier: "ExtendedTagTestsUnwindSegue", sender: self)
    }
    
    func availabilityEvent(available: Bool) {
        
    }
    
    func resultEvent(command: Int, error: Int) {
        enableStartButton(enabled: true)
        let errStr = (error == 0 ? "NO error": String(format: "Error %d", error))
        let result = String(format: "Result command = %d %@", command, errStr)
        appendText(text: result, error: error)
    }
    
    func batteryStatusEvent(status: Int) {
        
    }
    
    func firmwareVersionEvent(major: Int, minor: Int) {
        
    }
    
    func shutdownTimeEvent(time: Int) {
        
    }
    
    func RFpowerEvent(level: Int, mode: Int) {
        
    }
    
    func batteryLevelEvent(level: Float) {
        
    }
    
    func RFforISO15693tunnelEvent(delay: Int, timeout: Int) {
        
    }
    
    func ISO15693optionBitsEvent(option_bits: Int) {
        
    }
    
    func ISO15693extensionFlagEvent(flag: Bool, permanent: Bool) {
        
    }
    
    func ISO15693bitrateEvent(bitrate: Int, permanent: Bool) {
        
    }
    
    func EPCfrequencyEvent(frequency: Int) {
        
    }
    
    func tunnelEvent(data: [UInt8]?) {
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let childVC = segue.destination as? ExtendedTagTestsReadViewController {
            childVC._mainVC = self
            extendedTagTestsReadVC = childVC
        } else if let childVC = segue.destination as? ExtendedTagTestsWriteViewController {
            childVC._mainVC = self
            extendedTagTestsWriteVC = childVC
        }
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }
    
    @IBAction func unwindToExtendedTagTestsViewController(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }
}
