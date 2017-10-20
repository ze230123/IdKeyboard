//
//  IdKeyboard.swift
//  IdKeyboard
//
//  Created by 泽i on 2017/10/20.
//  Copyright © 2017年 泽i. All rights reserved.
//

import UIKit

fileprivate let screenWidth = UIScreen.main.bounds.width
fileprivate let screenHeight = UIScreen.main.bounds.height

fileprivate struct ScreenType {
    static let iphone5: CGFloat = 568
    static let iphone6: CGFloat = 667
    static let iphone6p: CGFloat = 736
    static let iphoneX: CGFloat = 812
}

/// 按钮数据
struct IdKeyEntry {
    var text: String
    var image: String
    var action: KeyAction
    init(dict: [String: String]) {
        text = dict["text"] ?? ""
        image = dict["image"] ?? ""
        action = KeyAction(rawValue: dict["type"] ?? "") ?? KeyAction.none
    }
}

/// 键盘按钮
class IdKeyView: UIButton {
    var idKeyEntry: IdKeyEntry?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 按钮功能
enum KeyAction: String {
    case none
    case num = "num"
    case cancel = "cancel"
    case delete = "delete"
    case done = "done"
}

/// 身份证键盘
class IdKeyboardController: UIInputViewController {
    private let keyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 1
        return stackView
    }()

    private lazy var keys: [[[String: String]]] = {
        guard let chatsURL = Bundle.main.url(forResource: "IdKeys", withExtension: "plist"),
            let rawConversations = NSArray(contentsOf: chatsURL) as? [[[String: String]]]
            else {
                return []
        }
        return rawConversations
    }()

    private var keyboardHeight: CGFloat {
        switch screenHeight {
        case ScreenType.iphone6:
            return 258
        case ScreenType.iphone6p, ScreenType.iphoneX:
            return 271
        default:
            return 224
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        inputView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: keyboardHeight)
        inputView?.addSubview(keyStackView)
        
        let stacks = keys.map(ceartStackView)
        stacks.forEach { keyStackView.addArrangedSubview($0) }
        
        let guide = inputView!.layoutMarginsGuide
        keyStackView.translatesAutoresizingMaskIntoConstraints = false
        keyStackView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: -16).isActive = true
        keyStackView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        keyStackView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 16).isActive = true
        keyStackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
    }

    // MARK: - 按钮点击
    @objc private func didTap(sender: IdKeyView) {
        guard let entry = sender.idKeyEntry else {
            return
        }
        switch entry.action {
        case .num:
            textDocumentProxy.insertText(entry.text)
        case .delete:
            textDocumentProxy.deleteBackward()
        case .cancel, .done:
            dismissKeyboard()
        case .none:
            break
        }
    }

    /// 创建竖排 stackView
    private func ceartStackView(keys: [[String: String]]) -> UIStackView {
        let stackView = VericalStackView

        let keysBtn = keys.map { IdKeyEntry(dict: $0) }
        let keyViews = keysBtn.map(ceartIdkeyView)
        keyViews.forEach { stackView.addArrangedSubview($0) }
        return stackView
    }

    /// 竖排 stackView
    private var VericalStackView: UIStackView {
        let view = UIStackView()
        view.distribution = .fillEqually
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 1
        return view
    }

    /// 创建按键
    private func ceartIdkeyView(idkeyEntry: IdKeyEntry) -> IdKeyView {
        let keyButton = IdKeyView(type: .custom)
        keyButton.idKeyEntry = idkeyEntry

        let image = fileImage(named: idkeyEntry.image)

        var backgroundColor: UIColor
        var titleColor: UIColor
        var font: UIFont

        if case .done = idkeyEntry.action {
            backgroundColor = UIColor(r: 28, g: 171, b: 235)
            titleColor = UIColor.white
            font = UIFont.systemFont(ofSize: 17)
        } else {
            backgroundColor = UIColor.white
            titleColor = UIColor.black
            font = UIFont.systemFont(ofSize: 25)
        }

        keyButton.backgroundColor = backgroundColor
        keyButton.titleLabel?.font = font
        keyButton.setTitleColor(titleColor, for: .normal)
        keyButton.setImage(image, for: .normal)
        keyButton.setTitle(idkeyEntry.text, for: .normal)
        keyButton.setBackgroundImage(UIImage.image(with: .lightGray), for: .highlighted)
        keyButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        return keyButton
    }

    private func fileImage(named: String) -> UIImage? {
        guard !named.isEmpty else {
            return nil
        }
        var image: UIImage?
        image = UIImage(named: named)
        return image
    }
}
// MARK: - 创建纯色图片
extension UIImage {
    public class func image(with color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContext(size)
        color.set()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIColor {
    /// 自定义
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
    }
}
