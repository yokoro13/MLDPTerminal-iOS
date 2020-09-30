//
//  TerminalViewController.swift
//  MLDPTerminal-iOS
//
//  Created by 横路海斗 on 2020/08/25.
//  Copyright © 2020 yokoro. All rights reserved.
//

import UIKit

class TerminalViewController: UIViewController {
    // オブジェクト
    @IBOutlet weak var textview: CustomTextView!
    @IBOutlet weak var menu: UIButton!
    @IBOutlet weak var menuBackView: UIView!
    @IBOutlet weak var connectDevice: UILabel!
    @IBOutlet weak var policy: UIButton!

    var presenter: TerminalPresentation!

    let notification = NotificationCenter.default    // 通知変数
    var receiveTimer = Timer()    // 受信タイマー
    let policyLink = "https://tctsigemura.github.io/MLDPTerminal/privacy.html"    // プライバシーポリシーURL

    var prevScroll = CGPoint(x: 0, y: 0)    // 画面スクロール制御変数

    let keyboard = UIStackView(frame: CGRect(x: 0, y: 0, width: 320, height: 40))   // ボタン追加view
    // ボタン追加Viewの背景View
    let buttonBackView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
    // 追加するボタン一覧
    let escButton = UIButton(frame: CGRect())
    let ctrlButton = UIButton(frame: CGRect())
    let tabButton = UIButton(frame: CGRect())
    let upButton = UIButton(frame: CGRect())
    let downButton = UIButton(frame: CGRect())
    let leftButton = UIButton(frame: CGRect())
    let rightButton = UIButton(frame: CGRect())
    let keyDownButton = UIButton(frame: CGRect())

