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

class ScanViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AbstractScanListenerProtocol {
    @IBOutlet weak var devicesTableView: UITableView!
    var btnScan: UIButton?
    private var defaultColor: UIColor? = nil
    private let _scanner = Scanner.getInstance()
    private var _scannedDevices = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        _scanner.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1;
        } else {
            return _scannedDevices.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell: BleTableViewHeaderCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! BleTableViewHeaderCell
            btnScan = cell.scanButton
            defaultColor = cell.backgroundColor!
            return cell
        } else {
            let cell: BleTableViewDeviceCell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell") as! BleTableViewDeviceCell
            var deviceName: String
            
            deviceName = _scannedDevices[indexPath.row]
            cell.deviceLabel.text = deviceName
            return cell
        }
    }
    
    @IBAction func btnScanPressed(_ sender: Any) {
        if _scanner.isScanning() == false {
            _scannedDevices.removeAll()
            _scanner.startScan()
        } else {
            _scanner.stopScan()
        }
    }
    
    // AbstractScanListenerProtocol implementation
    func deviceFoundEvent(deviceName: String) {
        _scannedDevices.append(deviceName)
        devicesTableView.reloadData()
    }
    
    func deviceScanErrorEvent(error: Int) {
        let alertView = UIAlertView(title: "Device scan error", message: "error", delegate: nil, cancelButtonTitle: "OK")
        alertView.show()
    }
    
    func deviceScanBeganEvent() {
        btnScan?.setTitle("STOP", for: .normal)
        devicesTableView.reloadData()
    }
    
    func deviceScanEndedEvent() {
        btnScan?.setTitle("SCAN", for: .normal)
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailView" {
            if let detail = segue.destination as? DeviceDetailViewController {
                if let row = devicesTableView.indexPathForSelectedRow?.row {
                    detail.deviceName = _scannedDevices[row];
                    if _scanner.isScanning() {
                        _scanner.stopScan()
                    }
                }
            }
        }
    }
    
    @IBAction func unwindToScanController(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
    }
}
