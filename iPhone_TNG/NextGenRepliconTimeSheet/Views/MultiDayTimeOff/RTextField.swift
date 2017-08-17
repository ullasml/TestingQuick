//
//  RTextField.swift
//  TableView
//
//  Created by Prithiviraj Jayapal on 28/04/17.
//  Copyright © 2017 replicon. All rights reserved.
//

import UIKit

//@IBDesignable
class RTextField: UITextField {
    
    var indexPath = IndexPath(row: 0, section: 0)
    
    @IBInspectable var inset: CGFloat = 0
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
//    @IBInspectable var cornerRadius: CGFloat = 4 {
//        didSet {
//            layer.cornerRadius = cornerRadius
//        }
//    }
    
    
    //Text Padding
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    //Hide copy & paste options
//    override func caretRect(for position: UITextPosition) -> CGRect {
//        return CGRect.zero
//    }
    
    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if action == #selector(cut(_:)) || action == #selector(copy(_:)) || action == #selector(selectAll(_:)) || action == #selector(paste(_:)) || action == #selector(select(_:)) || action == #selector(replace(_:withText:))  {
            
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }

}
