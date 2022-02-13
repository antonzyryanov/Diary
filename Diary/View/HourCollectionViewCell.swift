//
//  HourCollectionViewCell.swift
//  Diary
//
//  Created by Anton Zyryanov on 09.02.2022.
//

import UIKit
import SnapKit

class HourCollectionViewCell: UICollectionViewCell {
    var label: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        setupCell()
        isSelected = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupCell() {
        setupLabel()
    }
    private func setupLabel() {
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        addSubview(label)
        label.snp.makeConstraints { make in
            make.width.equalTo(self.frame.width/2)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(self.frame.width/2)
        }
    }
}
