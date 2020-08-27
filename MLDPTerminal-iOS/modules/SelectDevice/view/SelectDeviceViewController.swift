//
// Created by 横路海斗 on 2020/08/27.
// Copyright (c) 2020 yokoro. All rights reserved.
//

import UIKit
import CoreBluetooth

class SelectDeviceViewController: UIViewController{
    @IBOutlet weak var tableview: UITableView!

    var presenter: SelectDevicePresentation!
    var discoveredDevices: [BleDevice] = [] {
        didSet {
            tableview.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        // デバイス配列をクリアし元の画面に戻る
        discoveredDevices = []
        self.dismiss(animated: true, completion: nil)
    }
}

extension SelectDeviceViewController: SelectDeviceView {
    func showDevices(_ devices: [BleDevice]) {
        self.discoveredDevices = devices
    }
}

extension SelectDeviceViewController: UITableViewDelegate, UITableViewDataSource{
    /* Bluetooth以外関連メソッド */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableview.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)

        cell.textLabel!.text = discoveredDevices[indexPath.row].name
        return cell
    }

    // デバイスが選択されたとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectDevice(discoveredDevices[indexPath.section])
        discoveredDevices = []
    }
}

