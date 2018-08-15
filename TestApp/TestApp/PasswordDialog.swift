//
//  PasswordDialog.swift
//  RfidPassiveApiTestappIosSwift
//
//  Created by Stefano Crosara on 15/08/18.
//  Copyright © 2018 Stefano Crosara. All rights reserved.
//

import UIKit

class PasswordDialog: UIView {
    var backgroundView = UIView()
    var dialogView = UIView()
    
    convenience init(title: String, showOldPasswordBox: Bool) {
        self.init(frame: UIScreen.main.bounds)
        initialize(title: title, showOldPasswordBox: showOldPasswordBox)
    }
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    func initialize(title: String, showOldPasswordBox: Bool) {
        var textFieldView1: UITextField
        var textFieldView2: UITextField
        dialogView.clipsToBounds = true
        
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.6
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnBackgroundView)))
        addSubview(backgroundView)
        
        let dialogViewWidth = frame.width-64
        
        let titleLabel = UILabel(frame: CGRect(x: 8, y: 8, width: dialogViewWidth-16, height: 30))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        dialogView.addSubview(titleLabel)
        
        let separatorLineView = UIView()
        separatorLineView.frame.origin = CGPoint(x: 0, y: titleLabel.frame.height + 8)
        separatorLineView.frame.size = CGSize(width: dialogViewWidth, height: 1)
        separatorLineView.backgroundColor = UIColor.groupTableViewBackground
        dialogView.addSubview(separatorLineView)
        
        textFieldView1 = UITextField(frame: CGRect(x: 8, y: 40, width: dialogViewWidth-16, height: 20))
        dialogView.addSubview(textFieldView1)
        
        if showOldPasswordBox {
            textFieldView2 = UITextField(frame: CGRect(x: 8, y: 60, width: dialogViewWidth-16, height: 20))
            dialogView.addSubview(textFieldView2)
        }
        
        var dialogViewHeight = titleLabel.frame.height + 8 + separatorLineView.frame.height + 8 + textFieldView1.frame.height + 8
        if showOldPasswordBox {
            textFieldView2 = UITextField(frame: CGRect(x: 8, y: 80, width: dialogViewWidth-16, height: 20))
            dialogViewHeight += textFieldView2.frame.height + 8
        }
        dialogView.addSubview(separatorLineView)
        
        dialogView.frame.origin = CGPoint(x: 32, y: frame.height)
        dialogView.frame.size = CGSize(width: frame.width-64, height: dialogViewHeight)
        dialogView.backgroundColor = UIColor.white
        dialogView.layer.cornerRadius = 6
        addSubview(dialogView)
    }
    
    @objc func didTapOnBackgroundView() {
        self.removeFromSuperview()
    }
}