    // viewが読み込まれたときのイベント
    override func viewDidLoad() {
        print("--- viewDidLoad ---")
        super.viewDidLoad()

        // 画面スクロール用のイベントを登録する
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(sender:)))
        self.view.addGestureRecognizer(pan)
        textview.isScrollEnabled = false        // textviewのスクロール機能を停止
        hideMenu(0.0)                            // メニューを隠す

        textview.layer.borderColor = UIColor.lightGray.cgColor  // textviewに枠線をつける
        textview.layer.borderWidth = 1
        textview.font = UIFont.systemFont(ofSize: 12.00)        // textviewのフォントサイズを設定する
        textview.delegate = self                                // textviewのデリゲートをセット
        setSize()                                               // 画面サイズを設定する
        setupTextView()
    }

    // viewを表示する前のイベント
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setSize()           // 画面サイズを再設定する
        configureObserver() // Notificationを設定する
    }

    // viewが消える前のイベント
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        removeObserver()        // Notificationを削除する
    }

    // textviewをクリアする関数
    func setupTextView() {
        connectDevice.text = "Connection : "        // デバイスラベルを初期化する
        setupView()        // 追加キーボードボタンを初期化する
        moveCursor(cursor(x: 0, y: 0))
    }

    // 追加キーボードボタンを初期化する関数
    func setupView() {
        print("--- textKeyInit ---")
        // ボタンを追加するViewの設定
        keyboard.axis = .horizontal
        keyboard.alignment = .center
        keyboard.distribution = .fillEqually
        keyboard.spacing = 3
        keyboard.sizeToFit()

        // ボタン追加Viewの背景用Viewの設定
        buttonBackView.backgroundColor = UIColor.gray
        buttonBackView.sizeToFit()

        setButtonOption(button: escButton, title: "esc", action: #selector(escTapped))
        setButtonOption(button: ctrlButton, title: "Ctrl", action: #selector(ctrlTapped))
        setButtonOption(button: tabButton, title: "tab", action: #selector(tabTapped))
        setButtonOption(button: upButton, title: "↑", action: #selector(upTapped))
        setButtonOption(button: downButton, title: "↓", action: #selector(downTapped))
        setButtonOption(button: leftButton, title: "←", action: #selector(leftTapped))
        setButtonOption(button: rightButton, title: "→", action: #selector(rightTapped))

        // ボタンをViewに追加する
        keyboard.addArrangedSubview(escButton)
        keyboard.addArrangedSubview(ctrlButton)
        keyboard.addArrangedSubview(tabButton)
        keyboard.addArrangedSubview(upButton)
        keyboard.addArrangedSubview(downButton)
        keyboard.addArrangedSubview(leftButton)
        keyboard.addArrangedSubview(rightButton)

        // ボタンViewに背景をつける
        buttonBackView.addSubview(keyboard)

        // textViewと紐付ける
        textview.inputAccessoryView = buttonBackView
    }

    func setButtonOption(button: UIButton, title: String, action: Selector){
        button.backgroundColor = UIColor.lightGray
        button.setTitle(title, for: UIControl.State.normal)
        button.addTarget(self, action: action, for: UIControl.Event.touchUpInside)
    }

    // タッチ開始時のイベント
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // キーボードを閉じる
    }

    // 画面をスクロールさせる関数
    @objc func pan(sender: UIPanGestureRecognizer) {
        // 移動後の相対位置を取得する
        let location = sender.translation(in: self.view)
        if prevScroll.y - location.y > 2 {      // 画面を上にスワイプしたとき
            presenter.didScrollUp()
        } else if location.y - prevScroll.y > 2 { // 画面を下にスワイプしたとき
            presenter.didScrollDown()
        }
        prevScroll = location   // 位置を変更する
    }

    // textViewの入力値を取得し、カーソル位置に追記する関数
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var input = text
        if input == "" {
            input = "\u{08}"    // iPhoneのdelキーのときBS(後退)に変換する
        }
        if !input.isAscii() {   // ASCIIコード外のとき
            return false
        }
        presenter.didInputText(input)   // ペリフェラルにデータを書き込む
        return false
    }

    // Notificationを設定する関数
    func configureObserver() {
        // キーボード出現の検知
        notification.addObserver(
                self,
                selector: #selector(keyboardWillShow(notification:)),
                name: UIResponder.keyboardWillShowNotification,
                object: nil
        )
        // キーボード終了の検知
        notification.addObserver(
                self,
                selector: #selector(keyboardWillHide(notification:)),
                name: UIResponder.keyboardWillHideNotification,
                object: nil
        )
        // 画面回転の検知
        notification.addObserver(
                self,
                selector: #selector(onOrientationChange(notification:)),
                name: UIDevice.orientationDidChangeNotification,
                object: nil
        )
    }

    // Notificationを削除する関数
    func removeObserver() {
        notification.removeObserver(self)
    }

    // キーボードが現れるときに画面をずらす関数
    @objc func keyboardWillShow(notification: Notification?) {
        presenter.didShowKeyboard()
    }

    // キーボードが消えるときに画面を戻す関数
    @objc func keyboardWillHide(notification: Notification?) {
        presenter.didHideKeyboard()
    }

    // 画面が回転したときに呼ばれる関数
    @objc func onOrientationChange(notification: Notification?) {
        presenter.didOrientationChange()
    }

    // メニューが押されたとき
    @IBAction func menuTap(_ sender: UIButton) {
        presenter.didTapMenu()
    }

    // scanButtonが押されたとき
    @IBAction func scanTap(_ sender: UIButton) {
        presenter.didTapButton(.scan)
    }

    // disconButtonが押されたとき
    @IBAction func disconTap(_ sender: UIButton) {
        presenter.didTapButton(.disconnect)
    }

    // プライバシーポリシー表示ボタンが押されたとき
    @IBAction func policyTap(_ sender: UIButton) {
        // リンク先にページが存在するとき
        if let url = URL(string: policyLink) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    // 画面サイズを設定する関数
    func setSize() {
        // 最大行数
        let row = Int(floor((textview.frame.height - textview.layoutMargins.top - textview.layoutMargins.bottom) / " ".getStringHeight(textview.font!)))
        // 最大桁数
        let column = Int(floor((textview.frame.width - textview.layoutMargins.left - textview.layoutMargins.right) / " ".getStringWidth(textview.font!)))
        presenter.didChangeScreenSize(screenColumnSize: column, screenRowSize: row)
    }

    func tapButton(_ type: ButtonContentType){
        switch type {
        case .esc:
            buttonColorChange(button: escButton)
            break
        case .ctrl:
            if ctrlButton.backgroundColor == UIColor.white {
                ctrlButton.backgroundColor = UIColor.lightGray
                ctrlButton.setTitleColor(UIColor.white, for: .normal)
            } else {
                ctrlButton.backgroundColor = UIColor.white
                ctrlButton.setTitleColor(UIColor.lightGray, for: .normal)
            }
            break
        case .tab:
            buttonColorChange(button: tabButton)
            break
        case .up:
            buttonColorChange(button: upButton)
            break
        case .down:
            buttonColorChange(button: downButton)
            break
        case .right:
            buttonColorChange(button: rightButton)
            break
        case .left:
            buttonColorChange(button: leftButton)
            break
        default:
            return
        }
        presenter.didTapButton(type)
    }

    @objc func escTapped() {
        tapButton(.esc)
    }

    @objc func ctrlTapped() {
        tapButton(.ctrl)
    }

    @objc func tabTapped() {
        tapButton(.tab)
    }

    @objc func upTapped() {
        tapButton(.up)
    }

    @objc func downTapped() {
        tapButton(.down)
    }

    @objc func leftTapped() {
        tapButton(.left)
    }

    @objc func rightTapped() {
        tapButton(.right)
    }

    // キーボード追加ボタンの背景色を変更する関数
    func buttonColorChange(button: UIButton) {
        button.backgroundColor = UIColor.white
        UIView.animate(withDuration: TimeInterval(0.3)) {
            button.backgroundColor = UIColor.lightGray
        }
    }
}

extension TerminalViewController: TerminalView{
    func moveCursor(_ c: cursor) {
        /** TODO カーソルの表示処理を切り分ける
             1．textViewの右上座標を取得
                右端：r = view.frame.origin.x
                上端：u = view.frame.origin.y
             2．四角形を表示
                rectangle = UIBezierPath
                    (
                         rect: CGRect(
                             x: r+text.width*c.x,
                             y: u+text.height*c.y,
                             width: text.width,
                             height: text.height
                             )
                     )
                 // 内側の色
                 UIColor.gray.setFill()
                 // 内側を塗りつぶす
                 rectangle.fill()
        **/
    }

    func updateScreen(_ text: NSMutableAttributedString) {
        textview.attributedText = text
        textview.font = UIFont(name: "CourierNewPSMT", size: textview.font!.pointSize)
    }

    func hideMenu(_ duration: Float=0.7) {
        <#code#>
    }

    func showMenu(_ duration: Float=0.7) {
        print("--- showMenu ---")
        // デバイスラベルを移動させる
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.connectDevice.frame.origin.x = -self.connectDevice.frame.size.width
        }
        // メニューを移動させる
        UIView.animate(withDuration: TimeInterval(duration), delay: TimeInterval(duration / 2), options: [], animations: {
            self.menuBackView.center.x = self.view.center.x - self.menu.bounds.size.width
        })
        // メニューを表示する
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.menuBackView.alpha = 1.0
            self.connectDevice.alpha = 0.0
        }
    }
}

extension TerminalViewController: UITextViewDelegate{

}

